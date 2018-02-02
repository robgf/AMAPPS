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
require(odbc)
require(RODBC)
# ------------------ # 


# ------------- #
# create whoi poly
# ------------- #
w = as.data.frame(matrix(nrow=1,ncol=2,data=c(-70.6730857, 41.5264977)))
names(w) = c("lon","lat")
coordinates(w) = ~lon+lat
proj4string(w) = CRS("+proj=longlat") 
w = spTransform(w, CRS("+proj=utm +zone=19 +ellps=WGS84 
                       +datum=WGS84 +units=m +no_defs +towgs84=0,0,0"))

whoi_3mile_buffer <- gBuffer(w, width = 4828.03, byid = TRUE ) # 3 miles = 4828.03 meters = 482803 km
whoi_3mile_buffer = spTransform(whoi_3mile_buffer, CRS("+proj=longlat +init=epsg:4326"))
w = spTransform(w, CRS("+proj=longlat +init=epsg:4326"))

# plot
ww = as.data.frame(w)
whoi_3mile_buffer_df = as.data.frame(whoi_3mile_buffer@polygons[[1]]@Polygons[[1]]@coords)
names(whoi_3mile_buffer_df) = c("lon","lat")

bc_bbox <- make_bbox(lat = c(41.2, 41.8), lon = c(-70.9, -70.4))
whoi <- get_map(location = bc_bbox, source = "google", maptype = "terrain")
ggmap(whoi) + coord_fixed(1.3) + 
  coord_fixed(xlim = c(-70.75, -70.6),  ylim = c(41.45, 41.6), ratio = 1.3) + 
  geom_point(data = ww, aes(x=lon,y=lat), col = "black") +
  geom_point(data = whoi_3mile_buffer_df, aes(x=lon,y=lat), col= "black") + 
  theme_bw() + ggtitle("3 mile buffer")
# ------------- #


# ------------- #
# load data
# ------------- #
# get old data
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008',database='SeabirdCatalog')
old_obs = dbGetQuery(db,"select *, [Geometry].STX as lon,  [Geometry].STY as lat
                         from observation
                         where [Geometry].STY between 41.2 and 41.8")
old_obs = old_obs %>% 
  mutate(obs_dt = as.character(as.Date(obs_dt, format = "%Y-%m-%d"))) %>%
  dplyr::select(-Geometry)
coordinates(old_obs) <- ~ Long + Lat
proj4string(old_obs) <- CRS("+init=epsg:4269")
old_obs = as.data.frame(spTransform(old_obs, CRS("+init=epsg:4326")))

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlFetch(db, "observation")
dataset = sqlFetch(db, "dataset")
birdlist = sqlQuery(db, "select spp_cd, species_type_cd
                    from lu_species
                    where species_type_cd in (1,8)")
odbcClose(db)

obs = dplyr::rename(obs, Lat = temp_lat, Long = temp_lon) %>% 
  mutate(obs_dt = as.Date(obs_dt,format="m%/%d/%Y"),
         observation_id = observation_id + 804175) %>% 
  filter(spp_cd %in% landbirds$spp_cd) %>% rowwise %>% 
  mutate(obs_count_general_nb = replace(obs_count_general_nb,obs_count_general_nb==obs_count_intrans_nb,NA))

# combine old and new
# creat month column
dat = bind_rows(old_obs,obs) %>% 
  dplyr::select(spp_cd, Lat, Long, obs_dt, obs_count_intrans_nb, obs_count_general_nb, dataset_id) 

all_dat = bind_rows(old_obs,obs)

# filter to type in birds
all_dat = all_dat %>% filter(spp_cd %in% birdlist)
# ------------------ #


# ------------------ #
# subset data
# ------------------ #
# make spatial
coordinates(all_dat) = ~lon+lat
proj4string(all_dat) <- CRS("+init=epsg:4326")

# pull whats in the bounding box
x = sp::over(all_dat,whoi_3mile_buffer)
whoi.data = as.data.frame(fc[!is.na(x),])

whoi.data = as.data.frame(whoi.data)
write.csv(whoi.data,"Z:/seabird_database/data_sent/Scott_WHOI_oil_spill_Jan2018/observations.csv")
# ------------- #


# ------------- #
# plots
# ------------- #
# ------------- #
