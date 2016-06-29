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
yearLabel = "year2_2013"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
dir.in <- paste(dir, surveyFolder, "MCEC_Year2_Seabirds_9132013", sep = "/") 
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

survey_num <- list.files(paste(dir.in,"/MCEC_Year2_Seabirds_9132013",sep=""), pattern = "survey")
obs.files <- list.files(file.path(paste(dir.in,"/MCEC_Year2_Seabirds_9132013",sep="")), pattern = "OBS", recursive = TRUE, full.names = TRUE) 
obs <- lapply(setNames(obs.files, basename(obs.files)), getData)
obs <- lapply(obs, function(x) data.frame(cbind(x, "survey_num" = sapply(strsplit(sapply(strsplit(as.character(x$file), "/"), tail, 1),"_"),head,1))))
obs = rbindlist(obs, fill=TRUE)

track.files <- list.files(file.path(paste(dir.in,"/MCEC_Year2_Seabirds_9132013",sep="")), pattern = "TRACK", recursive = TRUE, full.names = TRUE) 
track <- lapply(setNames(track.files, basename(track.files)), getData)
track <- lapply(track, function(x) data.frame(cbind(x, "survey_num" = sapply(strsplit(sapply(strsplit(as.character(x$file), "/"), tail, 1),"_"),head,1))))
track <- lapply(track, function(x) data.frame(cbind(x, "year" = paste("20",substr(sapply(strsplit(sapply(strsplit(as.character(x$file), "/"), tail, 1),"_"),tail,1),5,6),sep=""))))
track <- lapply(track, function(x) data.frame(cbind(x, "month" = substr(sapply(strsplit(sapply(strsplit(as.character(x$file), "/"), tail, 1),"_"),tail,1),1,2))))
track <- lapply(track, function(x) data.frame(cbind(x, "day" = substr(sapply(strsplit(sapply(strsplit(as.character(x$file), "/"), tail, 1),"_"),tail,1),3,4))))
track = rbindlist(track, fill=TRUE)
track$type="WAYPNT"

# combine the two
names(obs)[names(obs)=="species"] <- "type"
names(obs)[names(obs)=="time"] <- "sec"
obs=rbind(obs,track,fill=TRUE)
rm(track)
obs <- obs[order(obs$year, obs$month, obs$day, obs$sec), ]
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
track = obs[grep("_NA_",obs$key),]
obs = obs[!grep("_NA_",obs$key),]
# in this case there are two observers for each track in the track file so can simply duplicate
add1 = track[!sapply(strsplit(track$key,"_"),head,1) %in% c("survey25","survey24")]
add2 = add1
add3 = track[sapply(strsplit(track$key,"_"),head,1) %in% c("survey25","survey24"),]
add1$seat = "rr"
add2$seat = "lr"
add3$seat = "lrrr"
add1$dataChange = paste(add1$dataChange, "; Duplicated track file for each observer", sep="")
add2$dataChange = paste(add2$dataChange, "; Duplicated track file for each observer", sep="")
add3$dataChange = paste(add3$dataChange, "; Changed SEAT from NA", sep="")
track = rbind(add1,add2,add3); rm(add1,add2,add3)
track$key <- paste(track$survey_num, track$seat, track$year, track$month, track$day, sep = "_")
track$key[track$key=="survey23TRACK_lr_2013_9_11"]= "survey23_lr_2013_9_11"
track$key[track$key=="survey23TRACK_rr_2013_9_11"]= "survey23_rr_2013_9_11"

# combine
obs = rbind(obs,track); rm(track)
obs <- obs[order(obs$year, obs$month, obs$day, obs$sec, obs$index), ]

# Fix transects that were flown backwards
# survey27_lr_2013_11_26
obs$type[obs$key=="survey27_lr_2013_11_26" & obs$type=="BEGCNT"] = "BEGTRAN"
obs$type[obs$key=="survey27_lr_2013_11_26" & obs$type=="ENDCNT"] = "ENDTRAN"
obs$sec = as.numeric(as.character(obs$sec))
obs$offline[obs$key=="survey27_lr_2013_11_26" & 
              obs$sec>=obs$sec[obs$key=="survey27_lr_2013_11_26" & obs$type=="BEGTRAN"] &  
              obs$sec<=obs$sec[obs$key=="survey27_lr_2013_11_26" & obs$type=="ENDTRAN"] & 
              obs$type=="WAYPNT"]= "0"
obs$offline[obs$key=="survey27_lr_2013_11_26" & 
              obs$sec<obs$sec[obs$key=="survey27_lr_2013_11_26" & obs$type=="BEGTRAN"]]= "1"

# survey27_rr_2013_11_26
add = obs[which.max(obs$sec[obs$key=="survey27_rr_2013_11_26"]),]
add$type = "ENDTRAN"
add2 = obs[obs$key=="survey27_lr_2013_11_26" & obs$type=="BEGTRAN",] 
add2$key = "survey27_rr_2013_11_26"
add2$observer = "BCH"
obs = rbind(obs,add,add2)
obs$offline[obs$key=="survey27_rr_2013_11_26" & 
              obs$sec>obs$sec[obs$key=="survey27_rr_2013_11_26" & obs$type=="BEGTRAN"] &  
              obs$sec<obs$sec[obs$key=="survey27_rr_2013_11_26" & obs$type=="ENDTRAN"] & 
              obs$type=="WAYPNT"]= "0"
obs$offline[obs$key=="survey27_rr_2013_11_26" & 
              obs$sec<obs$sec[obs$key=="survey27_rr_2013_11_26" & obs$type=="BEGTRAN"]]= "1"
rm(add,add2)

# "survey24_lrrr_2013_10_15"
sub_obs = obs[obs$type!="WAYPNT" & obs$key=="survey24_lrrr_2013_10_15",]
add = sub_obs[which.min(sub_obs$sec),]
add$type = "BEGTRAN"
add$count = 0
add$behavior = ""
add$index = add$index-0.1
obs = rbind(obs, add)
rm(add, sub_obs)
obs$type[obs$key=="survey24_lrrr_2013_10_15" & obs$type=="ENDCNT"] = "ENDTRAN"
obs$offline[obs$key=="survey24_lrrr_2013_10_15" & 
              obs$sec>=obs$sec[obs$key=="survey24_lrrr_2013_10_15" & obs$type=="BEGTRAN"] &  
              obs$sec<=obs$sec[obs$key=="survey24_lrrr_2013_10_15" & obs$type=="ENDTRAN"] & 
              obs$type=="WAYPNT"]= "0"
obs$offline[obs$key=="survey24_lrrr_2013_10_15" & 
              obs$sec<obs$sec[obs$key=="survey24_lrrr_2013_10_15" & obs$type=="BEGTRAN"] | 
              obs$sec>obs$sec[obs$key=="survey24_lrrr_2013_10_15" & obs$type=="ENDTRAN"]]= "1"

#
backwards = obs[obs$key %in% c("survey27_rr_2013_11_26","survey27_lr_2013_11_26","survey24_lrrr_2013_10_15"),]
obs = obs[!obs$key %in% c("survey27_rr_2013_11_26","survey27_lr_2013_11_26","survey24_lrrr_2013_10_15"),]

obs <- split(obs, list(obs$key))
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 7: ADD BEG/END POINTS WHERE NEEDED IN OBSERVATION FILES
# ---------------------------------------------------------------------------- #
# Fix WAYPOINTS that dont have offline definition and observations with wrong definition
source(file.path("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/MassCEC/MassCEC_surveyFix.R"))
obs = lapply(obs, MassCEC_surveyFix)
obs = do.call(rbind.data.frame, obs)

obs$offline[obs$index==3040.00 & obs$key=="survey16_lr_2013_1_21"] = "1" # fix error

# last min fixes after adding BEG and END
obs$count[obs$type %in% c("BEGCNT","ENDCNT")]=0
obs$behavior[obs$type %in% c("BEGCNT","ENDCNT")]=""
obs$comment[obs$type %in% c("BEGCNT","ENDCNT")]=""

# recombind with  backwards tracks
obs = rbind(obs,backwards)
rm(backwards)
# ---------------------------------------------------------------------------- #

# keys=unique(obs$key)
# obs2=obs
# obs=obs2[obs2$key==keys[17],]

# test plot
plot(obs$lon,obs$lat,col="grey",pch="-")
points(obs$lon[!obs$type %in% c("WAYPNT","BEGCNT","ENDCNT") & obs$offline=="0"],
       obs$lat[!obs$type %in% c("WAYPNT","BEGCNT","ENDCNT") & obs$offline=="0"],col="cyan",pch=20)
points(obs$lon[obs$offline=="1"],obs$lat[obs$offline=="1"],col="yellow",pch="-")
points(obs$lon[!obs$type %in% c("WAYPNT","BEGCNT","ENDCNT") & obs$offline=="1"],
       obs$lat[!obs$type %in% c("WAYPNT","BEGCNT","ENDCNT") & obs$offline=="1"],col="pink",pch=20)
points(obs$lon[obs$type=="BEGCNT"],obs$lat[obs$type=="BEGCNT"],col="green",pch=3)
points(obs$lon[obs$type=="ENDCNT"],obs$lat[obs$type=="ENDCNT"],col="red",pch=4)
points(obs$lon[obs$type=="BEGTRAN"],obs$lat[obs$type=="BEGTRAN"],col="forest green",pch=15)
points(obs$lon[obs$type=="ENDTRAN"],obs$lat[obs$type=="ENDTRAN"],col="dark red",pch=15)
leg.txt <- c("ONLINE WAYPNT","ONLINE OBS","OFFLINE WAYPNT","OFFLINE OBS", 
             "BEGCNT","ENDCNT","BEGTRAN","ENDTRAN")
legend("topright",leg.txt,
       col=c("grey","cyan","yellow","pink","green","red","forest green","dark red"),
       pch=c(1,20,20,20,3,4,15,15))
#points(obs$lon[which.min(obs$sec)],obs$lat[which.min(obs$sec)],col="green",pch=17)
#points(obs$lon[which.max(obs$sec)],obs$lat[which.max(obs$sec)],col="red",pch=17)

# ---------------------------------------------------------------------------- #
# STEP 12: OUTPUT DATA 
# ---------------------------------------------------------------------------- #
obs <- obs[order(obs$year,obs$month,obs$day,obs$seat,obs$sec),]

save.image(paste(dir.out, "/", yearLabel, ".Rdata",sep=""))
write.csv(obs, file=paste(dir.out,"/", yearLabel,".csv", sep=""), row.names=FALSE)
# divide obs and track with Beg/End count in both
obs.only=obs[!obs$type %in% c("WAYPNT","COCH"),]
track.only=obs[obs$type %in% c("WAYPNT","COCH","BEGCNT","ENDCNT"),]
offline.only=obs[obs$offline %in% c("1",NA),]
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
cat("\n\nFiles used:\n")
print(sapply(strsplit(as.character(obs.files), "/"), tail, 1))
print(sapply(strsplit(as.character(track.files), "/"), tail, 1))
cat("\nData points read:\n")
print(length(obs$year))
cat("\n\nNumber of observations read by observer and seat:\n")
print(table(obs$observer, obs$seat))
cat("Data processing completed on", date(), "\n")
sink()

