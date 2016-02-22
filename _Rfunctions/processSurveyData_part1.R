# ---------------------------------------------------------------------------- #
# processSurveyData_part1.R
# Author: Jeffery Leirness
# Date Created: 2015-03-20
# edited by: Kaycee Coleman, Feb. 2016
#
# Description: This program reads in the pilot and observer raw observation 
# files and creates a header row. It then checks for general errors & 
# BEGSEG/ENDSEG errors and outputs a .csv file documenting these errors 
# (ObsFiles_Errors.csv). It then fixes the observation file errors, reads in 
# the pilot and observer raw track files and creates a header row, compares 
# the track files to the observation files, and outputs the edited track 
# files containing only the survey segments.
# ---------------------------------------------------------------------------- #

processSurveyData_part1 <- function(dir.in, dir.out, errfix.file, py.exe) {
  
    
  # SET TIMER
  ptm <- proc.time()
  
  
  # STORE CREW FOLDER AND FILENAME REFERENCES
  crews <- list.files(dir.in, pattern = "Crew")
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 1: READ IN RAW OBSERVATION DATA
  # ---------------------------------------------------------------------------- #
  # CHECK IF THERE ARE RAW DATA FILES TO SPLIT/FIX SO JEFF'S SCRIPTS RUN SMOOTHER 
  if (length(list.files(dir.out, pattern = "FixFile")) == 1) {
    source(paste(dir.out, list.files(dir.out, pattern = "FixFile"), sep = "/"))
  }
  #
  obsfiles <- list.files(dir.in, pattern = "_birds", recursive = TRUE, full.names = TRUE) #changed from "_birds.txt"
  obs <- lapply(setNames(obsfiles, basename(obsfiles)), getObsFiles)
  obs <- lapply(obs, function(x) data.frame(cbind(x, "crew" = as.character(unlist(strsplit(basename(dirname(x$file)), "_"))[1]))))
  
  # SHOW WHICH OBSERVATION FILES ARE AVAILABLE
  out.obsfiles <- gsub(dir.in, "", obsfiles)
  
  # CREATE BAND AND BEHAVIOR COLUMNS
  obs <- lapply(obs, createBandBehavior)
  
  # ORGANIZE OBSERVATION DATA INTO A DATA FRAME; CREATE CREW COLUMN
  obs <- do.call(rbind.data.frame, obs)
  obs$crew <- as.character(obs$crew)
  row.names(obs) <- NULL
  
  # QUICK LOOK AT NUMBER OF RECORDS AVAILABLE
  out.obstab1 <- table(obs$crew, obs$seat)
  out.obstab2 <- table(obs$obs, obs$seat)
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 2: READ IN RAW TRACK DATA
  # ---------------------------------------------------------------------------- #
  trackfiles <- list.files(dir.in, pattern = "_track.txt", recursive = TRUE, 
                           full.names = TRUE)
  track <- lapply(setNames(trackfiles, basename(trackfiles)), getTrackFiles)
  track <- lapply(track, function(x) data.frame(cbind(x, "crew" = unlist(strsplit(basename(dirname(dirname(x$file))), "_"))[1])))
  
  # SHOW WHICH TRACK FILES ARE AVAILABLE
  out.trackfiles <- gsub(dir.in, "", trackfiles)
  
  # ORGANIZE TRACK DATA INTO A DATA FRAME; CREATE CREW COLUMN
  track <- do.call(rbind.data.frame, track)
  track$crew <- as.character(track$crew)
  
  # QUICK LOOK AT NUMBER OF RECORDS AVAILABLE
  out.tracktab <- table(track$crew, track$seat)
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 3: OUTPUT COAST SURVEY DATA; FIX OBSERVATION FILE ERRORS
  # ---------------------------------------------------------------------------- #
  obs <- commonErrors(obs)
  obs <- fixMixed(obs) # pull apart MIXD obs
  
  if (!file.exists(errfix.file)) {
    warning("Error fix R file is missing and will not be sourced.")
  } else source(errfix.file, local = TRUE)
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 4: CHECK OBSERVATION FILES FOR ERRORS, DOCUMENT IN .CSV FILE
  # ---------------------------------------------------------------------------- #
  obs <- errorCheckObsFiles(obs, dir.out, error.flag = TRUE)
  
  # STOP IF ERRORS STILL EXIST IN OBSERVATION FILES
  if (obs[["errorStatus"]] == 1) {
    stop("Errors still exist in observation files. These must be fixed before continuing.")
  } else obs <- obs[["data"]]
  
  # SUMMARIZE CERTAIN DATA COLUMNS
  tmp <- !is.na(obs$count) & obs$offline == 0 & 
    !(obs$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH"))
  if (!is.null(obs$band)) {
    out.obssum <- summary(obs[tmp, c("lat", "long", "sec", "GPSerror", "count", "band")])
  } else {
    out.obssum <- summary(obs[tmp, c("lat", "long", "sec", "GPSerror", "count")])
  }
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 5: RE-ORGANIZE OBSERVATION AND TRACK DATA INTO SEPARATE LISTS CONTAINING 
  #         UNIQUE DATA FRAMES - ONE DATA FRAME FOR EACH COMBINATION OF OBSERVER 
  #         AND DAY
  # ---------------------------------------------------------------------------- #
  # RE-ORGANIZE OBSERVATION DATA
  obs$key <- paste(obs$crew, obs$seat, obs$year, obs$month, obs$day, sep = "_")
  obs <- split(obs, list(obs$key))
  
  # RE-ORGANIZE TRACK DATA
  track$key <- paste(track$crew, track$seat, track$year, track$month, track$day, sep = "_")
  track <- split(track, list(track$key))
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 6: FIX MISSING SECONDS VALUES IN OBSERVATION FILES
  # ---------------------------------------------------------------------------- #
  obs <- lapply(setNames(names(obs), names(obs)), function(x) fixSeconds(obs[[x]], track[[x]]))
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 7: ADD BEG/END POINTS WHERE NEEDED IN OBSERVATION FILES
  # ---------------------------------------------------------------------------- #
  obs <- suppressMessages(lapply(obs, addBegEnd_obs))
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 8: COMBINE OBSERVATION FILES & TRACK FILES, OUTPUT EDITED
  #         TRACK FILES CONTAINING ONLY SURVEY SEGMENTS (WITH OBSERVATIONS)
  # ---------------------------------------------------------------------------- #
  obstrack <- lapply(setNames(names(obs), names(obs)), function(x) {
    alt <- names(track)[sapply(strsplit(names(track), "_"), 
                               function(y) all(y[-2] == strsplit(x, "_")[[1]][-2]))]
    combineObsTrack(obs[[x]], track[[x]], track[[alt[alt != x][1]]])
  })
  obstrack <- do.call(rbind.data.frame, obstrack)
  obstrack <- obstrack[order(obstrack$crew, obstrack$seat, obstrack$year, obstrack$month, 
                             obstrack$day, obstrack$sec, obstrack$index), ]
  row.names(obstrack) <- NULL
  obstrack$ID <- as.numeric(row.names(obstrack))
  
  if (file.exists(paste(dir.out,"postObstrackEdits.R",sep="/"))) {
    source(paste(dir.out,"postObstrackEdits.R",sep="/"))}
  
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 9: RELABEL TRANSECTS
  # ---------------------------------------------------------------------------- #
  #trans <- readOGR(dsn = file.path(paste(dbpath, "GIS", sep="")), layer = "tempPointsLineClip") # -1, +1 method
  trans <- readOGR(dsn = file.path(paste(dbpath, "GIS", sep="")), layer = "amapps_transects_new2014")
  if (proj4string(trans) != "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") {
    trans <- spTransform(trans, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  }
  #if (all(obstrack$year == 2010 & obstrack$month == 8)) {
  #  tmp <- (trans$transLat <= 2821 & trans$transLat %% 5 == 1) | 
  #    (trans$transLat > 2821 & trans$transLat %% 5 != 1)
  #  trans <- trans[!tmp, ]
  #} else if ((all(obstrack$year %in% 2011:2012) & any(obstrack$month == 2)) | 
  #             (all(obstrack$year == 2012 & obstrack$month == 3 & obstrack$day %in% 6:7))) {
  #  tmp <- trans$transLat %% 5 == 0
  #  trans <- trans[!tmp, ]
  #} else {
  #  tmp <- trans$transLat %% 5 != 1
  #  trans <- trans[!tmp, ]
  #}
  
  
  ## to cut down on time, define which transect the point is on
  obstrack$transect = na.locf(obstrack$transect)
  
  # CALCULATE DISTANCE FROM EACH POINT TO MASTER TRANSECT FILE
  # THIS PROCESS EMPLOYS PARALLEL COMPUTING TO DECREASE PROCESSING TIME
  
  strt<-Sys.time(); 
  cl <- makeCluster(as.numeric(detectCores()))
  clusterExport(cl, "trans", envir = environment())
  invisible(clusterEvalQ(cl, c(library(geosphere),
                               subFunc <- function(lat, lon, code) {
                                 a = NA
                                 b = NA
                                 if (any(trans$latidext == code)) {
                                   a = which(trans$latidext == code)
                                   subTrans = trans[a,]} else {
                                     b = which(trans$latidext == paste(substr(code,1,5),"0", sep="") | 
                                                 trans$latidext == paste(substr(code,1,5),"1", sep="") |
                                                 trans$latidext == paste(substr(code,1,5),"2", sep="") |
                                                 trans$latidext == paste(as.numeric(substr(code,1,4))+5, "00", sep="") |
                                                 trans$latidext == paste(as.numeric(substr(code,1,4))-5, "00", sep="") |
                                                 trans$latidext == paste(as.numeric(substr(code,1,4))+5, "01", sep="") |
                                                 trans$latidext == paste(as.numeric(substr(code,1,4))-5, "01", sep="") |
                                                 trans$latidext == paste(as.numeric(substr(code,1,4))+5, "02", sep="") |
                                                 trans$latidext == paste(as.numeric(substr(code,1,4))-5, "02", sep=""))
                                     subTrans = trans[b,]}
                                 ab = dist2Line(p = cbind(as.numeric(lon),as.numeric(lat)), 
                                                line = subTrans, distfun = distVincentyEllipsoid)
                                 out = c(ab, ifelse(any(is.na(b)),a,b[ab[4]]))
                                 return(out)
                               })))
    
  d <- parRapply(cl, obstrack, function(x) subFunc(x[1],x[2],x[13]))#x[27]))
  stopCluster(cl)
  d <- matrix(d, ncol = 5, byrow = TRUE) # distance(m), long, lat, code
  print(Sys.time()-strt)
  
  # RELABEL TRANSECT-S ACCORDING TO MASTER TRANSECT FILE
  # TRANSECTS GREATER THAN 2 KM FROM MASTER TRANSECT FILE ARE FLAGGED
  obstrack$transLat <- trans$latid[d[,5]] 
  obstrack$transLong <- trans$label[d[,5]]
  obstrack$flag1 <- ifelse(d[, 1] > 2000, 1, 0)
  rm(d)
                                 
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 10: FLAG POINTS FOR FURTHER INVESTIGATION
  # ---------------------------------------------------------------------------- #
  obstrack <- obstrack[order(obstrack$ID), ]
  obstrack$key <- paste(obstrack$crew, obstrack$seat, obstrack$year, obstrack$month, 
                        obstrack$day, obstrack$transLat, obstrack$transLong, sep = "_")
  allkeys <- unique(obstrack$key[as.numeric(obstrack$transLat) > 0])
  obstrack$bearing <- NA
  obstrack$sbearing <- NA
  obstrack$flag2 <- 0
  for (i in seq(along = allkeys)) {
    tmp <- obstrack$key == allkeys[i]
    obs.i <- obstrack[tmp, ]
    if (nrow(obs.i) > 1 & min(obs.i$sec) < max(obs.i$sec)) {
      for (j in 1:(nrow(obs.i)-1)) {
        obs.i$bearing[j] <- bearing(c(obs.i$long[j], obs.i$lat[j]), 
                                    c(obs.i$long[j+1], obs.i$lat[j+1]))
        if (is.na(obs.i$bearing[j])) next
        if (j > 1) {
          if (!(is.na(obs.i$bearing[j-1])) & abs(obs.i$bearing[j] - obs.i$bearing[j-1]) > 100) 
            obs.i$flag2[j] <- 1
        }
      }
      obs.i$sbearing[!is.na(obs.i$bearing)] <- smooth(obs.i$bearing[!is.na(obs.i$bearing)])
    }
    obstrack[tmp, ] <- obs.i
  }
  obstrack$flag3 <- ifelse(obstrack$transLat == 0 | obstrack$sbearing < 70 | 
                             (obstrack$sbearing > 110 & obstrack$sbearing < 250) | obstrack$sbearing > 290, 1, 0)
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 11: FLAG POINTS ON LAND FOR REMOVAL
  # ---------------------------------------------------------------------------- #
  geodat <- obstrack
  coordinates(geodat) <- ~ long + lat
  proj4string(geodat) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  
  # READ IN ATLANTIC COASTLINE SHAPEFILE
  land <- readOGR(dsn = file.path(paste(dir,"DataProcessing/GIS",sep=""), "data"), 
                  layer = "atlanticCoastline_buffer_halfNM")
  
  # FLAG POINTS THAT ARE ON LAND
  if (!identical(proj4string(geodat), proj4string(land))) {
    land <- spTransform(land, CRS(proj4string(temp)))
  }
  if (class(land) == "SpatialPolygonsDataFrame") {
    onland <- over(geodat, land)[, 1]
  } else if (class(land) == "SpatialPolygons") {
    onland <- over(geodat, land)
  }
  obstrack$onLand <- ifelse(is.na(onland), 0, 1)
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 12: OUTPUT DATA & CREATE MAP DOCUMENT FOR INTERACTIVE EDITS IN ArcGIS
  # ---------------------------------------------------------------------------- #
  obstrack$key <- paste(obstrack$crew, obstrack$seat, obstrack$year, obstrack$month, obstrack$day, sep = "_")
  obstrack$begend <- ifelse(obstrack$type %in% c("BEGCNT", "ENDCNT"), 1, 0)
  
  # CREATE temp_Shapefiles DIRECTORY WITHIN dir.out DIRECTORY 
  if (!file.exists(file.path(dir.out, "temp_shapefiles"))) {
    dir.create(file.path(dir.out, "temp_shapefiles"), recursive = TRUE)
  }
  
  # SAVE DATA FOR ArcGIS PROCESSING
  geodat <- obstrack
  coordinates(geodat) <- ~ long + lat
  proj4string(geodat) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  writeOGR(geodat, dsn = file.path(dir.out, "temp_shapefiles"), 
           layer = "temp_obsTrack", driver = "ESRI Shapefile", morphToESRI = TRUE)
  
  # READ IN GENERIC GISeditObsTrack.py FILE, CHANGE NECESSARY DIRECTORIES, & SAVE 
  # NEW .py FILE
  py <- readLines(file.path(dir, "DataProcessing/Code/GISeditObsTrack.py"))
  py[grep("^sdpath = ", py)] <- paste("sdpath = '", "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/'", sep = "")
  py[grep("^projpath = ", py)] <- paste("projpath = '", dir.out, "/'", sep = "")
  writeLines(py, file.path(dir.out, "GISeditObsTrack.py"))
  
  # RUN GISeditObsTrack.py PROGRAM IN ArcGIS, DELETE PROGRAM WHEN FINISHED
  system(paste(py.exe, file.path(dir.out, "GISeditObsTrack.py")))
  unlink(file.path(dir.out, "GISeditObsTrack.py"))
  # ---------------------------------------------------------------------------- #
  
  
  # CREATE DATA PROCESSING SUMMARY FILE
  sink(file.path(dir.out, "dataProcessingSummary.txt"))
  cat("Survey data folder:", dir.in, "\n\n")
  cat("Error fix R file used:", errfix.file, "\n\n")
  cat("\nObservation files read:\n")
  print(out.obsfiles)
  cat("\n\nNumber of observations read by crew and seat:\n")
  print(out.obstab1)
  cat("\n\nNumber of observations read by observer and seat:\n")
  print(out.obstab2)
  cat("\n\nTrack files read:\n")
  print(out.trackfiles)
  cat("\n\nNumber of track file records read by crew and seat:\n")
  print(out.tracktab)
  cat("\n\nSummary of select columns (excludes BEG/END points):\n\n")
  print(out.obssum)
  cat("\n", rep("-", 80), "\n\n", sep = "")
  print(sessionInfo())
  cat("\n", rep("-", 80), "\n\n", sep = "")
  cat("Data processing completed on", date(), "\n")
  cat("Total run time:", round((proc.time() - ptm)[3] / 3600, 2), "hours\n")
  cat("Number of CPU cores allocated for transect re-numbering:", as.numeric(detectCores()))
  sink()
  
  # ------------------------------------------------------------------------- #
  ### STEP 13: MANUALLY EDIT IN ARCMAP
  # ------------------------------------------------------------------------- #
  # create folder to store edited shapefiles
  if (!file.exists(file.path(dir.out, "edited_shapefiles"))) {
    dir.create(file.path(dir.out, "edited_shapefiles"), recursive = TRUE)
  }
  #   a. open GISeditObsTrack.mxd in ArcMap (open ArcGIS-> ArcMap ->)
  #   b. visually inspect points by crew/seat/day layer
  #   c. delete points that should be deleted
  #   d. save layer as shapefile (right click on layer-> data-> export data 
  #       -> click on the folder icon and switch 'save type as' to shapefile)
  # you will not be able to move on until this is completed (estimated time = 1 day)
  
  save(paste(dir.out,"obstrackWorkspace.Rdata",sep="/"))
  write.csv(obstrack, file=paste(dir.out,"obstrack_part1.csv",sep="/"), row.names=FALSE)
}
