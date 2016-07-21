# ------------------------------- #
# To reformat data for entry into the temporary database
# ------------------------------- #

forNWASC_import_obstbl <- function(data, id) {
  # load dataset descriptions
  library(RODBC)
  db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  obs.in.db = sqlFetch(db, "observation")
  transects.in.db = sqlFetch(db, "transect")
  dat = as.data.frame(matrix(ncol=dim(obs.in.db)[2], nrow=dim(data)[1], data=NA))
  colnames(dat) = colnames(obs.in.db)
  
  # move those variables over that have the same name
  same_nm = colnames(data[colnames(data) %in% colnames(dat)])
  dat[,colnames(dat) %in% same_nm] = data[,colnames(data) %in% same_nm]
  
  # reformat, create, and/or rename
  dat$spp_cd = data$type
  dat$dataset_id = id
  dat$observation_id = c((max(dat$observation_id)+1):(max(dat$observation_id)+dim(data)[1]))
  if (any(colnames(data) %in% c("index"))) {
    dat$source_obs_id = data$index
    } else dat$source_obs_id = 1:dim(data)[1]
  if (any(colnames(data) %in% c("offline"))) {
    dat$obs_count_intrans_nb[data$offline==0] = data$count[data$offline==0]
    dat$obs_count_general_nb[data$offline==1] = data$count[data$offline==1]
  } else dat$obs_count_intrans_nb = data$count
  if(any(colnames(data) %in% c("transect"))) {dat$source_transect_id = data$transect}
  if(length(dat$source_transect_id)==0 & any(colnames(data) %in% c("offline")) & any(!colnames(data) %in% c("transect"))) {
    dat$source_transect_id[data$offline==0] = 1
  }
  if(any(colnames(data) %in% c("date","start_date"))) {
    dat$obs_dt = format(as.Date(data[,which(colnames(data) %in% c("date","start_date"))]),'%m/%d/%Y') # month/ day/ year
  }
  if(any(!colnames(data) %in% c("date")) & all(colnames(data) %in% c("year","month","day"))) {
    dat$obs_dt = paste(data$month,data$day,data$year,sep="/")
  }
  #dat$obs_start_tm[!is.na(data$time)] = format(data$time[!is.na(data$time)], "%I:%M:%S %p") # hours (1-2): min: sec space am/pm
  if(any(colnames(data) %in% c("behavior"))) {dat$behavior_tx = data$behavior}
  if(any(colnames(data) %in% c("age"))) {dat$animal_age_tx = data$age}
  if(any(colnames(data) %in% c("flight_hei"))) {dat$flight_height_tx = data$flight_hei}
  if(any(colnames(data) %in% c("distance"))) {dat$distance_to_animal_tx = data$distance}
  if(any(colnames(data) %in% c("flight_dir"))) {dat$travel_direction_tx = data$flight_dir}
  if(any(colnames(data) %in% c("lon", "long", "longitude"))) {
    dat$temp_lon = data[,which(colnames(data) %in% c("lon", "long", "longitude"))]
  } 
  if(any(colnames(data) %in% c("lat", "latitude"))) {
    dat$temp_lat = data[,which(colnames(data) %in% c("lat", "latitude"))]
  }
  if(any(colnames(data) %in% c("comments", "dataChange"))) {
    dat$comments_tx = data[,which(colnames(data) %in% c("comments", "dataChange"))]
  }
    
  # add to NWASC temporary db
  add = c("Yes, I would like to add this observation dataset to the temporary database", 
          "No, I do not wish to add this observation dataset to the temporary database") 
  to_add = select.list(add, preselect = NULL, multiple = FALSE, title = NULL)
  if(substr(to_add,1,1)=="Y") {
    # need to have the same column names 
    sqlSave(db, dat, tablename = "observation", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
  }
  
  odbcClose(db) 
  return(dat)
}
