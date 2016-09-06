# --------------------------------- #
# StatOil ME Hywind BOEM
#
# created July 2016, Kaycee Coleman
# --------------------------------- #

require(geosphere) # used in fixSeconds function
require(rgdal) # for writeOGR
require(zoo) # fill in missing points
require(dplyr) # 
require(RODBC) # odbcConnect

# DEFINE SURVEY, CHANGE THIS!!!
surveyFolder = "BOEM_StatoilME/HywindME_BOEM_Statoil_20140115"
yearLabel = "HWME_Spatial_forBOEM_2012-2013"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress/StatOil", dir), sep = "/") 
speciesPath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/"

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))

# SET PATH TO R FILE THAT FIXES DATA ERRORS
errfix.file <- file.path(dir.out, paste(gsub("-","",yearLabel), "_ObsFilesFix.R", sep = ""))

# ---------------------------------------------------------------------------- #
# STEP 1: READ IN RAW OBSERVATION DATA (in this case, mixed with track data)
# ---------------------------------------------------------------------------- #
code <- odbcConnectExcel2007(xls.file = paste(dir.in, "/", yearLabel, ".xlsx", sep=""))
s1 <- sqlFetch(code, "Statoil_Hywind_Maine_Year_1")
s2 <- sqlFetch(code, "Statoil_Hywind_Maine_Year_2")
odbcClose(code); rm(code)
s2 = s2 %>% select(-F31,-F32,-F33,-F34,-F35,-F36,-F37,-F38)
s1 = s1 %>% select(-Cor_inflock) #no difference from __in_Flock
obs = rbind(s1,s2)
rm(s1,s2)

# shapefile
sf <- readOGR(dsn = file.path(paste(dir.in,"/To BOEM_Statoil_20140115/Hywind_Maine_AvianSurveys_2012-2013/",sep="")), 
              layer = "Statoil_BioSightings_2012_2013")
sfdf=as.data.frame(sf)
names(sfdf)[names(sfdf) == "X__in_Flock"] <- "__in_Flock"
sfdf = sfdf %>% select(-F25,-F26,-F27,-Cor_infloc,-coords.x1,-coords.x2) 
obs = rbind(obs, sfdf) 
rm(sfdf)
names(obs)[names(obs) == "SpeciesCor"] <- "type"
obs$type[!is.na(obs$Species__t) & is.na(obs$type)] = obs$Species__t[!is.na(obs$Species__t) & is.na(obs$type)]
obs$type[obs$type == ""] = obs$Species__t[obs$type==""]
obs = obs[!is.na(obs$type),]
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 2: OUTPUT COAST SURVEY DATA; FIX OBSERVATION FILE ERRORS
# ---------------------------------------------------------------------------- #
# REMOVE SPACES IN CERTAIN COLUMNS
obs <- commonErrors(obs)
obs <- fixMixed(obs) 

if (!file.exists(errfix.file)) {
  warning("Error fix R file is missing and will not be sourced.")
} else source(errfix.file, local = TRUE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 3: build transect

## what transect should look like based on mean points
#trans = cbind(c(-69.471,-69.49,-69.5086,-69.535,-69.5537,-69.5744,-69.5888),
#              c(43.557,43.512,43.556,43.487,43.541,43.4885,43.541))

## what transect should look like based on reports
trans = cbind(c(-69.471,-69.49,-69.5086,-69.535,-69.5537,-69.5744,-69.5888),
              c(43.556,43.5,43.556,43.487,43.541,43.4885,43.541))

trans = as.data.frame(trans)
names(trans) = c("lon","lat")

#plot(obs$lon,obs$lat, xlim = c(-69.59,-69.47), ylim = c(43.48,43.56))
#lines(trans$lon,trans$lat,col="red",lwd=3)

# spatial line shapefile
L1 = Line(cbind(trans$lon, trans$lat))
Ls1 = Lines(list(L1), ID = "1")
latlong = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
SL = SpatialLines(list(Ls1), proj4string = CRS(latlong))
SLDF = SpatialLinesDataFrame(SL, data.frame(piece = c("transect"), row.names = c("1")))
writeOGR(SLDF, dir.out, "StatOil", "ESRI Shapefile", morphToESRI = TRUE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# Define estimates start are end points of the transect
# ---------------------------------------------------------------------------- #
## did they always fly one way?
# split up into keys
obs$time = as.character(obs$time)
obs$time[is.na(obs$time)] = as.character(obs$gps_time[is.na(obs$time)])
obs$date_time = as.POSIXct(strptime(paste(obs$gps_date,obs$time,sep=" "),"%Y-%m-%d %I:%M:%S%p"))
#test = obs %>% select(gps_date, date_time, lon, lat) %>% filter(lat<43.6) %>% group_by(gps_date) %>% 
#  summarise(min_time = min(date_time), max_time = max(date_time)) 
## find lat/long
#for(a in 1:39){
#  test$min_lat[a] = obs$lat[obs$date_time == test$min_time[a]] 
#  test$max_lat[a] = obs$lat[obs$date_time == test$max_time[a]]
#  test$min_lon[a] = obs$lon[obs$date_time == test$min_time[a]] 
#  test$max_lon[a] = obs$lon[obs$date_time == test$max_time[a]]
#}

# match closest obs. point or add begin/end trans
# sort by date
start_lon = -69.471
start_lat = 43.556
end_lon = -69.5888
end_lat = 43.541

XX = obs %>% select(gps_date, date_time, lon, lat) %>% rowwise %>% 
  mutate(s.distance =  distm(c(start_lat, start_lon), c(as.numeric(lat), as.numeric(lon)), fun = distHaversine)) %>% 
  mutate(e.distance =  distm(c(end_lat, end_lon), c(as.numeric(lat), as.numeric(lon)), fun = distHaversine)) %>% 
  group_by(gps_date) %>% summarise(s.lat = lat[min(abs(s.distance))], 
                                   s.lon = lon[min(abs(s.distance))], 
                                   s.time = date_time[min(abs(s.distance))],
                                   e.lat = lat[min(abs(e.distance))], 
                                   e.lon = lon[min(abs(e.distance))], 
                                   e.time = date_time[min(abs(e.distance))])

# find which one is earlier in time to find direction
X = XX %>% summarise(min_time = min(date_time), max_time = max(date_time)) 

# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# STEP 5: OUTPUT DATA 
# ---------------------------------------------------------------------------- #
save.image(paste(dir.out, "/", yearLabel, ".Rdata",sep=""))
write.csv(obs, file=paste(dir.out,"/", yearLabel,".csv", sep=""), row.names=FALSE)
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


