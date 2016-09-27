# ------------------------------------------------------------------------- #
# NOAA/ NMFS/ NEFSC boat 2015
# Date Created: 9-2015
# Author: Kaycee Coleman
#
# ------------------------------------------------------------------------- #

# load necessary functions (generic for all surveys)
# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
surveyFolder = "NOAA NMFS"
yearLabel = "NOAA ship 2015"

dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
dir.in <- paste(dir, surveyFolder, yearLabel, sep = "/") 
dir.out <- paste(gsub("datasets_received", paste("data_import/in_progress", surveyFolder, yearLabel, sep="/"), dir), sep = "/") 
speciesPath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/"

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))
# ------------------------------------------------------------------------- #

# ------------------------------------------------------------------------- #
# LOAD DATA

require(lubridate)
require(rgdal)
require(dplyr)
require(RODBC)
 
db = odbcConnectExcel2007(file.path(dir.in, "HB1503birdsight.xls")) 
spp = sqlFetch(db, "data")
odbcClose(db)

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
track = readOGR(dir.in,"HB1503birdeffort")
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
spp = rename(spp, spp_cd = SPECIES, 
             obs_count_general_nb = GROUPSIZE, 
             animal_age_tx = AGE, 
             behavior_tx = BEHAVIORDESC, 
             angle_from_observer_nb = ANGLE, 
             flight_height_tx = HEIGHTRANGE,
             distance_to_animal_tx = DISTDESC, 
             comments_tx = COMMENTS, 
             source_transect_id = LEG,
             source_obs_id = ID,
             heading_tx = FLTDIR)
names(spp) = tolower(names(spp))

track.df = rename(track.df, transect_distance_nb = LENGTH_KM, 
                  seastate_beaufort_nb = BEAUFORT,
                  comments_tx = COMMENTS, 
                  source_transect_id = LEG)
names(track.df) = tolower(names(track.df))

spp$source_dataset_id = "AMAPPS_NOAA/NMFS_NEFSCBoat2015"
track.df$source_dataset_id = "AMAPPS_NOAA/NMFS_NEFSCBoat2015"

# pull out species info
#species = cbind(spp$spp_cd, as.character(spp$comname), as.character(spp$sciname))
#colnames(species) = c("spp_cd", "commonName", "scientificName")
#species = species[!duplicated(species),]
#out = c("COMNAME", "SCINAME")
#spp = spp[,!names(spp) %in% out]
#rm(out)

#track.LatLon = spp[,!names(LatLon) %in% "row.names"]

#library(oce)
#data(coastlineWorld)
#plot(coastlineWorld)
#plot(coastlineWorld, clatitude=40, clongitude=-72, span=2000, bg = "light blue")
#points(track.LatLon$lon, track.LatLon$lat, col = "blue", pch = 19)

transect = track.df
track = track.LatLon
rm(track.df,track.LatLon)
transect = rename(transect, observer_tx = observer1)
transect$dateset_id = 160 

# add BEG/END
# add date through join
track = rename(track, source_transect_id = LEG)
track = track %>% mutate(type = "WAYPNT") %>% group_by(source_transect_id) %>%
  mutate(type = replace(type, row_number()==1, "BEGTRAN")) %>% 
  mutate(type = replace(type, row_number()==n(),"ENDTRAN")) %>% ungroup() %>% as.data.frame() 
track = left_join(track, select(transect, source_transect_id, start_date, start_time, end_date, end_time), 
            by = "source_transect_id")  
track$track_tm = NA
track$track_tm[track$type == "BEGTRAN"] = track$start_time[track$type == "BEGTRAN"]
track$track_tm[track$type == "ENDTRAN"] = track$end_time[track$type == "ENDTRAN"]

# check for duplicates then combined dates
# any(track$start_date != track$end_date)
track$track_dt = track$start_date
track = track %>% select(-start_time,-end_time,-start_date,-end_date)
track$dateset_id = 160 

# add LAT/LON to transects from track

# summarise
track_summary = track %>% group_by(source_transect_id) %>% 
  mutate(start_lat = lat[type=="BEGTRAN"],
         start_lon = lon[type=="BEGTRAN"],
         end_lon = lon[type=="ENDTRAN"],
         end_lat = lat[type=="ENDTRAN"]) %>%
  filter(row_number()==1) %>% select(source_transect_id,start_lat,start_lon,end_lon,end_lat) %>% 
  ungroup %>% as.data.frame
transect = left_join(transect, track_summary, by = "source_transect_id")

# rename transect since not sure how to match to others, matched by leg
transect = rename(transect, local_transect_id = transect)

# ------------------------------------------------------------------------- #
# Export to csv's
# ------------------------------------------------------------------------- #
write.csv(spp, file = paste(dir.out, "NOAAship2015_obs.csv", sep = "/"), row.names = F)
#write.csv(species, file = paste(dir.out, "NOAAship2015_spp.csv", sep="/") row.names = F)
write.csv(track, file = paste(dir.out, "NOAAship2015_track.csv", sep="/"), row.names = F)
write.csv(transect, file = paste(dir.out, "NOAAship2015_transect.csv", sep="/"), row.names = F)
write.csv(dataChange, file = paste(dir.out,"NOAAship2015_dataChange.csv", sep="/"), row.names = F)


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
dataset_list$startdate = min(transect$start_date)
dataset_list$enddate = max(transect$end_date)
dataset_list$sponsors = "NOAA" 
dataset_list$subject = "seabird and marine mammals survey"
dataset_list$keywords = paste("seabirds", "NOAA","NMFS","Georges Bank", sep = ", ")
dataset_list$resp_party = "52" ##### NEW ENTRY/ CHECK? ##### Elizabeth (Beth) Josephson
dataset_list$coordsys = "Lat/Long"
dataset_list$numrecords = dim(spp)[1]
write.csv(dataset_list, file = paste(dir.out,"NOAAship2015_dataset_list.csv", sep="/"), row.names = F, na = "")


