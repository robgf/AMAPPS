# -------------------------------- #
# create metadata for NEW dataset (not already in the table)
# this will require looking at whatever report was submitted with the data
#
# created by Kaycee Coleman, July 2016
# -------------------------------- #

datalist <- function(data, dataset_name, newParent) {
  # load dataset descriptions
  library(RODBC)
  db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  datasets <- sqlFetch(db, "dataset")
  
  # fill table
  dataset_id = max(datasets$dataset_id)+1
  source_dataset_id = dataset_name
  possible_parents = c("","AMAPPS","DOEBRIBoat","EcoMon","HerringAcoustic","MassCEC", "SEFSC", "RISAMP", "WHOI")
  parent_project = ifelse(missing(newParent),select.list(possible_parents, preselect = NULL, multiple = FALSE, title = NULL),newParent)
  survey_type = c("Aerial = a", "Boat = b", "Camera = c", "Area-wide ground survey = g", "Fixed point ground survey = f")
  dataset_type = c("Original transect = ot", "Derived effort = de", "Original general observation = og")
  share_level = c("No data = 0", "Not shared = 1", "Limited use = 2", "Limited use (AKN+) = 3", 
                  "Limited use (AKN++) = 4", "Full data available = 5", "not entered = 9", "In process = 99") 
  survey_method = c("Continuous time strip = cts", "Discrete time strip = dts", "Discrete time horizon = dth",
                    "General observation = go", "bycatch = byc", "Christmas Bird Count = cbc", "targeted species survey = tss")
  
  # if there is only one date column
  if(any(!c("start_dt","end_dt") %in% colnames(data))) {
    ind = grep("date",colnames(obs))
    data$start_dt = as.Date(data[,ind])
    data$end_dt = as.Date(data[,ind])
  }
  
  out = as.data.frame(matrix(ncol=24, nrow=1, data=NA))
  colnames(out) = colnames(datasets)
  out$dataset_id = dataset_id
  out$survey_type_cd = sapply(strsplit(select.list(survey_type, preselect = NULL, multiple = FALSE, title = NULL), "= "),tail,1)
  out$dataset_type_cd = sapply(strsplit(select.list(dataset_type, preselect = NULL, multiple = FALSE, title = NULL), "= "),tail,1)
  out$share_level = sapply(strsplit(select.list(share_level, preselect = NULL, multiple = FALSE, title = NULL), "= "),tail,1)
  out$survey_method_cd = sapply(strsplit(select.list(survey_method, preselect = NULL, multiple = FALSE, title = NULL), "= "),tail,1)
  out$start_date = min(data$start_dt)
  out$end_date = max(data$end_dt)
  out$number_of_records = dim(data)[1]
  out$noaa_priority = sapply(strsplit(select.list(c("NOAA Priority level = 1","NOAA Priority level = 2", "NOAA Priority level = 3")), "= "),tail,1) 
  out$who_created = sapply(strsplit(select.list(c("Created by Andrew G. = 1","Created by Allison S. = 2", "Created by Kaycee C. = 3")), "= "),tail,1)           
  out$date_created = Sys.Date()
  
  # need to be filled in manually, but need the column names in order to use sqlSave
  out$survey_width_m = ""   
  out$admin_notes = ""            
  out$import_notes = ""            
  out$usgs_priority = ""            
  out$action_required = ""         
  out$action_taken = ""          
  out$discrete_time_unit = ""      
  out$noaa_import_priority = ""    
  out$funded = ""                 
  out$at_usgs = ""                 
  out$in_db = ""  
  
  # export
  out$dataset_id = as.numeric(out$dataset_id)
  out$start_date = as.character(out$start_date)
  out$end_date = as.character(out$end_date)
  out = as.data.frame(out)
  
  # add to NWASC temporary db
  add = c("Yes, I would like to add this dataset description to the temporary database", 
          "No, I do not wish to add this dataset description to the temporary database") 
  to_add = select.list(add, preselect = NULL, multiple = FALSE, title = NULL)
  if(substr(to_add,1,1)=="Y") {
    # need to have the same column names 
    sqlSave(db, out, tablename = "dataset", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=TRUE)
    print("Please fill enter notes and other pertinent information directly into the access table")
  }
  odbcClose(db)
  return(out)
}
