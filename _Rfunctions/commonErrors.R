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
  
  # IF THERE IS A TYPO IN SEAT, CHANGE IT TO THE FILE NAME
  seat <- substr(matrix(unlist(strsplit(basename(data$file), "_")), nrow = nrow(data), byrow = TRUE)[, 1], 
                 nchar(matrix(unlist(strsplit(basename(data$file), "_")), nrow = nrow(data), byrow = TRUE)[, 1]) - 1, 
                 nchar(matrix(unlist(strsplit(basename(data$file), "_")), nrow = nrow(data), byrow = TRUE)[, 1]))
  if(any(data$seat=="ff")) {
    data$dataChange[data$seat=="ff"] = paste(data$dataChange[data$seat=="ff"],
                                        "; Changed SEAT from ff",
                                        sep="")
    data$seat[data$seat=="ff"] = seat[data$seat=="ff"]
  }
  
  # IF THERE WAS AN ERROR AUTO-FILLING TRANSECT WHEN IT WAS EMPTY OR A TYPO IN TRANSECT
  if(any(data$transect[grepl("BEG", data$type)] != data$count[grepl("BEG", data$type)] |
         data$transect[grepl("BEG", data$type)] != data$count[grepl("BEG", data$type)]) {
    data$dataChange[data$transect[grepl("BEG", data$type)] != data$count[grepl("BEG", data$type)]:
                    data$transect[grepl("BEG", data$type)] != data$count[grepl("BEG", data$type)]=
                    paste(dataChange[data$transect[grepl("BEG", data$type)] != data$count[grepl("BEG", data$type)]],"; changed transect to match count", sep="")
    data$transect[data$transect[grepl("BEG", data$type)] != data$count[grepl("BEG", data$type)]:
                    data$transect[grepl("BEG", data$type)] != data$count[grepl("BEG", data$type)]=
                    data$count[data$transect[grepl("BEG", data$type)] != data$count[grepl("BEG", data$type)]
  }
    
  return(data)
}

