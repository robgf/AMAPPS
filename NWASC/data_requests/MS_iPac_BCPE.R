# -------------- #
# look for BCPE data around Mass. to QA/QC iPac beta
# also look for observations in July-Sept
# -------------- #


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
# load data
# -------------- #
db <- dbConnect(odbc::odbc(),
                driver='SQL Server',
                server='ifw9mbmsvr008',
                database='SeabirdCatalog')

# call the observation, returning the geometry field as x and y columns.
old_obs = dbGetQuery(db,"select observation_id,transect_id,dataset_id,obs_dt,
                     spp_cd, obs_count_intrans_nb, [Geometry].STY as Lat, 
                     [Geometry].STX as Long
                     from observation where spp_cd in ('BCPE')")

# identify column with coordinates
coordinates(old_obs) <- ~ Long + Lat

# set the projection, assume WGS84
proj4string(old_obs) <- CRS("+init=epsg:4326")

# turn back to dataframe
old_obs = as.data.frame(old_obs)

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlFetch(db, "observation")
dataset = sqlFetch(db, "dataset")
odbcClose(db)
obs = dplyr::rename(obs, Lat = temp_lat, Long = temp_lon) %>% 
  mutate(obs_dt = as.Date(obs_dt,format="m%/%d/%Y")) %>% 
  filter(spp_cd %in% 'BCPE')

# combine old and new
# creat month column
dat = bind_rows(old_obs,obs) %>% dplyr::select(spp_cd, Lat, Long, obs_dt, dataset_id) %>% 
  mutate(month = month(obs_dt))

# find those datasets with data in July (7) - Sept. (9)
x = dat %>% filter(month %in% c(7,8,9)) %>% group_by(month) %>% select(dataset_id, month) %>% distinct(dataset_id)
# -------------- #


# -------------- #
# plot
# -------------- #
usa <- map_data("usa")

ggplot(data =usa) + geom_polygon(aes(x = long, y = lat, group = group), fill = "#669933", color = "#333300") + 
  coord_fixed(1.3) + coord_fixed(xlim = c(-82, -65),  ylim = c(25, 47), ratio = 1.3) + 
  geom_point(data = dat, aes(x = Long, y = Lat)) + theme_bw() + ggtitle("BCPE observations")
# -------------- #

