# --------------------- #
# NOAA/ NMFS/ NEFSC AMAPPS boat 2017
# Date Created: 12/2017
# Author: K. Coleman
# --------------------- #


# --------------------- #
# load packages
# --------------------- #
require(rgdal)
require(lubridate)
require(RODBC)
require(ggplot2)
require(zoo)
require(dplyr)
library(readxl)
library(odbc)
library(ggmap)
library(maps)
library(mapdata)
# --------------------- #


# --------------------- #
# get data
# --------------------- #
obs <- read_excel("Z:/seabird_database/datasets_received/NOAA NMFS/NEFSC_AMAPPS_ship_2017/HRS1701SeabirdSightExport.xlsx")
track <- read_excel("Z:/seabird_database/datasets_received/NOAA NMFS/NEFSC_AMAPPS_ship_2017/HRS1701SeabirdEffortExport.xlsx")

usa <- map_data("usa")
# --------------------- #


# --------------------- #
# fix errors
# --------------------- #

# ------- #
# fix species
# ------- #
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
         time = paste(date, 
                      substring(sapply(strsplit(DATETIMELOCAL," "),tail,2)[1],1,8), 
                      sapply(strsplit(DATETIMELOCAL," "),tail,1), sep=".")) %>% 
  dplyr::select(-DATETIMELOCAL,-ampm)
# ------- #

# ------- #
# add transects to obs
# ------- #
# join obs and transect
names(obs)=tolower(names(obs))
obs = obs %>% rename(type = species)
names(track)=tolower(names(track))
track$type = "WAYPNT"

obstrack = bind.rows(obs,track) %>% mutate(transect = na.locf(transect))
# ------- #

# plots
ggplot(data =usa) + geom_polygon(aes(x = long, y = lat, group = group), fill = "#669933", color = "#333300") + 
  coord_fixed(1.3) + #coord_fixed(xlim = c(-82, -65),  ylim = c(25, 47), ratio = 1.3) + 
  coord_fixed(xlim = c(-75, -67),  ylim = c(38, 42), ratio = 1.3) + 
  geom_point(data = obs, aes(x = LON, y = LAT)) + theme_bw()
