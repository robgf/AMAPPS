# -------------------------------- #
# create metadata
# this will require looking at whatever report was submitted with the data
#
# created by Kaycee Coleman, July 2016
# -------------------------------- #

datalist <- funtion(data) {
  #a$dataset_id = "160" ### CHECK ### That this number is not used
  a$survey_type = switch(menu(c("Aerial", "Boat", "Camera", "Area-wide ground survey", "Fixed point ground survey")), 
                  "a", "b", "c", "g", "f") 
  a$survey_method_cd = switch(menu(c("Continuous time strip", "Discrete time strip", "Discrete time horizon", 
                       "General observation", "bycatch", "Christmas Bird Count", "targeted species survey")), 
                       "cts", "dts", "dth",	"go", "byc", "cbc", "tss") 
  a$dataset_type_cd = switch(menu(c("Original transect", "Derived effort", "Original general observation")), 
                      "ot", "de", "og") 
  a$share_levl = switch(menu(c("No data", "Not shared", "Limited use", "Limited use (AKN+)", "Limited use (AKN++)",
                 "Full data available", "not entered", "In process")), 
                 "0", "1", "2","3", "4", "5","9","99") 
  #a$source_dataset_id = "NOAA/NMFS_NEFSCBoat2015"
  #a$title = paste(dataset_list$source_dataset_id,"Georges Bank", sep = "; ")
  a$startdate = min(data$start_dt)
  a$enddate = max(data$end_dt)
  #a$sponsors = "NOAA" 
  #a$subject = "seabird and marine mammals survey"
  #a$keywords = paste("seabirds", "NOAA","NMFS","Georges Bank", sep = ", ")
  #a$resp_party = "63" 
  #a$coordsys = "Lat/Long"
  a$numrecords = dim(data)[1]
  return(a)
}
