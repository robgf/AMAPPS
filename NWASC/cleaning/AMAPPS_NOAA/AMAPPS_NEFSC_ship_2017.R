# --------------------- #
# NOAA/ NMFS/ NEFSC AMAPPS boat 2017
# Date Created: 12/2017
# Author: K. Coleman
# --------------------- #


# --------------------- #
# load packages
# --------------------- #
library(odbc) # dbConnect
require(zoo) # na.locf
require(dplyr) # %>%
library(readxl) # read_excel
require(ggplot2) # ggplot
library(maps)
# --------------------- #


# --------------------- #
# get data
# --------------------- #
obs <- read_excel("Z:/seabird_database/datasets_received/NOAA NMFS/NEFSC_AMAPPS_ship_2017/HRS1701SeabirdSightExport.xlsx")
track <- read_excel("Z:/seabird_database/datasets_received/NOAA NMFS/NEFSC_AMAPPS_ship_2017/HRS1701SeabirdEffortExport.xlsx")
# --------------------- #


# --------------------- #
# fix errors
# --------------------- #

# ------- #
# fix species
# ------- #
obs$original_species_tx = paste(obs$SPECIES,obs$COMNAME,sep="_")
  
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
spplist = dbGetQuery(db,"select * from lu_species")

tmp <- !obs$SPECIES %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$SPECIES[tmp]))

obs$SPECIES[obs$SPECIES %in% "AGPL"] = "AMGP" 
obs$SPECIES[obs$SPECIES %in% "AMRS"] = "AMRE" # American Redstart,
obs$SPECIES[obs$SPECIES %in% "CEWA"] = "CEDW" # Cedar Waxwing
#obs$SPECIES[obs$SPECIES %in% "GCFC"] = "" # added Great Crested Flycatcher, Myiarchus crinitus

obs$SPECIES[obs$SPECIES %in% "PLOV" & obs$COMMENTS %in% c("likely semipalmated plover")] = "SEPL" 
obs$SPECIES[obs$SPECIES %in% "PLOV" & obs$COMMENTS %in% c("possibly PIPL")] = "PIPL" 
obs$SPECIES[obs$SPECIES %in% "PLOV"] = "CHAR" 
obs$SPECIES[obs$SPECIES %in% "DUCK"] = "UNDU" 
obs$SPECIES[obs$SPECIES %in% "PASS" & obs$COMMENTS %in% c("unid warbler","warbler sp.")] = "UNWA" 
obs$SPECIES[obs$SPECIES %in% "PASS" & obs$COMMENTS %in% c("likely brown-headed cowbird")] = "BHCO" 
obs$SPECIES[obs$SPECIES %in% "PASS"] = "UNPA" 

rm(spplist)
# ------- #

# ------- #
# fix time
# ------- #
# split time and 
obs = mutate(obs, 
             date = as.Date(sapply(strsplit(SIGHTDATETIMELOCAL," "),head,1),format="%d-%b-%y"), 
             time = sapply(strsplit(SIGHTDATETIMELOCAL," "),tail,1)) %>% 
  dplyr::select(-SIGHTDATETIMELOCAL)

track = track %>% rowwise %>% 
  mutate(date = as.Date(sapply(strsplit(DATETIMELOCAL," "),head,1), format="%d-%b-%y"),
         hour = substring(sapply(strsplit(DATETIMELOCAL," "),tail,2)[1],1,2),
           min = substring(sapply(strsplit(DATETIMELOCAL," "),tail,2)[1],4,5),
           sec = substring(sapply(strsplit(DATETIMELOCAL," "),tail,2)[1],7,8),
           p = sapply(strsplit(DATETIMELOCAL," "),tail,1),
         hour = replace(hour,p %in% "PM" & !hour %in% "12",as.numeric(hour)+12),
         time = paste(hour,min,sec,sep=":")) %>% 
  dplyr::select(-DATETIMELOCAL,-hour,-min,-sec,-p)
# ------- #

# ------- #
# add transects to obs
# ------- #
# join obs and transect
names(obs)=tolower(names(obs))
obs = obs %>% rename(type = species)
names(track)=tolower(names(track))
track = mutate(track,
               type = "WAYPNT",
               type = replace(type, eventdesc %in% "begin transect","BEGCNT"),
               type = replace(type, eventdesc %in% "end transect","ENDCNT"))

obstrack = bind_rows(obs,track) %>% 
  arrange(date,time) %>% 
  mutate(obs_id = seq(1:length(id)),
         effort = replace(effort,obs_id %in% 1:3,"off"))
obstrack$effort = na.locf(obstrack$effort)
obstrack$transect[obstrack$effort %in% "on"] = na.locf(obstrack$transect[obstrack$effort %in% "on"])
#obstrack$leg[obstrack$effort %in% "on"] = na.locf(obstrack$leg[obstrack$effort %in% "on"])
obstrack$effort[obstrack$type %in% c('BEGCNT','ENDCNT')] = "on"
obstrack$transect[obstrack$effort %in% "off"] = NA
#obstrack$leg[obstrack$effort %in% "off"] = NA
obstrack$offline = ifelse(obstrack$effort %in% "off",1,0)

# pull obstrack apart
rm(obs,track)
obs = obstrack[!obstrack$type %in% c("BEGCNT","ENDCNT","WAYPNT"),]
track = obstrack[obstrack$type %in% c("BEGCNT","ENDCNT","WAYPNT"),]
# ------- #


# ------- #
# add age id, associate, & behavior_id
# ------- #
obs = obs %>% rowwise %>% 
  mutate(age_id = ifelse(age %in% 'Adult',1,ifelse(age %in% 'Subadult',7,5)),
         behavior_id = behaviordesc,
         behavior_id = replace(behavior_id,behavior_id %in% c("directional flight","non-directional flight"),13),
         behavior_id = replace(behavior_id,behavior_id %in% c("feeding"),9),
         behavior_id = replace(behavior_id,behavior_id %in% c("following ship"),15),
         behavior_id = replace(behavior_id,behavior_id %in% c("milling"),21),
         behavior_id = replace(behavior_id,behavior_id %in% c("other"),23),
         behavior_id = replace(behavior_id,behavior_id %in% c("pattering"),42),
         behavior_id = replace(behavior_id,behavior_id %in% c("piracy"),24),
         behavior_id = replace(behavior_id,behavior_id %in% c("sitting"),35),
         association = assocdesc,
         association = replace(association,association %in% "associated with other individuals",type),
         association = replace(association,association %in% "solitary bird",NA),
         association = replace(association,is.na(association) & behavior_id %in% 15,"BOAT")) %>% 
  as.data.frame()
# ------- #


# ------- #
# transects
# ------- #
transects = obstrack %>% filter(type %in% c('BEGCNT','ENDCNT')) %>% 
  arrange(transect,date,time) %>% 
  group_by(transect,date) %>% 
  filter(row_number()==1 | row_number()==n()) %>% 
  dplyr::select(type,lat,lon,date,time,beaufort,windspeed,transect) %>%
  summarize(av_beaufort = mean(beaufort),
         av_windspeed = mean(windspeed),
         start_time = first(time),
         end_time=last(time),
         start_lon = first(lon),
         end_lon=last(lon),
         start_lat = first(lat),
         end_lat=last(lat))
rm(obstrack)
# ------- #


# ------- #
# plots
# ------- #
# usa <- map_data("usa")
#
# ggplot(data =usa) + geom_polygon(aes(x = long, y = lat, group = group), fill = "#669933", color = "#333300") + 
#   coord_fixed(1.3) + #coord_fixed(xlim = c(-82, -65),  ylim = c(25, 47), ratio = 1.3) + 
#   coord_fixed(xlim = c(-75, -67),  ylim = c(38, 42), ratio = 1.3) + 
#   geom_point(data = obs, aes(x = LON, y = LAT)) + theme_bw()
# ------- #

id = 411
