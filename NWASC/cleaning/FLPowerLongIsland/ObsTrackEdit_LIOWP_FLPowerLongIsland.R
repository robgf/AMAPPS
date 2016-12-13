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
      if ("GPS_Date" %in% colnames(spp) && nchar(spp$GPS_Date[1]) == 5) {spp$GPS_Date = as.Date(spp$GPS_Date, origin = "1899-12-30")} # excel date
      if ("DATE" %in% colnames(spp) && nchar(spp$DATE[1]) == 5) {
        spp$GPS_Date = as.Date(spp$DATE, origin = "1899-12-30")
        spp = select(spp, -DATE)} # excel date
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
    if("GROUPSZ" %in% colnames(spp)) {spp = rename(spp, GroupSZ = GROUPSZ)}
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

# remove NAs
boat.transect = boat.transect[!is.na(boat.transect$Latitude),]
boat.obs = boat.obs[!is.na(boat.obs$Latitude),]
boat.point.ge = boat.point.ge[!is.na(boat.point.ge$Latitude),]
boat.point.ge = boat.point.ge[boat.point.ge$Comment != "Comment",] 

# pull transect info out
boat.obs$index = seq.int(nrow(boat.obs))
tmp = boat.obs[boat.obs$SPECIES1 %in% c("10n","10s","11n","11s","12n","12s","2n","2ss",
                                        "3n","3s","4s","5s","6n","6s","7n","7s","8n",
                                        "8s","9n","9s","t4","2s","4n","5n","5S","6N",
                                        "12","10 n"),]
ind = which(tmp$SPECIES1 == "t4")  
tmp$SPECIES1[ind] = NA 
tmp$TRANSECT = as.numeric(strsplit(as.character(tmp$SPECIES1), "[^0-9]+"))
tmp$TRANSECT[ind] = 4

for(a in 1:(nrow(tmp)-1)) {
  if(tmp$TRANSECT[a] == tmp$TRANSECT[a+1]) {
    if(tmp$index[a+1]-tmp$index[a]-1 >= 1) {
      boat.obs$TRANSECT[(tmp$index[a]+1):(tmp$index[a+1]-1)] = replicate(tmp$index[a+1]-tmp$index[a]-1, tmp$TRANSECT[a])
    }
  }
}


# fix transects that dont have start and stops
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_071105" & boat.obs$GPS_Time == "03:40:03pm"]:
  boat.obs$index[boat.obs$filename == "Final_raw_data_071105" & boat.obs$GPS_Time == "03:59:47pm"]] = 10 
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "02:29:59pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "03:33:19pm"]] = 6
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "03:40:55pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "04:10:39pm"]] = 4
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "04:53:11pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:16:23pm"]] = 2
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:24:23pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:44:59pm"]] = 8 
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:04:55pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:25:55pm"]] = 9 
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:31:11pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:57:27pm"]] = 10 
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "07:05:27pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "07:31:43pm"]] = 11 

# remove transect info from obs
boat.obs[tmp$index,] = NULL
