# ------------------------------------------------------------------------- #
## written by: Kaycee Coleman
## Oct. 2015
##
## This script should be run after processSurveyData_part1.R
## It will finalize the data for use
##
## This script was based off Jeff Lierness' ObsTrackEdit script
# ------------------------------------------------------------------------- #
#Define the function


# since most likely you are running part 2 at a later date than part 1
# install packages
require(rgdal) # read shapefiles
require(parallel) # used to make a cluster
require(RODBC) #for NWASC codes
library(plyr) #used to rename columns

# Set dir
dir <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/"
setwd(dir)
surveyFolder = "AMAPPS"
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
yearLabel = "AMAPPS_2013_09"
survey = "2013 Fall AMAPPS"
surveyNbr = 13
#source(file.path(paste(dir,"DataProcessing/Code",sep=""),"surveyPrompt.R"))
dir.out <- paste("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/Surveys", surveyFolder, yearLabel, sep = "/") 
dir.in = paste(dir.out, "edited_shapefiles",sep="/")
speciesPath <- paste(dir,"DataProcessing/",sep="")

# Link R functions
source(file.path(dir, "_Rfunctions/sourceDir.R"))
sourceDir(file.path(dir, "_Rfunctions"))
       
# Shapefile prompt to make sure shapefiles were edited before running this script
#source(file.path(paste(dir,"DataProcessing/Code",sep=""),"shapefilePrompt.R"))
       
# Upload obstack 
#obstrack = read.csv(paste(dir.out, "obstrack_part1.csv",sep="/"))
load(paste(dir.out,"obstrackWorkspace.Rdata",sep="/")) # use obstrack_part1.csv if workspace corrupt

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
shapefileDataframe = lapply(fileNames, function(x) BuildDataframe(x[1]))
shapefileDataframe = as.data.frame(do.call(rbind, shapefileDataframe))

# rename to compare to obstrack
colnames(shapefileDataframe)[colnames(shapefileDataframe)=="coords.x1"] <- "long"
colnames(shapefileDataframe)[colnames(shapefileDataframe)=="coords.x2"] <- "lat"

# remove duplicates that might have occured in this process
shapefileDataframe = shapefileDataframe[!duplicated(shapefileDataframe), ]

# compare old with new  
deletedPoints = rbind(shapefileDataframe, obstrack)
rownames(deletedPoints) = NULL #remove row.names
deletedPoints = deletedPoints[-(which(duplicated(deletedPoints[,1:11]) | duplicated(deletedPoints[,1:11], fromLast=TRUE))),]
# not using all rows for duplicates since some have NA or empty which come up as different rather than duplicate

# visually inspect that no files were misslabeled, and that edits look about right...
plot(shapefileDataframe$long,shapefileDataframe$lat)
points(deletedPoints$long,deletedPoints$lat,col="red")
ifelse(any(deletedPoints$type != "WAYPNT" & 
           deletedPoints$type != "BEGCNT" & 
           deletedPoints$type != "ENDCNT" & 
           deletedPoints$offline == 0),
       stop("You deleted an online observation point, please investigate this before continuing"),
       "No online observations were deleted in your edits")


# ------------------------------------------------------------------------- #
### STEP 15: FIX MISLABELED TRANSECTS
# ------------------------------------------------------------------------- #

# flag1 is the distance error flag for points > 2km from the transect line
# after edits, offline points are deleted but there are some that are just mislabeled
# These need to be fixed to the proper transect line code

# had issues when switching this to  "all_atlantic_flylines_wNE_extend" shapefile
trans <- readOGR(dsn = file.path(paste(dbpath, "GIS", sep="")), layer = "amapps_transects_new2014")
if (proj4string(trans) != "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") {
  trans <- spTransform(trans, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
}
trans$latidext = as.character(trans$latidext)
  
strt<-Sys.time(); 
cl <- makeCluster(as.numeric(detectCores()))
clusterExport(cl, "trans", envir = environment())
invisible(clusterEvalQ(cl, c(library(geosphere),
                             subFunc <- function(lat, lon, code) {
                               b = which(trans$latidext == paste(substr(code,1,5),"0", sep="") | 
                                         trans$latidext == paste(substr(code,1,5),"1", sep="") |
                                         trans$latidext == paste(substr(code,1,5),"2", sep="") |
                                         trans$latidext == paste(as.numeric(substr(code,1,4))+5, "00", sep="") |
                                         trans$latidext == paste(as.numeric(substr(code,1,4))-5, "00", sep="") |
                                         trans$latidext == paste(as.numeric(substr(code,1,4))+5, "01", sep="") |
                                         trans$latidext == paste(as.numeric(substr(code,1,4))-5, "01", sep="") |
                                         trans$latidext == paste(as.numeric(substr(code,1,4))+5, "02", sep="") |
                                         trans$latidext == paste(as.numeric(substr(code,1,4))-5, "02", sep=""))
                               subTrans = trans[b,]
                               ab = dist2Line(p = cbind(as.numeric(lon),as.numeric(lat)), 
                                              line = subTrans, distfun = distVincentyEllipsoid)
                               out = c(ab, b[ab[4]])
                               return(out)
                             })))

d <- parRapply(cl, shapefileDataframe[shapefileDataframe$flag1==1,], function(x) subFunc(x[35],x[34],x[11]))
stopCluster(cl)
d <- matrix(d, ncol = 5, byrow = TRUE) # distance(m), long, lat, code
print(Sys.time()-strt)

shapefileDataframe$dataChange = as.character(shapefileDataframe$dataChange)
shapefileDataframe$dataChange[shapefileDataframe$flag1==1] = paste(shapefileDataframe$dataChange[shapefileDataframe$flag1==1],
                                                                   "; Changed TRANSECT from ", 
                                                                   shapefileDataframe$transect[shapefileDataframe$flag1==1],
                                                                   sep="")
shapefileDataframe$transect[shapefileDataframe$flag1==1] = as.character(trans$latidext[d[,5]])
rm(trans, d)


# ------------------------------------------------------------------------- #
### STEP 16: ADD NECESSARY BEG/END ROWS TO GIS EDITED TRACK FILES
# this takes a while...
# ------------------------------------------------------------------------- #
track.final = addBegEnd_GISeditObsTrack(shapefileDataframe)
# ------------------------------------------------------------------------- #
  
  
# ------------------------------------------------------------------------- #
### STEP 17: VERIFY CONDITION CODE ERRORS ARE STILL FIXED AFTER GIS EDITS
# ------------------------------------------------------------------------- #
obs = subset(track.final, !type %in% c("", " "))
conditionCodeErrorChecks(obs, yearLabel)
# ------------------------------------------------------------------------- #

  
summary(track.final)
  

# ------------------------------------------------------------------------- #
### STEP 18: ADD REPLICATE COLUMN IF TRANSECT WAS FLOWN TWICE
# ------------------------------------------------------------------------- #

# Create replicate column for if a transect was flown more than once in a survey
track.final$replicate = 1
track.final$replicate[duplicated(substr(unique(paste(track.final$transect,track.final$day,sep="_")),1,6))] = 2
# need to check that this works


# ------------------------------------------------------------------------- #
### STEP 19: SAVE DELETED POINTS CSVs and DEFINE POINTS TO KEEP
# ------------------------------------------------------------------------- #

# Define points to keep #
track.final$keep = 1
track.final$keep[track.final$offline == 1 | track.final$band == 3] = 0
table(track.final$band, track.final$keep)
deletedPoints$keep = 0

# ADD OFFLINE OBSERVATIONS TO track.final #
# might want to check these before adding to make sure they make sense, have a BEGCNT and ENDCNT
deletedPoints[deletedPoints$offline==1,] # should be offline observations
deletedPoints$replicate = 1
track.final = rbind(track.final, deletedPoints[deletedPoints$offline==1,])

# save deleted points as a .csv
deletedPoints = deletedPoints[deletedPoints$offline == 0,]
write.csv(deletedPoints, file =paste(dir.out,"/deletedShapefilePoints_", yearLabel, "_Final.csv", sep=""), row.names=FALSE)

# save offline points as a .csv
offlinePoints = track.final[track.final$offline == 1,]
write.csv(offlinePoints, file =paste(dir.out,"/offlinePoints_", yearLabel, "_Final.csv", sep=""), row.names=FALSE)


# ------------------------------------------------------------------------- #
### STEP 20: SAVE MARINE MAMMALS/ FISH DATA TO SEND TO NOAA AMAPPS
# ID: 2 (mammals), 3 (reptiles), 4 (fish) in NWASC_codes table
# ------------------------------------------------------------------------- #

# GET SPECIES_INFORMATION TABLE FROM ATLANTIC COAST SURVEYS DATABASE
code <- odbcConnectExcel2007(xls.file = paste(speciesPath, "NWASC_codes.xlsx", sep=""))
spplist <- sqlFetch(code, "codes")$spp_cd
sppcode <- sqlFetch(code, "codes")$species_type_cd
odbcCloseAll()

# PULL MARINE DATA
tmp = track.final$type %in% c(as.character(spplist[sppcode=="2" | sppcode=="3" | sppcode=="4"]),
                              "HOCR","ALGA","BAIT","CAJE","KRILL","MACR","PMOW","RCKW","SARG","UNJE","ZOOP")
sort(unique(track.final$type[tmp]))
forNOAA = track.final[tmp,]
forNOAA = forNOAA[,!names(forNOAA) %in% c("dataError","transLat", "transLong", "flag1", "bearing", "sbearing", "flag2", 
                          "flag3", "onLand", "begend", "replicate", "keep")]
write.csv(forNOAA, file =paste(dir.out,"/forNOAA_", yearLabel, ".csv", sep=""), row.names=FALSE)


# ------------------------------------------------------------------------- #
### STEP 21: AMAPPS database vs. NWASC database seperation
# ------------------------------------------------------------------------- #

# include all birds & boats but not marine life
# if catagory 'species_type-cd' 2, 3, or 4 in NWASC_codes list exclude from AMAPPS access database

# NON-SURVEY SPECIES (all marine mammals, reptiles, and fish) 
tmp = !(track.final$type %in% c(as.character(spplist[sppcode=="1" | sppcode=="5"]), "", 
                                "BEGSEG", "BEGCNT", "ENDSEG", "ENDCNT", "COCH"))
sort(unique(track.final$type[tmp]))
track.final$keep[tmp] = 0
  
# SAVE EXTRANEOUS OBSERVATIONS TO FILE FOR DATABASE
track.final$survey = surveyNbr
obs.misc = subset(track.final, keep == 0, select = c(survey, crew, seat, obs, year, month, day, 
                                                     sec, lat, long, GPSerror, type, count, 
                                                     condition, band, comment)) #flightStatus,
names(obs.misc) = c("SurveyNbr", "Crew", "Seat", "Obs", "Year", "Month", "Day", "Sec", "Lat", "Long", 
                    "GpsError", "Species", "FlockSize", "Condition", "Band", "Comment") #"FlightStatus", 

# reorder and save both as offline (final) and misc (temp)
obs.misc = obs.misc[order(obs.misc$SurveyNbr, obs.misc$Crew, obs.misc$Seat, obs.misc$Obs, 
                          obs.misc$Year, obs.misc$Month, obs.misc$Day, obs.misc$Sec), ]
write.csv(obs.misc, file.path(dir.out, paste("OfflineObs", yearLabel, "_Final.csv", sep = "")), 
          row.names = FALSE, na = "")
write.csv(obs.misc, file.path(dir, "DataProcessing/temp_MiscObservations.csv"), 
          row.names = FALSE, na = "")
  
# REMOVE OFFLINE OBSERVATIONS FROM track.final #
track.final = subset(track.final, keep == 1)
track.final$keep = NULL
track.final$survey = NULL
summary(track.final)
  
  
# ------------------------------------------------------------------------- #
### STEP 22: OUTPUT FINAL EDITED TRACK FILE 
# ------------------------------------------------------------------------- #
# check files, create csvs for Missing observation files, Crew Summary
obsTrackFinalOutput(track.final, yearLabel, dir.in)
write.csv(track.final, file =paste(dir.out,"/obstrack_", yearLabel, "_Final.csv", sep=""), row.names=FALSE)
# ------------------------------------------------------------------------- #


# ------------------------------------------------------------------------- #
### STEP 23: TEMP OBS AND TRACK FILES FOR ATLANTIC COAST SURVEYS DATABASE 
#            (TEMP OBS.MISC ALREADY CREATED)
# ------------------------------------------------------------------------- #
# in DataProcessing folder, deleted after use
temp_Observations.csv
temp_Tracks.csv
temp_Transect_Information.csv
#temp_MiscObservations.csv (not going to make this, just going to put it in csv)
# ------------------------------------------------------------------------- #



# ------------------------------------------------------------------------- #
### STEP 24: ADD BOATS, BALLOONS, AND MISC. OBS TO EXCEL FILES
# ------------------------------------------------------------------------- #


# ADD BOAT OBSERVATIONS TO Atlantic_Coast_Surveys_BoatObservations.csv DATA FILE
boats = read.csv(file.path(dbpath, "Atlantic_Coast_Surveys_BoatObservations.csv"), stringsAsFactors = FALSE)
boats_to_add = track.final[track.final$type %in% c("BOTD","BOAC","BOAT","BOBA","BOCA","BOCF","BOCG","BOCR",
                                               "BOCS","BOFE","BOFI","BOLO","BOME","BONA","BOPL","BOPS",
                                               "BORF","BORV","BOSA","BOSU","BOTA","BOTU","BOWW","BOYA"),]

boats_to_add = rename(boats_to_add, c("transect"= "Transect", "replicate" = "Replicate", "crew" = "Crew", 
                                            "seat" = "Seat", "obs" = "Obs", "year" = "Year", "month" = "Month", 
                                            "day" = "Day", "sec" = "Sec", "lat"="Lat", "long"="Long", "GPSerror"="GpsError", 
                                            "type"="Species", "count"="FlockSize", "condition" = "Condition", "band" = "Band"))

boats_to_add$FlockSize[boats_to_add$FlockSize == 0] = 1 # CHANGE FLOCK SIZE FOR BOATS WHERE FLOCK SIZE == 0 TO 1
boats_to_add$SurveyNbr = surveyNbr
boats_to_add$Dist2Coast_m = ""  
boats_to_add$Dist2Coast_nm = ""   
boats_to_add$Depth = ""           
boats_to_add$Slope = ""   
if(any(boats$Species=="TRAW")) {boats$Species[boats$Species=="TRAW"]="BOTD"} # one time thing since Jeff used TRAW but NWASC code for trawler is BOTD
boats = rbind(boats, subset(boats_to_add, select=colnames(boats)))
if(any(duplicated(boats))) {boats = boats[!duplicated(boats, MARGIN = 1),]} # make sure there are not duplicates in case this is run more than once
write.csv(boats, file.path(dbpath, "Atlantic_Coast_Surveys_BoatObservations.csv"),  row.names = FALSE, na = "")


# ADD BALLOON OBSERVATIONS TO Atlantic_Coast_Surveys_BalloonObservations.csv DATA FILE
balloons = read.csv(file.path(dbpath, "Atlantic_Coast_Surveys_BalloonObservations.csv"), stringsAsFactors = FALSE)
balloons_to_add = track.final[track.final$type=="BALN",]
balloons_to_add = rename(balloons_to_add, c("transect"= "Transect", "replicate" = "Replicate", "crew" = "Crew", 
                          "seat" = "Seat", "obs" = "Obs", "year" = "Year", "month" = "Month", 
                          "day" = "Day", "sec" = "Sec", "lat"="Lat", "long"="Long", "GPSerror"="GpsError", 
                          "type"="Species", "count"="FlockSize", "condition" = "Condition", "band" = "Band"))
balloons_to_add$SurveyNbr = surveyNbr
balloons_to_add$Dist2Coast_m = ""  
balloons_to_add$Dist2Coast_nm = ""   
balloons_to_add$Depth = ""           
balloons_to_add$Slope = ""   
balloons = rbind(balloons, subset(balloons_to_add, select=colnames(balloons)))
if(any(duplicated(balloons))) {balloons = balloons[!duplicated(balloons),]} # make sure there are not duplicates in case this is run more than once
write.csv(balloons, file.path(dbpath, "Atlantic_Coast_Surveys_BalloonsObservations.csv"), row.names = FALSE, na = "")

# ADD MISCELLANEOUS OBSERVATIONS TO Atlantic_Coast_Surveys_MiscObservations.csv DATA FILE
obs.misc = read.csv(file.path(dbpath, "Atlantic_Coast_Surveys_MiscObservations.csv"), stringsAsFactors = FALSE)
obs.misc.add = read.csv(file.path(dir, "DataProcessing/temp_MiscObservations.csv"), stringsAsFactors = FALSE)
obs.misc = rbind(obs.misc, obs.misc.add)
obs.misc = obs.misc[order(obs.misc$SurveyNbr, obs.misc$Crew, obs.misc$Seat, obs.misc$Obs, 
                          obs.misc$Year, obs.misc$Month, obs.misc$Day, obs.misc$Sec), ]
write.csv(obs.misc, file.path(dbpath, "Atlantic_Coast_Surveys_MiscObservations.csv"),  row.names = FALSE, na = "")
# ------------------------------------------------------------------------- #
