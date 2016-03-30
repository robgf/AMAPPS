# ------------------------------------------------------------------------- #
# ObsTrackFinalOutput.R
# Date Created: 2011-11-04
# Author: JBL
# edited 2/2016 by Kaycee Coleman
#
# This program outputs a final version of the combined observation/track 
# files ("survlab"_TrackFileEdit_Final.csv) and an updated crew summary .csv 
# file ("survlab"_CrewSummary.csv).
# ------------------------------------------------------------------------- #

obsTrackFinalOutput = function(data, survlab = "", path) {
  

  data = subset(data, select = c(Transect, Replicate, Crew, Seat, Obs, Year, Month, Day, Sec, Lat, 
                                 Long, GpsError, Species, FlockSize, Condition, Band, FlightStatus, 
                                 Comment, file, dataChange, index, ID))
  #comment, file, dataChange, MissingTrackFile, index, ID))
  data = data[order(data$ID), ]
  
  # MAKE SURE THERE ARE BOTH "LF" AND "RF" OBSERVATIONS FOR EACH TRANSECT
  tmp = data$Transect >= 100000 & data$Transect < 999999 & !grepl("delete row", data$dataChange)
  data$key = paste(data$Crew, data$Transect, data$Year, data$Month, data$Day, sep = "-")
  allkeys = sort(unique(data$key[tmp]))
  obs.missing = NULL
  for (i in seq(along = allkeys)) {
    if (nrow(data[data$key == allkeys[i] & data$Seat == "lf",]) == 0) { 
      if (is.null(obs.missing)) obs.missing = paste(allkeys[i], "lf", sep = "-") else 
        obs.missing = rbind(obs.missing, paste(allkeys[i], "lf", sep = "-"))
    }
    if (nrow(data[data$key == allkeys[i] & data$Seat == "rf",]) == 0) { 
      if (is.null(obs.missing)) obs.missing = paste(allkeys[i], "rf", sep = "-") else 
        obs.missing = rbind(obs.missing, paste(allkeys[i], "rf", sep = "-"))
    }
  }
  data$key = NULL
  
  # SAVE FILE LISTING TRANSECTS WITH MISSING OBSERVATIONS #
  obs.missing = unique(obs.missing)
  if (!is.null(obs.missing)) {
    obs.missing = matrix(unlist(strsplit(obs.missing, "-")), 
                         nrow = length(obs.missing), byrow = TRUE)
    obs.missing = paste("Missing '", toupper(obs.missing[, 6]), 
                        "' observations for transect ", obs.missing[, 2], 
                        " (", obs.missing[, 1], ": ", obs.missing[, 4], 
                        "/", obs.missing[, 5], "/", obs.missing[, 3], ")",
                        sep = "")
    cat("Missing observation files: see ", survlab, "_MissingObsFiles.txt", sep = "")
  } else cat("No missing observation files.\n\n")
  write.table(obs.missing, file.path(path, paste(survlab, "_MissingObsFiles.txt", sep = "_")), 
              quote = FALSE, row.names = FALSE, col.names = FALSE)
  
  # CREATE CREW SUMMARY FILE
  crewlist = subset(data, select = c(Transect, Replicate, Year:Day, Crew, 
                                     Seat, Obs))
  crewlist = crewlist[!duplicated(crewlist) & !is.na(crewlist$Replicate), ]
  crewlist = reshape(crewlist, timevar = "Seat", 
                     idvar = c("Transect", "Replicate", "Year", "Month", "Day", "Crew"), 
                     direction = "wide")
  names(crewlist) = gsub("Obs.", "Obs_", names(crewlist))
  write.csv(crewlist, file.path(path, paste(survlab, "_CrewSummary.csv", sep = "_")), 
            row.names = FALSE, na = "")
  
  # SAVE FILE LISTING TRANSECTS WITH MISSING TRACK FILES #
  track.missing = subset(data, MissingTrackFile == 1, 
                         select = c(Transect, Year, Month, Day, Crew, Seat))
  track.missing = track.missing[!duplicated(track.missing), ]
  track.missing = track.missing[order(track.missing$Crew, 
                                      track.missing$Year, 
                                      track.missing$Month, 
                                      track.missing$Day, 
                                      track.missing$Transect), ]
  track.missing = paste("Missing '", toupper(track.missing$Seat), 
                        "' track file for transect ", track.missing$Transect, 
                        " (", track.missing$Crew, ": ", track.missing$Month, 
                        "/", track.missing$Day, "/", track.missing$Year, 
                        ")",  sep = "")
  write.table(track.missing, file.path(path, paste(survlab, "_MissingTrackFiles.txt", sep = "_")), 
              quote = FALSE, row.names = FALSE, col.names = FALSE)
  
}
