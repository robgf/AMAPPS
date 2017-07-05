# --------------------- #
# Quality control StellwagenBank data
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(dplyr)
require(measurements)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "Stellwagen"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
# observations
db <- odbcConnectAccess2007(file.path(dir.in, "Seabird_Mike_v.45_2017_04_21st.accdb"))
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

# gps
db = odbcConnectExcel2007(paste(dir.in,"auk_gps_standardized_2012_thru_Aug_05_2015 (2).xlsx",sep="/")) # open a connection to the Excel file
a = sqlFetch(db, "Mike_Auk_GPS")
odbcClose(db)

a = a %>% mutate(time = sapply(strsplit(as.character(Time_LCL_BOSTON)," "),tail,1)) %>%
  dplyr::select(-Source,-Time_LCL_BOSTON) %>% 
  rename(date = Date_LCL_BOSTON,date_time = Timestamp_LCL_BOSTON) 

d = read.table(paste(dir.in,"2015_10_27th_Auk_Standardized_Garmin_Unit2.txt",sep="/"), sep = "\t", header=FALSE, skip=19)
e = read.table(paste(dir.in,"2015_09_28th_Auk_GarminUnit2.txt",sep="/"), sep = "\t", header=FALSE, skip=19)
f = read.table(paste(dir.in,"2015_12_26th_Auk_Unit1.txt",sep="/"), sep = "\t", header=FALSE, skip=19)
b = bind_rows(d,e,f)

names(b)= c("point_type","Position","Time","Altitude","Depth",
            "Temperature","Leg_length","Leg_time","Speed","Course")
b = b %>% mutate(Position = as.character(Position),
                 lat = sapply(strsplit(Position, "W"),head,1),
                 lat = sapply(strsplit(lat, "N"),tail,1),
                 long = sapply(strsplit(Position, "W"),tail,1),
                 Latitude = as.numeric(measurements::conv_unit(lat, from = 'deg_dec_min', to = 'dec_deg')),
                 Longitude = measurements::conv_unit(long, from = 'deg_dec_min', to = 'dec_deg'),
                 Longitude = as.numeric(Longitude)*-1,
                 date_time = as.POSIXct(Time,format="%m/%d/%Y %H:%M:%S %p "),
                 date = as.POSIXct(sapply(strsplit(as.character(date_time)," "),head,1)),
                 time = sapply(strsplit(as.character(date_time)," "),tail,1),
                 heading = sapply(strsplit(Course,"°"),head,1)) %>% 
  dplyr::select(-lat,-long,-Position,-Time,-Course)

track = bind_rows(a,b) %>% arrange(date_time)
rm(a,b,d,e,f)
#---------------------# 

#---------------------# 
# fix codes
#---------------------# 
# replace codes
obs = left_join(obs, lu_age, by=c("Age"="ID")) %>% 
  left_join(., select(lu_behavior, Behavior, Behavior_Code), by=c("Behavior"="Behavior_Code")) %>% 
  left_join(., select(lu_plumage, ID, Plumage), by=c("Plumage"="ID")) %>% 
  left_join(., mutate(lu_assoc,Ass_Code=as.factor(Ass_Code)), by=c("Association"="Ass_Code")) %>% 
  left_join(., select(lu_weather, -Order) %>% mutate(WX_Code=as.factor(WX_Code)), by=c("Weather"="WX_Code")) %>% 
  left_join(., lu_precip, by=c("Precipitation"="Precip_Code")) %>%  
  left_join(., lu_glare, by=c("Glare"="Glare_Code")) %>% 
  rename(animal_age_tx=Age.y, behavior_tx = Behavior.y, plumage_tx=Plumage.y,
         Association_tx=Association.y, glare_tx=Glare.y, weather_tx=Weather.y) %>%
  mutate(cloud_cover_tx = weather_tx,
         weather_tx = paste(weather_tx, Precipitation.y, sep = "; ")) %>%
  dplyr::select(-Behavior, -Precipitation, -Precipitation.y, -Glare, -Age) 

rm(lu_age, lu_behavior, lu_plumage, lu_assoc, lu_weather, lu_precip, lu_glare)

# fix time
obs = rename(obs, gps_time = Sighting_Time) %>% 
  mutate(gps_time = sapply(strsplit(as.character(gps_time), " "), tail, 1))

# merge comments
obs = obs %>% mutate(comments = paste(Comments, WXNotes, Association, sep = "; ")) %>% 
  select(-Comments, -WXNotes) %>% 
  mutate(comments = ifelse(comments %in% c("NA;NA;NA"),NA,comments))

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
