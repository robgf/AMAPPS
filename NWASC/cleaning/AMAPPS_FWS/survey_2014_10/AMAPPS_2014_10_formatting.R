#---------------------#
# format AMAPPS fall 2014 data that was already cleaned
#---------------------#


#---------------------#
# load packages
#---------------------#
require(dplyr)
#---------------------#


#---------------------#
# set paths
#---------------------#
surveyFolder = "AMAPPS_FWS/AMAPPS_2014_10"

dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
#---------------------#


#---------------------#
# load data
#---------------------#
transect = read.csv(file.path(dir.in, "AMAPPS_2014_10_TransectTbl.csv"), header = TRUE)
track = read.csv(file.path(dir.in, "AMAPPS_2014_10_Tracks.csv"), header = TRUE)
obs = read.csv(file.path(dir.in, "AMAPPS_2014_10_Observations.csv"), header = TRUE)
#---------------------#


#---------------------#
# get rid of COCH (code change)
#---------------------#
track = track[!track$type %in% "COCH",] 
#---------------------#


#---------------------#
# obs formatting
#---------------------#
obs = obs %>% 
  rename(source_transect_id = transect, obs_position = seat, seconds_from_midnight_nb = Time_secs,
         spp_cd = type, temp_lat = latitude_dd, temp_lon = longitude_dd, source_obs_id = ID) %>%
  mutate(original_species_tx = spp_cd, 
         source_transect_id = paste(source_transect_id, obs, day, sep="_"),
         obs_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"))
#---------------------#


#---------------------#
# track formating
#---------------------#
track = track %>%
  rename(source_transect_id = transect, observer_position = seat, seconds_from_midnight_nb = sec, 
         observer = obs) %>%
  mutate(source_transect_id = paste(source_transect_id, obs, day, sep="_"),
         track_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"))#,
         #type = replace(type, type=="BEGTRAN","BEGCNT"),
         #type = replace(type, type=="ENDTRAN","ENDCNT"))
#---------------------#
