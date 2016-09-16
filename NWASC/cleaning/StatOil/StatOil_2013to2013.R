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
obs$Comments = as.character(obs$Comments)
obs = rbind(obs, sfdf) 
rm(sfdf)
names(obs)[names(obs) == "SpeciesCor"] <- "type"
obs$type = as.character(obs$type)
obs$Species__t = as.character(obs$Species__t)
obs$type[!is.na(obs$Species__t) & is.na(obs$type)] = obs$Species__t[!is.na(obs$Species__t) & is.na(obs$type)]
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

## total distance
# test = cbind(trans[1:6,],trans[2:7,])
# names(test) = c("start_lon","start_lat","end_lon","end_lat")
# test %>%  rowwise %>% mutate(distance =  distm(c(start_lat, start_lon), c(end_lat, end_lon), fun = distHaversine)) 
# sum(test$distance)

#plot(obs$lon,obs$lat, xlim = c(-69.59,-69.47), ylim = c(43.48,43.56))
#lines(trans$lon,trans$lat,col="red",lwd=3)

# spatial line shapefile
L1 = Line(cbind(trans$lon, trans$lat))
Ls1 = Lines(list(L1), ID = "1")
latlong = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
SL = SpatialLines(list(Ls1), proj4string = CRS(latlong))
SLDF = SpatialLinesDataFrame(SL, data.frame(piece = c("transect"), row.names = c("1")))
writeOGR(SLDF, dir.out, "StatOil_transect", "ESRI Shapefile", morphToESRI = TRUE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# Define estimates start are end points of the transect
# ---------------------------------------------------------------------------- #
## did they always fly one way?
# No they did not...

# create a date_time index
# "gps time" and "time" are not always the same, which is an issue but we need time for each record
obs$time = as.character(obs$time)
obs$time[is.na(obs$time)] = as.character(obs$gps_time[is.na(obs$time)])
obs$date_time = as.POSIXct(strptime(paste(obs$gps_date,obs$time,sep=" "),"%Y-%m-%d %I:%M:%S%p"))
obs$time = sapply(strsplit(as.character(obs$date_time)," "), tail, 1) #removes am/pm and changes to 24h

# sort by time
obs = obs %>% arrange(date_time)
# assign an index
obs$index = row.names(obs)

# match closest obs. point to the beg/end of the transect
# sort by date
# find which one is earlier in time to find direction for flight to assign beg/end of transect
e_lon = -69.471 # east
e_lat = 43.556
w_lon = -69.5888 # west
w_lat = 43.541

XX = obs %>% select(gps_date, date_time, lon, lat, index) %>% filter(lat != "") %>% rowwise %>% 
  mutate(e.distance =  distm(c(e_lat, e_lon), c(as.numeric(lat), as.numeric(lon)), fun = distHaversine)) %>% 
  mutate(w.distance =  distm(c(w_lat, w_lon), c(as.numeric(lat), as.numeric(lon)), fun = distHaversine)) %>% 
  as.data.frame %>% 
  group_by(gps_date) %>% 
  summarise(e.lat = lat[which.min(abs(e.distance))], 
            e.lon = lon[which.min(abs(e.distance))], 
            e.time = date_time[which.min(abs(e.distance))],
            w.lat = lat[which.min(abs(w.distance))], 
            w.lon = lon[which.min(abs(w.distance))], 
            w.time = date_time[which.min(abs(w.distance))],
            w.index = index[which.min(abs(w.distance))],
            e.index = index[which.min(abs(e.distance))]) %>% 
  ungroup %>% rowwise %>%
  mutate(start.side = ifelse(e.time < w.time, "east", "west")) %>% 
  mutate(add.to.index = ifelse(e.lat[start.side == "east"] <= e_lat, "-0.1", "0.1")) %>% 
  mutate(add.to.index1 = ifelse(w.lat[start.side == "west"] <= w_lat, "-0.1", "0.1")) %>% 
  mutate(index.for.start = replace(add.to.index, is.na(add.to.index), add.to.index1)) %>% 
  select(-add.to.index,-add.to.index1) %>% 
  mutate(add.to.index = ifelse(e.lat[start.side == "west"] <= e_lat, "0.1", "-0.1")) %>% 
  mutate(add.to.index1 = ifelse(w.lat[start.side == "east"] <= w_lat, "0.1", "-0.1")) %>% 
  mutate(index.for.end = replace(add.to.index, is.na(add.to.index), add.to.index1)) %>% 
  select(-add.to.index,-add.to.index1) %>% 
  mutate(start.lat = ifelse(start.side == "east", e_lat, w_lat)) %>% 
  mutate(start.lon = ifelse(start.side == "east", e_lon, w_lon)) %>% 
  mutate(end.lat = ifelse(start.side == "east", w_lat, e_lat)) %>% 
  mutate(end.lon = ifelse(start.side == "east", w_lon, e_lon)) %>% 
  mutate(index.for.start = ifelse(start.side == "east",
                                as.numeric(index.for.start) + as.numeric(e.index),
                                as.numeric(index.for.start) + as.numeric(w.index))) %>% 
  mutate(index.for.end = ifelse(start.side == "east",
                                as.numeric(index.for.end) + as.numeric(w.index),
                                as.numeric(index.for.end) + as.numeric(e.index))) %>% 
  select(-w.lat,-w.lon,-e.lat,-e.lon,-w.time,-e.time,-w.index,-e.index) %>% as.data.frame 

# split starts from end data, reformat
starts = XX %>% select(gps_date, contains("start")) 
starts$type = "BEGTRAN"
# add waypoints
east.start = trans[2:6,]
west.start = cbind(rev(trans[[1]]),rev(trans[[2]]))
west.start = as.data.frame(west.start[2:6,])
names(west.start) = c("lon","lat")
east.start$type = "WAYPNT"
west.start$type = "WAYPNT"
east.start$order = 2:6
west.start$order = 2:6
starts$order = 1
names(starts) = c("gps_date","start.side","index","lat","lon","type","order")

for (a in 1:40) {
  if(starts$start.side[a]=="east") {new = east.start} else new = west.start
  new$gps_date = rep(starts$gps_date[a],5)
  starts = bind_rows(starts, new)
  rm(new)
}

ends = XX %>% select(gps_date, contains("end")) 
ends$type = "ENDTRAN"
names(ends) = c("gps_date","index","lat","lon","type")
track = bind_rows(starts, ends)
rm(XX, ends, starts)
track$order[track$type=="ENDTRAN"] = 7
track$transect = 1
track=track %>% arrange(gps_date,order) %>% select(-start.side)

# define transect/offline for observation points
obs$index = as.numeric(obs$index)
obs$lat = as.numeric(obs$lat)
obs$lon = as.numeric(obs$lon)
obs = bind_rows(obs,track[type %in% c("BEGTRAN","ENDTRAN"),])
obs = obs %>% arrange(index) %>% group_by(gps_date) %>% 
  mutate(offline = ifelse(index >= index[which(type == "BEGTRAN")] & 
                           index <= index[which(type == "ENDTRAN")], 0, 1)) %>% 
  mutate(transect = ifelse(offline == 0, 1, NA))
obs = obs %>% filter(!type %in% c("BEGTRAN","ENDTRAN")) %>% as.data.frame
# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# STEP 5: OUTPUT DATA 
# ---------------------------------------------------------------------------- #
save.image(paste(dir.out, "/", yearLabel, ".Rdata",sep=""))
write.csv(obs, file=paste(dir.out,"/", yearLabel,".csv", sep=""), row.names=FALSE)
write.csv(trans, file=paste(dir.out,"/", yearLabel,"_estimated_transect.csv", sep=""), row.names=FALSE)
write.csv(track, file=paste(dir.out,"/", yearLabel,"_estimated_track.csv", sep=""), row.names=FALSE)
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


