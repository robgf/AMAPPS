#-------------------- #
# Arliss
# White-winged Scoter
# MassCEC
# between -71 and -70.4 degrees East and between 40.5 and 41.25 degrees
# ------------------- #

# ------------------------ #
# load packages
# ------------------------ #
library(RODBC)
require(odbc)
library(dplyr)
require(ggplot2)
require(rgdal)
require(ggmap)
# ------------------------ #


# ------------------------ #
# directory for export
# ------------------------ #
dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/Arliss_WWSC_March2018"
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
                     where spp_cd = 'WWSC'")

old_obs = old_obs %>% 
  mutate(obs_dt = as.character(as.Date(obs_dt, format = "%Y-%m-%d"))) %>%
  dplyr::select(-Geometry)
coordinates(old_obs) <- ~ lon + lat
proj4string(old_obs) <- CRS("+init=epsg:4269")
old_obs = as.data.frame(spTransform(old_obs, CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")))

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlQuery(db, "select * from observation
                where spp_cd = 'WWSC'")
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
             heading_tx = as.character(heading_tx),
             obs_dt = as.Date(obs_dt,format="%Y-%m-%d"))

old_obs = old_obs %>% 
  mutate(obs_dt = as.Date(obs_dt,format="%Y-%m-%d"),
         source_obs_id = as.character(source_obs_id))

all_dat = bind_rows(old_obs, obs) %>% 
  dplyr::select(observation_id, spp_cd, original_species_tx, 
                lat, lon, obs_dt, 
                dataset_id, comments_tx,
                obs_count_intrans_nb, obs_count_general_nb) %>% 
  filter(dataset_id %in% dataset$dataset_id[!dataset$share_level_id %in% 1],
         lat > 40, lat < 42, lon > (-73), lon < (-69)) %>% 
  left_join(., dplyr::select(dataset,dataset_id,dataset_name),by="dataset_id")

# grab map
bc_bbox <- make_bbox(lat = c(40, 42), lon = c(-73, -69))
mapdata <- get_map(location = bc_bbox, source = "google", maptype = "terrain")

# create poly
bb = as.data.frame(rbind(c(-71,40.5),
                        c(-71,41.25),
                        c(-70.4,41.25),
                        c(-70.4,40.5),
                        c(-71,40.5)))
names(bb) = c("long","lat")
P1 = Polygon(bb)
Ps1 = SpatialPolygons(list(Polygons(list(P1), ID = "a")), 
                      proj4string=CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"))

# plot all data
p = ggmap(mapdata) + coord_fixed(1.3) + 
  coord_fixed(xlim = c(-73, -69),  ylim = c(40, 42), ratio = 1.3) + 
  geom_polygon(data = Ps1, aes(x = long, y= lat),fill="white",alpha=0.5,col="grey") +
  geom_point(data = all_dat,aes(x = lon, y = lat, col = dataset_name))+geom_point()+theme_bw()+
  guides(col=guide_legend(title="Dataset"))+
  #scale_colour_manual(values=cbPalette)+
  ggtitle("All available WWSC observations in Arliss' bounding box")
p
ggsave(file=paste(dir.out, "/all_WWSC.png", sep=""), plot=p)

# plot MassCEC data
MassCEC_WWSC = filter(all_dat, dataset_id %in% c(161,162,135))
p = ggmap(mapdata) + coord_fixed(1.3) + 
  coord_fixed(xlim = c(-73, -69),  ylim = c(40, 42), ratio = 1.3) + 
  geom_polygon(data = Ps1, aes(x = long, y= lat), fill="white",alpha=0.5,col="grey") +
  geom_point(data = MassCEC_WWSC, aes(x=lon, y=lat, col=dataset_name))+
  ggtitle("MassCEC WWSC observations (2011-2013, none in 2014 in bounding box)")+
  guides(col=guide_legend(title="Survey"))+theme_bw()
p
ggsave(file=paste(dir.out, "/MassCEC_WWSC.png", sep=""), plot=p)
# ------------------ #

