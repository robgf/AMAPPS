# ---------------------------------------------------------------------------- #
# getObsFiles.R
# Author: Jeffery Leirness
# Date Created: 2011-09-16
#
# Description: This fuction appends the pilot and observer observation files 
# and creates a header row. The output is an R data frame named Obs."crew".
#
# This function references the following files and/or programs: 
#   H:/Sea Duck Survey_JL/R functions/CombineByName.R
# ---------------------------------------------------------------------------- #

getObsFiles <- function(data.path) {
  
  # READ IN OBSERVATION FILES #
  nrows <- length(count.fields(data.path, sep = ",", quote = NULL))
  ncols <- max(count.fields(data.path, sep = ",", quote = NULL))
  obs.i <- read.csv(data.path, header = FALSE, col.names = paste("col", seq_len(ncols), sep = ""), 
                    colClasses = "character")
  names(obs.i)[1:15] <- c("year", "month", "day", "seat", "obs", "transect", "condition", 
                          "offline", "WAVfile", "lat", "long", "sec", "GPSerror", "type", 
                          "count")
  
  # CREATE COMMENT COLUMN TO CAPTURE COMMENTS WITHIN OBSERVATION FILE
  if (ncols <= 15) {
    obs.i$comment <- ""
  } else {
    obs.i$comment <- apply(obs.i[, 16:ncols, drop = FALSE], 1, function(x) paste(x, collapse = ","))
    obs.i$comment <- gsub("^\\s+|\\s+$", "", obs.i$comment)  # remove leading and trailing spaces
    obs.i$comment <- gsub("^,|,$", "", obs.i$comment)  # remove leading and trailing commas
    obs.i <- obs.i[, -c(16:ncols)]
  }
  
  # MAKE CERTAIN COLUMNS LOWER CASE
  tmp <- c("seat", "obs")
  obs.i[, tmp] <- apply(obs.i[, tmp, drop = FALSE], 2, tolower)
  
  # MAKE CERTAIN COLUMNS UPPER CASE
  tmp <- c("type")
  obs.i[, tmp] <- apply(obs.i[, tmp, drop = FALSE], 2, toupper)
  
  # REMOVE SPACES IN CERTAIN COLUMNS
  tmp <- c("year", "month", "day", "seat", "obs", "transect", "condition", "offline", "count")
  obs.i[, tmp] <- apply(obs.i[, tmp, drop = FALSE], 2, function(x) gsub("\\s", "", x))
  
  # CODE CERTAIN COLUMNS AS NUMERIC #
  tmp <- c("lat", "long", "sec", "GPSerror")
  obs.i[, tmp] <- apply(obs.i[, tmp, drop = FALSE], 2, as.numeric)
  
  # FILE SHOULD ONLY CONTAIN DATA FROM ONE DAY
  if (any(length(unique(obs.i$year)) > 1, length(unique(obs.i$month)) > 1, 
          length(unique(obs.i$day)) > 1)) {
    stop("File contains observations from more than one day: ", data.path, "\n")
  }
  
  # CREATE INDEX COLUMN
  obs.i$index <- as.numeric(row.names(obs.i))
  
  # FILE SHOULD BE ORDERED BY SECONDS VALUE
  obs.i <- obs.i[order(obs.i$sec, obs.i$index), ]
  row.names(obs.i) <- NULL
  if (sum(row.names(obs.i) != obs.i$index) > 0) {
    stop("Observations not in sequential order: ", data.path, "\n")
  }
  
  # CREATE FILE COLUMN
  obs.i$file <- data.path
  
  return(obs.i)
  
}
