# --------------------- #
# NOAA/ NMFS/ NEFSC boat 2016
# Date Created: 1-2017
# Author: Kaycee Coleman
# --------------------- #


# --------------------- #
# load packages
# --------------------- #
require(rgdal)
require(lubridate)
require(dplyr)
require(RODBC)
# --------------------- #


# --------------------- #
# set paths
# --------------------- #
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
surveyFolder = "NOAA NMFS"
yearLabel = "NEFSC_AMAPPS_ship_2016"
dir.in <- paste(dir, surveyFolder, yearLabel, sep = "/") 
dir.out <- paste(gsub("datasets_received", paste("data_import/in_progress", surveyFolder, yearLabel, sep="/"), dir), sep = "/") 

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))
# --------------------- #


# --------------------- #
# load data
# --------------------- #
obs = read.csv(file.path(dir.in,"HB1603Seabirdmerged.csv")) 
# --------------------- #


#---------------------#
# break apart obs and track
#---------------------#  
track = obs[is.na(obs$species),]
obs = obs[!is.na(obs$species),]
#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

obs$original_species_tx = obs$species
obs = rename(obs, type = species)
obs$type = as.character(obs$type)

tmp <- !obs$type %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))

obs$type[obs$type %in% ""] = ""     
obs$type[obs$type %in% "DEDE"] = ""   
obs$type[obs$type %in% "FLOT"] = ""   
obs$type[obs$type %in% "GLME"] = ""   
obs$type[obs$type %in% "LHSP"] = ""   
obs$type[obs$type %in% "NPSS"] = ""   
obs$type[obs$type %in% "PASS"] = ""   
obs$type[obs$type %in% "RAPT"] = ""   
obs$type[obs$type %in% "TRPE"] = ""   
obs$type[obs$type %in% "UNTR"] = ""  
#---------------------#




