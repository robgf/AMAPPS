#---------------------#
# format AMAPPS Aug. 2017 data that was already cleaned
#---------------------#


#---------------------#
# load packages
#---------------------#
require(dplyr) # %>% 
require(zoo) # na.locf
require(geosphere) # distVincentySphere
#---------------------#


#---------------------#
# set paths
#---------------------#
surveyFolder = "AMAPPS_FWS/AMAPPS_2017_08"

dir <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
#---------------------#


#---------------------#
# load data
#---------------------#
track = read.csv(file.path(dir.in, "AMAPPS_2017_08_Track.csv"), header = TRUE)
obs = read.csv(file.path(dir.in, "AMAPPS_2017_08_Observations.csv"), header = TRUE)
transect = read.csv(file.path(dir.in, "AMAPPS_2017_08_transectTbl.csv"), header = TRUE)
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
         spp_cd = SpeciesId, temp_lat = latitude_dd, temp_lon = longitude_dd, source_obs_id = ID) %>%
  mutate(original_species_tx = spp_cd, 
         source_transect_id = paste(source_transect_id, obs, day, sep="_"),
         obs_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         surveyband = as.numeric(surveyband),
         distance_to_animal_tx = surveyband,
         distance_to_animal_tx = replace(distance_to_animal_tx, is.na(distance_to_animal_tx), surveyband[is.na(distance_to_animal_tx)]),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==1, "1: 0-100 meters"), 
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==2, "2: 100-200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==3, "3: >200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==0, "0: <200 meters or unknown"),
         distance_to_animal_tx = replace(distance_to_animal_tx, !is.na(distance.to.obs),
                                         paste(distance_to_animal_tx[!is.na(distance.to.obs)], "; ",
                                               distance.to.obs[!is.na(distance.to.obs)],
                                               " (meter(s) or nautical mile(s) if not specified)", sep=" "))) %>%
  select(-index)
#---------------------#


#---------------------#
# track formating
#---------------------#
track = track %>%
  rename(source_transect_id = transect, observer_position = seat, seconds_from_midnight_nb = sec, 
         observer = obs, source_track_id = ID, observer = obs) %>%
  mutate(source_transect_id = paste(source_transect_id, observer, day, sep="_"),
         track_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         type = replace(type, type=="BEGTRAN","BEGCNT"),
         type = replace(type, type=="ENDTRAN","ENDCNT"))
#---------------------#


#---------------------#
# transect
#---------------------#
transect = transect %>% 
  rename(observer_position = seat) %>% 
  mutate(observer_position = as.character(observer_position),
         observer_position = replace(observer_position, observer_position %in% "lf","left front of aircraft"),
         observer_position = replace(observer_position, observer_position %in% "rf","right front of aircraft"))
# -------------------- #

id = 395
