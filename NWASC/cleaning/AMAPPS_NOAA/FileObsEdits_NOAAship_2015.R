# ------------------------------------------------------------------------- #
# NOAA/ NMFS/ NEFSC boat 2015
# Date Created: 9-2015
# Author: Kaycee Coleman
#
# ------------------------------------------------------------------------- #

# load necessary functions (generic for all surveys)
# CHECK WHICH COMPUTER: LAPTOP OR FWS DESKTOP
cpu = if (file.exists("M:/")) "work" else "home"

# SET PATH TO DATA DIRECTORY
dir = if (cpu == "work") file.path("M:/seabird_database/Kaycee_Working_Folder") else 
  file.path("C:/Users/KColeman/Documents/seabird_database/Kaycee_Working_Folder")
setwd(dir)
rm(cpu)

source(file.path(dir, "RProfile.R"))

# ------------------------------------------------------------------------- #
#
# SET PATH TO DATA DIRECTORY
yearlab = "NOAAship_2015"
path = file.path(dir, "DataProcessing/Surveys/MiscSurveys/NOAAship", yearlab)
inpath = file.path(gsub("DataProcessing/Surveys", "SurveyData", path))
speciesPath = file.path(dir,"Database") 

# ------------------------------------------------------------------------- #
# LOAD DATA

require(lubridate)
require(rgdal)
library(plyr)


database = odbcConnectExcel2007(file.path(inpath, "HB1503birdsight.xls")) 
spp = sqlFetch(database, "Export Worksheet")
odbcClose(database)

# FIX TIME
times = cbind(substr(spp$SIGHTDATETIMELOCAL, 1, 2),
              substr(spp$SIGHTDATETIMELOCAL, 4, 6),
              substr(spp$SIGHTDATETIMELOCAL, 8, 9),
              substr(spp$SIGHTDATETIMELOCAL, 11, 12), 
              substr(spp$SIGHTDATETIMELOCAL, 14, 15), 
              substr(spp$SIGHTDATETIMELOCAL, 17, 18))
index = substr(spp$SIGHTDATETIMELOCAL, 30, 31)
times[,2] = 6 # replace JUN
times[,3] = 2015 # replace 15
index = which(index=="PM")
times[index,4] = as.numeric(times[index,4]) + 12 # change hour to remove AM/PM column

spp$obs_date = ymd(paste(times[,3],times[,2],times[,1], sep="/"))
spp$obs_time = paste(times[,4],times[,5],times[,6],sep = ":")
rm(times, index)
spp = spp[,!names(spp) %in% c("SIGHTDATETIMELOCAL"," ")]


# CHECK SPECIES CODES
# COMPARE TYPE VALUES TO DATABASE SPECIES LIST
code <- odbcConnectExcel2007(file.path(speciesPath, "NWASC_codes.xlsx"))
spplist <- sqlFetch(code, "codes")$spp_cd
odbcClose(code)
tmp <- !spp$SPECIES %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
list(spp$SPECIES[tmp])
rm(spplist, tmp)

# fix
spp$original_species_tx = spp$SPECIES
if (!exists("dataChange")) {dataChange = ""; dataChange = dataChange[-1]}
dataChange = rbind(dataChange, "Changed SPECIES from PASS to UNPA")
spp$SPECIES = as.character(spp$SPECIES)
spp$SPECIES[spp$SPECIES == "PASS"] = "UNPA"

# READ IN EFFORT FILE
track = readOGR(inpath,"HB1503birdeffort")
# print(proj4string(track)) # check that projection is lat, lon instead of something else
# plot(track, axes = TRUE)
# points(spp$LON, spp$LAT, col = "red")
# ogrInfo(inpath,"HB1503birdeffort")
# attributes(track@data)
# str(track[1,])
track.df = as(track, "data.frame")
track.coords = coordinates(track)
track.LatLon = as.data.frame(matrix(nrow = 1, ncol = 3))
colnames(track.LatLon) = c("ESRI_OID", "lon", "lat")
for (a in 1:84) {
  b = cbind(rep(a, nrow(as.data.frame(track.coords[[a]]))), as.data.frame(track.coords[[a]]))
  colnames(b) = c("ESRI_OID", "lon", "lat")
  track.LatLon = rbind(track.LatLon, b)
}
rm(a,b,track.coords)
track.LatLon = track.LatLon[-1,] #rm the NA in the first row

## check 
# plot(track, axes = TRUE)
# points(track.LatLon$lon, track.LatLon$lat, col = "red")

## ADD TRACK df LEG to TRACK LatLon
# since everything is ordered the same this is viable
for (a in 1:length(track.LatLon$ESRI_OID)) {
  track.LatLon$LEG[a] = track.df$LEG[track.df$ESRI_OID == track.LatLon$ESRI_OID[a]]
  #track.LatLon$TRANSECT[a] = track.df$TRANSECT[track.df$ESRI_OID == track.LatLon$ESRI_OID[a]]
} 
rm(a)
# remove row name now that we have LEG identifier
track.LatLon = track.LatLon[,!names(track.LatLon) %in% "ESRI_OID"]
track.df = track.df[,!names(track.df) %in% "ESRI_OID"]

## plots to look at LEG information  
# rb = c(rainbow(10),rainbow(10),rainbow(10),rainbow(10),rainbow(10),rainbow(10),rainbow(10),rainbow(10),rainbow(4))

# plot(track.LatLon$lon, track.LatLon$lat)
# for (a in 1:84) {points(track.LatLon$lon[track.LatLon$LEG == a], track.LatLon$lat[track.LatLon$LEG == a], col = rb[a])}

# plot(track.LatLon$lon, track.LatLon$lat)
# for (a in 1:84) {points(spp$LON[spp$LEG == a], spp$LAT[spp$LEG == a], col = rb[a], pch = 19)}

## START AND END OF EACH LEG
# plot(track.LatLon$lon, track.LatLon$lat, col = "gray")
# lines(track, axes = TRUE)
# for (a in 1:84) {points(track.LatLon$lon[track.LatLon$LEG == a][1], track.LatLon$lat[track.LatLon$LEG == a][1], col = "green", pch = 19)}
# for (a in 1:84) {points(track.LatLon$lon[track.LatLon$LEG == a][length(track.LatLon$lon[track.LatLon$LEG == a])], 
#                  track.LatLon$lat[track.LatLon$LEG == a][length(track.LatLon$lat[track.LatLon$LEG == a])], col = "red")}

# plot(track.LatLon$lon, track.LatLon$lat, col = "gray")
# lines(track, axes = TRUE)
# transectList = unique(track.LatLon$TRANSECT)
# for (a in 1:length(transectList)) {points(track.LatLon$lon[track.LatLon$TRANSECT == a][1], track.LatLon$lat[track.LatLon$TRANSECT == a][1], col = "green", pch = 19)}
# for (a in 1:length(transectList)) {points(track.LatLon$lon[track.LatLon$TRANSECT == a][length(track.LatLon$lon[track.LatLon$TRANSECT == a])], 
#                  track.LatLon$lat[track.LatLon$TRANSECT == a][length(track.LatLon$lat[track.LatLon$TRANSECT == a])], col = "red")}

times = cbind(substr(track.df$BEGINTIME, 1, 2),
              substr(track.df$BEGINTIME, 4, 6),
              substr(track.df$BEGINTIME, 8, 11),
              substr(track.df$BEGINTIME, 13, 14), 
              substr(track.df$BEGINTIME, 16, 17), 
              substr(track.df$BEGINTIME, 19, 20))
index = substr(track.df$BEGINTIME, 32, 33)
times[,2] = 6 # replace JUN
index = which(index=="PM")
times[index,4] = as.numeric(times[index,4]) + 12 # change hour to remove AM/PM column

track.df$start_date = ymd(paste(times[,3], times[,2], times[,1], sep = "/"))
track.df$start_time = paste(times[,4],times[,5],times[,6],sep = ":")
rm(times, index)
times = cbind(substr(track.df$ENDTIME, 1, 2),
              substr(track.df$ENDTIME, 4, 6),
              substr(track.df$ENDTIME, 8, 11),
              substr(track.df$ENDTIME, 13, 14), 
              substr(track.df$ENDTIME, 16, 17), 
              substr(track.df$ENDTIME, 19, 20))
index = substr(track.df$ENDTIME, 32, 33)
times[,2] = 6 # replace JUN
index = which(index=="PM")
times[index,4] = as.numeric(times[index,4]) + 12 # change hour to remove AM/PM column

track.df$end_date = ymd(paste(times[,3], times[,2], times[,1], sep = "/"))
track.df$end_time = paste(times[,4],times[,5],times[,6],sep = ":")
rm(times, index)
track.df = track.df[,!names(track.df) %in% c("ENDTIME","BEGINTIME")]



## change names for import
# NOTE LEG but not TRANSECT in spp BUT both TRANSECT and LEG in track
spp = rename(spp,c("SPECIES" = "spp_cd", "GROUPSIZE" = "obs_count_general_nb", "AGE" = "animal_age_tx", 
                   "BEHAVIORDESC" = "behavior_tx", "ANGLE" = "angle_from_observer_nb", "HEIGHTRANGE" = "flight_height_tx",
                   "DISTDESC" ="distance_to_animal_tx", "COMMENTS" = "comments_tx", "LEG" = "local_transect_id",
                   "ID" = "observation_id", "LAT" = "lat", "LON" = "lon"))


track.df = rename(track.df,c("LENGTH_KM" = "transect_distance_nb", "BEAUFORT" = "seastate_beaufort_nb",
                             "COMMENTS" = "comments_tx", "LEG" = "local_transect_id"))
spp$source_dataset_id = "AMAPPS_NOAA/NMFS_NEFSCBoat2015"

# pull out species info
species = cbind(spp$spp_cd, as.character(spp$COMNAME), as.character(spp$SCINAME))
colnames(species) = c("spp_cd", "commonName", "scientificName")
species = species[!duplicated(species),]
out = c("COMNAME", "SCINAME")
spp = spp[,!names(spp) %in% out]
rm(out)

track.LatLon = spp[,!names(LatLon) %in% "row.names"]

#library(oce)
#data(coastlineWorld)
#plot(coastlineWorld)
#plot(coastlineWorld, clatitude=40, clongitude=-72, span=2000, bg = "light blue")
#points(track.LatLon$lon, track.LatLon$lat, col = "blue", pch = 19)

# Export for Kyle
#write.csv(spp, file = "NOAAship2015_obs.csv", row.names = F)
#write.csv(species, file = "NOAAship2015_spp.csv", row.names = F)
#write.csv(track.LatLon, file = "NOAAship2015_trackLatLon.csv", row.names = F)
#write.csv(track.df, file = "NOAAship2015_trackData.csv", row.names = F)
write.csv(dataChange, file = paste(path,"NOAAship2015_dataChange.csv", sep="/"), row.names = F)


# ------------------------------------------------------------------------- #
# INFORMATION FOR DATABASE ENTRY
# ------------------------------------------------------------------------- #

# DATASET LIST TABLE
dataset_list = as.data.frame(matrix(ncol = 31, nrow = 1))
colnames(dataset_list) = c("dataset_id", "survey_type", "survey_method_cd",
                           "dataset_type_cd", "source_dataset_id", "survey_width_m",
                           "subject", "keywords", "title", "version", "abstract", 
                           "purpose", "datastatus", "progress", "updatfreq", 
                           "startdate", "enddate", "numrecords", "area_cover",
                           "datatype", "datatype2", "datum", "coordsys", "qual_code",
                           "qual_rpt", "metastd", "resp_party", "at_usgs", "comments",
                           "sponsors","urlprogram")
dataset_list$dataset_id = "160" ### CHECK ### That this number is not used
dataset_list$survey_type = "b" # boat
dataset_list$survey_method_cd = "cts" # continuous
dataset_list$dataset_type_cd = "ot" # original transect
dataset_list$source_dataset_id = "NOAA/NMFS_NEFSCBoat2015"
dataset_list$title = paste(dataset_list$source_dataset_id,"Georges Bank", sep = "; ")
dataset_list$startdate = min(track.df$start_dt)
dataset_list$enddate = max(track.df$end_dt)
dataset_list$sponsors = "NOAA" 
dataset_list$subject = "seabird and marine mammals survey"
dataset_list$keywords = paste("seabirds", "NOAA","NMFS","Georges Bank", sep = ", ")
dataset_list$resp_party = "63" ##### NEW ENTRY/ CHECK? ##### Elizabeth (Beth) Josephson
dataset_list$coordsys = "Lat/Long"
dataset_list$numrecords = dim(spp)[1]
write.csv(dataset_list, file = paste(path,"NOAAship2015_dataset_list.csv", sep="/"), row.names = F, na = "")


