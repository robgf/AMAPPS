# --------------------- #
# Quality control EcoMon Sept. 2012 data
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# LOAD PACKAGES
# -------------------------------- #
require(RODBC) # odbcConnect
require(lubridate) #fix timestamps
require(zoo) #na.locf
require(dplyr) # %>% 
library(dtplyr) #data.table
library(stringr) #extract parts of a string
require(rgeos)
require(sp)
library(geosphere)
# -------------------------------- #


# -------------------------------- #
# DEFINE SURVEY
# -------------------------------- #
surveyFolder = "EcoMon_Feb13"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received/EcoMon"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
db = odbcConnectExcel2007(file.path(dir.in, "EM_Feb_2013.xls")) 
obs = sqlFetch(db, "EM130210-130225final")
odbcClose(db)
#---------------------#



#---------------------#
# fix beaufort seastate
#---------------------#  
colnames(obs) = str_replace_all(colnames(obs), fixed(" "), "")
obs = obs %>% rename(beaufort = ort) %>%
  mutate(beaufort=replace(beaufort,is.na(beaufort),Beauf[is.na(beaufort)])) %>% 
  select(-Beauf) 
#---------------------#  


#---------------------#
# fix time
#---------------------#
names(obs)[names(obs) == "ss#s"] = "ss"
obs = mutate(obs,date = as.POSIXct(paste(paste(YYYY,MM1,DD,sep="/")," ", paste(hh,mm,ss,sep=":")), 
                                   format="%Y/%m/%d %H:%M:%S")) %>% 
  select(-YYYY,-MM1,-DD,-hh,-mm,-ss)
#---------------------#


#---------------------#
# break apart obs and track
#---------------------#  
obs = rename(obs, source_transect_id = Transect) 

track = obs[is.na(obs$Spp),]
obs = obs[!is.na(obs$Spp),]
#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

obs$original_species_tx = obs$Spp

tmp <- !obs$Spp %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$Spp[tmp]))

obs = obs %>% select(-Type) %>% rename(type = Spp)
obs$type = as.character(obs$type)
#---------------------#


#---------------------#
# other edits
#---------------------#
# change names to lowercase
colnames(obs) = tolower(names(obs))

# merge comments
obs = obs %>% mutate(comment = paste(comment1, comment2, sep = "; ")) %>% 
  select(-comment1, -comment2)
#---------------------#


#---------------------#
# fix track
#---------------------#
# change names to lowercase
colnames(track) = tolower(names(track))

#get rid of unused columns
track = select(track, -count, -behavior, -plumage, -age, -spp)

#change GPS to WAYPNT
track$type = as.character(track$type)
track$type[track$type %in% "GPS  "] = "WAYPNT"
#track[track$type %in% "USER ",] 
#---------------------#
