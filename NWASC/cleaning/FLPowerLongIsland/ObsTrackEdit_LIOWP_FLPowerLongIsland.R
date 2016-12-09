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
boat.data.list = boat.data.list[!boat.data.list %in% c("GPS_02-02-2006.XLSB",
                                                       "Thumbs.db",
                                                       "Boat_Transect_Excel_Files_06-08-06.zip",
                                                       "Final_raw_data_042105.xls",
                                                       "Final_raw_data_042805.xls",
                                                       "Final_raw_data_050305.xls",
                                                       "Final_raw_data_051005.xls",
                                                       "Final_raw_data_051905.xls",
                                                       "Final_raw_data_052305.xls",
                                                       "Final_raw_data_053105.xls")]
# several files have a "b" version

# function to Rbind all columns despite different size
rbind.all.columns <- function(x, y) {
  x.diff <- setdiff(colnames(x), colnames(y))
  y.diff <- setdiff(colnames(y), colnames(x))
  x[, c(as.character(y.diff))] <- NA
  y[, c(as.character(x.diff))] <- NA
  return(rbind(x, y))
}

# import the data 
for (i in seq(along = boat.data.list)) {
    database = odbcConnectExcel2007(file.path(boatpath, boat.data.list[i])) 
    
    if ("SPECIES$" %in% sqlTables(database)$TABLE_NAME) {
      spp = sqlFetch(database, "TRANSECT$")} else {spp = sqlFetch(database, "Sheet1$")}
    if (exists("spp") == TRUE & length(spp) >1) {
      #spp = spp[!is.na(spp$GROUPSZ),]
      if (length(spp) == 21) {spp$TRANSECT = NA}
      spp$filename = strsplit(boat.data.list[i],"[.]")[[1]][1]
      if (nchar(spp$GPS_Date[1]) == 5) {spp$GPS_Date = as.Date(spp$GPS_Date, origin = "1899-12-30")} # excel date
    } 

    if ("TRANSECT$" %in% sqlTables(database)$TABLE_NAME) {
      transect = sqlFetch(database, "TRANSECT$")} else {transect = sqlFetch(database, "Sheet2$")}
    if (exists("transect") == TRUE & length(transect) >1) {
      if ("F18" %in% colnames(transect)) {transect$F18 = NULL}
      transect = transect[!is.na(transect$TRANSECT),]
      transect$filename = strsplit(boat.data.list[i],"[.]")[[1]][1]
      if (nchar(transect$GPS_Date[1]) == 5) {transect$GPS_Date = as.Date(transect$GPS_Date, origin = "1899-12-30")} # excel date
    } 

    if ("Point_ge$" %in% sqlTables(database)$TABLE_NAME) {
      ptge = sqlFetch(database, "Point_ge$")} else if ("Sheet3$" %in% sqlTables(database)$TABLE_NAME) {
        ptge = sqlFetch(database, "Sheet3$")}   
    if (exists("ptge") == TRUE) {
      if (length(ptge) > 1) {
        if (length(ptge) == 7) {ptge$TRANSECT = NA}
        if ("F9" %in% colnames(ptge)) {ptge$F9 = NULL}
        ptge = ptge[!is.na(ptge$GPS_Date),]
        ptge$filename = strsplit(boat.data.list[i],"[.]")[[1]][1]
      } 
    }
    odbcCloseAll()

    if(i == 1) {
      boat.transect = transect
      boat.obs = spp
      if (exists("ptge")) {boat.point.ge = ptge}
    } else {
      boat.obs = rbind.all.columns(boat.obs, spp)
      boat.transect = rbind.all.columns(boat.transect, transect)
      if (exists("boat.point.ge") & exists("ptge")) {
        boat.point.ge = rbind.all.columns(boat.point.ge, ptge)} else if (exists("ptge")) {boat.point.ge = ptge}
    }
    rm(spp, transect, ptge)
}


