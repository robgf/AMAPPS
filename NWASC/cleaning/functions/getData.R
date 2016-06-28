# ------------------------------------------ #
# Written off of getObsFiles to be more generic
# This function pulls all the data from separate 
# folders and aggregates it together
#
# written by Kaycee Coleman
# June 2016
# ------------------------------------------ #

getData <- function(data.path) {
  
  # READ IN OBSERVATION FILES #
  ncols <- max(count.fields(data.path, sep = ",", quote = NULL))
  obs.i <- read.csv(data.path, header = TRUE,  
                  colClasses = "character")
  if(ncols==3 & dirname(data.path)=="\\\\IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received/MassCEC/MCEC_Year2_Seabirds_9132013/MCEC_Year2_Seabirds_9132013" |
       dirname(data.path)=="\\\\IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received/MassCEC/year3") {colnames(obs.i)=c("lat","lon","sec")}
  
  # CREATE DISTANCE COLUMN IF THERE ISNT ONE
  if(all(!names(obs.i) %in% "distance")) {obs.i$distance=""}
  # FIX COLUMN NAMES
  if(any(names(obs.i) %in% "number_")){names(obs.i)[names(obs.i) == "number_"] = "number"}
  if(any(names(obs.i) %in% "time_")){names(obs.i)[names(obs.i) == "time_"] = "time"}
  if(any(names(obs.i) %in% "OBJECTID")){names(obs.i)[names(obs.i) == "OBJECTID"] = "objectid"}
  if(any(names(obs.i) %in% c("dist","distance.1"))){names(obs.i)[names(obs.i) %in% c("dist","distance.1")] = "distance"}
  if(any(names(obs.i) %in% "year_")){names(obs.i)[names(obs.i) == "year_"] = "year"}
  if(any(names(obs.i) %in% "month_")){names(obs.i)[names(obs.i) == "month_"] = "month"}
  if(any(names(obs.i) %in% "day_")){names(obs.i)[names(obs.i) == "day_"] = "day"}
  if(any(names(obs.i) %in% "null_")){names(obs.i)[names(obs.i) == "null_"] = "null"}
  if(any(names(obs.i) %in% "position_")){names(obs.i)[names(obs.i) == "position_"] = "position"}
  if(any(names(obs.i) %in% "trans")){names(obs.i)[names(obs.i) == "trans"] = "transect"}
  if(any(names(obs.i) %in% "conditons")){names(obs.i)[names(obs.i) == "conditons"] = "conditions"}
  if(any(names(obs.i) %in% c("comment","comment_"))){names(obs.i)[names(obs.i) %in% c("comment","comment_")] = "comments"}
  if(any(names(obs.i) %in% "beahvior")){names(obs.i)[names(obs.i) == "beahvior"] = "behavior"}
  
  # CREATE FILE COLUMN
  obs.i$file <- data.path
  
  return(obs.i)
}
