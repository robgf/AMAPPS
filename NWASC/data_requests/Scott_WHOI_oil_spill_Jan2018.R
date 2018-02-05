# ------------- #
# request from Scott J. USFWS for all birds 3 miles out of WHOI in Jan/Feb.
# ------------- #


# ------------------ # 
# load packages
# ------------------ # 
require(dplyr)
require(ggplot2)
require(maps)
library(sp)
library(rgeos)
library(rgdal)
require(RODBC)
require(odbc)
require(ggmap)
require(lubridate)
# ------------------ # 


# ------------- #
# create whoi poly
# ------------- #
w = as.data.frame(matrix(nrow=1,ncol=2,data=c(-70.6730857, 41.5264977)))
names(w) = c("lon","lat")
coordinates(w) = ~lon+lat
proj4string(w) = CRS("+proj=longlat") 
w = spTransform(w, CRS("+proj=utm +zone=19 +ellps=WGS84 +datum=WGS84 +units=m +no_defs +towgs84=0,0,0"))

whoi_3mile_buffer <- gBuffer(w, width = 4828.03, byid = TRUE ) # 3 miles = 4828.03 meters = 482803 km
whoi_3mile_buffer = spTransform(whoi_3mile_buffer, CRS("+proj=longlat +init=epsg:4326"))
w = spTransform(w, CRS("+proj=longlat +init=epsg:4326"))

# plot
ww = as.data.frame(w)

bc_bbox <- make_bbox(lat = c(41.2, 41.8), lon = c(-70.9, -70.4))
whoi <- get_map(location = bc_bbox, source = "google", maptype = "terrain")

ggmap(whoi) + coord_fixed(1.3) + 
  coord_fixed(xlim = c(-70.75, -70.6),  ylim = c(41.47, 41.58), ratio = 1.3) + 
  geom_point(data = ww, aes(x=lon,y=lat), col = "magenta") +
  geom_polygon(data = whoi_3mile_buffer, aes(x = long, y= lat),fill="white",alpha=0.2,col="black") +
  theme_bw() + ggtitle("3 mile buffer")
# ------------- #


# ------------- #
# load data
# ------------- #
# get bird list
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
birdlist = dbGetQuery(db, "select spp_cd from lu_species where species_type_id in (1,8)")
dataset = dbGetQuery(db, "select * from dataset")
spp = dbGetQuery(db, "select * from lu_species")

# get old data
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008',database='SeabirdCatalog')
old_obs = dbGetQuery(db,"select [Geometry].STY as lat, [Geometry].STX as lon, * from observation
                     where [Geometry].STY between 41.47 and 41.58
                     and [Geometry].STX between -70.75 and -70.6")
old_obs = old_obs %>% 
  mutate(obs_dt = as.character(as.Date(obs_dt, format = "%Y-%m-%d"))) %>%
  dplyr::select(-Geometry)
coordinates(old_obs) <- ~ lon + lat
proj4string(old_obs) <- CRS("+init=epsg:4269")
old_obs = as.data.frame(spTransform(old_obs, CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")))

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlQuery(db, "select * from observation
                where temp_lat between 41.47 and 41.58
                and temp_lon between -70.75 and -70.6")
odbcClose(db)

obs = dplyr::rename(obs, lat = temp_lat, lon = temp_lon) %>% 
  mutate(obs_dt = as.Date(obs_dt,format = "%m/%d/%Y"),
         observation_id = observation_id + 804175) %>% 
  mutate(obs_count_general_nb = replace(obs_count_general_nb, obs_count_general_nb==obs_count_intrans_nb, NA))

# combine old and new
# create month and filter to Jan. + Feb.
obs = mutate(obs, source_obs_id = as.character(source_obs_id))
old_obs = old_obs %>% mutate(obs_dt = as.Date(obs_dt,format="%Y-%m-%d"))

all_dat = bind_rows(old_obs, obs) %>% 
  dplyr::select(spp_cd, lat, lon, obs_dt, dataset_id, 
                obs_count_intrans_nb, obs_count_general_nb) %>% 
  mutate(month = month(obs_dt)) %>% 
  filter(spp_cd %in% birdlist$spp_cd, 
         month %in% c(1,2), 
         dataset_id %in% dataset$dataset_id[!dataset$share_level_id %in% 1]) 
# ------------------ #


# ------------------ #
# subset data
# ------------------ #
# make spatial
all_data = all_dat #df
coordinates(all_dat) = ~lon+lat
proj4string(all_dat) <- CRS("+proj=longlat +init=epsg:4326")

# pull whats in the bounding box
x = sp::over(all_dat, whoi_3mile_buffer)
whoi.data = as.data.frame(all_dat[!is.na(x),])
nodata = as.data.frame(all_dat[is.na(x),])

whoi.data = as.data.frame(whoi.data)
write.csv(whoi.data,"Z:/seabird_database/data_sent/Scott_WHOI_oil_spill_Jan2018/observations.csv")

dataset = filter(dataset, dataset_id %in% whoi.data$dataset_id)
write.csv(whoi.data,"Z:/seabird_database/data_sent/Scott_WHOI_oil_spill_Jan2018/datasets.csv")
# ------------- #


# ------------- #
# plots
# ------------- #
ggmap(whoi) + coord_fixed(1.3) + 
  coord_fixed(xlim = c(-70.75, -70.6),  ylim = c(41.47, 41.58), ratio = 1.3) + 
  geom_point(data = ww, aes(x=lon,y=lat), col = "magenta") +
  geom_polygon(data = whoi_3mile_buffer, aes(x = long, y= lat),fill="white",alpha=0.2,col="black") +
  theme_bw() + ggtitle("bird observations in 3 mile buffer")+
  geom_point(data = all_data, aes(x=lon, y=lat), col="darkgrey") + 
  geom_point(data = whoi.data, aes(x=lon, y=lat)) 

whoi.data = whoi.data %>% mutate(group = ifelse(is.na(obs_count_intrans_nb),"off transect","on transect"),
                                 counts = ifelse(is.na(obs_count_intrans_nb),obs_count_general_nb,obs_count_intrans_nb)) %>%
  left_join(.,dplyr::select(spp,spp_cd,common_name),by="spp_cd")

ggplot(data = whoi.data, aes(x = counts, y = reorder(common_name,counts), col=spp_cd))+
  geom_jitter(width = 0.005)+
  theme_bw()+
  ggtitle("Counts\n **not normalized or corrected for effort**")+
  theme(legend.position = "none")+
  facet_wrap(~group)+ 
  ylab("species")

ggmap(whoi) + coord_fixed(1.3) + 
  coord_fixed(xlim = c(-70.75, -70.6),  ylim = c(41.47, 41.58), ratio = 1.3) + 
  geom_point(data = ww, aes(x=lon,y=lat), col = "magenta") +
  geom_polygon(data = whoi_3mile_buffer, aes(x = long, y= lat),fill="white",alpha=0.5,col="black") +
  theme_bw() + ggtitle("bird observations in 3 mile buffer by species")+
  geom_point(data = whoi.data, aes(x=lon, y=lat, col=spp_cd)) 

# ------------- #
