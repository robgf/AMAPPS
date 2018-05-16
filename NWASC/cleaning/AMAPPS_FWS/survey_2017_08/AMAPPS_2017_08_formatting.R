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
  rename(source_transect_id = transect, 
         obs_position = seat, 
         seconds_from_midnight_nb = Time_secs,
         spp_cd = SpeciesId, 
         temp_lat = latitude_dd, 
         temp_lon = longitude_dd, 
         source_obs_id = ID) %>%
  mutate(original_species_tx = spp_cd, 
         source_transect_id = paste(key, source_transect_id, sep="_"),
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
                                               " (meter(s) or nautical mile(s) if not specified)", sep=" ")),
         behavior_id = as.character(behavior),
         behavior_id = replace(behavior_id, behavior_id %in% "f", 13),
         behavior_id = replace(behavior_id, behavior_id %in% "s", 35),
         behavior_id = replace(behavior_id, behavior_id %in% "", 44),
         age_id = as.character(age),
         age_id = replace(age_id, age_id %in% "adult",1),
         age_id = replace(age_id, age_id %in% "immature",6),
         age_id = replace(age_id, age_id %in% "juvenile",2),
         age_id = replace(age_id, age_id %in% "subadult",7),
         age_id = replace(age_id, is.na(age_id),5),
         sex_id = 5,
         obs_position = as.character(obs_position),
         obs_position = replace(obs_position, obs_position %in% "lf","left front of aircraft"),
         obs_position = replace(obs_position, obs_position %in% "rf","right front of aircraft")) %>%
  select(-index)
#---------------------#


#---------------------#
# track formating
#---------------------#
track = track %>%
  rename(observer_position = seat, 
         seconds_from_midnight_nb = sec, 
         observer = obs, 
         source_track_id = ID, 
         observer = obs) %>%
  mutate(observer_position = as.character(observer_position),
         source_transect_id = paste(key, transect, sep="_"),
         track_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         observer_position = replace(observer_position, observer_position %in% "lf","left front of aircraft"),
         observer_position = replace(observer_position, observer_position %in% "rf","right front of aircraft"))
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
data = obs
data_track = track
data_transect = transect
rm(obs, track, transect)
