# ------------------------------------------------------------------------- #
# Date Created: 7-2015
# Author: Kaycee Coleman
#
# Description: This program reads in the pilot and observer raw observation 
# files and creates a header row. It then checks for general errors & 
# BEGSEG/ENDSEG errors and outputs a .csv file documenting these errors 
# (ObsFiles_Errors.csv). It then fixes the observation file errors, reads in 
# the pilot and observer raw track files and creates a header row, compares 
# the track files to the observation files, and outputs the edited track 
# files containing only the survey segments.
#
# ------------------------------------------------------------------------- #

# -------------------------------- #
# LOAD PACKAGES
# -------------------------------- #
require(RODBC) # odbcConnect
require(lubridate) #fix timestamps
require(zoo) #na.locf
require(dplyr) # %>% 
library(dtplyr) #data.table
# -------------------------------- #


# -------------------------------- #
# DEFINE SURVEY
# -------------------------------- #
surveyFolder = "LIOWP_FLPowerLongIsland"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing"
dir.in <- paste(dir, surveyFolder, sep = "/") 
boatpath = paste(dir.in, "/BoatTransectExcelFiles", sep ="")
planepath = paste(dir.in, "/AerialTransectExcelFiles", sep ="")
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
speciesPath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/"

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))

# SET PATH TO R FILE THAT FIXES DATA ERRORS
errfix.file <- file.path(dir.out, paste(surveyFolder, "_ObsFilesFix.R", sep = ""))
# -------------------------------- #


# ------------------------------------------------------------------------- #
# BOAT
# ------------------------------------------------------------------------- #

# get a list of the data available
boat.data.list = list.files(boatpath)

# function to Rbind all columns despite different size
rbind.all.columns <- function(x, y) {
  x.diff <- setdiff(colnames(x), colnames(y))
  y.diff <- setdiff(colnames(y), colnames(x))
  x[, c(as.character(y.diff))] <- NA
  y[, c(as.character(x.diff))] <- NA
  return(rbind(x, y))
}

# import the data 
# GPS data all formated the same
boat.gps.list = boat.data.list[grep("GPS",boat.data.list)]
boat.gps.list = boat.gps.list[!boat.gps.list %in% "GPS_02-02-2006.XLSB"]

for (i in seq(along = boat.gps.list)) {
  database = odbcConnectExcel2007(file.path(boatpath, boat.gps.list[i])) 
  spp = sqlFetch(database, "SPECIES")
  spp$filename = strsplit(boat.gps.list[i],"[.]")[[1]][1]
   
  transect = sqlFetch(database, "TRANSECT")
  if ("F18" %in% colnames(transect)) {transect$F18 = NULL}
  transect$filename = strsplit(boat.gps.list[i],"[.]")[[1]][1]
 
  ptge = sqlFetch(database, "Point_ge")
  if (length(ptge) == 7) {ptge$TRANSECT = NA}
  if ("F9" %in% colnames(ptge)) {ptge$F9 = NULL}
  ptge$filename = strsplit(boat.gps.list[i],"[.]")[[1]][1]

  odbcCloseAll()
  
  if(i == 1) {
    boat.transect = transect
    boat.obs = spp
    boat.point.ge = ptge
  } else {boat.obs = rbind.all.columns(boat.obs, spp)
          boat.transect = rbind.all.columns(boat.transect, transect)
          boat.point.ge = rbind.all.columns(boat.point.ge, ptge)}
  rm(spp, transect, ptge)
}

# load the other messier data
boat.raw.list = boat.data.list[grep("Final",boat.data.list)]

for (i in seq(along = boat.raw.list)) {
    database = odbcConnectExcel2007(file.path(boatpath, boat.raw.list[i])) 
    
    if ("SPECIES$" %in% sqlTables(database)$TABLE_NAME) {
      spp = sqlFetch(database, "SPECIES$")} else {spp = sqlFetch(database, "Sheet1$")}
    if (exists("spp") == TRUE && dim(spp)[1] >1) {
      spp$filename = strsplit(boat.raw.list[i],"[.]")[[1]][1]
      if ("GPS_Date" %in% colnames(spp) && nchar(spp$GPS_Date[4]) == 5) {
        spp$GPS_Date = as.Date(spp$GPS_Date, origin = "1899-12-30")} # excel date
      if ("DATE" %in% colnames(spp) && nchar(spp$DATE[1]) == 5) {
        spp$DATE = as.Date(spp$DATE, origin = "1899-12-30")
        spp = select(spp, -DATE)} # excel date
      if ("CODE" %in% colnames(spp)) {spp = rename(spp, SPECIES1 = CODE)}
    } 

    if ("TRANSECT$" %in% sqlTables(database)$TABLE_NAME) {
      transect = sqlFetch(database, "TRANSECT$")} else {transect = sqlFetch(database, "Sheet2$")}
    if (exists("transect") == TRUE && dim(transect)[1] >1) {
      if ("F18" %in% colnames(transect)) {transect = select(transect, -F18)}
      transect$filename = strsplit(boat.raw.list[i],"[.]")[[1]][1]
      if (nchar(transect$GPS_Date[1]) == 5) {transect$GPS_Date = as.Date(transect$GPS_Date, origin = "1899-12-30")} # excel date
      transect$GPS_Time = format(transect$'GPS Time', "%H:%M:%S")
    } else rm(transect)

    if ("Point_ge$" %in% sqlTables(database)$TABLE_NAME) {
      ptge = sqlFetch(database, "Point_ge$")} else if ("Sheet3$" %in% sqlTables(database)$TABLE_NAME) {
        ptge = sqlFetch(database, "Sheet3$")}   
    if (exists("ptge") == TRUE && dim(ptge)[1] >1) {
        if ("F9" %in% colnames(ptge)) {ptge$F9 = NULL}
        ptge$filename = strsplit(boat.raw.list[i],"[.]")[[1]][1]
    } else rm(ptge)

    odbcCloseAll()

    # fix names
    if("LAT" %in% colnames(spp)) {spp = rename(spp, Latitude = LAT, Longitude = LONG, GroupSZ = GROUP_SIZE, 
                                               SPECIES1 = SPECIES, BEHAVIOR = BEHAV, DIRECTION = DIR)}
    if("GroupSZ" %in% colnames(spp)) {spp = rename(spp, GROUPSZ = GroupSZ)}
    if("FLDIR" %in% colnames(spp)) {spp = rename(spp, DIRECTION = FLDIR)}
    if("Date" %in% colnames(spp)) {spp = rename(spp, GPS_Date = Date)}
    if("Lat" %in% colnames(spp)) {spp = rename(spp, Latitude = Lat, Longitude = Long,
                                               SPECIES1 = Species, BEHAVIOR = Behavior)}
    if("FIRSTOB" %in% colnames(spp)) {spp = rename(spp, DIS_OB_1ST = FIRSTOB)}
    if("CLOSEST" %in% colnames(spp)) {spp = rename(spp, DIS_OB_CL = CLOSEST)}
    if("Transect" %in% colnames(spp)) {spp = rename(spp, TRANSECT = Transect)}
    
    # aggregate data
    boat.obs = rbind.all.columns(boat.obs, spp); rm(spp)
    if (exists("transect")) {boat.transect = rbind.all.columns(boat.transect, transect); rm(transect)}
    if (exists("ptge")) {boat.point.ge = rbind.all.columns(boat.point.ge, ptge); rm(ptge)}
}



# ------------------------------------------------------------------------- #
# Plane
# ------------------------------------------------------------------------- #
plane.list = list.files(planepath)
plane.gps = sapply(strsplit((plane.list[grep("GPS",plane.list)]),"[.]"),head,1)
plane.list = sapply(strsplit(plane.list[grep("Final",plane.list)],"[.]"),head,1)


# ------------------------------------------------------------------------- #
# STEP 3: FIX OBSERVATION FILE BEGSEG/ENDSEG ERRORS
# look at yearlab_AOUErrors.xlsx and yearlab_ObsFileErrors.xlsx for help
# ------------------------------------------------------------------------- #
source(file.path(path, paste("ObsFilesFix_", yearlab, ".R", sep = "")))
# ------------------------------------------------------------------------- #
