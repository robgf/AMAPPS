# ------------------------ #
# combine old and new seabird catalog data
# pull out black-capped petrel observations

# in progress

# ------------------------ #


# ------------------------ #
# load packages
# ------------------------ #
library(RODBC)
library(dplyr)
library(sp)  # vector data
library(raster)  # raster data
library(rgdal)  # input/output, projections
library(rgeos)  # geometry ops
# ------------------------ #


# ------------------------ #
# load dataset descriptions
# ------------------------ #
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
transects.in.db = sqlFetch(db, "transect")
tracks.in.db = sqlFetch(db, "track")
data.in.db = sqlFetch(db, "dataset")
obs.in.db = sqlFetch(db, "observation")
odbcClose(db)
# ------------------------ #


# ------------------------ #
# directory for export
# ------------------------ #
dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/TomWhite_BCPE_Aug2017"
dir.archive = "//ifw-hqfs1/MB SeaDuck/seabird_database/database_export/archive/seabird_database_obs_trans_tbls_April2016"
dir.from.segmentation = "//ifw-hqfs1/MB SeaDuck/Kyle_Working_Folder/Segmentation/Data/transect_shp_files"
# ------------------------ #


# ------------------------ #
# load archive observations
# and transects
# ------------------------ #
# read in old obs data
old_obs = read.csv(file = paste(dir.archive, "vw_obs.csv", sep="/"), header=TRUE, quote="", row.names=NULL, stringsAsFactors = FALSE)
# assuming this is an export error?
old_obs$observation_id = as.numeric(as.character(old_obs$observation_id))
old_obs = old_obs[!is.na(old_obs$observation_id),]
old_obs$transect_id = as.numeric(as.character(old_obs$transect_id))
old_obs$source_obs_id = as.numeric(as.character(old_obs$source_obs_id))
old_obs$obs_count_intrans_nb = as.numeric(as.character(old_obs$obs_count_intrans_nb))
old_obs$obs_count_general_nb = as.numeric(as.character(old_obs$obs_count_general_nb))
old_obs$angle_from_observer_nb = as.numeric(as.character(old_obs$angle_from_observer_nb))
old_obs$seastate_beaufort_nb = as.numeric(as.character(old_obs$seastate_beaufort_nb))
old_obs$seasurface_tempc_nb = as.numeric(as.character(old_obs$seasurface_tempc_nb))
old_obs$who_created = as.numeric(as.character(old_obs$who_created))
old_obs$temp_lat = as.numeric(as.character(old_obs$temp_lat))
old_obs$temp_lon = as.numeric(as.character(old_obs$temp_lon))
old_obs$who_imported = as.numeric(as.character(old_obs$who_imported))
old_obs$salinity_ppt_nb = as.numeric(as.character(old_obs$salinity_ppt_nb))
old_obs$local_obs_id = as.numeric(as.character(old_obs$local_obs_id))
old_obs$heading_tx = as.character(old_obs$heading_tx)
old_obs = old_obs[!is.na(old_obs$dataset_id),]

# read in old transect data
old_transects = read.csv(file = paste(dir.archive, "vw_trans.csv", sep="/"), header=TRUE)
# assuming this is an export error?
old_transects$transect_id = as.numeric(as.character(old_transects$transect_id))
old_transects = old_transects[!is.na(old_transects$transect_id),]
old_transects$dataset_id = as.numeric(as.character(old_transects$dataset_id))
old_transects = old_transects[!is.na(old_transects$dataset_id),]
old_transects$seastate_beaufort_nb = as.numeric(as.character(old_transects$seastate_beaufort_nb))
old_transects$seasurface_tempc_nb = as.numeric(as.character(old_transects$seasurface_tempc_nb))
old_transects$heading_tx = as.numeric(as.character(old_transects$heading_tx))

# read in old track data
lines = readOGR(dir.from.segmentation,"line")
points = readOGR(dir.from.segmentation,"point")

# transform projection
lines = spTransform(lines, CRS("+proj=longlat +datum=WGS84"))
points = spTransform(points, CRS("+proj=longlat +datum=WGS84"))

# turn into a dataframe
old_transect_lines = as(as(lines, "SpatialPointsDataFrame"),"data.frame")
old_transect_points = as(points, "data.frame")

# formatting
old_transect_lines = old_transect_lines %>%
  rename(transect_id = transect_i,
         track_lat = coords.x2,
         track_lon = coords.x1) %>% 
  dplyr::select(-Lines.NR, -Lines.ID, -Line.NR)
old_transect_points = old_transect_points %>%
  rename(transect_id = transect_i,
         track_lat = coords.x2,
         track_lon = coords.x1)
# ------------------------ #


# ------------------------ #
# combine datasets
# ------------------------ #
obs.in.db$heading_tx = as.character(obs.in.db$heading_tx)

# fix numbers based on data already present
obs.in.db$observation_id = obs.in.db$observation_id + 804175
min(obs.in.db$observation_id)
max(old_obs$observation_id)

# combine
obs.in.db$wind_speed_tx=as.character(obs.in.db$wind_speed_tx)
obs.in.db$wind_dir_tx=as.character(obs.in.db$wind_dir_tx)

obs_data = bind_rows(obs.in.db, old_obs)
track_data = bind_rows(tracks.in.db, old_transect_lines, old_transect_points) %>% 
  mutate(point_type = replace(point_type,point_type=="BEGTRAN","BEGCNT"),
         point_type = replace(point_type,point_type=="ENDTRAN","ENDCNT"))

min(transects.in.db$transect_id)
max(old_transects$transect_id)
transect_data = bind_rows(transects.in.db, old_transects) %>% arrange(transect_id)
# ------------------------ #


# ------------------------ #
# filter out BCPE
# ------------------------ #
data = filter(obs_data, spp_cd %in% "BCPE")

# errors
data$lon[data$observation_id %in% c(787484,802769,789131)] = NA 
data$lon[data$observation_id %in% c(353280,353407,353404,787484,802769,54980,789131)] = data$lat[data$observation_id %in% c(353280,353407,353404,787484,802769,54980,789131)]
data$lat[data$observation_id %in% c(353280,353407,353404,787484,802769,54980,789131)] = NA

data = data %>% mutate(lon = replace(lon[is.na(lon)],is.na(lon),temp_lon[is.na(lon)]),
                       lat = replace(lat[is.na(lat)],is.na(lat),temp_lat[is.na(lat)]),
                       lon = as.numeric(lon), lat = as.numeric(lat)) %>%
  dplyr::select(-temp_lat, -temp_lon, -who_created, -who_created_tx)

# filter out transects that are in this data

# ------------------------ #


# ------------------------ #
# export csv
# ------------------------ #
write.csv(data, paste(dir.out, "observations.csv", sep="/"), row.names=FALSE)
write.csv(track_data, paste(dir.out, "tracks.csv", sep="/"), row.names=FALSE)
write.csv(transect_data, paste(dir.out, "transects.csv", sep="/"), row.names=FALSE)
write.csv(data.in.db, paste(dir.out, "datasets.csv", sep="/"), row.names=FALSE)

rm(old_transects, transects.in.db, transect_data, old_transect_lines, old_transect_points, data.in.db)

# remove NA's
obs_data = obs_data[!is.na(obs_data$temp_lat),]
obs_data = obs_data[!is.na(obs_data$temp_lon),]

track_data = track_data[!is.na(track_data$track_lat),]
# ------------------------ #


# ------------------------ #
# make shapefiles
# ------------------------ #
# Coerce into SpatialPointsDataframe
coordinates(data) = ~temp_lon + temp_lat
coordinates(tracks.in.db) = ~track_lon + track_lat
coordinates(track_data) = ~track_lon + track_lat

# Assign projection
proj4string(data)=CRS("+proj=longlat +datum=WGS84") 
proj4string(tracks.in.db)=CRS("+proj=longlat +datum=WGS84") 
proj4string(track_data)=CRS("+proj=longlat +datum=WGS84") 

# write shapefile
writeOGR(obj=data, dsn=dir.out, layer="all_obs_data", driver="ESRI Shapefile") 
writeOGR(obj=tracks.in.db, dsn=dir.out, layer="new_track_data", driver="ESRI Shapefile") 
writeOGR(obj=track_data, dsn=dir.out, layer="all_track_data_as_points", driver="ESRI Shapefile") 
# old line and point track files will also be in the folder 
# since they might be easier to work with 
# ------------------------ #




