# Example: Create multipart spatial lines shapefile from AMAPPS track tables
# Kyle Dettloff
# 06-17-2016

library(maptools)
library(dplyr)

# load track data
load("Q:/Kyle_Working_Folder/Segmentation/Atlantic_Coast_Surveys/Data/tracks.RData")

# prepare track file to become shapefile
seg = tracks %>% select(-c(Crew, Seat)) %>% arrange(SurveyNbr, Transect, Replicate, Obs, Year, Month, Day, Sec) %>%
  mutate(Piece = ifelse(Type %in% c("BEGTRAN", "BEGCNT"), 1, 0)) %>%
  group_by(SurveyNbr, Transect, Replicate, Obs) %>% mutate(Piece = cumsum(Piece)) %>%
  distinct(Long, Lat, Piece, Replicate, Obs, Transect, SurveyNbr) %>%
  mutate(id = paste(SurveyNbr, Transect, Replicate, Obs, Piece, sep = "-"),
         transect_id = paste(SurveyNbr, Transect, Replicate, Obs, sep = "-"))

# create dataframe suitable to become spatial lines object 
listLines = function(df) {
  df %>% select(Long, Lat) %>% as.data.frame %>% Line %>% list
}

linelist = seg %>% group_by(transect_id, id) %>% do(coords = listLines(.))
# create spatial lines dataframe from segment waypoints and assign ID to each segment
lineframe = mapply(x = linelist$coords, ids = linelist$id, function(x, ids) Lines(x, ids)) %>% SpatialLines %>%
  SpatialLinesDataFrame(., as.data.frame(select(linelist, transect_id)), match.ID = FALSE)

# specify target directory #
setwd("Q:/Kyle_Working_Folder/ArcGIS/NWASC/ACS")
# create shapefile
writeSpatialShape(lineframe, "track_lines_acs")

### In ArcGIS ###
# Geoprocessing --> Dissolve
# Select 'track_lines_acs' as Input Feature, choose name and file location of Output Feature
# Choose 'transect_id' as Dissolve_Field

# read new multipart shapefile into R
library(rgdal)
shp = readOGR("C:/Users/kdettloff/Documents/ArcGIS/NWASC/ACS", "track_lines_acs_multi")

