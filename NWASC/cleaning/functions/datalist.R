# -------------------------------- #
# create metadata for NEW dataset (not already in the table)
# this will require looking at whatever report was submitted with the data
#
# created by Kaycee Coleman, July 2016
# -------------------------------- #

datalist <- function(data, dataset_name, newParent) {
  library(RODBC)
  db <- odbcConnect("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb"))
  datalist <- sqlFetch(db, "dataset")
  odbcClose(db)
  
  dataset_id = max(datalist$dataset_id)+1
  source_dataset_id = dataset_name
  possible_parents = c("AMAPPS","MassCEC","DOEBRIBoat","EcoMon","HerringAcoustic")
  parent_project = ifelse(missing(newParent),select.list(possible_parents, preselect = NULL, multiple = FALSE, title = NULL),newParent)
  survey_type = c("Aerial = a", "Boat = b", "Camera = c", "Area-wide ground survey = g", "Fixed point ground survey = f")
  dataset_type = c("Original transect = ot", "Derived effort = de", "Original general observation = og")
  share_level = c("No data = 0", "Not shared = 1", "Limited use = 2", "Limited use (AKN+) = 3", 
                  "Limited use (AKN++) = 4", "Full data available = 5", "not entered = 9", "In process = 99") 
  survey_method = c("Continuous time strip = cts", "Discrete time strip = dts", "Discrete time horizon = dth",
                    "General observation = go", "bycatch = byc", "Christmas Bird Count = cbc", "targeted species survey = tss")
  

  survey_type_cd = sapply(strsplit(select.list(survey_type, preselect = NULL, multiple = FALSE, title = NULL), "= "),tail,1)
  dataset_type_cd = sapply(strsplit(select.list(dataset_type, preselect = NULL, multiple = FALSE, title = NULL), "= "),tail,1)
  share_level = sapply(strsplit(select.list(share_level, preselect = NULL, multiple = FALSE, title = NULL), "= "),tail,1)
  survey_method_cd = sapply(strsplit(select.list(survey_method, preselect = NULL, multiple = FALSE, title = NULL), "= "),tail,1)
  start_date = min(data$start_dt)
  end_date = max(data$end_dt)
  number_of_records = dim(data)[1]
  out = cbind(dataset_id, source_dataset_id, survey_type_cd, dataset_type_cd, share_level, survey_method_cd, start_date, end_date, number_of_records)
  return(out)
}

