commonErrors <- function(data) {
    
  # CREATE COLUMNS TO TRACK DATA CHANGES & DOCUMENT DATA ERRORS
  if (is.null(data$dataChange)) {
    data$dataChange <- ""
    data$dataError <- "" }
  
  # REMOVE BLANK SPACES IN TYPE FIELD
  data$type <- gsub(" ", "", data$type)
  
  # CHANGE ALL BEGSEG/ENDSEG TO BEGCNT/ENDCNT
  data$type[data$type == "BEGSEG"] <- "BEGCNT"
  data$type[data$type == "ENDSEG"] <- "ENDCNT"
  
  data$type[data$type == "TRAWL" | data$type == "TRAW"] = "BOTD"
  data$type[data$type == "TOWER"] = "TOWR"
  
  return(data)
}

