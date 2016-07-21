# ------------------------------- #
# To format track and transect survey effort for temporary database
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
  unique_transect_days = sort(unique(paste(data$transect,data$date,sep="_")))
  dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=length(unique_transect_days), data=NA))
  colnames(dat_transect) = colnames(transects.in.db)
  
  # group by transect and day
  # find min/max times for each day/transect
  
  # reformat, create, and/or rename
  if(!missing(data_transect)) {
    dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
    colnames(dat_transect) = colnames(transects.in.db)
    
    # move those variables over that have the same name
    same_nm = colnames(data[colnames(data_transect) %in% colnames(dat_transect)])
    dat[,colnames(dat) %in% same_nm] = data[,colnames(data) %in% same_nm]
    
    dat_transect$dataset_id = id
    dat_transect$transect_id = c((max(dat_design$transect_id)+1):(max(dat_design$transect_id)+dim(design)[1]))
    dat_transect$temp_start_lon = data_transect[,which(colnames(data_transect) %in% c("start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]
    dat_transect$temp_start_lat = data_transect[,which(colnames(data_transect) %in% c("start_lat", "begin_lat","start_latitude", "begin_latitude"))]
    dat_transect$temp_stop_lon = data_transect[,which(colnames(data_transect) %in% c("end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))]
    dat_transect$temp_stop_lat = data_transect[,which(colnames(data_transect) %in% c("end_lat", "stop_lat","end_latitude", "stop_latitude"))]
    dat_transect$start_dt = format(as.Date(data_transect$date),'%m/%d/%Y')
    dat_transect$end_dt = format(as.Date(data_transect$date),'%m/%d/%Y')

  }
  # ------------------------ #
  
  
  # ------------------------ #
  # track
  # ------------------------ #
  unique_transect_piece_days = sort(unique(paste(data$transect,data$date,sep="_")))
  dat_track = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=length(unique_transect_piece_days), data=NA))
  colnames(dat_track) = colnames(track.in.db)
  
  # group by transect and day
  # find min/max times for each day/transect
  
  # if its is estimated data go straight to 
  # reformat, create, and/or rename
  
  # move those variables over that have the same name
  same_nm = colnames(data[colnames(data_transect) %in% colnames(dat)])
  dat[,colnames(dat) %in% same_nm] = data[,colnames(data) %in% same_nm]
  
  dat_track$dataset_id = id
  dat_track$temp_start_lon = data[,which(colnames(data_transect) %in% c("start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]
  dat_track$temp_start_lat = data[,which(colnames(data_transect) %in% c("start_lat", "begin_lat","start_latitude", "begin_latitude"))]
  dat_track$temp_stop_lon = data[,which(colnames(data_transect) %in% c("end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))]
  dat_track$temp_stop_lat = data[,which(colnames(data_transect) %in% c("end_lat", "stop_lat","end_latitude", "stop_latitude"))]
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
