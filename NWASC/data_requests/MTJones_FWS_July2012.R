# in progress...

# ------------------------ #
# combine old and new seabird catalog data
# pull FWS AMAPPS and seaduck data
#
# dataset ids: 141, 142, 164, 118, 140, 138, 137, 139, 100, 97, 147, 146, 113, 106
# include ITIS codes, common names, species names
# change to fit column names of Regional Point Species Database Structure
# do not need track/transect data, only obs
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
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
data.in.db = sqlFetch(db, "dataset")
obs.in.db = sqlFetch(db, "observation")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)
# ------------------------ #


# ------------------------ #
# directory for export
# ------------------------ #
dir.out = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_sent/MTJones_FWS_July2017"
dir.archive = "//IFW9mbm-fs1/SeaDuck/seabird_database/database_export/archive/seabird_database_obs_trans_tbls_April2016"
dir.from.segmentation = "//IFW9mbm-fs1/SeaDuck/Kyle_Working_Folder/Segmentation/Data/transect_shp_files"
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
# ------------------------ #


# ------------------------ #
# combine datasets
# ------------------------ #
obs.in.db = mutate(obs.in.db, heading_tx = as.character(heading_tx),
                   wind_speed_tx = as.character(wind_speed_tx),
                   wind_dir_tx = as.character(wind_dir_tx),
                   observation_id = obs.in.db$observation_id + 804175) # fix numbers based on data already present

# combine
obs_data = bind_rows(obs.in.db, old_obs)

# fix codes that were deleted when database was updated
obs_data$spp_cd[obs_data$spp_cd %in% "UNPI"]="UNSE" # unidentified pinniped to unidentified seal (no sea lions on east coast)
obs_data$spp_cd[obs_data$spp_cd %in% "CRTE"]="UCRT" # two codes for unidentified common or roseate tern, cut one

rm(old_obs, obs.in.db)
# ------------------------ #


# ------------------------ #
# pull FWS data
# ------------------------ #
obs_data = obs_data %>% filter(dataset_id %in% c(141, 142, 164, 118, 140, 138, 137, 139, 100, 97, 147, 146, 113, 106))
# ------------------------ #

# ------------------------ #
# fix archived observation species codes
# ------------------------ #
tmp <- !obs_data$spp_cd %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs_data$spp_cd[tmp]))

obs_data$spp_cd[obs_data$spp_cd %in% c("TRAW")] = "BOTD"              
# ------------------------ #


# ------------------------ #
# join itis codes and names
# ------------------------ #
obs_data = left_join(obs_data, dplyr::select(spplist,-species_type_cd), by="spp_cd")
# ------------------------ #


# ------------------------ #
# change names
# ------------------------ #
obs_data = obs_data %>% rename(longitude = temp_lon, latitude = temp_lat, itis_tsn = itis_cd,
                               observation_date = obs_dt) %>% 
  dplyr::select(latitude, longitude, observation_date, itis_tsn, common_name, scientific_name) %>% 
  mutate(count_type = "individual observation", centroid = "no", year, month, day, time = NA)
# ------------------------ #


# ------------------------ #
# export csv
# ------------------------ #
write.csv(obs_data, paste(dir.out, "observations.csv", sep="/"), row.names=FALSE)
write.csv(data.in.db, paste(dir.out, "datasets.csv", sep="/"), row.names=FALSE)

# remove NA's
obs_data = obs_data[!is.na(obs_data$latitude),]
obs_data = obs_data[!is.na(obs_data$longitude),]
# ------------------------ #


# ------------------------ #
# make shapefiles
# ------------------------ #
# Coerce into SpatialPointsDataframe
coordinates(obs_data) = ~longitude + latitude

# Assign projection
proj4string(obs_data)=CRS("+proj=longlat +datum=WGS84") 

# write shapefile
writeOGR(obj=obs_data, dsn=dir.out, layer="all_obs_data", driver="ESRI Shapefile") 
# ------------------------ #

