# --------------------- #
# Quality control EcoMon Sept. 2012 data
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# LOAD PACKAGES
# -------------------------------- #
require(RODBC) # odbcConnect
require(lubridate) #fix timestamps
require(zoo) #na.locf
require(dplyr) # %>% 
library(dtplyr) #data.table
library(stringr) #extract parts of a string
require(rgeos)
require(sp)
library(geosphere)
# -------------------------------- #


# -------------------------------- #
# DEFINE SURVEY
# -------------------------------- #
surveyFolder = "EcoMon_Feb13"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received/EcoMon"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
db = odbcConnectExcel2007(file.path(dir.in, "ecomon_feb_2013_edit_TPW.xls")) 
obs = sqlFetch(db, "ecomon_feb_2013_edit_TPW")
odbcClose(db)
#---------------------#


#---------------------#
# fix time
#---------------------#
obs = mutate(obs, date_time = as.POSIXct(paste(paste(YYYY,MM1,DD,sep="/")," ", paste(hh,mm,ss_s,sep=":")), 
                                   format="%Y/%m/%d %H:%M:%S")) %>% 
  select(-YYYY,-MM1,-DD,-hh,-mm,-ss_s) %>% mutate(date = sapply(strsplit(as.character(date_time), " "), head, 1), 
                                                  time = sapply(strsplit(as.character(date_time), " "), tail, 1))
#---------------------#


#---------------------#
# break apart obs and track
#---------------------#  
obs = rename(obs, source_transect_id = Transect) 

track = obs %>% filter(Type %in% "GPS") %>% select(-Type, -F28, -Spp) %>% mutate(type = "WAYPNT")
obs = obs %>% filter(Type %in% "USER") %>% select(-Type, -F28) %>% rename(type = Spp) %>% mutate(type = as.character(type))
obs$type[obs$start_stop %in% c("start","stert"," start")] = "BEGCNT"
obs$type[obs$start_stop %in% c("stop"," stop")] = "ENDCNT"
track$type[track$start_stop %in% c("start","stert"," start")] = "BEGCNT"
track$type[track$start_stop %in% c("stop"," stop")] = "ENDCNT"
to.add = track[track$type %in% c("BEGCNT", "ENDCNT"),]
obs = rbind(obs, to.add) %>% arrange(FID)
rm(to.add)
track = filter(track, !type %in% c("BEGCNT", "ENDCNT")) 
#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

obs$original_species_tx = obs$type

tmp <- !obs$type %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))
#---------------------#


#---------------------#
# other edits
#---------------------#
# change names to lowercase
colnames(obs) = tolower(names(obs))

# merge comments
obs = obs %>% mutate(comment = paste(comment_1, comment_2, sep = "; ")) %>% 
  select(-comment_1, -comment_2)

# remove empty cells
obs$type[obs$type %in% " "] = NA
obs = obs[!is.na(obs$type),]

# offline
obs$offline = 0
obs = obs %>% mutate(date_time = as.character(date_time))
obs$offline[obs$date_time %in% "2013-02-23 13:56:38"] = 1
obs$offline[obs$date_time %in% "2013-02-13 21:57:09"] = 1
obs$offline[obs$date_time %in% "2013-02-15 13:57:50"] = 1
obs$offline[obs$date_time %in% "2013-02-15 14:00:06"] = 1
#obs$offline[obs$date_time %in% "2013-02-11 20:50:41"] = 1
#obs$offline[obs$date_time %in% "2013-02-11 20:56:12"] = 1
#obs$offline[obs$date_time %in% "2013-02-23 21:45:01"] = 1

# switch BEG/END 
obs$type[obs$date_time %in% "2013-02-13 12:47:15"] = "ENDCNT"
obs$type[obs$date_time %in% "2013-02-16 17:00:03"] = "ENDCNT"
obs$type[obs$date_time %in% "2013-02-16 18:46:39"] = "BEGCNT"
obs$type[obs$date_time %in% "2013-02-20 12:21:35"] = "ENDCNT"
obs$type[obs$date_time %in% "2013-02-14 17:44:47"] = NA #???
obs$type[obs$date_time %in% "2013-02-23 21:36:50"] = NA #???
obs = obs[!is.na(obs$type),]

# assign piece names as transect names
to.add = obs %>% select(type, fid) %>% filter(type %in% "BEGCNT") %>% 
                                                      mutate(source_transect_id = seq(1:n()))
obs = left_join(obs, to.add, by=c("fid","type")) %>% select(-source_transect_id.x) %>% 
  rename(source_transect_id = source_transect_id.y)
rm(to.add)
obs$source_transect_id = na.locf(obs$source_transect_id)
obs$source_transect_id[obs$offline %in% 1] = NA
#---------------------#


#---------------------#
# fix track
#---------------------#
# change names to lowercase
colnames(track) = tolower(names(track))

# move BEG/END from obs to track
to.add = obs %>% filter(type %in% c("BEGCNT", "ENDCNT"))
obs = obs %>% filter(!type %in% c("BEGCNT", "ENDCNT"))
track = track %>% mutate(date_time = as.character(date_time)) %>% bind_rows(., to.add)
rm(to.add)

#get rid of unused columns
track = select(track, -count, -behavior, -plumage, -age)
#---------------------#


#---------------------#
# make transect
#---------------------#
transect = track %>% select(latitude, longitude, date, source_transect_id, type, time) %>% 
  mutate(type = as.character(type)) %>% filter(type %in% c("BEGCNT","ENDCNT")) %>%  
  mutate(source_transect_id = factor(source_transect_id)) %>% 
  group_by(source_transect_id) %>%   arrange(type) %>%
  summarize(start_lon = first(longitude), start_lat = first(latitude), 
            end_lon = last(longitude), end_lat = last(latitude),
            start_tm = first(time),end_tm = last(time),
            gps_date = first(date)) 
#---------------------#
