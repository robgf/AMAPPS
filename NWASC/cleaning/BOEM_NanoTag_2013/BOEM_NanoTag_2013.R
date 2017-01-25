# --------------------- #
# Quality control BOEM NanoTag 2013 data
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(tidyverse) # read and bind csvs
require(rgdal) # read shapefiles
require(foreign) # read dbf
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

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
#--------#
# load observations with waypoints
#--------#
# the data are formated differently, need to be uploaded separately 
data.list = c( "TernSurvey1_CorrectedObservations.csv","TernSurvey2_CorrectedObservations.csv",
               "TernSurvey3_CorrectedObservations.csv","TernSurvey4_CorrectedObservations.csv")
data.list = paste(dir.in, data.list, sep="/")

data = data.list %>% map_df(~read_csv(.x, col_types = cols(.default = "c")))
data2 = read.csv(file.path(dir.in,"Tern_aerial_survey_NS_2013.csv")) 

colnames(data) = tolower(names(data))
colnames(data2) = tolower(names(data2))

# change data2 coordinates from zone 19N

# combine data & data2
#--------#

#--------#
# load tracks
#--------#
# waypoints are in data above for half of the data
track04 = read.dbf(file.path(track.dir, "Track04Sep13.dbf"), as.is=FALSE)
track06 = read.dbf(file.path(track.dir, "Track06Sep13.dbf"), as.is=FALSE)
track18 = read.dbf(file.path(track.dir, "Track18Aug13.dbf"), as.is=FALSE)
track04$filename = "Track04Sep13"
track06$filename = "Track06Sep13"
track18$filename = "Track18Aug13"
vars = c("Latitude", "Longitude", "altitude","time_", "filename", "ltime")
track2 = bind_rows(select(track04, Latitude, Longitude, altitude, time_, filename, ltime), 
                   select(track06, Latitude, Longitude, altitude, time_, filename, ltime), 
                   select(track18, Latitude, Longitude, altitude, time_, filename, ltime))
rm(track04, track06, track18)
track2 = rename(track2, track_dt = ltime, gps_time = time_)
colnames(track2)=tolower(names(track2))
track2$gps_time = substr(sapply(strsplit(track2$gps_time, " "), tail, 1),1,8)
track$longitude = as.numeric(track$longitude) * -1
#--------#

#--------#
#load transect design
#--------#
transect0406 = readOGR(dsn = track.dir, layer = "Aerial_Tran_04_06Sep13")
transect18 = readOGR(dsn = track.dir, layer = "Aerial_Tran_18Aug13")
#---------------------#


#---------------------#
# break apart obs and track
#---------------------#  
track = data[data$type %in% c("GPS"),]#,"START"
obs = data[data$type=="USER",]
#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

obs$original_species_tx = obs$spp

tmp <- !obs$spp %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$spp[tmp]))

obs$spp[obs$spp %in% "'CXFC"] = "" 
obs$spp[obs$spp %in% "BLUFI"] = ""  
obs$spp[obs$spp %in% "FRONT"] = ""  
obs$spp[obs$spp %in% "FT"] = ""    
obs$spp[obs$spp %in% "MIACO"] = ""  
obs$spp[obs$spp %in% "RBTU"] = ""   
obs$spp[obs$spp %in% "SILTF"] = ""  
obs$spp[obs$spp %in% "STTE"] = ""   
obs$spp[obs$spp %in% "UNTU"] = "" 
obs$spp[obs$spp %in% "START"] = "BEGCNT"
obs$spp[obs$spp %in% "END"] = "ENDCNT"
obs$spp[obs$spp %in% "BOATS"] = ""  
#---------------------#


#---------------------#
# fix track
#---------------------#
# change names to lowercase
track = rename(track, point_type = type)
track$type[track$point_type %in% "GPS  "] = "WAYPNT"
#---------------------#
