# --------------------------------------------- #
# For generic public data requests that only have share level 5 clearance
# this script grabs the archived data from the last USGS PostgreSQL export
# and new data from the temporary Access database
#
# This script is not for NOAA or AKN exports since they can use all share levels except 1
#
# This script will not be needed once the new improved SQL Server database is finished
#
# created by Kaycee Coleman
# Oct. 2016
# --------------------------------------------- #


# --------------------------------------------- #
# LOAD PACKAGES
# --------------------------------------------- #
require(rgdal) # shapefiles
require(RODBC) # database
require(dplyr) # data manipulation (%>%)
# --------------------------------------------- #


# --------------------------------------------- #
# SET INPUT/OUTPUT DIRECTORY PATHS
# --------------------------------------------- #
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/seabird_database_export/archive/"
setwd(dir)

#### ENTER FOLDER NAME FOR DATA REQUEST #####
folder = ""
dir.out = paste("//IFW9mbm-fs1/SeaDuck/seabird_database/data_sent/", folder, sep="")
# --------------------------------------------- #


# --------------------------------------------- #
# load data
# --------------------------------------------- #

# ------------------- #
## load archived data

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

## make data.frame
# points has different datasets in it than lines
transect_points = as.data.frame(transect_points) 
tl = as(transect_lines, "SpatialPointsDataFrame")
transect_lines = as.data.frame(tl)
obs = as.data.frame(obs) 
effort = bind_rows(transect_points, transect_lines)
rm(transect_lines, transect_points)
# ------------------- #


# ------------------- #
## load new data
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
transects.in.db = sqlFetch(db, "transect")
tracks.in.db = sqlFetch(db, "track")
data.in.db = sqlFetch(db, "dataset")
obs.in.db = sqlFetch(db, "observation")
camera.in.db = sqlFetch(db, "camera_effort")
odbcClose(db)
# ------------------- #


# ------------------- #
# format 

## combine both datasets
effort = effort %>% rename(track_lon = coords.x1, track_lat = coords.x2)
obs = obs %>% rename(temp_lon = coords.x1, temp_lat = coords.x2)

# might need to add track index number for transect line files # CHECK THIS

effort = bind_rows(effort, tracks.in.db)
obs = bind_rows(obs, obs.in.db)
rm(obs.in.db, tracks.in.db)

# use only share level = 5
to.keep = sort(data.in.db$dataset_id[data.in.db$share_level == 5])
effort = effort[effort$dataset_id %in% to.keep,]
obs = obs[obs$dataset_id %in% to.keep,]
# --------------------------------------------- #

# now query based on request.... 
