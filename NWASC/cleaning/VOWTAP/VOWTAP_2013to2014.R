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
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
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
s2$time = format(as.POSIXct(strptime(s2$DATE,"%m/%d/%Y %H:%M",tz="")) ,format = "%H:%M")
s2$DATE = format(as.POSIXct(strptime(s2$DATE,"%m/%d/%Y %H:%M",tz="")) ,format = "%Y-%m-%d")
s1$DATE = as.character(s1$DATE)
s1$DATE_TEXT = as.character(s1$DATE_TEXT)
s2$DATE_TEXT = as.character(s2$DATE_TEXT)
obs = full_join(s1, s2)
rm(s1,s2)
colnames(obs) = tolower(colnames(obs))

# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 2: OUTPUT COAST SURVEY DATA; FIX OBSERVATION FILE ERRORS
# ---------------------------------------------------------------------------- #
# REMOVE SPACES IN CERTAIN COLUMNS
obs$behavior=gsub("\\s", "", obs$behavior)
names(obs)[names(obs) == "species"] <- "type"
names(obs)[names(obs) == "shape_x"] <- "lon"
names(obs)[names(obs) == "shape_y"] <- "lat"
names(obs)[names(obs) == "flock_size"] <- "count"

obs <- commonErrors(obs)
obs <- fixMixed(obs) 

if (!file.exists(errfix.file)) {
  warning("Error fix R file is missing and will not be sourced.")
} else source(errfix.file, local = TRUE)
# ---------------------------------------------------------------------------- #

# check plot
plot(obs$lon,obs$lat,pch=16,xlab="Longitude",ylab="Latitude")
points(obs$lon[obs$offline==1],obs$lat[obs$offline==1],col="red")
points(obs$lon[obs$offline==0],obs$lat[obs$offline==0],col="blue")
legend("topleft",c("Observation", "Transit","Transect"),pch=16, col=c("black","red","blue"))

# ---------------------------------------------------------------------------- #
# STEP 12: OUTPUT DATA 
# ---------------------------------------------------------------------------- #
save.image(paste(dir.out, "/", yearLabel, ".Rdata",sep=""))
write.csv(obs, file=paste(dir.out,"/", yearLabel,".csv", sep=""), row.names=FALSE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 13: 
# ---------------------------------------------------------------------------- #
# CREATE DATA PROCESSING SUMMARY FILE
sink(file.path(dir.out, "dataProcessingSummary.txt"))
cat("Survey data folder:", dir.in, "\n\n")
cat("Error fix R file used:", errfix.file, "\n\n")
cat("\n\nFiles used:\n")
paste(dir.in, "/", yearLabel, ".xlsx", sep="")
cat("\nData points read:\n")
print(length(obs$date))
cat("Data processing completed on", date(), "\n")
sink()
