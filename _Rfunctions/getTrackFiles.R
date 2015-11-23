# ---------------------------------------------------------------------------- #
# getTrackFiles.R
# Author: Jeffery Leirness
# Date Created: 2011-09-11
#
# Description: This function appends the pilot and observer track files and 
# creates a header row. The output is an R data frame named Track."crew".
# ---------------------------------------------------------------------------- #

getTrackFiles <- function(data.path) {
  
  track.i <- read.csv(data.path, header = FALSE, as.is = TRUE)
  names(track.i) <- c("lat", "long", "sec")
  
  track.i <- track.i[!duplicated(track.i), ]
  row.names(track.i) <- NULL
  
  track.i$month <- as.numeric(substr(unlist(strsplit(basename(data.path), "_"))[2], 1, 2))
  track.i$day <- as.numeric(substr(unlist(strsplit(basename(data.path), "_"))[2], 3, 4))
  track.i$year <- as.numeric(substr(unlist(strsplit(basename(data.path), "_"))[2], 5, 8))
  track.i$seat <- substr(unlist(strsplit(basename(data.path), "_"))[1], 
                         nchar(unlist(strsplit(basename(data.path), "_"))[1]) - 1, 
                         nchar(unlist(strsplit(basename(data.path), "_"))[1]))
  
  track.i$file <- data.path
  
  track.i$index <- as.numeric(row.names(track.i))
  track.i <- track.i[order(track.i$sec), ]
  row.names(track.i) <- NULL
  if (sum(row.names(track.i) != track.i$index) > 0) 
    warning("Flight computer time error: ", data.path, "\n")
  
  return(track.i)
  
}
