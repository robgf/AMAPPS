# ---------------------------------------------------------------------------- #
# addBegEnd_Obs.R
# Date Created: 2014-06-27
# Author: JBL
#
# This program adds necessary 'BEGCNT', 'ENDCNT' rows to the observation 
# files. The output is an R data frame.
# ---------------------------------------------------------------------------- #

addBegEnd_obs <- function(data) {
  
  # REMOVE BLANK SPACES IN TYPE FIELD
  data$type <- gsub(" ", "", data$type)
  
  # CHANGE ALL BEGSEG/ENDSEG TO BEGCNT/ENDCNT
  data$type[data$type == "BEGSEG"] <- "BEGCNT"
  data$type[data$type == "ENDSEG"] <- "ENDCNT"
  
  data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  
  # ADD BEGCNT
  if (data$type[1] != "BEGCNT") {
    add <- data[1, ]
    add$type <- "BEGCNT"
    add$index <- add$index - .01
    add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point", 
                            sep = "")
    data <- rbind(data, add)
    data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  }
  
  # ADD ENDCNT
  if (data$type[nrow(data)] != "ENDCNT") {
    add <- data[nrow(data), ]
    add$type <- "ENDCNT"
    add$index <- add$index + .01
    add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point", 
                            sep = "")
    data <- rbind(data, add)
    data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  }
  
  if (nrow(data) > 2) {
    for (j in 2:(nrow(data)-1)) {
      if (data$type[j] == "BEGCNT" & !(data$type[j-1] == "ENDCNT")) {
        add <- data[j-1, ]
        add$type <- "ENDCNT"
        add$index <- add$index + .01
        add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point", 
                                sep = "")
        data <- rbind(data, add)
      }
      if (data$type[j] == "ENDCNT" & !(data$type[j+1] == "BEGCNT")) {
        add <- data[j+1, ]
        add$type <- "BEGCNT"
        add$index <- add$index - .01
        add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point", 
                                sep = "")
        data <- rbind(data, add)
      }
    }
    
    # ADD COCH
    data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
    if (nrow(data) > 2) {
      for (j in 2:nrow(data)) {
        if (data$condition[j] != data$condition[j-1] & !(data$type[j] %in% c("BEGCNT", "COCH"))) {
          add1 <- data[j-1, ]
          add1$condition <- "0"
          add1$type <- "COCH"
          add1$count <- "0"
          add1$offline <- 0
          add1$index <- add1$index + .01
          add1$dataChange <- paste(add1$dataChange, "; added row for change in observation condition", 
                                   sep = "")
          add2 <- data[j, ]
          add2$type <- "COCH"
          add2$count <- add2$condition
          add2$offline <- 0
          add2$index <- add2$index - .01
          add2$dataChange <- paste(add2$dataChange, "; added row for change in observation condition", 
                                   sep = "")
          data <- rbind(data, add1, add2)
        }
      }
    }
  }
  
  # PRINT HOW MANY ADDED BEG/END POINTS
  tmp <- grepl("added row due to missing BEG/END point", data$dataChange)
  message("Added ", sum(tmp), " rows due to missing BEG/END point.")
  
  # PRINT HOW MANY ADDED ROWS FOR CONDITION CODE CHANGES
  tmp <- grepl("added row for change in observation condition", data$dataChange)
  message("Added ", sum(tmp), " rows for change in observation condition.")
  
  data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  return(data)
  
}
