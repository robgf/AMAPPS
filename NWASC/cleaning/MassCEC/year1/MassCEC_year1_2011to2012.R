# ------------------------------------------ #
# Mass CEC 2011-2012 year 1
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
surveyFolder = "MassCEC"
yearLabel = "year1_2011to2012"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
dir.in <- paste(dir, surveyFolder, "seabirds_masscec_yr1_raw", sep = "/") 
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
# CHECK IF THERE ARE RAW DATA FILES TO SPLIT/FIX SO JEFF'S SCRIPTS RUN SMOOTHER 
if (length(list.files(dir.out, pattern = "FixFile")) == 1) {
  source(paste(dir.out, list.files(dir.out, pattern = "FixFile"), sep = "/"))
}

survey_num <- list.files(dir.in, pattern = "survey")
files <- list.files(file.path(dir.in,survey_num), pattern = "sur", recursive = TRUE, full.names = TRUE) 
files <- files[grep("csv",files)]
files = c(files,
          list.files(file.path(dir.in,survey_num), pattern = "Survey", recursive = TRUE, full.names = TRUE), 
          list.files(file.path(dir.in,survey_num), pattern = "tr", recursive = TRUE, full.names = TRUE))
obs <- lapply(setNames(files, basename(files)), getData)
obs <- lapply(obs, function(x) data.frame(cbind(x, "survey_num" = as.character(unlist(strsplit(basename(dirname(x$file)), "_"))[1]))))
obs = rbindlist(obs, fill=TRUE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 2: OUTPUT COAST SURVEY DATA; FIX OBSERVATION FILE ERRORS
# ---------------------------------------------------------------------------- #
# REMOVE SPACES IN CERTAIN COLUMNS
obs$behavior=gsub("\\s", "", obs$behavior)
names(obs)[names(obs) == "species"] <- "type"

obs <- commonErrors(obs)
obs <- fixMixed(obs) 

if (!file.exists(errfix.file)) {
  warning("Error fix R file is missing and will not be sourced.")
} else source(errfix.file, local = TRUE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 4: CHECK OBSERVATION FILES FOR ERRORS, DOCUMENT IN .CSV FILE
# ---------------------------------------------------------------------------- #
obs <- genericErrorCheck(obs, dir.out, error.flag = TRUE)

# STOP IF ERRORS STILL EXIST IN OBSERVATION FILES
if (obs[["errorStatus"]] == 1) {
  stop("Errors still exist in observation files. These must be fixed before continuing.")
} else obs <- obs[["data"]]

# if you've checked the errors and still want to continue, 
# just run the else statement
obs <- obs[["data"]]
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 5: RE-ORGANIZE OBSERVATION AND TRACK DATA INTO SEPARATE LISTS CONTAINING 
#         UNIQUE DATA FRAMES - ONE DATA FRAME FOR EACH COMBINATION OF OBSERVER 
#         AND DAY
# ---------------------------------------------------------------------------- #
# RE-ORGANIZE OBSERVATION DATA
if(all(!names(obs) %in% "index")){
  obs <- obs[order(obs$year, obs$month, obs$day, obs$sec),]
  obs$index = as.numeric(row.names(obs))}
obs$key <- paste(obs$survey_num, obs$seat, obs$year, obs$month, obs$day, sep = "_")
# since each obs is sharing a track file, need to make sure that is incorporated
# for each unique key without waypoints duplicate the track data and assign it to each observer
track = obs[grep("__",obs$key),]
obs = obs[!grep("__",obs$key),]
# in this case there are two observers for each track in the track file so can simply duplicate
add1=track
add2=track
add1$seat="rr"
add2$seat="lr"
add1$dataChange=paste(add1$dataChange, "; Duplicated track file for each observer", sep="")
add2$dataChange=paste(add1$dataChange, "; Duplicated track file for each observer", sep="")
obs=rbind(obs,add1,add2)
rm(add1,add2,track)
obs$key <- paste(obs$survey_num, obs$seat, obs$year, obs$month, obs$day, sep = "_")
obs <- split(obs, list(obs$key))
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 7: ADD BEG/END POINTS WHERE NEEDED IN OBSERVATION FILES
# ---------------------------------------------------------------------------- #
obs <- suppressMessages(lapply(obs, addBegEnd_obs))
obs = do.call(rbind.data.frame, obs)
# ---------------------------------------------------------------------------- #

# plot check
p = obs %>% group_by(survey_num) %>% do(print(plots=ggplot(data=.)+
     aes(x=lon,y=lat)+geom_point()+ggtitle(.$survey_num)))
invisible(lapply(p$plots, print))

# ---------------------------------------------------------------------------- #
# STEP 12: OUTPUT DATA 
# ---------------------------------------------------------------------------- #
save.image(paste(dir.out, "/", yearLabel, ".Rdata",sep=""))
write.csv(obs, file=paste(dir.out,"/", yearLabel,".csv", sep=""), row.names=FALSE)
# divide obs and track with Beg/End count in both
obs.only=obs[!obs$type %in% c("WAYPNT","COCH"),]
track.only=obs[obs$type %in% c("WAYPNT","COCH","BEGCNT","ENDCNT"),]
offline.only=obs[obs$offline==1,]
write.csv(obs.only, file=paste(dir.out,"/", yearLabel,"_obs.csv", sep=""), row.names=FALSE)
write.csv(track.only, file=paste(dir.out,"/", yearLabel,"_track.csv", sep=""), row.names=FALSE)
write.csv(offline.only, file=paste(dir.out,"/", yearLabel,"_offline.csv", sep=""), row.names=FALSE)

# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# STEP 13: 
# ---------------------------------------------------------------------------- #
# CREATE DATA PROCESSING SUMMARY FILE
sink(file.path(dir.out, "dataProcessingSummary.txt"))
cat("Survey data folder:", dir.in, "\n\n")
cat("Error fix R file used:", errfix.file, "\n\n")
cat("\nObservation files read:\n")
print(length(obs$year))
cat("\n\nNumber of observations read by crew and seat:\n")
print(out.obstab1)
cat("\n\nNumber of observations read by observer and seat:\n")
print(out.obstab2)
cat("Data processing completed on", date(), "\n")
sink()

