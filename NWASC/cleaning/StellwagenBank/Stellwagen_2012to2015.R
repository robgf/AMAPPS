# --------------------- #
# Quality control StellwagenBank data
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(dplyr)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "Stellwagen"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received/"
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
db <- odbcConnectAccess2007(file.path(dir.in, "NCCOS_Stellwagen_Deliverable_2015_11_13th_v1.accdb"))
obs <- sqlFetch(db, "Bird_Sightings")
lu_age <- sqlFetch(db, "LUT_Age")
lu_assoc <- sqlFetch(db, "LUT_Association")
lu_behavior <- sqlFetch(db, "LUT_Behaviors")
lu_plumage <- sqlFetch(db, "LUT_Plumage")
lu_weather <- sqlFetch(db, "LUT_Weather")
lu_precip <- sqlFetch(db, "LUT_Precipitation")
lu_glare <- sqlFetch(db, "LUT_Glare")
lu_spp <- sqlFetch(db, "LUT_Seabird_Species")
odbcClose(db)

# replace codes
obs = left_join(obs, lu_age, by=c("Age"="ID")) %>% select(-Age) %>% rename(animal_age_tx=Age.y)
obs = left_join(obs, select(lu_behavior, Behavior, Behavior_Code), by=c("Behaviors"="Behavior_Code")) %>% 
  select(-Behaviors) %>% rename(behavior_tx = Behavior)
obs = left_join(obs, select(lu_plumage, ID, Plumage), by=c("Plumage"="ID")) %>% select(-Plumage) %>% 
  rename(plumage_tx=Plumage.y)
obs$Association[obs$Association %in% 0] = NA # no need to denote no association
obs = left_join(obs, lu_assoc, by=c("Association"="Ass_Code")) %>% select(-Association) %>% 
  rename(Association=Association.y)
obs = left_join(obs, select(lu_weather, -Order), by=c("Weather"="WX_Code")) %>% select(-Weather) %>% 
  rename(weather_tx=Weather.y)
obs$cloud_cover_tx = obs$weather_tx
obs = left_join(obs, lu_precip, by=c("Precipitation"="Precip_Code")) %>%  
  mutate(weather_tx = paste(weather_tx, Precipitation.y, sep = "; ")) %>% 
  select(-Precipitation, -Precipitation.y)
obs = left_join(obs, lu_glare, by=c("Glare"="Glare_Code")) %>% select(-Glare) %>% rename(glare_tx=Glare.y)
rm(lu_age, lu_behavior, lu_plumage, lu_assoc, lu_weather, lu_precip, lu_glare)

# fix time
obs = rename(obs, gps_time = Sighting_Time)
obs$gps_time = sapply(strsplit(as.character(obs$gps_time), " "), tail, 1)

# merge comments
obs = obs %>% mutate(comments = paste(Comments, WXNotes, Association, sep = "; ")) %>% 
  select(-Comments, -WXNotes)

# add row for when an associations

#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)
spplist$common_name = tolower(spplist$common_name)

# check if species codes are different
lu_spp$Common_Name = tolower(lu_spp$Common_Name)
lu_spp$Common_Name = as.character(lu_spp$Common_Name)
lu_spp$Species = as.character(lu_spp$Species)
test = left_join(lu_spp, select(spplist,spp_cd,common_name), by=c("Code"="spp_cd")) 
test = test[test$Common_Name != test$common_name,]
rm(test, lu_spp) #after inspected 

# fix codes
obs$original_species_tx = obs$Species

tmp <- !obs$Species %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$Species[tmp]))
rm(spplist)

obs = obs %>% rename(spp = Species) %>% mutate(spp = as.character(spp))
obs$spp[obs$spp %in% "GRSP"] = "UNGR"  #unid grebe
obs$spp[obs$spp %in% "POSP"] = "UNPO" #unid porp
obs$spp[obs$spp %in% "SWSP"] = "SWAL" #unid swallow
obs$spp[obs$spp %in% "UNSH"] = "SHAR" #unid shark
obs$spp[obs$spp %in% "ABFT"] = "BFTU" # atlantic blue fin tuna 
obs$spp[obs$spp %in% "AGWT"] = "GWTE" # american green-winged teal 
obs$spp[obs$spp %in% "ALSP"] = "UNAL" # unidentified alcid
obs$spp[obs$spp %in% "BUSP"] = "UBUT" # butterfly species  
obs$spp[obs$spp %in% "COSP"] = "UNCO" # unidentified cormorant species  
obs$spp[obs$spp %in% "DUSP"] = "UNDU" # unidentified sea duck
obs$spp[obs$spp %in% "GUSP"] = "UNGU" # unidentified gull  
obs$spp[obs$spp %in% "JASP"] = "UNJA" # unidentified jaeger  
obs$spp[obs$spp %in% "LAND"] = "UNBI" # any unidentified terrestrial bird  
obs$spp[obs$spp %in% "LOSP"] = "UNLO" # loon species  
#obs$spp[obs$spp %in% "MADE"] = "" # marine debris (NEED TO PULL OUT BALLOONS FROM COMMENTS)
obs$spp[obs$spp %in% "NAWH"] = "RIWH" # north atlantic right whale  
obs$spp[obs$spp %in% "OTHER"] = "UNKN"  
obs$spp[obs$spp %in% "PHSP"] = "UNPH" #unidentified phalarope  
obs$spp[obs$spp %in% "SCSP"] = "UNSC" #unidentified scoter  
obs$spp[obs$spp %in% "SHSP"] = "UNSH" #unidentified shearwater  
obs$spp[obs$spp %in% "SONG"] = "UNPA" #unidentified songbird species  
obs$spp[obs$spp %in% "TESP"] = "UNTE" #unidentified tern 
obs$spp[obs$spp %in% "TUSP"] = "TURT" #unidentified turtle  
obs$spp[obs$spp %in% "VESS"] = "BOAT" #vessel
obs$spp[obs$spp %in% "WASP"] = "UNWA" #unidentified warbler  
obs$spp[obs$spp %in% "WHSP"] = "UNWH" #unidentified whale 
#---------------------#

