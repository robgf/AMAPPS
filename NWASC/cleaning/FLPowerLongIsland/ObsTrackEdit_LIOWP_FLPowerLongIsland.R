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
library(stringr) #extract parts of a string
require(rgeos)
require(sp)
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

#fix names
boat.obs = rename(boat.obs, DIRECTION = FLDIR, DIS_OB_1ST = FIRSTOB, DIS_OB_CL = CLOSEST)

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
        spp$GPS_Date = as.Date(spp$DATE, origin = "1899-12-30")
        spp = select(spp, -DATE)} # excel date
      if ("CODE" %in% colnames(spp)) {spp = rename(spp, SPECIES1 = CODE)}
    } 

    if ("TRANSECT$" %in% sqlTables(database)$TABLE_NAME) {
      transect = sqlFetch(database, "TRANSECT$")} else {transect = sqlFetch(database, "Sheet2$")}
    if (exists("transect") == TRUE && dim(transect)[1] >1) {
      if ("F18" %in% colnames(transect)) {transect = select(transect, -F18)}
      transect$filename = strsplit(boat.raw.list[i],"[.]")[[1]][1]
      if (nchar(transect$GPS_Date[1]) == 5) {
        transect$GPS_Date = as.Date(transect$GPS_Date, origin = "1899-12-30")} # excel date
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
    if("LAT" %in% colnames(spp)) {spp = rename(spp, Latitude = LAT, Longitude = LONG, GROUPSZ = GROUP_SIZE, SPECIES1 = SPECIES, BEHAVIOR = BEHAV, DIRECTION = DIR)}
    if("GroupSZ" %in% colnames(spp)) {spp = rename(spp, GROUPSZ = GroupSZ)}
    if("FLDIR" %in% colnames(spp)) {spp = rename(spp, DIRECTION = FLDIR)}
    if("Date" %in% colnames(spp)) {spp = rename(spp, GPS_Date = Date)}
    if("Lat" %in% colnames(spp)) {spp = rename(spp, Latitude = Lat, Longitude = Long,SPECIES1 = Species, BEHAVIOR = Behavior)}
    if("FIRSTOB" %in% colnames(spp)) {spp = rename(spp, DIS_OB_1ST = FIRSTOB)}
    if("CLOSEST" %in% colnames(spp)) {spp = rename(spp, DIS_OB_CL = CLOSEST)}
    if("Transect" %in% colnames(spp)) {spp = rename(spp, TRANSECT = Transect)}
    if("STATION_ID" %in% colnames(spp)) {spp = rename(spp, TRANSECT = STATION_ID)}
    if("SPECIES2" %in% colnames(spp)) {spp$SPECIES2 = as.factor(spp$SPECIES2)}
    if("BEHAVIOR" %in% colnames(spp)) {spp$BEHAVIOR = as.factor(spp$BEHAVIOR)}
    if("TRANSECT" %in% colnames(spp)) {spp$TRANSECT = as.character(spp$TRANSECT)}
    if("FL_C_1ST" %in% colnames(spp)) {
      spp$FL_C_1ST = as.numeric(spp$FL_C_1ST)
      spp$FL_C_LOW = as.numeric(spp$FL_C_1ST)
      spp$FL_C_HIGH = as.numeric(spp$FL_C_1ST)}
    if(spp$filename[1] == "Final_raw_summer04") {
      spp$GPS_Time = as.character(spp$GPS_Time)
      spp$GPS_Time = as.factor(sapply(str_split(spp$GPS_Time," "),tail,1))}
   
    # aggregate data
    boat.obs = rbind.all.columns(boat.obs, spp); rm(spp)
    if (exists("transect")) {boat.transect = rbind.all.columns(boat.transect, transect); rm(transect)}
    if (exists("ptge")) {boat.point.ge = rbind.all.columns(boat.point.ge, ptge); rm(ptge)}
}
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
# Plane
# ------------------------------------------------------------------------- #
plane.list = list.files(planepath)
plane.list = plane.list[!plane.list %in% c("Final_raw_data_072005.xls","Aerial_Transect_Excel_Files_06-08-06.zip")]

for (i in seq(along = plane.list)) {
  database = odbcConnectExcel2007(file.path(planepath, plane.list[i])) 
  
  if("SPECIES$" %in% sqlTables(database)$TABLE_NAME) {spp = sqlFetch(database, "SPECIES")}
  if("COUNT_EVENTS_FINAL$" %in% sqlTables(database)$TABLE_NAME) {spp = sqlFetch(database, "COUNT_EVENTS_FINAL")}
  spp$filename = strsplit(plane.list[i],"[.]")[[1]][1]
  if("SPECIES" %in% colnames(spp)) {spp = rename(spp, SPECIES1=SPECIES)}
  if("CODE" %in% colnames(spp)) {spp = rename(spp, SPECIES1=CODE)}
  if("GPSTIME" %in% colnames(spp)) {spp = rename(spp, GPS_Time=GPSTIME)}
  if("TRANSECTID" %in% colnames(spp)) {spp = rename(spp, TRANSECT=TRANSECTID)}
  if("DATE_" %in% colnames(spp)) {spp = rename(spp, GPS_Date=DATE_)}
  if("LAT" %in% colnames(spp)) {spp = rename(spp, Latitude=LAT)}
  if("LON" %in% colnames(spp)) {spp = rename(spp, Longitude=LON)}
  
  if("TRANSECT$" %in% sqlTables(database)$TABLE_NAME) {
    transect = sqlFetch(database, "TRANSECT")
    transect$filename = strsplit(plane.list[i],"[.]")[[1]][1]
  }
  
  if("Point_ge$" %in% sqlTables(database)$TABLE_NAME) {
    ptge = sqlFetch(database, "Point_ge")
    ptge$filename = strsplit(plane.list[i],"[.]")[[1]][1]
  }
  
  odbcCloseAll()
  
  if(i == 1) {
    plane.transect = transect
    plane.obs = spp
    plane.point.ge = ptge
    rm(spp, transect, ptge)
  } else {
    plane.obs = rbind.all.columns(plane.obs, spp)
    rm(spp)
    if(exists("transect")) {
      plane.transect = rbind.all.columns(plane.transect, transect)
      rm(transect)
    }
    if(exists("ptge")) {
      plane.point.ge = rbind.all.columns(plane.point.ge, ptge)
      rm(ptge)
      }
    }
}

# ------------------------------------------------------------------------- #
# FIX OBSERVATION FILE BEGSEG/ENDSEG ERRORS
# ------------------------------------------------------------------------- #
source(file.path(dir.out, paste(surveyFolder, "_ObsFilesFix.R", sep = "")))
# ------------------------------------------------------------------------- #
