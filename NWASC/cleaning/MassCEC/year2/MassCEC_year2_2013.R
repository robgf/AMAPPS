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
add2$dataChange = paste(add1$dataChange, "; Duplicated track file for each observer", sep="")
add2$dataChange = paste(add1$dataChange, "; Changed SEAT from NA", sep="")
track = rbind(add1,add2,add3); rm(add1,add2,add3)
track$key <- paste(track$survey_num, track$seat, track$year, track$month, track$day, sep = "_")
track$key[track$key=="survey23TRACK_lr_2013_9_11"]= "survey23_lr_2013_9_11"
track$key[track$key=="survey23TRACK_rr_2013_9_11"]= "survey23_rr_2013_9_11"

# combine
obs = rbind(obs,track); rm(track)
obs <- obs[order(obs$year, obs$month, obs$day, obs$sec, obs$index), ]
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 7: ADD BEG/END POINTS WHERE NEEDED IN OBSERVATION FILES
# ---------------------------------------------------------------------------- #
obs$offline[is.na(obs$offline)]="2" #temporary to run addBegEnd func
obs <- split(obs, list(obs$key))

addBegEnd_obs <- function(data) {
  
  data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  
  # REMOVE BLANK SPACES IN TYPE FIELD
  data$type <- gsub(" ", "", data$type)
  
  # CHANGE ALL BEGSEG/ENDSEG TO BEGCNT/ENDCNT
  data$type[data$type == "BEGSEG"] <- "BEGCNT"
  data$type[data$type == "ENDSEG"] <- "ENDCNT"
  
  data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  
  # ADD BEGCNT
  if (data$type[1] != "BEGCNT") {
    add <- data[1, ]
    add$type <- "BEGCNT"
    add$index <- add$index - .01
    add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point", 
                            sep = "")
    data <- rbind(data, add)
    data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  }
  
  # ADD ENDCNT
  if (data$type[nrow(data)] != "ENDCNT") {
    add <- data[nrow(data), ]
    add$type <- "ENDCNT"
    add$index <- add$index + .01
    add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point", 
                            sep = "")
    data <- rbind(data, add)
    data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  }
  
  if (nrow(data) > 2) {
    for (j in 2:(nrow(data)-1)) {
      if (data$type[j] == "BEGCNT" & !(data$type[j-1] == "ENDCNT")) {
        add <- data[j-1, ]
        add$type <- "ENDCNT"
        add$index <- add$index + .01
        add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point", 
                                sep = "")
        data <- rbind(data, add)
      }
      if (data$type[j] == "ENDCNT" & !(data$type[j+1] == "BEGCNT")) {
        add <- data[j+1, ]
        add$type <- "BEGCNT"
        add$index <- add$index - .01
        add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point", 
                                sep = "")
        data <- rbind(data, add)
      }
    }
    
    
    # OFFLINE
    data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
    for (j in 2:nrow(data)) {
      if(data$offline[j] == "0" & data$offline[j-1] == "1" & !data$type[j-1] %in% "ENDCNT" & !data$type[j] %in% "ENDCNT") {
        add <- data[j-1, ]
        add$type <- "ENDCNT"
        add$index <- add$index + .01
        add$behavior <- ""
        add$count <- "0"
        add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point",  sep = "")
        data <- rbind(data, add)}
      if(data$offline[j] == "1" & data$offline[j-1] == "0" & !data$type[j-1] %in% "ENDCNT" & !data$type[j] %in% "ENDCNT") { 
        add <- data[j-1, ]
        add$type <- "ENDCNT"
        add$index <- add$index + .01
        add$behavior <- ""
        add$count <- "0"
        add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point",  sep = "")
        data <- rbind(data, add)}
    }
    
    data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
    for (j in 2:(nrow(data)-1)) {
      if(data$type[j-1] == "ENDCNT" & !data$type[j] %in% "BEGCNT") { 
        add <- data[j, ]
        add$type <- "BEGCNT"
        add$index <- add$index - .01
        add$behavior <- ""
        add$count <- "0"
        add$dataChange <- paste(add$dataChange, "; added row due to missing BEG/END point",  sep = "")
        data <- rbind(data, add)
      }    
    }   
  }
  data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  return(data)  
}

obs <- suppressMessages(lapply(obs, addBegEnd_obs))

# since WAYPOINTS are mainly NAs
obs = do.call(rbind.data.frame, obs)
obs$offline[obs$offline=="2"] = NA # change back to NA for na.locf
obs <- split(obs, list(obs$key))

extraStep<-function(data){
  data <- data[order(data$year, data$month, data$day, data$sec, data$index), ]
  data$piece = 0
  for (j in 1:nrow(data)) {if(data$type[j]=="BEGCNT"){data$piece[j:nrow(data)]=data$piece[j:nrow(data)]+1}}
  return(data)
}
obs = lapply(obs, extraStep)
obs = do.call(rbind.data.frame, obs)

obs$offline[obs$index==3040.00 & obs$key=="survey16_lr_2013_1_21" & obs$piece==3] = "1" # fix error

data = obs %>% group_by(key,piece) %>% arrange(year,month,day,sec) %>% 
  mutate(offline = ifelse(any(offline[!is.na(offline)]=="0") & any(offline[!is.na(offline)]=="1"),
                "2", na.locf(offline))) %>% as.data.frame
# summary table
toFix = data %>% select(key,piece,offline) %>% distinct()
toFix[toFix$offline=="2",]
# if everything looks ok and there are no offline==2, or you have fixed those where offline==2
data$dataChange[!is.na(data$offline) & is.na(obs$offline)] = paste(data$dataChange[!is.na(data$offline) & is.na(obs$offline)],
                                                     "; Changed OFFLINE from NA", sep="")
obs = data; rm(data, toFix)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 12: OUTPUT DATA 
# ---------------------------------------------------------------------------- #
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
cat("\nObservation files read:\n")
print(length(obs$year))
cat("\n\nNumber of observations read by crew and seat:\n")
print(out.obstab1)
cat("\n\nNumber of observations read by observer and seat:\n")
print(out.obstab2)
cat("Data processing completed on", date(), "\n")
sink()
