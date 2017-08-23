# ------------------------ #
# combine old and new seabird catalog data
# pull out black-capped petrel observations
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

data$obs_count_general_nb[data$dataset_id %in% c(23,174) & !is.na(data$obs_count_intrans_nb)]=NA

data = data %>% mutate(lon = ifelse(is.na(lon),temp_lon,lon),
                       lat = ifelse(is.na(lat),temp_lat,lat),
                       lon = as.numeric(lon), lat = as.numeric(lat)) %>% 
  rowwise() %>% mutate(total_count = sum(obs_count_general_nb,obs_count_intrans_nb,na.rm=TRUE)) %>%
  dplyr::select(-temp_lat, -temp_lon, -who_created, -who_created_tx)


# fix dates to be the same format
data$obs_dt[grepl("/",data$obs_dt)] = as.character(as.Date(data$obs_dt[grepl("/",data$obs_dt)],format="%m/%d/%Y"))

# create year variable due to users intent for data use and select those of interest
data = mutate(data, year = substr(obs_dt, 1, 4),
              month = as.numeric(substr(obs_dt, 6, 7)),
              season = ifelse(month %in% 3:5, "spring",
                              ifelse(month %in% 6:8, "summer",
                                     ifelse(month %in% 9:11, "fall","winter")))) %>% 
  dplyr::select(observation_id, dataset_id, source_dataset_id, transect_id, 
                obs_dt, year, month, season, obs_count_intrans_nb, obs_count_general_nb,
                total_count, lat, lon)

# filter out transects that are in this data
track_data = filter(track_data, transect_id %in% unique(data$transect_id))
transect_data = filter(transect_data, transect_id %in% unique(data$transect_id))

# filter out datasets
datasets = filter(data.in.db, dataset_id %in% unique(data$dataset_id)) %>% 
  dplyr::select(dataset_id, survey_type_cd, survey_method_cd, dataset_type_cd, 
                source_dataset_id, survey_width_m, individual_observation_width_m, 
                start_date, end_date, parent_project, qual_rpt, meta_std, resp_party, 
                comments, url_program,subject, keywords, title, version, abstract, purpose)
# ------------------------ #


# ------------------------ #
# summarize data
# They are interested in total sightings/year within the survey area. 
# Also, a helpful metric would be total days surveyed or sampled each of those years. 
# This would help us to determine (or at least account for) if any changes in petrel 
# numbers from one year to another was due to real population changes, or perhaps a result of 
# increased/decreased survey effort(s).
# ------------------------ #

# number by year
x = data %>%
  group_by(year) %>% 
  summarise(mean_count_intrans=mean(obs_count_intrans_nb), var_count_intrans = var(obs_count_intrans_nb), sd_count_intrans = sd(obs_count_intrans_nb), 
            mean_count_ingeneral=mean(obs_count_general_nb), var_count_ingeneral = var(obs_count_general_nb), sd_count_ingeneral = sd(obs_count_general_nb),
            mean_count_total=mean(total_count), var_count_total = var(total_count), sd_count_total = sd(total_count),
            sum_count_intrans=sum(obs_count_intrans_nb,na.rm=TRUE), 
            sum_count_general = sum(obs_count_general_nb,na.rm=TRUE), 
            sum_count_total = sum(total_count,na.rm=TRUE),
            sum_days = length(unique(paste(obs_dt,dataset_id)))) 

ggplot(data, aes(year,obs_count_intrans_nb,fill=year))+
  geom_boxplot()+
  guides(fill=FALSE)+
  xlab("year")+
  ylab("count")+
  ggtitle("mean count per year on transect, not normalized by effort, y-axis cut at 25")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,25))

ggplot(data, aes(year,obs_count_general_nb,fill=year))+
  geom_boxplot()+
  guides(fill=FALSE)+
  xlab("year")+
  ylab("count")+
  ggtitle("mean count per year off transect, not normalized by effort, y-axis cut at 25")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,25))

ggplot(data, aes(year,total_count,fill=year))+
  geom_boxplot()+
  guides(fill=FALSE)+
  xlab("year")+
  ylab("count")+
  ggtitle("mean count per year total, not normalized by effort, y-axis cut at 25")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,25))

ggplot(x, aes(year,sum_count_general))+
  geom_bar(stat="identity")+
  xlab("year")+
  ylab("count")+
  ggtitle("total counts per year off transect, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(year,sum_count_intrans))+
  geom_bar(stat="identity")+
  xlab("year")+
  ylab("count")+
  ggtitle("total counts per year on transect, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(year,sum_count_total))+
  geom_bar(stat="identity")+
  xlab("year")+
  ylab("count")+
  ggtitle("total counts per year, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(year,sum_days))+
  geom_bar(stat="identity")+
  xlab("year")+
  ylab("count")+
  ggtitle("total days surveys per year")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# by season
x = data %>% 
  group_by(season) %>% 
  summarise(mean_count_intrans=mean(obs_count_intrans_nb, na.rm=TRUE), var_count_intrans = var(obs_count_intrans_nb, na.rm=TRUE), sd_count_intrans = sd(obs_count_intrans_nb, na.rm=TRUE), 
            mean_count_ingeneral=mean(obs_count_general_nb, na.rm=TRUE), var_count_ingeneral = var(obs_count_general_nb, na.rm=TRUE), sd_count_ingeneral = sd(obs_count_general_nb, na.rm=TRUE),
            mean_count_total=mean(total_count, na.rm=TRUE), var_count_total = var(total_count, na.rm=TRUE), sd_count_total = sd(total_count, na.rm=TRUE),
            sum_count_intrans=sum(obs_count_intrans_nb, na.rm=TRUE), 
            sum_count_general = sum(obs_count_general_nb, na.rm=TRUE), 
            sum_count_total = sum(total_count, na.rm=TRUE),
            sum_days = length(unique(paste(obs_dt,dataset_id)))) 

ggplot(data, aes(season,obs_count_intrans_nb,fill=season))+
  geom_boxplot()+
  guides(fill=FALSE)+
  xlab("season")+
  ylab("count")+
  ggtitle("mean count per season on transect, not normalized by effort, y-axis cut at 10")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,10))

ggplot(data, aes(season,obs_count_general_nb,fill=season))+
  geom_boxplot()+
  guides(fill=FALSE)+
  xlab("season")+
  ylab("count")+
  ggtitle("mean count per season off transect, not normalized by effort, y-axis cut at 20")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,20))

ggplot(data, aes(season,total_count,fill=season))+
  geom_boxplot()+
  guides(fill=FALSE)+
  xlab("season")+
  ylab("count")+
  ggtitle("mean count per season total, not normalized by effort, y-axis cut at 15")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,15))

ggplot(x, aes(season,sum_count_general))+
  geom_bar(stat="identity")+
  xlab("season")+
  ylab("count")+
  ggtitle("total counts per season off transect, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(season,sum_count_intrans))+
  geom_bar(stat="identity")+
  xlab("season")+
  ylab("count")+
  ggtitle("total counts per season on transect, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(season,sum_count_total))+
  geom_bar(stat="identity")+
  xlab("season")+
  ylab("count")+
  ggtitle("total counts per season, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(season,sum_days))+
  geom_bar(stat="identity")+
  xlab("season")+
  ylab("count")+
  ggtitle("total days surveyed per seaon")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# by year by season
x = data %>% 
  group_by(year, season) %>% 
  summarise(mean_count_intrans=mean(obs_count_intrans_nb, na.rm=TRUE), var_count_intrans = var(obs_count_intrans_nb, na.rm=TRUE), sd_count_intrans = sd(obs_count_intrans_nb, na.rm=TRUE), 
            mean_count_ingeneral=mean(obs_count_general_nb, na.rm=TRUE), var_count_ingeneral = var(obs_count_general_nb, na.rm=TRUE), sd_count_ingeneral = sd(obs_count_general_nb, na.rm=TRUE),
            mean_count_total=mean(total_count, na.rm=TRUE), var_count_total = var(total_count, na.rm=TRUE), sd_count_total = sd(total_count, na.rm=TRUE),
            sum_count_intrans=sum(obs_count_intrans_nb, na.rm=TRUE), 
            sum_count_general = sum(obs_count_general_nb, na.rm=TRUE), 
            sum_count_total = sum(total_count, na.rm=TRUE),
            sum_days = length(unique(paste(obs_dt,dataset_id))))  

ggplot(data, aes(year,obs_count_intrans_nb,fill=season))+
  geom_boxplot()+
  guides(fill=FALSE)+
  facet_wrap(~as.factor(season), nrow=4)+
  xlab("year")+
  ylab("count")+
  ggtitle("mean count per season on transect, not normalized by effort, y-axis cut at 20")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,20))

ggplot(data, aes(year,obs_count_general_nb,fill=season))+
  geom_boxplot()+
  guides(fill=FALSE)+
  facet_wrap(~as.factor(season), nrow=4)+
  xlab("year")+
  ylab("count")+
  ggtitle("mean count per season off transect, not normalized by effort, y-axis cut at 30")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,30))

ggplot(data, aes(year,total_count,fill=season))+
  geom_boxplot()+
  guides(fill=FALSE)+
  facet_wrap(~as.factor(season), nrow=4)+
  xlab("year")+
  ylab("count")+
  ggtitle("mean count per season, not normalized by effort, y-axis cut at 30")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  coord_cartesian(ylim = c(0,30))

ggplot(x, aes(year,sum_count_intrans))+
  geom_bar(stat="identity")+
  facet_wrap(~as.factor(season), nrow=4)+
  xlab("year")+
  ylab("count")+
  ggtitle("total counts per season on transect, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(year,sum_count_general))+
  geom_bar(stat="identity")+
  facet_wrap(~as.factor(season), nrow=4)+
  xlab("year")+
  ylab("count")+
  ggtitle("total counts per season off transect, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(year,sum_count_total))+
  geom_bar(stat="identity")+
  facet_wrap(~as.factor(season), nrow=4)+
  xlab("year")+
  ylab("count")+
  ggtitle("total counts per season, not normalized by effort")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(x, aes(year,sum_days))+
  geom_bar(stat="identity")+
  facet_wrap(~as.factor(season), nrow=4)+
  xlab("year")+
  ylab("count")+
  ggtitle("total days surveyed per season by year")+ 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# ------------------------ #


# ------------------------ #
# export csv
# ------------------------ #
write.csv(data, paste(dir.out, "observations.csv", sep="/"), row.names=FALSE)
write.csv(track_data, paste(dir.out, "tracks.csv", sep="/"), row.names=FALSE)
write.csv(transect_data, paste(dir.out, "transects.csv", sep="/"), row.names=FALSE)
write.csv(datasets, paste(dir.out, "datasets.csv", sep="/"), row.names=FALSE)

rm(old_transects, transects.in.db, transect_data, old_transect_lines, old_transect_points, 
   data.in.db, obs.in.db, tracks.in.db, old_obs, obs_data)
# ------------------------ #
