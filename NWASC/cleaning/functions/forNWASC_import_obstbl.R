# ------------------------------- #
#
# ------------------------------- #

forNWASC_import_obstbl <- function(data, id) {
  
  # load dataset descriptions
  library(RODBC)
  db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  data.in.db = sqlFetch(db, "dataset")
  obs.in.db = sqlFetch(db, "observation")
  
  dat = as.data.frame(matrix(ncol = dim(obs.in.db)[2], nrow = dim(data)[1], data=NA))
  colnames(dat) = colnames(obs.in.db)
  dat$dataset_id = id
  dat$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])
  
  # move those variables over that have the same name
  same_nm = colnames(data[colnames(data) %in% colnames(dat)])
  dat[,same_nm] = data[,same_nm] 
  
  # assign observation id based on what is already in the temp db
  dat$observation_id = c((max(obs.in.db$observation_id)+1):(max(obs.in.db$observation_id)+dim(data)[1]))
  
  # reformat, create, and/or rename
  if(any(colnames(data) %in% c("spp","type"))) {dat$spp_cd = data[,which(colnames(data) %in% c("spp","type"))]}  
  if(any(colnames(data) %in% c("index"))) {dat$source_obs_id = data$index} else dat$source_obs_id = 1:dim(data)[1]
  if(any(colnames(data) %in% c("transect"))) {dat$source_transect_id = data$transect}
  if(length(dat$source_transect_id)==0 & any(colnames(data) %in% c("offline")) & any(!colnames(data) %in% c("transect"))) {
    dat$source_transect_id[data$offline==0] = 1
  }
  if(any(colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt"))) {
    dat$obs_dt = format(as.Date(data[,which(colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt"))]),'%m/%d/%Y') # month/ day/ year
  }
  if(any(!colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt")) & all(colnames(data) %in% c("year","month","day"))) {
    dat$obs_dt = paste(data$month,data$day,data$year,sep="/")
  }
  if(any(colnames(data) %in% c("time","obs_time","obs_tm"))) {
    dat$obs_start_tm = data[,which(colnames(data) %in% c("time","obs_time","obs_tm"))]
    #dat$obs_start_tm[!is.na(data$time)] = format(data$time[!is.na(data$time)], "%I:%M:%S %p") # hours (1-12): min: sec space am/pm
  }
  if(any(colnames(data) %in% c("association","assocdesc"))) {
    dat$association_tx = data[,which(colnames(data) %in% c("association","assocdesc"))]
  }
  if(any(colnames(data) %in% c("behavior"))) {dat$behavior_tx = data$behavior}
  if(any(colnames(data) %in% c("age"))) {dat$animal_age_tx = data$age}
  if(any(colnames(data) %in% c("flight_hei"))) {dat$flight_height_tx = data$flight_hei}
  if(any(colnames(data) %in% c("distance"))) {dat$distance_to_animal_tx = data$distance}
  if(any(colnames(data) %in% c("heading"))) {dat$heading_tx = data[,which(colnames(data) %in% c("heading"))]}
  if(any(colnames(data) %in% c("flight_dir,flidir","fltdir"))) {
    dat$travel_direction_tx = data[,which(colnames(data) %in% c("flight_dir,flidir","fltdir"))]
  }
  if(any(colnames(data) %in% c("lon", "long", "longitude"))) {dat$temp_lon = data[,which(colnames(data) %in% c("lon", "long", "longitude"))]} 
  if(any(colnames(data) %in% c("lat", "latitude"))) {dat$temp_lat = data[,which(colnames(data) %in% c("lat", "latitude"))]}
  if(any(colnames(data) %in% c("comments"))) { #, "dataChange", "datachange"))) {
    dat$comments_tx = data[,which(colnames(data) %in% c("comments"))]
    #dat$comments_tx = data[,which(colnames(data) %in% c("comments", "dataChange", "datachange"))]
  }
  if(any(colnames(data) %in% c("count","obs_count_general_nb"))) {
    dat$obs_count_general_nb = data[,which(colnames(data) %in% c("count","obs_count_general_nb"))]
    dat$obs_count_intrans_nb = data[,which(colnames(data) %in% c("count","obs_count_general_nb"))]
  }
  # if there is a definition of where they were off effort, make the intransect counts for off effort NA
  if(any(colnames(data) %in% c("offline"))) {
    dat$obs_count_intrans_nb = data$count
    dat$obs_count_intrans_nb[data$offline == 1] = NA
  }
     
  # classes
  dat = dat %>% mutate(observation_id = as.numeric(observation_id),
                       transect_id = as.numeric(transect_id),
                       dataset_id = as.numeric(dataset_id),
                       local_obs_id = as.numeric(local_obs_id),
                       local_transect_id = as.numeric(local_transect_id),
                       source_obs_id = as.numeric(source_obs_id),
                       source_transect_id = as.character(source_transect_id),
                       source_dataset_id = as.character(source_dataset_id),
                       original_species_tx = as.character(original_species_tx),
                       spp_cd = as.character(spp_cd),
                       obs_count_intrans_nb = as.numeric(obs_count_intrans_nb),
                       obs_count_general_nb = as.numeric(obs_count_general_nb),
                       animal_age_tx = as.character(animal_age_tx),
                       plumage_tx = as.character(plumage_tx),
                       behavior_tx = as.character(behavior_tx),
                       travel_direction_tx = as.character(travel_direction_tx),
                       flight_height_tx = as.character(flight_height_tx),
                       distance_to_animal_tx = as.character(distance_to_animal_tx),
                       angle_from_observer_nb = as.numeric(angle_from_observer_nb),
                       visibility_tx = as.character(visibility_tx),
                       weather_tx = as.character(weather_tx),
                       seastate_beaufort_nb = as.numeric(seastate_beaufort_nb),
                       wind_speed_tx = as.character(wind_speed_tx),
                       wind_dir_tx = as.character(wind_dir_tx),
                       seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
                       comments_tx = as.character(comments_tx),
                       animal_sex_tx = as.character(animal_sex_tx),
                       cloud_cover_tx = as.character(cloud_cover_tx),
                       association_tx = as.character(association_tx),
                       who_created_tx = as.character(who_created_tx),
                       who_created = as.numeric(who_created),
                       temp_lat = as.numeric(temp_lat),
                       temp_lon = as.numeric(temp_lon),
                       who_imported = as.numeric(who_imported),
                       salinity_ppt_nb = as.numeric(salinity_ppt_nb),
                       admin_notes = as.character(admin_notes),
                       platform_tx = as.character(platform_tx),
                       station_tx = as.character(station_tx),
                       survey_type = as.character(survey_type),
                       heading_tx = as.character(heading_tx),
                       wave_height_tx = as.character(wave_height_tx),
                       obs_position = as.character(obs_position),
                       glare_tx = as.character(glare_tx),
                       whitecaps_tx = as.character(whitecaps_tx),
                       visit = as.character(visit),
                       obs_dt = as.character(obs_dt),
                       obs_start_tm = as.character(obs_start_tm),
                       date_imported = as.character(date_imported),
                       date_created = as.character(date_created),
                       obs_end_tm = as.character(obs_end_tm))
  
  # add to NWASC temporary db
  sqlSave(db, dat, tablename = "observation", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
  
  odbcClose(db) 
}
