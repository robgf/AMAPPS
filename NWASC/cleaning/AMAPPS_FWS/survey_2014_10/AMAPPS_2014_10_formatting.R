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
transect = read.csv(file.path(dir.in, ".csv"), header = TRUE)
track = read.csv(file.path(dir.in, ".csv"), header = TRUE)
obs = read.csv(file.path(dir.in, ".csv"), header = TRUE)
#---------------------#


#---------------------#
# get rid of COCH (code change)
#---------------------#
track = track[!track$type %in% "COCH",] 
#---------------------#


#---------------------#
# obs formatting
#---------------------#
obs = obs %>% mutate(Condition = replace(Condition, Condition==1, "1 - worst observation conditions"),
                     Condition = replace(Condition, Condition==2, "2 - bad observation conditions"), 
                     Condition = replace(Condition, Condition==3, "3 - average observation conditions"),
                     Condition = replace(Condition, Condition==4, "4 - good observation conditions"),
                     Condition = replace(Condition, Condition==5, "5 - excellent observation conditions"))
      rename(source_transect_id = Transect, weather_tx = Condition, obs_position = Seat,
      seconds_from_midnight_nb = Sec)
obs = mutate(obs, source_transect_id = paste(source_transect_id, Obs, sep="_"))
obs$obs_dt = as.POSIXct(paste(obs$Year, obs$Month, obs$Day, sep="/"), format="%Y/%m/%d")
#---------------------#


#---------------------#
# track formating
#---------------------#
track = rename(track, source_transect_id = Transect,  
               observer_position = Seat, seconds_from_midnight_nb = Sec, observer = Obs)
track = mutate(track, source_transect_id = paste(source_transect_id, Obs, sep="_"))
track$track_dt = as.POSIXct(paste(track$Year, track$Month, track$Day, sep="/"), format="%Y/%m/%d")
track$type[track$type %in% "BEGSEG"] = "BEGCNT"
track$type[track$type %in% "ENDSEG"] = "ENDCNT"
#---------------------#
