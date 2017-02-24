# ------------------------------------------------------------------------- #
## written by: Kaycee Coleman
## Oct. 2015
##
## This script should be run after processSurveyData_part1.R
## It will finalize the data for use
##
## This script was based off Jeff Lierness' ObsTrackEdit script
# ------------------------------------------------------------------------- #


# since most likely you are running part 2 at a later date than part 1
# install packages
require(rgdal) # read shapefiles
require(parallel) # used to make a cluster
library(gmt) #geodist
require(geosphere) #dist2Line
library(sp) #SpatialLines from SpatialLinesDataFrame
library(FNN) #nearest neighbor
require(xlsx) # read excel file
require(RODBC) # odbcConnect
library(rgeos)
library(dplyr) # %>%

# Set dir
dir <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder"
setwd(dir)
surveyFolder = "AMAPPS"
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
yearLabel = "AMAPPS_2014_10"
survey = "2014 Fall AMAPPS"
surveyNbr = 15
#source(file.path(paste(dir,"DataProcessing/Code",sep=""),"surveyPrompt.R"))
dir.out <- paste(dir,"DataProcessing/Surveys", surveyFolder, yearLabel, sep = "/") 

# Link R functions
source(file.path(dir, "_Rfunctions/sourceDir.R"))
sourceDir(file.path(dir, "_Rfunctions"))

# Shapefile prompt to make sure shapefiles were edited before running this script
#source(file.path(paste(dir,"DataProcessing/Code",sep=""),"shapefilePrompt.R"))

# Upload obstack 
#obstrack = read.csv(paste(dir.out, "obstrack_part1.csv",sep="/"))
load(paste(dir.out,"obstrack_part1.Rdata",sep="/")) # use obstrack_part1.csv if workspace corrupt

# redo because dir out changed when we load part1
dir.out <- paste(dir,"DataProcessing/Surveys", surveyFolder, yearLabel, sep = "/") 
dir.in = paste(dir.out, "edited_shapefiles",sep="/")
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 14: IMPORT EDITED SHAPEFILES
# ------------------------------------------------------------------------- #
# These shapefiles have been edited from the original and
# flagged points deemed unworthy have been deleted
# flag 1: greater than 2 km from the defined transect line
#         there might be a typo in the transect for these files
# flag 2: greater than a right turn (bearing > 100) from the point prior
# flag 3: obstrack$transLat == 0 | obstrack$sbearing < 70 | (obstrack$sbearing > 110 & obstrack$sbearing < 250) | obstrack$sbearing > 290
# onLand: points on land

# check that all shapefiles have been edited and are in the edited shapefiles folder
fileNames = unique(obstrack$key)
shapefileNames = unique(unlist(strsplit(list.files(dir.in, pattern = "Crew"),".",fixed=T)))
shapefileNames = shapefileNames[nchar(shapefileNames)>4]
ifelse(all(sort(shapefileNames)==sort(fileNames)),
       "All shapefiles are edited",
       stop("You are missing a shapefile"))


# read in shapefiles
# combine into one dataframe

shapefileDataframe = as.data.frame(matrix(ncol=35,nrow=0))
colnames(shapefileDataframe) = c(colnames(obstrack)[3:35],"coords.x1","coords.x2")
BuildDataframe <- function(shapefile) {
  newShapefile = readOGR(dsn = dir.in, layer = shapefile)
  newShapefileDataframe <- as(newShapefile, "data.frame")
  shapefileDataframe = rbind(shapefileDataframe, newShapefileDataframe)
  return(shapefileDataframe)
}
shapefileDataframe = lapply(shapefileNames, function(x) BuildDataframe(x[1]))
shapefileDataframe = as.data.frame(do.call(rbind, shapefileDataframe))

# rename to compare to obstrack
shapefileDataframe = rename(shapefileDataframe, long = coords.x1, lat = coords.x2)

# remove duplicates that might have occured in this process
shapefileDataframe = shapefileDataframe[!duplicated(shapefileDataframe), ]

# compare old workspace with edited shapefiles to see what was deleted   
deletedPoints = rbind(shapefileDataframe, obstrack)
rownames(deletedPoints) = NULL #remove row.names
ind = paste(deletedPoints$key,deletedPoints$sec, deletedPoints$type, sep="_")
deletedPoints = deletedPoints[!(duplicated(ind) | duplicated(ind, fromLast=TRUE)),]
rm(ind)
deletedPoints = deletedPoints[!is.na(deletedPoints$day),]
# not using all rows for duplicates since some have NA or empty which come up as different rather than duplicate

# visually inspect that no files were deleted, and that edits look about right...
plot(shapefileDataframe$long,shapefileDataframe$lat)
points(deletedPoints$long,deletedPoints$lat,col="red")
ifelse(any(!deletedPoints$type %in% c("WAYPNT","BEGCNT","ENDCNT") & deletedPoints$offline == 0),
       stop("You deleted an online observation point, please investigate this before continuing"),
       "No online observations were deleted in your edits")

# investigate deleted points
# grab those that are species observaitons
# add if offline and was deleted by accident or change to offline
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
sppcode <- sqlFetch(db, "lu_species")$spp_type_cd # used later when breaking apart data
odbcClose(db)

if(any(deletedPoints$type %in% spplist)) {
  x = deletedPoints[deletedPoints$type %in% spplist,]
  x$offline = 1
  shapefileDataframe = bind_rows(shapefileDataframe,x) 
  rm(x)
}

# corrections from investigation 
if (file.exists(paste(dir.out,"postGISEdits.R",sep="/"))) {
  source(paste(dir.out,"postGISEdits.R",sep="/"))}
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 15: IF THERE ARE STILL DISTANCE ERRORS (e.g. labeled as wrong transect) 
# REDEFINE TRANSECT
# ------------------------------------------------------------------------- #
if(any(shapefileDataframe$flag1==1)) {
  # find closest point to line 
  data = shapefileDataframe[shapefileDataframe$flag1==1,]
  data$dataChange = paste(data$dataChange, "; Changed transect from ", data$transect, sep="")
  coordinates(shapefileDataframe) = cbind(shapefileDataframe$long, shapefileDataframe$lat)
  
  trans <- readOGR(dsn = file.path(paste(dbpath, "GIS", sep="")), layer = "amapps_transects_new2014")
  if (proj4string(trans) != "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") {
    trans <- spTransform(trans, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  }
  
  m = gDistance(shapefileDataframe, trans, byid=TRUE)
  shapefileDataframe$transect2 = trans@data$latidext[as.numeric(apply(m, 2, function(X) rownames(m)[order(X)][1]))+1] # +1 since row starts at 0 instead of 1
  
  shapefileDataframe$transect[shapefileDataframe$ID %in% data$ID] = data$transect
  rm(data, trans, m)
}
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 16: ADD NECESSARY BEG/END ROWS TO GIS EDITED TRACK FILES
# this takes a while...
# ------------------------------------------------------------------------- #
track.final = addBegEnd_GISeditObsTrack(shapefileDataframe)

# after inspection, corrections if BEG/END counts are added when not needed 
if (file.exists(paste(dir.out,"postGIS_BEGEND_Edits.R",sep="/"))) {
  source(paste(dir.out,"postGIS_BEGEND_Edits.R",sep="/"))}
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 17: VERIFY CONDITION CODE ERRORS ARE STILL FIXED AFTER GIS EDITS
# ------------------------------------------------------------------------- #
obs = subset(track.final, !type %in% c("", " ", NA))
conditionCodeErrorChecks(obs, yearLabel)
# ------------------------------------------------------------------------- #


summary(track.final)


# ------------------------------------------------------------------------- #
### STEP 18: ADD REPLICATE COLUMN IF TRANSECT WAS FLOWN TWICE
# ------------------------------------------------------------------------- #
# Create replicate column for if a transect was flown more than one day in a survey
track.final$replicate = 1
track.final$comment= as.character(track.final$comment)
ind = unique(paste(track.final$transect, track.final$seat, track.final$day,sep="_"))
if (any(duplicated(substr(ind,1,9)))) {
  track.final$replicate[track.final$transect %in% substr(ind[duplicated(substr(ind,1,9))],1,6) &
                          track.final$seat %in% substr(ind[duplicated(substr(ind,1,9))],8,9) & 
                          track.final$day %in% substr(ind[duplicated(substr(ind,1,9))],11,12)] = 2
  track.final$comment[track.final$transect %in% substr(ind[duplicated(substr(ind,1,9))],1,6) &
                        track.final$seat %in% substr(ind[duplicated(substr(ind,1,9))],8,9) &
                        track.final$day %in% substr(ind[duplicated(substr(ind,1,9))],11,12)] = 
    paste(track.final$comment[track.final$transect %in% substr(ind[duplicated(substr(ind,1,9))],1,6) &
                                track.final$seat %in% substr(ind[duplicated(substr(ind,1,9))],8,9) &
                                track.final$day %in% substr(ind[duplicated(substr(ind,1,9))],11,12)],
          "; Transect flown more than one day ", sep="")
}
rm(ind)
#
###### this code snippet needs work since a replicate could occur on the same day #########
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 19: SAVE DELETED POINTS CSVs and DEFINE POINTS TO KEEP
# ------------------------------------------------------------------------- #
# Define points to keep #
track.final$keep = 1
track.final$keep[track.final$offline == 1 | track.final$band == 3] = 0
table(track.final$band, track.final$keep)

# save deleted points as a .csv
deletedPoints = deletedPoints[deletedPoints$offline == 0,]
write.csv(deletedPoints, file =paste(dir.out,"/", yearLabel, "_DeletedShapefilePoints.csv", sep=""), row.names=FALSE)
rm(deletedPoints)
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 20: SAVE MARINE MAMMALS/ FISH DATA TO SEND TO NOAA AMAPPS
# ID: 2 (mammals), 3 (reptiles), 4 (fish) in NWASC_codes table
# ------------------------------------------------------------------------- #
# GET SPECIES_INFORMATION TABLE 
# PULL MARINE DATA
tmp = track.final$type %in% c(as.character(spplist[sppcode=="2" | sppcode=="3" | sppcode=="4"]),
                              "HOCR","ALGA","BAIT","CAJE","KRILL","MACR","PMOW","RCKW","SARG","UNJE","ZOOP")
sort(unique(track.final$type[tmp]))
forNOAA = track.final[tmp,]
forNOAA = forNOAA[,!names(forNOAA) %in% c("dataError","transLat", "transLong", "flag1", "bearing", "sbearing", "flag2", 
                                          "flag3", "onLand", "begend", "replicate", "keep")]
write.csv(forNOAA, file =paste(dir.out, "/", yearLabel, "_Send2NOAA.csv", sep=""), row.names=FALSE)
rm(forNOAA)
# ------------------------------------------------------------------------- #



# RENAME TO MATCH HEADERS IN DOCUMENTS
if (is.null(track.final$flightStatus)) track.final$flightStatus = NA
track.final = rename(track.final, Transect = transect, Replicate = replicate, Crew = crew, 
                     Seat = seat, Obs = obs, Year = year, Month = month, Day = day,
                     Sec = sec, Lat = lat, Long = long, GpsError = GPSerror, 
                     Species = type, FlockSize = count, Condition = condition, 
                     Band = band, Comment = comment, FlightStatus = flightStatus)
track.final$SurveyNbr = surveyNbr



# ----------------------------------------------------------------------- #
# TRACK TABLE
# ----------------------------------------------------------------------- #
trackTbl = track.final[track.final$Species %in% c("WAYPNT","BEGSEG", "BEGCNT", "ENDSEG", "ENDCNT", "COCH"),]
trackTbl$Species[trackTbl$Species=="BEGSEG"] = "BEGTRAN" 
trackTbl$Species[trackTbl$Species=="ENDSEG"] = "ENDTRAN" 
trackTbl$begend = 0
trackTbl$begend[grepl("BEG", trackTbl$Type)] = -1
trackTbl$begend[grepl("END", trackTbl$Type)] = 1
trackTbl$coch = 0
trackTbl$coch[trackTbl$Type == "COCH" & trackTbl$Condition == 0] = 1
trackTbl = trackTbl[order(trackTbl$SurveyNbr, trackTbl$Transect, trackTbl$Replicate, trackTbl$Crew, 
                      trackTbl$Seat, trackTbl$Obs, trackTbl$Year, trackTbl$Month, trackTbl$Day, 
                      trackTbl$Sec, trackTbl$begend, trackTbl$coch), ]
trackTbl$MissingTrackFile = NULL
trackTbl$begend = NULL
trackTbl$coch = NULL
write.csv(trackTbl, file =paste(dir.out,"/", yearLabel, "_Tracks.csv", sep=""), row.names=FALSE)


# ------------------------------------------------------------------------- #
# ADD COVARIATES TO OBSERVATIONS (DEPTH, SLOPE, DISTANCE TO COAST)
# ------------------------------------------------------------------------- #
track.final = track.final[!track.final$Species %in% c("WAYPNT","COCH"),]


nnSearch <- function(inCoords, refCoords, covariate, toPull) {
  x = inCoords[,c("Lat","Long")]  
  ref = refCoords[,c("Lat","Long")]  # note names have to be the same
  nns <- get.knnx(ref, x, k=1) 
  matched <- covariate[nns$nn.index, toPull] # to pull = c("lat","lon") or "depth" etc. variable name in ref df
  return(matched)
}

# coastline
coastline <- read.csv(paste(dir,"/DataProcessing/coastline.csv",sep=""))
nnCoords = nnSearch(track.final, coastline, coastline, c("Long","Lat"))
track.final$nnLong = nnCoords$Long
track.final$nnLat = nnCoords$Lat
track.final$Dist2Coast_m = distVincentySphere(cbind(track.final$Long, track.final$Lat), cbind(track.final$nnLong,track.final$Lat))
track.final$Dist2Coast_nm = track.final$Dist2Coast_m * 0.000539957
track.final = track.final[,!colnames(track.final) %in% c("nnLong","nnLat")]
rm(coastline, nnCoords)

# Ignoring depth and slope for now
# these are calculated using Jeff's old "add2database.R" script which at the moment I am not running
# they can be found in "CalbObsCovariates.py" ... 
track.final$Depth = ""           
track.final$Slope = ""   

# ------------------------------------------------------------------------- #
### STEP 21: ADD BOATS, BALLOONS, AND MISC. OBS TO EXCEL FILES
# ------------------------------------------------------------------------- #

# ADD BOAT OBSERVATIONS TO Atlantic_Coast_Surveys_BoatObservations.csv DATA FILE
boats = read.csv(file.path(dbpath, "Atlantic_Coast_Surveys_BoatObservations.csv"), stringsAsFactors = FALSE)
boats_to_add = track.final[track.final$Species %in% c("BOTD","BOAC","BOAT","BOBA","BOCA","BOCF","BOCG","BOCR",
                                                   "BOCS","BOFE","BOFI","BOLO","BOME","BONA","BOPL","BOPS",
                                                   "BORF","BORV","BOSA","BOSU","BOTA","BOTU","BOWW","BOYA"),]
boats_to_add$FlockSize[boats_to_add$FlockSize == 0] = 1 # CHANGE FLOCK SIZE FOR BOATS WHERE FLOCK SIZE == 0 TO 1
if(any(boats$Species=="TRAW")) {boats$Species[boats$Species=="TRAW"]="BOTD"} # one time thing since Jeff used TRAW but NWASC code for trawler is BOTD
boats = rbind(boats, subset(boats_to_add, select=colnames(boats)))
boats = boats[complete.cases(boats[,10:12]),] # get rid of NA rows that might pop up
if(any(duplicated(boats[,1:15]))) {boats = boats[!duplicated(boats[,1:15]),]} # make sure there are not duplicates in case this is run more than once
write.csv(boats, file.path(dbpath, "Atlantic_Coast_Surveys_BoatObservations.csv"),  row.names = FALSE, na = "")
rm(boats, boats_to_add)


# ADD BALLOON OBSERVATIONS TO Atlantic_Coast_Surveys_BalloonObservations.csv DATA FILE
balloons = read.csv(file.path(dbpath, "Atlantic_Coast_Surveys_BalloonObservations.csv"), stringsAsFactors = FALSE)
balloons_to_add = track.final[track.final$Species=="BALN",]
balloons = rbind(balloons, subset(balloons_to_add, select=colnames(balloons)))
balloons = balloons[complete.cases(balloons[,14]),] # get rid of NA rows that might pop up
if(any(duplicated(balloons[,1:15]))) {balloons = balloons[!duplicated(balloons[,1:15]),]} # make sure there are not duplicates in case this is run more than once
write.csv(balloons, file.path(dbpath, "Atlantic_Coast_Surveys_BalloonsObservations.csv"), row.names = FALSE, na = "")
rm(balloons, balloons_to_add)


# ADD MISCELLANEOUS OBSERVATIONS TO Atlantic_Coast_Surveys_MiscObservations.csv DATA FILE
# SAVE EXTRANEOUS OBSERVATIONS TO FILE FOR NWASC DATABASE
obs.misc_to_add = subset(track.final, keep == 0, select = c(SurveyNbr, Crew, Seat, Obs, Year, Month, Day, 
                                                     Sec, Lat, Long, GpsError, Species, FlockSize, 
                                                     Condition, Band, Comment, FlightStatus))
# reorder and save both as offline (final) and misc (temp)
obs.misc_to_add = obs.misc_to_add[order(obs.misc_to_add$SurveyNbr, obs.misc_to_add$Crew, obs.misc_to_add$Seat, 
                                        obs.misc_to_add$Obs, obs.misc_to_add$Year, obs.misc_to_add$Month, 
                                        obs.misc_to_add$Day, obs.misc_to_add$Sec), ]
write.csv(obs.misc_to_add, file.path(dir.out, paste(yearLabel, "OfflineObs_Final.csv", sep = "_")), row.names = FALSE, na = "")

obs.misc = read.csv(file.path(dbpath, "Atlantic_Coast_Surveys_MiscObservations.csv"), stringsAsFactors = FALSE)
obs.misc = rbind(obs.misc, obs.misc_to_add)
obs.misc = obs.misc[complete.cases(obs.misc[,12]),] # get rid of NA rows that might pop up
if(any(duplicated(obs.misc[,1:13]))) {obs.misc = obs.misc[!duplicated(obs.misc[,1:13]),]} # make sure there are not duplicates in case this is run more than once
write.csv(obs.misc, file.path(dbpath, "Atlantic_Coast_Surveys_MiscObservations.csv"),  row.names = FALSE, na = "")
rm(obs.misc,obs.misc_to_add)
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 22: AMAPPS database vs. NWASC database seperation
# ------------------------------------------------------------------------- #

# ----------------------------------------------------------------------- #
# TRANSECT INFORMATION TABLE FOR ATLANTIC COAST SURVEYS DATABASE
  # ----------------------------------------------------------------------- #

# average condition is weighted by distance flown at each observation condition
# distance flown per transect is in nautical miles, distance between points in meters 
df = track.final %>% group_by(SurveyNbr,Transect,Replicate,Crew,Seat,Obs)  %>% 
  mutate(lon = lead(Long, default = last(Long), order_by = index),
         lat = lead(Lat, default = last(Lat), order_by = index)) %>%
  rowwise() %>% mutate(distance = distVincentySphere(c(Long, Lat), c(lon, lat))) %>%
  select(-lon, -lat) %>% group_by(SurveyNbr,Transect,Replicate,Crew,Seat,Obs) %>%  
  summarise(AvgCondition = as.numeric(weighted.mean(Condition, distance)), 
            DistFlown = sum(distance)*0.000539957,
            minDay = min(Day), maxDay = max(Day),
            minMonth = min(Month), maxMonth = max(Month),
            minYear = min(Year), maxYear = max(Year))  %>%
  ungroup()
df$StartDt = paste(df$minMonth,"/", df$minDay, "/", df$minYear,sep="")
df$EndDt = paste(df$maxMonth,"/", df$maxDay, "/", df$maxYear,sep="")
df = subset(df, select=-c(minYear, minMonth, minDay, maxYear, maxMonth, maxDay))

# Check that the output looks ok...
head(df)

# Check that there isn't an Av. condition of zero
if(df$AvgCondition==0) {
  print("Average condition of zero. The following transects need to be investigated: ")
  df[df$AvgCondition==0,]}

# Columns in the ACS db that we should probably do something about but need to talk about it...
df$ACWSD=""
df$ACWSDreport=""
df$WindArea=""
df$MissingTrackFile=""
df$ImputedDistFlown=""

df = df[order(df$SurveyNbr, df$Transect, df$Replicate, df$Crew, df$Seat, df$Obs), ]

write.csv(df, file = paste(dir.out, "/", yearLabel, "_Transect_Information.csv", sep=""), row.names=FALSE)
rm(df)

  
# include all birds & boats but not marine life
# if catagory 'species_type-cd' 2, 3, or 4 in NWASC_codes list exclude from AMAPPS access database

# NON-SURVEY SPECIES (all marine mammals, reptiles, and fish) CHANGE KEEP TO 0
# out of species code 5 only boats (listed) and balloons go into ACS database
# species code 1 is all birds
tmp = !(track.final$type %in% c(as.character(spplist[sppcode=="1"],  
                                                     "BEGSEG", "BEGCNT", "ENDSEG", "ENDCNT", "COCH", "BALN",
                                                     "BOTD","BOAC","BOAT","BOBA","BOCA","BOCF","BOCG","BOCR",
                                                     "BOCS","BOFE","BOFI","BOLO","BOME","BONA","BOPL","BOPS",
                                                     "BORF","BORV","BOSA","BOSU","BOTA","BOTU","BOWW","BOYA")))
sort(unique(track.final$Species[tmp]))
track.final$keep[tmp] = 0

# REMOVE OFFLINE OBSERVATIONS FROM track.final for Atlantic Coast Survey Access Database#
track.final.ACS = track.final[!track.final$Species %in% c("WAYPNT","BEGSEG", "BEGCNT", "ENDSEG", "ENDCNT", "COCH"),]
track.final.ACS = subset(track.final.ACS, keep == 1)
track.final.ACS$keep = NULL
track.final.ACS$survey = NULL
summary(track.final.ACS)

track.final.ACS = track.final.ACS[order(track.final.ACS$SurveyNbr, track.final.ACS$Transect, 
                                        track.final.ACS$Replicate, track.final.ACS$Crew, 
                                        track.final.ACS$Seat, track.final.ACS$Obs, 
                                        track.final.ACS$Year, track.final.ACS$Month, 
                                        track.final.ACS$Day, track.final.ACS$Sec), ]

# OBS TABLE
write.csv(track.final.ACS, file = paste(dir.out,"/", yearLabel,"_Observations.csv", sep=""), row.names=FALSE)
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 23: OUTPUT FINAL EDITED TRACK FILE 
# ------------------------------------------------------------------------- #
# This includes all observations (even marine)
obsTrackFinalOutput(track.final, yearLabel, dir.out)
write.csv(track.final, file =paste(dir.out,"/", yearLabel, "_Obstrack_Final.csv", sep=""), row.names=FALSE)
save.image(paste(dir.out,"obstrack_final.Rdata",sep="/"))
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
# NEXT STEP...
# TO IMPORT DATA INTO THE ACS DATABASE USE add2ACSDatabase.R
# THIS DATABASE IS IN TRANSITION
# A NEW SQL SERVER DATABASE HAS BEEN CREATED AND IS BEING TESTED
# ------------------------------------------------------------------------- #





