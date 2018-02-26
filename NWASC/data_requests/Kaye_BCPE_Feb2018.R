# ----------- #
# All BCPE data
# this is a continuation of Tom Whites request
# but for only the geospatial information
# ----------- #


# ------------------------ #
# load packages
# ------------------------ #
library(RODBC)
require(odbc)
library(dplyr)
require(ggplot2)
require(rgdal)
# ------------------------ #


# ------------------------ #
# directory for export
# ------------------------ #
dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/Kaye_BCPE_Feb2018"
# ------------------------ #

# ------------------------ #
# load data
# ------------------------ #
# get dataset list
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
dataset = dbGetQuery(db, "select * from dataset2")

# get old data
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008',database='SeabirdCatalog')
old_obs = dbGetQuery(db,"select [Geometry].STY as lat, [Geometry].STX as lon, * from observation
                     where spp_cd = 'BCPE'")

old_obs = old_obs %>% 
  mutate(obs_dt = as.character(as.Date(obs_dt, format = "%Y-%m-%d"))) %>%
  dplyr::select(-Geometry)
coordinates(old_obs) <- ~ lon + lat
proj4string(old_obs) <- CRS("+init=epsg:4269")
old_obs = as.data.frame(spTransform(old_obs, CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")))

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlQuery(db, "select * from observation
                where spp_cd = 'BCPE'")
odbcClose(db)

obs = dplyr::rename(obs, lat = temp_lat, lon = temp_lon) %>% 
  mutate(observation_id = observation_id + 804175,
         obs_count_general_nb = replace(obs_count_general_nb, obs_count_general_nb==obs_count_intrans_nb, NA),
         obs_dt = ifelse(grepl("/",obs$obs_dt), as.character(as.Date(obs$obs_dt[grepl("/",obs$obs_dt)], format = "%m/%d/%Y")), 
                         as.character(as.Date(obs$obs_dt[grepl("-",obs$obs_dt)], format = "%Y-%m-%d"))))

# combine old and new
# create month and filter to Jan. + Feb.
obs = mutate(obs, source_obs_id = as.character(source_obs_id),
             source_transect_id = as.character(source_transect_id),
             travel_direction_tx = as.character(travel_direction_tx),
             visibility_tx = as.character(visibility_tx),
             wind_speed_tx = as.character(wind_speed_tx),
             wind_dir_tx = as.character(wind_dir_tx),
             obs_dt = as.Date(obs_dt,format="%Y-%m-%d"))

old_obs = old_obs %>% 
  mutate(obs_dt = as.Date(obs_dt,format="%Y-%m-%d"),
         source_obs_id = as.character(source_obs_id))

all_dat = bind_rows(old_obs, obs) %>% 
  dplyr::select(observation_id, spp_cd, original_species_tx, 
                lat, lon, obs_dt, 
                dataset_id, comments_tx,
                obs_count_intrans_nb, obs_count_general_nb) %>% 
  filter(dataset_id %in% dataset$dataset_id[!dataset$share_level_id %in% 1]) 
rm(obs, old_obs)

# subset datalist
dataset = filter(dataset, dataset_id %in% unique(all_dat$dataset_id)) %>% 
  mutate(survey_type_cd = replace(survey_type_cd, survey_type_cd %in% 'b','boat'),
         survey_type_cd = replace(survey_type_cd, survey_type_cd %in% 'a','airplane'),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% 'cts','continuous time strip'),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% 'dts','discrete time strip'),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% 'go ','general observation'),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% 'tss','targeted species survey'),
         dataset_type_cd = replace(dataset_type_cd, dataset_type_cd %in% 'ot','original transect'),
         dataset_type_cd = replace(dataset_type_cd, dataset_type_cd %in% 'og','original general observation'))
# ------------------ #



# ------------------ #
# effort
# ------------------ #
# old transect and track data 
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008',database='SeabirdCatalog')
old_transects = dbGetQuery(db,"select Geometry.STStartPoint().STY as start_lat,
                           Geometry.STStartPoint().STX as start_lon,
                           Geometry.STEndPoint().STY as stop_lat,
                           Geometry.STEndPoint().STX as stop_lon, * from transect
                           where dataset_id in (12,15,20,21,23,28,29,30,31,39,73,116,117,
                           121,122,123,138,143,149,158,174,411)")
old_transects = old_transects %>%
  dplyr::select(-Geometry, -newGeometry, -geography)
coordinates(old_transects) <- ~ start_lon + start_lat
proj4string(old_transects) <- CRS("+init=epsg:4269")
old_transects = as.data.frame(spTransform(old_transects, CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")))
coordinates(old_transects) <- ~ stop_lon + stop_lat
proj4string(old_transects) <- CRS("+init=epsg:4269")
old_transects = as.data.frame(spTransform(old_transects, CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")))

# read in old track data
dir.from.segmentation = "//ifw-hqfs1/MB SeaDuck/archive/Kyle_Working_Folder/Segmentation/Data/transect_shp_files"
lines = readOGR(dir.from.segmentation,"line")
points = readOGR(dir.from.segmentation,"point")

# transform projection
lines = spTransform(lines, CRS("+proj=longlat +datum=WGS84"))
points = spTransform(points, CRS("+proj=longlat +datum=WGS84"))

# turn into a dataframe
old_track_lines = as(as(lines, "SpatialPointsDataFrame"),"data.frame")
old_track_points = as(points, "data.frame")
rm(lines, points)

# formatting
old_track_lines = old_track_lines %>% 
  mutate(track_id = seq(1:length(dataset_id))) %>%
  rename(transect_id = transect_i,
         track_lat = coords.x2,
         track_lon = coords.x1) %>% 
  dplyr::select(-Lines.NR, -Lines.ID, -Line.NR) %>% 
  filter(dataset_id %in% c(12,15,20,21,23,28,29,30,31,39,73,116,117,
                           121,122,123,138,143,149,158,174,411)) %>% 
  group_by(dataset_id) %>% 
  arrange(dataset_id, track_id)

old_track_points = old_track_points %>%
  mutate(track_id = seq(1:length(dataset_id))) %>%
  rename(transect_id = transect_i,
         track_lat = coords.x2,
         track_lon = coords.x1) %>% 
  filter(dataset_id %in% c(12,15,20,21,23,28,29,30,31,39,73,116,117,
                           121,122,123,138,143,149,158,174,411)) %>% 
  group_by(dataset_id) %>%  
  arrange(dataset_id, track_id)

# new track and transect data 
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
transects = sqlQuery(db,"select * from transect
                     where dataset_id in (12,15,20,21,23,28,29,30,31,39,73,116,117,
                     121,122,123,138,143,149,158,174,411)")
tracks = sqlQuery(db,"select * from track
                  where dataset_id in (12,15,20,21,23,28,29,30,31,39,73,116,117,
                  121,122,123,138,143,149,158,174,411)")
odbcCloseAll()

#fix track id
tracks = mutate(tracks, track_id = track_id + 2353647)

# fix names in transects
transects = rename(transects, 
                   start_lon = temp_start_lon,
                   stop_lon = temp_stop_lon,
                   start_lat = temp_start_lat,
                   stop_lat = temp_stop_lat)
# max old transect id = 117916, min new transect id is 122266 so there is a gap based on bad info on where to start the new ids
# but this also means we don't need to alter transect ids which is ideal since they connect obs and tracks

# join old and new
all_transects = bind_rows(transects, old_transects) %>% 
  arrange(dataset_id, transect_id)
# ------------------ #


# ------------------ #
# export
# ------------------ #
write.csv(all_dat, paste(dir.out, "observations.csv", sep="/"), row.names=FALSE)
write.csv(dataset, paste(dir.out, "datasets.csv", sep="/"), row.names=FALSE)
# ------------------ #

