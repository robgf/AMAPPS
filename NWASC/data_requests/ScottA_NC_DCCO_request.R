# --------------- #
# request from Scott A., NC Wildlife RC
# DCCO, obs and effort
#
# should be readdressed when new data is in
# requested - Sept. 2016
# filled - Jan. 2017
#
# created by K. Coleman
# --------------- #


# --------------- #
# packages
# --------------- #
require(rgdal)
require(dplyr)
library(RODBC)
# --------------- #


# --------------- #
# paths
# --------------- #
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/database_export/archive"
dir.out = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_sent/ScottAnderson_Jan2016"
setwd(dir)
# --------------- #


# --------------- #
# load data
# --------------- #
## The input file geodatabase
fgdb = file.path(dir, "seabird_database_export_boem_15July2014.gdb")

## List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list = ogrListLayers(fgdb)
print(fc_list)

## Read the feature class
obs = readOGR(dsn = fgdb,layer = "observations")
transect_lines = readOGR(dsn = fgdb,layer = "transect_lines")   
transect_points = readOGR(dsn = fgdb,layer = "transect_points") 

## grab DCCO data
obs = as.data.frame(obs)
obs = obs[obs$spp_cd == "DCCO",]
obs = rename(obs, longitude = coords.x1, latitude = coords.x2)
obs$longitude[obs$longitude==0] = NA
obs$latitude[obs$latitude==0] = NA

## make data.frame
# points has different datasets in it than lines
transect_points = as.data.frame(transect_points) 
tl = as(transect_lines, "SpatialPointsDataFrame")
transect_lines = as.data.frame(tl)
transect_points = rename(transect_points, longitude = coords.x1, latitude = coords.x2)
transect_lines = rename(transect_lines, longitude = coords.x1, latitude = coords.x2)
transect_lines$spatialDataFrameType = "From SpatialLinesDataFrame"  
transect_points$spatialDataFrameType = "From SpatialPointsDataFrame" 
effort = bind_rows(transect_lines, transect_points)
rm(transect_lines, transect_points)
# --------------- #


# --------------- #
# grab share level 5 datasets
# --------------- # 
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
data.in.db = sqlFetch(db, "dataset")
odbcClose(db)
sl5 = data.in.db$dataset_id[data.in.db$share_level %in% 5]
rm(data.in.db)
obs = obs[obs$dataset_id %in% sl5,]
obs$obs_dt = sapply(strsplit(as.character(obs$obs_dt), " "), head, 1) # had time as 00:00:00 in the cells
effort = effort[effort$dataset_id %in% unique(obs$dataset_id),]
effort$start_dt = sapply(strsplit(as.character(effort$start_dt), " "), head, 1) # had time as 00:00:00 in the cells
effort$end_dt = sapply(strsplit(as.character(effort$end_dt), " "), head, 1) # had time as 00:00:00 in the cells

datasets_metadata = data.in.db[data.in.db$dataset_id %in% unique(obs$dataset_id),]
datasets_metadata$survey_type_cd = as.character(datasets_metadata$survey_type_cd)
datasets_metadata$dataset_type_cd = as.character(datasets_metadata$dataset_type_cd)
datasets_metadata$survey_method_cd = as.character(datasets_metadata$survey_method_cd)
datasets_metadata$survey_type_cd[datasets_metadata$survey_type_cd=="b"]="boat" 
datasets_metadata$survey_type_cd[datasets_metadata$survey_type_cd=="a"]="aerial" 
datasets_metadata$dataset_type_cd[datasets_metadata$dataset_type_cd=="og        "]="original general observation" 
datasets_metadata$dataset_type_cd[datasets_metadata$dataset_type_cd=="ot        "]="original transect" 
datasets_metadata$survey_method_cd[datasets_metadata$survey_method_cd=="cts"]="continuous time strip" 
datasets_metadata$survey_method_cd[datasets_metadata$survey_method_cd=="dts"]="discrete time strip" 
datasets_metadata$survey_method_cd[datasets_metadata$survey_method_cd=="go"]="general observation" 
datasets_metadata$survey_method_cd[datasets_metadata$survey_method_cd=="tss"]="targeted species survey" 
datasets_metadata$survey_method_cd[datasets_metadata$survey_method_cd=="byc"]="bycatch" 
datasets_metadata = select(datasets_metadata,-who_created,-date_created,-share_level,-admin_notes,
                           -import_notes,-usgs_priority,-noaa_priority,-action_required,-action_taken,
                           -parent_project,-noaa_import_priority,-funded,-at_usgs,-in_db,-progress)
# --------------- #


# --------------- #
# export as csvs
# --------------- #
write.csv(obs, file=paste(dir.out,"DCCO_obs_points.csv",sep="/"), row.names = FALSE)
write.csv(effort, file=paste(dir.out,"DCCO_effort_points.csv",sep="/"), row.names = FALSE)
write.csv(datasets_metadata, file=paste(dir.out,"DCCO_datasets_metadata.csv",sep="/"), row.names = FALSE)
# --------------- #
