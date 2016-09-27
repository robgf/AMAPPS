# ------------------------------- #
# This script is to format track and transect data and 
# to import it into a temporary database to be evaluated
#
# run forNWASC_import_obstbl first so that we can then add the transect_id numbers to the observations
# matching by date
# ------------------------------- #
A# ------------------------------- #
# This script is to format track and transect data and 
# to import it into a temporary database to be evaluated
#
# run forNWASC_import_obstbl first so that we can then add the transect_id numbers to the observations
# matching by date
# ------------------------------- #

forNWASC_import_effort <- function(id, data_track, data_transect) {

  # ------------------------ #
  # load dataset descriptions
  # ------------------------ #
  library(RODBC)
  db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  transects.in.db = sqlFetch(db, "transect")
  tracks.in.db = sqlFetch(db, "track")
  data.in.db = sqlFetch(db, "dataset")
  obs.in.db = sqlFetch(db, "observation")
  # ------------------------ #
  
    
  # ------------------------ #
  # track
  # ------------------------ #
  # the track data should not be in start/stop lat/lon format. There should be a point type with each location
  # only transect information for be in the start/stop format
  
  dat_track = as.data.frame(matrix(ncol=dim(tracks.in.db)[2], nrow=dim(data_track)[1], data=NA))
  colnames(dat_track) = colnames(tracks.in.db)
  
  # move those variables over that have the same name
  same_nm = colnames(data_track[colnames(data_track) %in% colnames(dat_track)])
  dat_track[,same_nm] = data_track[,same_nm]
  
  dat_track$dataset_id = id
  dat_track$track_id = c((max(tracks.in.db$track_id)+1):(max(tracks.in.db$track_id)+dim(data_track)[1]))
  
  # fill in unmatched variables
  if(any(colnames(data_track) %in% c("lon", "longitude", "long"))) {
    dat_track$track_lon = data_track[,which(colnames(data_track) %in% c("lon", "longitude", "long"))]
  }
  if(any(colnames(data_track) %in% c("lat", "latitude"))) {
    dat_track$track_lat = data_track[,which(colnames(data_track) %in% c("lat", "latitude"))]
  }
  if(any(colnames(data_track) %in% c("type"))) {dat_track$point_type = data_track[,which(colnames(data_track) %in% c("type"))]}
  if(any(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))) {
    dat_track$track_dt = format(as.Date(data_track[,which(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))]),'%m/%d/%Y')
  }
  if(any(colnames(data_track) %in% c("time"))) {
    dat_track$track_tm = data_track[,which(colnames(data_track) %in% c("time"))]
  }
  if(any(colnames(data_track) %in% c("transect","transect_id"))) {
    dat_track$source_transect_id = data_track[,which(colnames(data_track) %in% c("transect","transect_id"))]
  }
  if(any(colnames(data_track) %in% c("index"))) {
    dat_track$source_track_id = data_track[,which(colnames(data_track) %in% c("index"))]
  } else dat_track$source_track_id = 1:dim(data_track)[1]
  
  dat_track = dat_track %>% mutate(track_id = as.numeric(track_id),           
                       track_dt = as.character(track_dt),           
                       track_tm = as.character(track_tm),           
                       track_lat = as.numeric(track_lat),                
                       track_lon = as.numeric(track_lon),               
                       point_type = as.character(point_type),          
                       source_survey_id = as.character(source_survey_id),    
                       source_transect_id = as.character(source_transect_id),  
                       observer_position = as.character(observer_position),   
                       observer = as.character(observer),           
                       offline = as.numeric(offline),                  
                       seastate = as.character(seastate),           
                       comment = as.character(comment),            
                       transect_id = as.numeric(transect_id),             
                       dataset_id = as.numeric(dataset_id),              
                       track_gs = as.character(track_gs),            
                       piece = as.numeric(piece),                 
                       source_track_id = as.numeric(source_track_id))
  # ------------------------ #
    
  
  # ------------------------ #
  # transect
  # ------------------------ #
  # reformat, create, and/or rename
  if(!missing(data_transect)) {
    dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
    colnames(dat_transect) = colnames(transects.in.db)
    
    # move those variables over that have the same name
    same_nm = colnames(data_transect[colnames(data_transect) %in% colnames(dat_transect)])
    dat_transect[,same_nm] = data_transect[,same_nm]
    
    dat_transect$dataset_id = id
    dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))
    dat_transect$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])   
        
    if(any(colnames(data_transect) %in% c("transect","transect_id"))) {
      dat_track$source_transect_id = data_transect[,which(colnames(data_transect) %in% c("transect","transect_id"))]
    }
    if(any(colnames(data_transect) %in% c("start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))) {
      dat_transect$temp_start_lon = data_transect[,which(colnames(data_transect) %in% c("start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]
    }
    if(any(colnames(data_transect) %in% c("start_lat", "begin_lat","start_latitude", "begin_latitude"))) {
      dat_transect$temp_start_lat = data_transect[,which(colnames(data_transect) %in% c("start_lat", "begin_lat","start_latitude", "begin_latitude"))]
    }
    if(any(colnames(data_transect) %in% c("end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))) {
      dat_transect$temp_stop_lon = data_transect[,which(colnames(data_transect) %in% c("end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))]
    }
    if(any(colnames(data_transect) %in% c("end_lat", "stop_lat","end_latitude", "stop_latitude"))) {
      dat_transect$temp_stop_lat = data_transect[,which(colnames(data_transect) %in% c("end_lat", "stop_lat","end_latitude", "stop_latitude"))]
    }
    if(any(colnames(data_transect) %in% c("date","start_dt","start_date"))) {
      dat_transect$start_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))]),'%m/%d/%Y')
    }
    if(any(colnames(data_transect) %in% c("date","end_dt","end_date"))) {
      dat_transect$end_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))]),'%m/%d/%Y')
    }
    if(any(colnames(data_transect) %in% c("time","start_time","start_tm"))) {
      dat_transect$start_tm = data_transect[,which(colnames(data_transect) %in% c("time","start_time","start_tm"))]
    }
    if(any(colnames(data_transect) %in% c("time","end_time","end_tm"))) {
      dat_transect$end_tm = data_transect[,which(colnames(data_transect) %in% c("time","end_time","end_tm"))]
    }
    if(any(colnames(data_transect) %in% c("observer","observers","observer_tx"))) {
      dat_transect$observers_tx = data_transect[,which(colnames(data_transect) %in% c("observer","observers","observer_tx"))]
    }
    # calculations
    dat_transect$transect_time_min_nb = difftime(as.POSIXct(paste(dat_transect$end_dt, dat_transect$end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                               as.POSIXct(paste(dat_transect$start_dt, dat_transect$start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                               units = "mins")
  }
  
  # if the transect information needs to be pulled from the track files
  if(missing(data_transect)) {
    # group by transect and day
    # pieces in transect
    # only works if there is a Beg and End
    library(geosphere)
    # pieces
    transect_pieces = dat_track %>% select(track_lat, track_lon, track_dt, source_transect_id, piece, point_type) %>% 
      filter(point_type %in% c("BEGTRAN","BEGCNT","ENDTRAN","ENDCNT")) %>%
      mutate(source_transect_id = factor(source_transect_id)) %>% 
      group_by(source_transect_id, piece, track_dt) %>%
      arrange(point_type) %>%
      summarize(start_lon = first(track_lon), start_lat = first(track_lat), end_lon = last(track_lon), end_lat = last(track_lat)) %>%
      rowwise %>% 
      mutate(distance =  distm(c(start_lat, start_lon), c(end_lat, end_lon), fun = distHaversine)) %>% 
      ungroup %>% as.data.frame
    
    #summarize pieces to transects
    transects = transect_pieces %>% 
      mutate(source_transect_id = factor(source_transect_id)) %>% 
      group_by(source_transect_id, track_dt) %>% 
      summarise(transect_distance_nb = sum(distance)) %>% mutate(transect_distance_nb = transect_distance_nb[1]) %>%
      rename(start_dt = track_dt) %>% ungroup %>% as.data.frame
    
    # fill in the db transects table
    dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(transects)[1], data=NA))
    colnames(dat_transect) = colnames(transects.in.db)
    same_nm = colnames(transects[colnames(transects) %in% colnames(dat_transect)])
    dat_transect[,same_nm] = transects[,same_nm]
    dat_transect$dataset_id = id
    dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))
    dat_transect$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])   
    dat_transect = dat_transect %>% 
      mutate(temp_start_lat = transect_pieces$start_lat[transect_pieces$track_dt == start_dt]) %>%
      mutate(temp_start_lon = transect_pieces$start_lon[transect_pieces$track_dt == start_dt]) %>%
      mutate(temp_stop_lat = transect_pieces$end_lat[transect_pieces$track_dt == end_dt]) %>%
      mutate(temp_stop_lat = transect_pieces$end_lon[transect_pieces$track_dt == end_dt])
    
    # calculations
    dat_transect$transect_time_min_nb = difftime(as.POSIXct(paste(dat_transect$end_dt, dat_transect$end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                                 as.POSIXct(paste(dat_transect$start_dt, dat_transect$start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                                 units = "mins")
    
  }

  # format class names
  dat_transect = dat_transect %>% mutate(transect_id = as.numeric(transect_id),
                                           dataset_id = as.numeric(dataset_id),
                                           source_transect_id = as.character(source_transect_id),
                                           source_dataset_id = as.character(source_dataset_id),
                                           start_dt = as.character(start_dt),
                                           start_tm = as.character(start_tm),
                                           end_dt = as.character(end_dt),
                                           end_tm = as.character(end_tm),
                                           transect_time_min_nb = as.numeric(transect_time_min_nb),
                                           transect_distance_nb = as.numeric(transect_distance_nb),
                                           traversal_speed_nb = as.numeric(traversal_speed_nb),
                                           transect_width_nb = as.numeric(transect_width_nb),
                                           observers_tx = as.character(observers_tx),
                                           visability_tx = as.character(visability_tx),
                                           weather_tx = as.character(weather_tx),
                                           seastate_beaufort_nb = as.numeric(seastate_beaufort_nb),
                                           wind_speed_tx = as.character(wind_speed_tx),
                                           wind_dir_tx = as.character(wind_dir_tx),
                                           seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
                                           comments_tx = as.character(comments_tx),
                                           track_gs = as.character(track_gs),
                                           conveyance_name_tx = as.character(conveyance_name_tx),
                                           heading_tx = as.character(heading_tx),
                                           wave_height_tx = as.character(wave_height_tx),
                                           spatial_type_tx = as.character(spatial_type_tx),
                                           who_created = as.character(who_created),
                                           date_created = as.character(date_created),
                                           utm_zone = as.character(utm_zone),
                                           whole_transect = as.character(whole_transect),
                                           local_transect_id = as.character(local_transect_id),
                                           who_imported = as.character(who_imported),
                                           temp_start_lat = as.numeric(temp_start_lat),
                                           temp_start_lon = as.numeric(temp_start_lon),
                                           temp_stop_lat = as.numeric(temp_stop_lat),
                                           temp_stop_lon = as.numeric(temp_stop_lon),
                                           obs_position = as.character(obs_position),
                                           visit = as.character(visit),
                                           time_from_midnight_start = as.character(time_from_midnight_start),
                                           time_from_midnight_stop = as.character(time_from_midnight_stop),
                                           date_imported = as.character(date_imported),
                                           local_survey_id = as.character(local_survey_id),
                                           local_transect_id2 = as.character(local_transect_id2),
                                           survey_type = as.character(survey_type))
  # ------------------------ #
  
  
  # ------------------------ #
  # join transect numbers to both track and observations tables based on date
  # ------------------------ #
  dat_track = full_join(dat_track, select(dat_transect, dataset_id, source_transect_id, transect_id), 
                        by=c("dataset_id","source_transect_id"))
  dat_transect$source_transect_id = as.numeric(dat_transect$source_transect_id)
  dat_transect$transect_id = as.numeric(dat_transect$transect_id)
  obs.in.db = full_join(obs.in.db, select(dat_transect, dataset_id, source_transect_id, transect_id), 
                        by=c("dataset_id","source_transect_id")) %>% select(transect_id.y, observation_id) %>%
    replace(transect_id,dataset_id==id,transect_id.y) %>% select(-transect_id.y)
  
  ## replace data in db
  sqlUpdate(db, obs.in.db, tablename = "observation", index = "observation_id") 
  # sqlUpdate(db, track_transect_id, tablename = "track", index = "track_id") # if already created
  # sqlSave(db, obs.in.db, tablename = "observation", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE) # if you mess up, delete and replace
  # ------------------------ #
  

  # ------------------------ #
  # add to NWASC temporary db
  # ------------------------ #
  sqlSave(db, dat_track, tablename = "track", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
  sqlSave(db, dat_transect, tablename = "transect", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
 
  odbcClose(db) 
  # ------------------------ #
}

forNWASC_import_effort <- function(id, data_track, data_transect) {

  # ------------------------ #
  # load dataset descriptions
  # ------------------------ #
  library(RODBC)
  db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  transects.in.db = sqlFetch(db, "transect")
  tracks.in.db = sqlFetch(db, "track")
  data.in.db = sqlFetch(db, "dataset")
  obs.in.db = sqlFetch(db, "observation")
  # ------------------------ #
  
    
  # ------------------------ #
  # track
  # ------------------------ #
  # the track data should not be in start/stop lat/lon format. There should be a point type with each location
  # only transect information for be in the start/stop format
  
  dat_track = as.data.frame(matrix(ncol=dim(tracks.in.db)[2], nrow=dim(data_track)[1], data=NA))
  colnames(dat_track) = colnames(tracks.in.db)
  
  # move those variables over that have the same name
  same_nm = colnames(data_track[colnames(data_track) %in% colnames(dat_track)])
  dat_track[,same_nm] = data_track[,same_nm]
  
  dat_track$dataset_id = id
  dat_track$track_id = c((max(tracks.in.db$track_id)+1):(max(tracks.in.db$track_id)+dim(data_track)[1]))
  
  # fill in unmatched variables
  if(any(colnames(data_track) %in% c("lon", "longitude", "long"))) {
    dat_track$track_lon = data_track[,which(colnames(data_track) %in% c("lon", "longitude", "long"))]
  }
  if(any(colnames(data_track) %in% c("lat", "latitude"))) {
    dat_track$track_lat = data_track[,which(colnames(data_track) %in% c("lat", "latitude"))]
  }
  if(any(colnames(data_track) %in% c("type"))) {dat_track$point_type = data_track[,which(colnames(data_track) %in% c("type"))]}
  if(any(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))) {
    dat_track$track_dt = format(as.Date(data_track[,which(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))]),'%m/%d/%Y')
  }
  if(any(colnames(data_track) %in% c("time"))) {
    dat_track$track_tm = data_track[,which(colnames(data_track) %in% c("time"))]
  }
  if(any(colnames(data_track) %in% c("transect","transect_id"))) {
    dat_track$source_transect_id = data_track[,which(colnames(data_track) %in% c("transect","transect_id"))]
  }
  if(any(colnames(data_track) %in% c("index"))) {
    dat_track$source_track_id = data_track[,which(colnames(data_track) %in% c("index"))]
  } else dat_track$source_track_id = 1:dim(data_track)[1]
  
  dat_track = dat_track %>% mutate(track_id = as.numeric(track_id),           
                       track_dt = as.character(track_dt),           
                       track_tm = as.character(track_tm),           
                       track_lat = as.numeric(track_lat),                
                       track_lon = as.numeric(track_lon),               
                       point_type = as.character(point_type),          
                       source_survey_id = as.character(source_survey_id),    
                       source_transect_id = as.character(source_transect_id),  
                       observer_position = as.character(observer_position),   
                       observer = as.character(observer),           
                       offline = as.numeric(offline),                  
                       seastate = as.character(seastate),           
                       comment = as.character(comment),            
                       transect_id = as.numeric(transect_id),             
                       dataset_id = as.numeric(dataset_id),              
                       track_gs = as.character(track_gs),            
                       piece = as.numeric(piece),                 
                       source_track_id = as.numeric(source_track_id))
  # ------------------------ #
    
  
  # ------------------------ #
  # transect
  # ------------------------ #
  # reformat, create, and/or rename
  if(!missing(data_transect)) {
    dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
    colnames(dat_transect) = colnames(transects.in.db)
    
    # move those variables over that have the same name
    same_nm = colnames(data_transect[colnames(data_transect) %in% colnames(dat_transect)])
    dat_transect[,same_nm] = data_transect[,same_nm]
    
    dat_transect$dataset_id = id
    dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))
    dat_transect$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])   
        
    if(any(colnames(data_transect) %in% c("transect","transect_id"))) {
      dat_track$source_transect_id = data_transect[,which(colnames(data_transect) %in% c("transect","transect_id"))]
    }
    if(any(colnames(data_transect) %in% c("start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))) {
      dat_transect$temp_start_lon = data_transect[,which(colnames(data_transect) %in% c("start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]
    }
    if(any(colnames(data_transect) %in% c("start_lat", "begin_lat","start_latitude", "begin_latitude"))) {
      dat_transect$temp_start_lat = data_transect[,which(colnames(data_transect) %in% c("start_lat", "begin_lat","start_latitude", "begin_latitude"))]
    }
    if(any(colnames(data_transect) %in% c("end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))) {
      dat_transect$temp_stop_lon = data_transect[,which(colnames(data_transect) %in% c("end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))]
    }
    if(any(colnames(data_transect) %in% c("end_lat", "stop_lat","end_latitude", "stop_latitude"))) {
      dat_transect$temp_stop_lat = data_transect[,which(colnames(data_transect) %in% c("end_lat", "stop_lat","end_latitude", "stop_latitude"))]
    }
    if(any(colnames(data_transect) %in% c("date","start_dt","start_date"))) {
      dat_transect$start_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))]),'%m/%d/%Y')
    }
    if(any(colnames(data_transect) %in% c("date","end_dt","end_date"))) {
      dat_transect$end_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))]),'%m/%d/%Y')
    }
    if(any(colnames(data_transect) %in% c("time","start_time","start_tm"))) {
      dat_transect$start_tm = data_transect[,which(colnames(data_transect) %in% c("time","start_time","start_tm"))]
    }
    if(any(colnames(data_transect) %in% c("time","end_time","end_tm"))) {
      dat_transect$end_tm = data_transect[,which(colnames(data_transect) %in% c("time","end_time","end_tm"))]
    }
    if(any(colnames(data_transect) %in% c("observer","observers","observer_tx"))) {
      dat_transect$observers_tx = data_transect[,which(colnames(data_transect) %in% c("observer","observers","observer_tx"))]
    }
    # calculations
    dat_transect$transect_time_min_nb = difftime(as.POSIXct(paste(dat_transect$end_dt, dat_transect$end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                               as.POSIXct(paste(dat_transect$start_dt, dat_transect$start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                               units = "mins")
  }
  
  # if the transect information needs to be pulled from the track files
  if(missing(data_transect)) {
    # group by transect and day
    # pieces in transect
    # only works if there is a Beg and End
    library(geosphere)
    # pieces
    transect_pieces = dat_track %>% select(track_lat, track_lon, track_dt, source_transect_id, piece, point_type) %>% 
      filter(point_type %in% c("BEGTRAN","BEGCNT","ENDTRAN","ENDCNT")) %>%
      mutate(source_transect_id = factor(source_transect_id)) %>% 
      group_by(source_transect_id, piece, track_dt) %>%
      arrange(point_type) %>%
      summarize(start_lon = first(track_lon), start_lat = first(track_lat), end_lon = last(track_lon), end_lat = last(track_lat)) %>%
      rowwise %>% 
      mutate(distance =  distm(c(start_lat, start_lon), c(end_lat, end_lon), fun = distHaversine)) %>% 
      ungroup %>% as.data.frame
    
    #summarize pieces to transects
    transects = transect_pieces %>% 
      mutate(source_transect_id = factor(source_transect_id)) %>% 
      group_by(source_transect_id, track_dt) %>% 
      summarise(transect_distance_nb = sum(distance)) %>% mutate(transect_distance_nb = transect_distance_nb[1]) %>%
      rename(start_dt = track_dt) %>% ungroup %>% as.data.frame
    
    # fill in the db transects table
    dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(transects)[1], data=NA))
    colnames(dat_transect) = colnames(transects.in.db)
    same_nm = colnames(transects[colnames(transects) %in% colnames(dat_transect)])
    dat_transect[,same_nm] = transects[,same_nm]
    dat_transect$dataset_id = id
    dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))
    dat_transect$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])   
    dat_transect = dat_transect %>% 
      mutate(temp_start_lat = transect_pieces$start_lat[transect_pieces$track_dt == start_dt]) %>%
      mutate(temp_start_lon = transect_pieces$start_lon[transect_pieces$track_dt == start_dt]) %>%
      mutate(temp_stop_lat = transect_pieces$end_lat[transect_pieces$track_dt == end_dt]) %>%
      mutate(temp_stop_lat = transect_pieces$end_lon[transect_pieces$track_dt == end_dt])
    
    # calculations
    dat_transect$transect_time_min_nb = difftime(as.POSIXct(paste(dat_transect$end_dt, dat_transect$end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                                 as.POSIXct(paste(dat_transect$start_dt, dat_transect$start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                                 units = "mins")
    
  }

  # format class names
  dat_transect = dat_transect %>% mutate(transect_id = as.numeric(transect_id),
                                           dataset_id = as.numeric(dataset_id),
                                           source_transect_id = as.character(source_transect_id),
                                           source_dataset_id = as.character(source_dataset_id),
                                           start_dt = as.character(start_dt),
                                           start_tm = as.character(start_tm),
                                           end_dt = as.character(end_dt),
                                           end_tm = as.character(end_tm),
                                           transect_time_min_nb = as.numeric(transect_time_min_nb),
                                           transect_distance_nb = as.numeric(transect_distance_nb),
                                           traversal_speed_nb = as.numeric(traversal_speed_nb),
                                           transect_width_nb = as.numeric(transect_width_nb),
                                           observers_tx = as.character(observers_tx),
                                           visability_tx = as.character(visability_tx),
                                           weather_tx = as.character(weather_tx),
                                           seastate_beaufort_nb = as.numeric(seastate_beaufort_nb),
                                           wind_speed_tx = as.character(wind_speed_tx),
                                           wind_dir_tx = as.character(wind_dir_tx),
                                           seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
                                           comments_tx = as.character(comments_tx),
                                           track_gs = as.character(track_gs),
                                           conveyance_name_tx = as.character(conveyance_name_tx),
                                           heading_tx = as.character(heading_tx),
                                           wave_height_tx = as.character(wave_height_tx),
                                           spatial_type_tx = as.character(spatial_type_tx),
                                           who_created = as.character(who_created),
                                           date_created = as.character(date_created),
                                           utm_zone = as.character(utm_zone),
                                           whole_transect = as.character(whole_transect),
                                           local_transect_id = as.character(local_transect_id),
                                           who_imported = as.character(who_imported),
                                           temp_start_lat = as.numeric(temp_start_lat),
                                           temp_start_lon = as.numeric(temp_start_lon),
                                           temp_stop_lat = as.numeric(temp_stop_lat),
                                           temp_stop_lon = as.numeric(temp_stop_lon),
                                           obs_position = as.character(obs_position),
                                           visit = as.character(visit),
                                           time_from_midnight_start = as.character(time_from_midnight_start),
                                           time_from_midnight_stop = as.character(time_from_midnight_stop),
                                           date_imported = as.character(date_imported),
                                           local_survey_id = as.character(local_survey_id),
                                           local_transect_id2 = as.character(local_transect_id2),
                                           survey_type = as.character(survey_type))
  # ------------------------ #
  
  
  # ------------------------ #
  # join transect numbers to both track and observations tables based on date
  # ------------------------ #
  dat_track = full_join(dat_track, select(dat_transect, dataset_id, source_transect_id, transect_id), 
                        by=c("dataset_id","source_transect_id"))
  dat_transect$source_transect_id = as.numeric(dat_transect$source_transect_id)
  dat_transect$transect_id = as.numeric(dat_transect$transect_id)
  obs_transect_id = full_join(obs.in.db, select(dat_transect, dataset_id, source_transect_id, transect_id), 
                        by=c("dataset_id","source_transect_id")) %>% select(transect_id.y, observation_id) %>%
    rename(transect_id = transect_id.y)
  
  sqlUpdate(db, obs_transect_id, tablename = "observation", index = "observation_id") 
  # sqlUpdate(db, track_transect_id, tablename = "track", index = "track_id") # if already created
  # ------------------------ #
  

  # ------------------------ #
  # add to NWASC temporary db
  # ------------------------ #
  sqlSave(db, dat_track, tablename = "track", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
  sqlSave(db, dat_transect, tablename = "transect", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
 
  odbcClose(db) 
  # ------------------------ #
}
