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
# STEP 3: create estimated transect lines 
# ---------------------------------------------------------------------------- #
one = cbind(rbind(c(-75.51966,36.86826),c(-75.4503,36.86826)),c(1,1),c("BEGCNT","ENDCNT"))
two = cbind(rbind(c(-75.51966,36.8844),c(-75.4503,36.8844)),c(2,2),c("BEGCNT","ENDCNT"))
three = cbind(rbind(c(-75.51966,36.90023),c(-75.4503,36.90023)),c(3,3),c("BEGCNT","ENDCNT"))
four = cbind(rbind(c(-75.51966,36.91702),c(-75.4503,36.91702)),c(4,4),c("BEGCNT","ENDCNT"))
five = cbind(rbind(c(-75.51966,36.93232),c(-75.4503,36.93232)),c(5,5),c("BEGCNT","ENDCNT"))
six = cbind(rbind(c(-75.51966,36.95019),c(-75.4503,36.95019)),c(6,6),c("BEGCNT","ENDCNT"))

track = rbind(one,two,three,four,five,six)
colnames(track) = c("lon","lat","piece","type")
track = as.data.frame(track)
track$lat = as.numeric(as.character(track$lat))
track$lon = as.numeric(as.character(track$lon))
plot(obs$lon[obs$offline==0],obs$lat[obs$offline==0],col="grey")
points(track$lon[track$type=="BEGCNT"],track$lat[track$type=="BEGCNT"],col="forest green",pch=20)
points(track$lon[track$type=="ENDCNT"],track$lat[track$type=="ENDCNT"],col="dark red",pch=20)
lines(one[,1],one[,2],col="red")
lines(two[,1],two[,2],col="orange")
lines(three[,1],three[,2],col="gold")
lines(four[,1],four[,2],col="green")
lines(five[,1],five[,2],col="blue")
lines(six[,1],six[,2],col="purple")
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 4: MAKE SPATIAL LINE OUTPUT FOR TRACK
# ---------------------------------------------------------------------------- #
L1 = Line(cbind(track$lon[track$piece==1],track$lat[track$piece==1]))
L2 = Line(cbind(track$lon[track$piece==2],track$lat[track$piece==2]))
L3 = Line(cbind(track$lon[track$piece==3],track$lat[track$piece==3]))
L4 = Line(cbind(track$lon[track$piece==4],track$lat[track$piece==4]))
L5 = Line(cbind(track$lon[track$piece==5],track$lat[track$piece==5]))
L6 = Line(cbind(track$lon[track$piece==6],track$lat[track$piece==6]))
Ls1 = Lines(list(L1), ID = "1")
Ls2 = Lines(list(L2), ID = "2")
Ls3 = Lines(list(L3), ID = "3")
Ls4 = Lines(list(L4), ID = "4")
Ls5 = Lines(list(L5), ID = "5")
Ls6 = Lines(list(L6), ID = "6")
latlong = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
SL = SpatialLines(list(Ls1, Ls2, Ls3, Ls4, Ls5, Ls6), proj4string = CRS(latlong))
SLDF = SpatialLinesDataFrame(SL, data.frame(piece = c("1","2","3","4","5","6")))
writeOGR(SLDF, dir.out, "VOWTAP", "ESRI Shapefile", morphToESRI = TRUE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 5: OUTPUT DATA 
# ---------------------------------------------------------------------------- #
save.image(paste(dir.out, "/", yearLabel, ".Rdata",sep=""))
write.csv(obs, file=paste(dir.out,"/", yearLabel,".csv", sep=""), row.names=FALSE)
write.csv(track, file=paste(dir.out,"/", yearLabel,"_EstimatedTrack.csv", sep=""), row.names=FALSE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 6: SUMMARY
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
