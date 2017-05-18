# --------------------- #
# Quality control BOEM NanoTag 2013 data
# from FWS MB
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
#require(rgdal) # read shapefiles
require(dplyr)
#library(maptools)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "BOEM_NanoTag_Study"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received/"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
track.dir <- paste(dir.in, "NanoTag_aerial_gps_tracks_2013", sep="/")
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
data2 = read.csv(file.path(dir.in,"Tern_aerial_survey_NS_2013.csv")) 

colnames(data2) = tolower(names(data2))

# change data2 coordinates from zone 19N
library(rgdal)
coordinates(data2) = ~x_19n + y_19n
sputm <- SpatialPoints(data2, proj4string=CRS("+proj=utm +zone=19 +datum=WGS84"))  
spgeo <- spTransform(sputm, CRS("+proj=longlat +datum=WGS84"))
spgeo = as.data.frame(spgeo)     
colnames(spgeo)=c("longitude","latitude")
# combine data2 & lat lon
data2 = as.data.frame(data2)
data2 = cbind(data2,spgeo)
rm(spgeo,sputm)

# format
data2 = dplyr::select(data2, -x_19n, -y_19n, -objectid,-globalid) %>% rename(behavior = behav) %>%
  mutate(date = sapply(strsplit(as.character(data2$date_time_est)," "),head,1),
         time = sapply(strsplit(as.character(data2$date_time_est)," "),tail,1)) 

#change species
data2$original_species_tx = data2$spp
data2$spp="UNTE"

#change behavior
data2$behavior_id = ifelse(data2$behavior=="fly",14,17) #14=fly, 17=forage
data2 = rename(data2, comments=behavior)

#break data
data18=data2[1:61,]
data04=data2[62:78,]
data06=data2[79:84,]
rm(data2)
#--------#


#--------#
# load tracks
#--------#
# waypoints are in data above for half of the data
track04 = read.dbf(file.path(track.dir, "Track04Sep13.dbf"), as.is=FALSE)
track06 = read.dbf(file.path(track.dir, "Track06Sep13.dbf"), as.is=FALSE)
track18 = read.dbf(file.path(track.dir, "Track18Aug13.dbf"), as.is=FALSE)

#type
track04$type = ifelse(track04$new_seg=="True","BEGCNT","WAYPNT")
track04$type[which(track04$type=="BEGCNT")-1]="ENDCNT"
track04$type[846]="ENDCNT"

track06$type="WAYPNT"
track06$type[1]="BEGCNT"
track06$type[1020]="ENDCNT"

track18$type = ifelse(track18$new_seg==-1,"BEGCNT","WAYPNT")
track18$type[1]="BEGCNT"
track18$type[which(track18$type=="BEGCNT")-1]="ENDCNT"
track18$type[281]="ENDCNT"
#--------#


#--------#
#load transect design
#--------#
#transect0406 = readOGR(dsn = track.dir, layer = "Aerial_Tran_04_06Sep13")
#transect18 = readOGR(dsn = track.dir, layer = "Aerial_Tran_18Aug13")

#aug_sldf <- spTransform(transect18, "+proj=longlat +datum=WGS84")
#sep_sldf <- spTransform(transect0406, "+proj=longlat +datum=WGS84")
#---------------------#

