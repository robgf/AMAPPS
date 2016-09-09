# ------------------------------- #
# track = pieces
# transect = 1
# ------------------------------- #

forNWASC_import_effort <- function(id, data_track, data_transect) {
  # load dataset descriptions
  library(RODBC)
  db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  transects.in.db = sqlFetch(db, "transect")
  tracks.in.db = sqlFetch(db, "track")
  
  # ------------------------ #
  # transect
  # ------------------------ #
  # reformat, create, and/or rename
  if(!missing(data_transect)) {
    dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
    colnames(dat_transect) = colnames(transects.in.db)
    
    # move those variables over that have the same name
    same_nm = colnames(data_transect[colnames(data_transect) %in% colnames(dat_transect)])
    dat[,colnames(dat) %in% same_nm] = data[,colnames(data) %in% same_nm]
    
    dat_transect$dataset_id = id
    dat_transect$transect_id = c((max(dat_design$transect_id)+1):(max(dat_design$transect_id)+dim(design)[1]))
    dat_track$source_transect_id = data_transect[,which(colnames(data_transect) %in% c("transect","transect_id"))]
    dat_transect$temp_start_lon = data_transect[,which(colnames(data_transect) %in% c("start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]
    dat_transect$temp_start_lat = data_transect[,which(colnames(data_transect) %in% c("start_lat", "begin_lat","start_latitude", "begin_latitude"))]
    dat_transect$temp_stop_lon = data_transect[,which(colnames(data_transect) %in% c("end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))]
    dat_transect$temp_stop_lat = data_transect[,which(colnames(data_transect) %in% c("end_lat", "stop_lat","end_latitude", "stop_latitude"))]
    dat_transect$start_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))]),'%m/%d/%Y')
    dat_transect$end_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))]),'%m/%d/%Y')
  }
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
  dat_track$track_lon = data_track[,which(colnames(data_track) %in% c("lon", "longitude", "long"))]
  dat_track$track_lat = data_track[,which(colnames(data_track) %in% c("lat", "latitude"))]    
  dat_track$point_type = data_track[,which(colnames(data_track) %in% c("type"))]
  dat_track$track_dt = format(as.Date(data_track[,which(colnames(data_track) %in% c("date","start_dt","start_date","gps_date"))]),'%m/%d/%Y')
  dat_track$source_transect_id = data_track[,which(colnames(data_track) %in% c("transect","transect_id"))]
  dat_track$source_track_id = data_track[,which(colnames(data_track) %in% c("index"))]
  
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
      mutate(distance =  distm(c(start_lat, start_lon), c(end_lat, end_lon), fun = distHaversine)) %>% ungroup 
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
    
 }
  # ------------------------ #
  
    
  # ------------------------ #
  # add to NWASC temporary db
  # ------------------------ #
  add = c("Yes, I would like to add this track dataset to the temporary database", 
          "No, I do not wish to add this track dataset to the temporary database") 
  to_add = select.list(add, preselect = NULL, multiple = FALSE, title = NULL)
  if(substr(to_add,1,1)=="Y") {
    # need to have the same column names 
    sqlSave(db, dat_track, tablename = "track", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
  }
  add2 = c("Yes, I would like to add this transect dataset to the temporary database", 
          "No, I do not wish to add this transect dataset to the temporary database") 
  to_add2 = select.list(add2, preselect = NULL, multiple = FALSE, title = NULL)
  if(substr(to_add2,1,1)=="Y") {
    # need to have the same column names 
    sqlSave(db, dat_transect, tablename = "transect", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
  }
  
  
  odbcClose(db) 
  return(dat_track)
}
