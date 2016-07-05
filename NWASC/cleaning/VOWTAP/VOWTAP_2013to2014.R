# ------------------------------------------ #
# VOWTAP (2013-2014)
# data QA/QC and formating
#
# written by Kaycee Coleman
# June 2016
# ------------------------------------------ #

#processSurveyData_part1 <- function(dir.in, dir.out, errfix.file, py.exe) {
# LOAD PACKAGES 
require(geosphere) # used in fixSeconds function
require(parallel) # used to make a cluster
require(rgdal) # for writeOGR
require(zoo) # fill in missing points
require(xlsx) # read excel file
require(dplyr) # 
require(data.table) # combine lists into dataframe, when not equal
require(RODBC) # odbcConnect

# DEFINE SURVEY, CHANGE THIS!!!
surveyFolder = "VOWTAP"
yearLabel = "VOWTAP_Avian_Data"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  yearLabel, sep = "/") 
speciesPath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/"

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))

# SET PATH TO R FILE THAT FIXES DATA ERRORS
errfix.file <- file.path(dir.out, paste(yearLabel, "_ObsFilesFix.R", sep = ""))

# SET PATH TO python.exe FILE
#py.exe = "E:/Python27/ArcGISx6410.2/python.exe"
#py.exe = "C:/Python27/ArcGIS10.3/python.exe" #32 bit
#py.exe = "C:/Python27/ArcGISx6410.3/python.exe" #64 bit

# ---------------------------------------------------------------------------- #
# STEP 1: READ IN RAW OBSERVATION DATA (in this case, mixed with track data)
# ---------------------------------------------------------------------------- #
code <- odbcConnectExcel2007(xls.file = paste(dir.in, "/", yearLabel, ".xlsx", sep=""))
s1 <- sqlFetch(code, "VOWTAP_Avian_Transect")
s2 <- sqlFetch(code, "VOWTAP_Avian_Transit")
odbcClose(code)
s1$offline = 0
s2$offline = 1
s1$DISTANCE = as.numeric(s1$DISTANCE)
s2$DISTANCE = as.numeric(NA)
s1$BEARING = as.numeric(s1$BEARING)
s2$BEARING = as.numeric(NA)
s1$DATE = as.character(s1$DATE)
s2$DATE = as.character(s2$DATE)
s1$DATE_TEXT = as.character(s1$DATE_TEXT)
s2$DATE_TEXT = as.character(s2$DATE_TEXT)
obs = full_join(s1, s2)
# ---------------------------------------------------------------------------- #
