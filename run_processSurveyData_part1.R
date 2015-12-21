## created by J. Leirness, July 2015
## edited by K. Coleman, July 2015

# LOAD PACKAGES 
require(RODBC) # used in ObsFilesErrorCheck function to import excel species codes
require(geosphere) # used in fixSeconds function
require(parallel) # used to make a cluster
require(rgdal) # for writeOGR
require(zoo) # fill in missing points

# DEFINE SURVEY, CHANGE THIS!!!
surveyFolder = "AMAPPS/"
yearLabel = "AMAPPS_2013_09"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/"
setwd(dir)
dbpath <- gsub("Jeff_Working_Folder", "DataBase", dir)
dir.in <- paste(gsub("Jeff_Working_Folder", "SurveyData/", dir), surveyFolder, yearLabel, sep = "") 
dir.out <- paste(dir,"DataProcessing/Surveys/", surveyFolder, yearLabel, sep = "") 
speciesPath = paste(dir,"DataProcessing/",sep="")

# SOURCE R FUNCTIONS
source(file.path(dir, "_Rfunctions/sourceDir.R"))
sourceDir(file.path(dir, "_Rfunctions"))

# SET PATH TO R FILE THAT FIXES DATA ERRORS
errfix.file <- file.path(dir.out, paste(yearLabel, "_ObsFilesFix.R", sep = ""))

# SET PATH TO python.exe FILE
py.exe = "E:/Python27/ArcGISx6410.2/python.exe"

# RUN EDIT FUNCTION
source("//IFW9MBMSVR010/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/Code/processSurveyData_part1.R")

processSurveyData_part1(dir.in, dir.out, errfix.file, py.exe = "'C:/Program Files (x86)/ArcGIS/ArcGIS 10.2/python.exe'")
