#---------------------#
# format AMAPPS winter 2014 data that was already cleaned
#---------------------#


#---------------------#
# load packages
require(dplyr)
require(gdata)
require(RODBC)
#---------------------#


#---------------------#
# set paths
surveyFolder = "AMAPPS_FWS/AMAPPS_2014_02"

dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing"
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
speciesPath <- gsub("datasets_received", "data_import/in_progress", dir)
#---------------------#


#---------------------#
# load data
online = read.csv(file.path(dir.in, "TrackFileEdit2014_Final.csv"), header = TRUE)

track = online[online$type %in% c("BEGSEG","BEGCNT","ENDSEG","ENDCNT"),]
track2 = online[as.character(online$type) %in% "",]
track2$type = "WAYPNT"
track$type = as.character(track$type)
track = bind_rows(track, track2) %>% arrange(ID) %>% select(-count)
rm(track2)

online = online[!online$type %in% c("BEGSEG","BEGCNT","ENDSEG","ENDCNT"),]
online = online[!as.character(online$type) %in% "",]
online = rename(online, obs_count_intrans_nb = count)
online$obs_count_general_nb = online$obs_count_intrans_nb

offline = read.csv(file.path(dir.in, "OfflineObs2014_Final.csv"), header = TRUE)
offline = rename(offline, obs_count_general_nb = FlockSize, type = Species, gps_error = GpsError)
offline$gps_error = as.numeric(offline$gps_error)

# combine offline and online data
colnames(online) = tolower(names(online))
colnames(offline) = tolower(names(offline))
obs = bind_rows(online, offline)
rm(online, offline)
#---------------------#


#---------------------#
# fix species
db <- odbcConnectAccess2007(file.path(speciesPath,"NWASC_temp.accdb"))
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

obs$original_species_tx = obs$type

tmp <- !obs$type %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))
obs$type = as.character(obs$type)
obs$type[obs$type %in% "ALCD"] = "UNAL"
obs$type[obs$type %in% "BBGU"] = "UBBG" 
obs$type[obs$type %in% "BIRD"] = "UNBI"
obs$type[obs$type %in% "DOLP"] = "UNDO"
obs$type[obs$type %in% "DUCK"] = "UNDU"
obs$type[obs$type %in% "DWSC"] = "DASC" 
obs$type[obs$type %in% "EIDE"] = "UNEI"
obs$type[obs$type %in% "GOLD"] = "UNGO" 
obs$type[obs$type %in% "GRST"] = "GRTU"
obs$type[obs$type %in% "GULL"] = "UNGU"
obs$type[obs$type %in% "LEST"] = "LETU"
obs$type[obs$type %in% "LOON"] = "UNLO"
obs$type[obs$type %in% "LOST"] = "LOTU"
obs$type[obs$type %in% "MERG"] = "UNME"
obs$type[obs$type %in% "PORP"] = "UNPO"
obs$type[obs$type %in% "SCOT"] = "UNSC"
obs$type[obs$type %in% "SEAL"] = "UNSE"
obs$type[obs$type %in% "UIST"] = "TURT"
obs$type[obs$type %in% "WHAL"] = "UNWH"
obs$type[obs$type %in% "CAGO"] = "CANG"
obs$type[obs$type %in% "GEAR"] = "FIGE"
obs$type[obs$type %in% "TRAW"] = "BOTD"
obs$type[obs$type %in% "USHO"] = "SHOR"

# get rid of COCH (code change)
obs = obs[!obs$type %in% "COCH",] 
#---------------------#
