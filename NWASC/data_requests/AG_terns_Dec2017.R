
# -------------- #
# load packages
# -------------- #
library(odbc)
library(RODBC)
library(sp)
library(maps)
library(ggmap)
library(maps)
library(dplyr)
library(lubridate)
# -------------- #


# -------------- #
# functions
# -------------- #
fix_proj <- function(x) {
  coordinates(x) <- ~ lon + lat
  proj4string(x) <- CRS("+init=epsg:4269")
  x = as.data.frame(spTransform(x, CRS("+init=epsg:4326")))
  return(x)
}
# -------------- #


# -------------- #
# load observation data
# -------------- #
# get old data
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008',database='SeabirdCatalog')
terns = dbGetQuery(db,"select * from observation where spp_cd in ('ROST','COTE','UNTE','UNST','UNMT','UNLT','UCAT','UCRT')")

# call the observation, returning the geometry field as x and y columns.
terns_geom = dbGetQuery(db,"select observation_id, [Geometry].STY as lat, [Geometry].STX as lon from observation where spp_cd in ('ROST','COTE','UNTE','UNST','UNMT','UNLT','UCAT','UCRT')")
terns = left_join(terns, terns_geom, by="observation_id")
terns = terns %>% mutate(obs_dt = as.character(as.Date(obs_dt, format = "%Y-%m-%d"))) %>%
  dplyr::select(-Geometry)
rm(terns_geom)
terns = fix_proj(terns)

# load new data
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlFetch(db, "observation")
track <- sqlFetch(db, "track")
transect <- sqlFetch(db, "transect")
odbcClose(db)

obs = obs %>% rename(lon = temp_lon, lat = temp_lat) %>% rowwise %>% 
  mutate(obs_count_general_nb = replace(obs_count_general_nb,obs_count_general_nb==obs_count_intrans_nb,NA),
         obs_dt = ifelse(grepl("/",obs_dt),
                         as.character(as.Date(obs_dt, format = "%m/%d/%Y")),
                         as.character(as.Date(obs_dt, format = "%Y-%m-%d"))),
         source_obs_id = as.character(source_obs_id),
         wind_speed_tx = as.character(wind_speed_tx),
         wind_dir_tx = as.character(wind_dir_tx),
         heading_tx = as.character(heading_tx),
         observation_id = observation_id + 804175) %>% 
  filter(spp_cd %in% c('ROST','COTE','UNTE','UNST','UNMT','UNLT','UCAT','UCRT'))

# combine
all_data = bind_rows(terns, obs)

# are any datasets not public?
# datasets
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
datasets = dbGetQuery(db,"select * from dataset")
datalist = as.integer(unlist(distinct(all_data,dataset_id)))
datasets = datasets %>% filter(share_level_id %in% 5,
                               dataset_id %in% datalist)
all_data = all_data %>% filter(dataset_id %in% datasets$dataset_id)

# write csv
write.csv(all_data, file = "Z:/seabird_database/data_sent/AndrewGilbert_terns_Dec2017/tern_observations.csv")
# -------------- #


# -------------- #
# transect and track data
# -------------- #
track = track %>% filter(dataset_id %in% datalist)
transect = transect %>% filter(dataset_id %in% datalist)

db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008',database='SeabirdCatalog')
terns_transect = dbGetQuery(db,"select * from transect")

terns_transect_points = dbGetQuery(db,"select transect_id, 
                                 [Geometry].STY as lat, 
                                 [Geometry].STX as lon
                                 from transect_points")
terns_transect_points = fix_proj(terns_transect_points)

terns_transect_lines = dbGetQuery(db,"select transect_id, 
                                 [Geometry].STAsText() as ShapeWKT
                                 from transect_lines")
terns_transect_lines$step1 = apply(terns_transect_lines, 1, function(x) new = readWKT(x[2])) # read spatial lines list -> tried to keep id
terns_transect_lines$step2 = apply(terns_transect_lines, 1, function(x) {as.data.frame(as(x[3], "SpatialPointsDataFrame"))}) #change to points and df

fix_proj()

terns_transect = left_join(terns_transect, terns_transect_points, terns_transect_lines, by="transect_id") %>%
  dplyr::select(-Geometry) %>% 
  filter(dataset_id %in% datalist)
rm(terns_transect_geom)
# -------------- #
