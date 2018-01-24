
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
library(rgeos) #readWKT
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
rm(obs,terns)
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
new_df = as.data.frame(matrix(nrow=0,ncol=3))
names(new_df) = c("x","y","transect_id")
for (z in 1:length(terns_transect_lines$transect_id)) {
  a = as.data.frame(as(readWKT(terns_transect_lines$ShapeWKT[z]),"SpatialPointsDataFrame"))
  b = rep(terns_transect_lines$transect_id[z],length(a$y))
  a$transect_id = b
  a$source_id = seq(1:length(a$transect_id))
  new_df = rbind(new_df,dplyr::select(a,x,y,transect_id,source_id))
}
new_df = rename(new_df, lat=x, lon=y)
new_df = fix_proj(new_df)
# this is a horrible loop... 
#write.csv(new_df, file = "Z:/seabird_database/data_sent/AndrewGilbert_terns_Dec2017/transect_lines_as_points.csv")

new_terns_transect_points = left_join(terns_transect_points, terns_transect, by="transect_id") %>%
  dplyr::select(-Geometry,-geography,-newGeometry) %>% 
  filter(dataset_id %in% datalist) %>% mutate(source_id = NA)
new_terns_transect_lines = left_join(new_df,terns_transect, by="transect_id") %>%
  dplyr::select(-Geometry,-geography,-newGeometry) %>% 
  filter(dataset_id %in% datalist)
rm(new_df)

old_track = bind_rows(new_terns_transect_points, new_terns_transect_lines) %>% 
  group_by(transect_id) %>% 
  mutate(start = ifelse(row_number()==1, 1, NA),
         stop = ifelse(row_number()==n(), 1, NA)) %>%
  ungroup %>% 
  mutate(time = NA,
         time = ifelse(start==1, start_tm, NA),
         time = ifelse(stop==1, end_tm, NA))
old_transect = old_track %>% group_by(dataset_id, transect_id) %>% 
  filter(row_number()==1 | row_number()==n())
  
all_track = rbind(track, old_track) %>% arrange(dataset_id,date,time)
all_track = rbind(transect, old_transect) %>% arrange(dataset_id,date,time)
# -------------- #
