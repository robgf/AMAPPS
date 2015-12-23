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

# Set dir
dir <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/"
setwd(dir)
surveyFolder = "AMAPPS/"
dbpath <- gsub("Jeff_Working_Folder", "DataBase", dir)
source(file.path(paste(dir,"DataProcessing/Code",sep=""),"yearLabelPrompt.R"))
source(file.path(paste(dir,"DataProcessing/Code",sep=""),"surveyPrompt.R"))
source(file.path(paste(dir,"DataProcessing/Code",sep=""),"surveyNumberPrompt.R"))
dir.out <- paste("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/Surveys/", surveyFolder, yearLabel, sep = "") 
       
# Link R functions
source(file.path(dir, "_Rfunctions/sourceDir.R"))
sourceDir(file.path(dir, "_Rfunctions"))
       
# Shapefile prompt to make sure shapefiles were edited before running this script
source(file.path(paste(dir,"DataProcessing/Code",sep=""),"shapefilePrompt.R"))
       
# Upload obstack 
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
dir.in = paste(dir.out, "edited_shapefiles",sep="/")
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

trans <- readOGR(dsn = file.path(paste(dbpath, "GIS", sep="")), layer = "all_atlantic_flylines_wNE_extend")
if (proj4string(trans) != "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") {
  trans <- spTransform(trans, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
}

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
### STEP 18: SAVE DELETED POINTS CSVs and DEFINE POINTS TO KEEP
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
track.final = rbind(track.final, deletedPoints[deletedPoints$offline==1,])

# save deleted points as a .csv
deletedPoints = deletedPoints[deletedPoints$offline == 0,]
write.csv(deletedPoints, file =paste(dir.out,"/deletedShapefilePoints_", yearLabel, "_Final.csv", sep=""), row.names=FALSE)

# save offline points as a .csv
#offlinePoints = track.final[track.final$offline == 1,]
#write.csv(offlinePoints, file =paste(dir.out,"/offlinePoints_", yearLabel, "_Final.csv", sep=""), row.names=FALSE)

# ------------------------------------------------------------------------- #
### STEP 20: AMAPPS database vs. NWASC database seperation
# ------------------------------------------------------------------------- #

# include all birds & boats but not marine life
# if catagory 'species_type-cd' 2, 3, or 4 in NWASC_codes list exclude from AMAPPS access database

# GET SPECIES_INFORMATION TABLE FROM ATLANTIC COAST SURVEYS DATABASE
code <- odbcConnectExcel2007(xls.file = paste(speciesPath, "NWASC_codes.xlsx", sep=""))
spplist <- sqlFetch(code, "codes")$spp_cd
sppcode <- sqlFetch(code, "codes")$species_type_cd
odbcCloseAll()
  
# NON-SURVEY SPECIES (all marine mammals, reptiles, and fish)
tmp = !(track.final$type %in% c(as.character(spplist[sppcode=="1" | sppcode=="5"]), "", 
                                "BEGSEG", "BEGCNT", "ENDSEG", "ENDCNT", "COCH"))
sort(unique(track.final$type[tmp]))
track.final$keep[tmp] = 0
  
# SAVE EXTRANEOUS OBSERVATIONS TO FILE FOR DATABASE
track.final$survey = surveyNbr
obs.misc = subset(track.final, keep == 0, select = c(survey, crew, seat, obs, year, month, day, 
                                                     sec, lat, long, GPSerror, type, count, 
                                                     condition, band, flightStatus, comment))
names(obs.misc) = c("SurveyNbr", "Crew", "Seat", "Obs", "Year", "Month", "Day", "Sec", "Lat", "Long", 
                    "GpsError", "Species", "FlockSize", "Condition", "Band", "FlightStatus", "Comment")
#obs.misc[obs.misc$Species %in% c("GEAR", "TRAW"), ]
tmp = obs.misc$Species %in% c("BOTD","BOAC","BOAT","BOBA","BOCA","BOCF","BOCG","BOCR",
                              "BOCS","BOFE","BOFI","BOLO","BOME","BONA","BOPL","BOPS",
                              "BORF","BORV","BOSA","BOSU","BOTA","BOTU","BOWW",
                              "BOYA") & obs.misc$FlockSize == 0 #!= 1 #c("GEAR", "TRAW")
obs.misc[tmp, ]
#tmp[max(which(tmp))] = FALSE
#obs.misc[tmp, ]
obs.misc$Comment[tmp] = paste(obs.misc$Comment[tmp], "; Changed FlockSize from 0", sep="")#obs.misc$FlockSize[tmp])
obs.misc$FlockSize[tmp] = 1
obs.misc[tmp, ]
obs.misc = obs.misc[order(obs.misc$SurveyNbr, obs.misc$Crew, obs.misc$Seat, obs.misc$Obs, 
                          obs.misc$Year, obs.misc$Month, obs.misc$Day, obs.misc$Sec), ]
write.csv(obs.misc, file.path(path, paste("OfflineObs", yearlab, "_Final.csv", sep = "")), 
          row.names = FALSE, na = "")
#write.csv(obs.misc, file.path(dir, "DataProcessing/temp_MiscObservations.csv"), 
#          row.names = FALSE, na = "")
  
# REMOVE OFFLINE OBSERVATIONS FROM track.final #
track.final = subset(track.final, keep == 1)
track.final$keep = NULL
track.final$survey = NULL
summary(track.final)
  
  
# ------------------------------------------------------------------------- #
### STEP 21: OUTPUT FINAL EDITED TRACK FILE & ADD TO ACCESS DATABASE
# ------------------------------------------------------------------------- #
# check files, create csvs for Missing observation files, Crew Summary
obsTrackFinalOutput(track.final, yearLabel, dir.in)
write.csv(track.final, file =paste(dir.out,"/obstrack_", yearLabel, "_Final.csv", sep=""), row.names=FALSE)
# ------------------------------------------------------------------------- #
