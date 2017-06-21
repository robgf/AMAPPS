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
# --------------------- #


# --------------------- #
# load data
# --------------------- #
obs = read.csv(file.path(dir.in,"HB1603Seabirdmerged.csv")) 
# --------------------- #


#---------------------#
# break apart obs and track
#---------------------#  
track = obs[obs$species %in% "",]
obs = obs[!obs$species %in% "",]
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
obs$type[obs$type %in% "DEDE"] = "CODO" # unknown    
obs$type[obs$type %in% "FLOT"] = "FLJE"  
obs$type[obs$type %in% "GLME"] = "LFPW"   
obs$type[obs$type %in% "LHSP"] = "UNSP" #Leach's/Hartcourt's storm-petrel   
obs$type[obs$type %in% "NPSS" & obs$comments %in% "Eurasian Collared-Dove"] = "EUCD" 
obs$type[obs$type %in% "PASS" & obs$comments %in% "Brown-headed Cowbird"] = "BHCO"   
obs$type[obs$type %in% "PASS" & obs$comments %in% "Baltimore Oriole"] = "BAOR"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Palm warbler"] = "PAWA"
obs$type[obs$type %in% "PASS" & obs$comments %in% "unid waterthrush"] = "UNPA"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Common Yellowthroat"] = "COYE"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Barn Swallow"] = "BARS"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Cliff Swallow"] = "CLSW"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Red-breasted Nuthatch landed briefly on canopy"] = "RBNU"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Ovenbird, on foredeck at dawn"] = "OVEN"
obs$type[obs$type %in% "PASS" & obs$comments %in% "probable Tree Swallow"] = "TRES"
obs$type[obs$type %in% "PASS" & obs$comments %in% "same bird as yesterday, spent night on board"] = "UNPA"
obs$type[obs$type %in% "RAPT"] = "OSPR"   
obs$type[obs$type %in% "TRPE"] = "HEPE"  
obs$type[obs$type %in% "UNTR"] = "UNTB" 

# fix codes
sex=as.data.frame(rbind(c(1,"unknown"), c(2,"female"), c(3,"male"))); names(sex)=c("code","desc")
age=as.data.frame(rbind(c(1,"adult"), c(2,"subadult"))); names(age)=c("code","desc")
assoc=as.data.frame(rbind(c(2,"association with another individidual"), c(3,"assoc. unknown"), 
                          c(1,"solitary bird"),c(0,"none"),c(10,"fish shoal"),c(11,"cetaceans"),
                          c(13,"convergence zone"),c(14,"floating litter"),c(17,"floating weeds"),
                          c(26,"fishing vessel"))); names(assoc)=c("code","desc")
behavior=as.data.frame(rbind(c(1,"sitting"), c(10,"milling"),c(11,"pattering"),c(12,"porpoising"),
                             c(13,"diving"),c(14,"forage flight"),c(15,"unknown flight"),
                             c(16,"flocking"),c(17,"dead"),c(3,"following ship"),c(4,"feeding"),
                             c(5,"piracy"),c(6,"other"),c(7,"unknown"),c(8,"direct flight"),
                             c(9,"non-directional flight"))); names(behavior)=c("code","desc")
assoc$code=as.numeric(assoc$code)
age$code=as.numeric(age$code)
sex$code=as.numeric(sex$code)
behavior$code=as.numeric(behavior$code)

obs = left_join(obs,assoc,by = c("association"="code")) %>% select(-association) %>% rename(association = desc) %>%
  left_join(.,age,by = c("age"="code")) %>% select(-age) %>% rename(age = desc) %>%
  left_join(.,sex,by = c("sex"="code")) %>% select(-sex) %>% rename(sex = desc) %>%
  left_join(.,behavior,by = c("behavior"="code")) %>% select(-behavior) %>% rename(behavior = desc)
rm(age,sex,behavior,assoc)


db <- odbcDriverConnect('driver={SQL Server};server=ifw-dbcsqlcl1.fws.doi.net;database=NWASC;trusted_connection=true')
lu_behavior = sqlFetch(db, "lu_behaviors")
lu_age = sqlFetch(db,"lu_age")
lu_sex = sqlFetch(db,"lu_sex")
odbcClose(db)

obs = left_join(obs,lu_age,by = c("age"="age_ds")) %>% 
  left_join(.,lu_sex,by = c("sex"="sex_ds")) %>% 
  left_join(.,lu_behavior,by = c("behavior"="behavior_ds"))
rm(lu_age,lu_sex,lu_behavior)
#---------------------#




