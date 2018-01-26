# ------------ #
# ECOMON 2017 data
# GU1701
# GU1702
# GU1706
# ------------ #


# ------------ #
# load packages
# ------------ #
require(dplyr)
require(readxl)
require(odbc)
# ------------ #


# ------------ #
# load data
# ------------ #
obs <- read_excel("Z:/seabird_database/datasets_received/EcoMon/ECOMON_2017/EcomonSeabirdSightings2017.xlsx")
effort <- read_excel("Z:/seabird_database/datasets_received/EcoMon/ECOMON_2017/EcomonSeabirdEffort2017.xlsx")
# ------------ #


# ------------ #
# fix errors
# ------------ #
names(obs) = tolower(names(obs))
names(effort) = tolower(names(effort))

obs$original_species_tx = paste(obs$species,obs$comname,obs$sciname,sep="_")

# ------- #
# look up species errors
# ------- #
db <- dbConnect(odbc::odbc(), driver='SQL Server', server='ifw-dbcsqlcl1', database='NWASC')
spplist = dbGetQuery(db,"select * from lu_species2")

tmp <- !obs$species %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$species[tmp]))

obs$species[obs$species %in% "BASW"] = "BARS" #Barn swallow
obs$species[obs$species %in% "LEST"] = "LETE" #least tern
obs$species[obs$species %in% "LHSP"] = "UNSP" #Leach's/Hartcourt's storm-petrel
obs$species[obs$species %in% "PASS"] = "UNPA" 
obs$species[obs$species %in% "RWBB"] = "RWBL" #Red-winged blackbird
obs$species[obs$species %in% "STTE"] = "CATE" #Common/Arctic tern
obs$species[obs$species %in% "TRPE"] = "HEPE" #Trinidad petrel aka Herald Petrel
obs$species[obs$species %in% "WTTB"] = "WTTR" #White-tailed tropicbird
# ------- #

# ------- #
# split time and date
# ------- #
obs = mutate(obs, 
             date = as.Date(sapply(strsplit(sightdatetimelocal," "),head,1),format="%d-%b-%y"), 
             time = sapply(strsplit(sightdatetimelocal," "),tail,1)) %>% 
  dplyr::select(-sightdatetimelocal)

effort = mutate(effort, 
                date = as.Date(sapply(strsplit(datetimelocal," "),head,1),format="%d-%b-%y"), 
                hour = substring(sapply(strsplit(datetimelocal," "),tail,2)[1],1,2),
                min = substring(sapply(strsplit(datetimelocal," "),tail,2)[1],4,5),
                sec = substring(sapply(strsplit(datetimelocal," "),tail,2)[1],7,8),
                p = sapply(strsplit(datetimelocal," "),tail,1),
                hour = ifelse(p %in% "PM" & !hour %in% "12",as.numeric(hour)+12,hour),
                time = paste(hour,min,sec,sep=":")) %>% 
  dplyr::select(-datetimelocal,-hour,-min,-sec,-p)
# ------- #

# ------- #
# add age id, associate, & behavior_id
# ------- #
obs = obs %>%
  mutate(behavior_id = behaviordesc,
         association = assocdesc) %>%
  rename(type = species,behavior_tx = behaviordesc, age_tx = age) %>% 
  rowwise %>% 
  mutate(age_id = ifelse(age_tx %in% 'Adult',1,ifelse(age_tx %in% 'Subadult',7,5)),
         behavior_id = replace(behavior_id,behavior_id %in% c("directional flight","non-directional flight"),13),
         behavior_id = replace(behavior_id,behavior_id %in% c("feeding"),9),
         behavior_id = replace(behavior_id,behavior_id %in% c("following ship"),15),
         behavior_id = replace(behavior_id,behavior_id %in% c("milling"),21),
         behavior_id = replace(behavior_id,behavior_id %in% c("other"),23),
         behavior_id = replace(behavior_id,behavior_id %in% c("pattering"),42),
         behavior_id = replace(behavior_id,behavior_id %in% c("piracy"),24),
         behavior_id = replace(behavior_id,behavior_id %in% c("sitting"),35),
         behavior_id = replace(behavior_id,behavior_id %in% c("porpoising"),25),
         behavior_id = replace(behavior_id,behavior_id %in% c("diving"),8),
         behavior_id = replace(behavior_id,behavior_id %in% c("unknown"),44), 
         association = replace(association,association %in% "associated with other individuals",type),
         association = replace(association,association %in% "solitary bird",NA),
         association = replace(association,association %in% "association unknown",'UNKN'),
         association = replace(association,is.na(association) & behavior_id %in% 15,"BOAT")) %>% 
  as.data.frame()
# ------- #

# ------- #
# add type in effort
# ------- #
effort = mutate(effort, type = NA,
                type = replace(type,event %in% 1,"BEGCNT"),
                type = replace(type,event %in% 3,"ENDCNT"),
                offline = ifelse(effort %in% 'off',1,0))
# ------- #

# ------- #
# assign transect ids and effort to obs
# ------- #
# ------- #

# ------------ #


# ------------ #
# split by survey and assign id
#  GU1701 2017-05-16 to 2017-06-06 -> id 393
#  GU1702 2017-06-10 to 2017-06-22 -> id 394
#  GU1706 2017-10-31 to 2017-11-09 -> id 412
# ------------ #
obs = obs %>% mutate(dataset_id = 412,
                     dataset_id = replace(dataset_id,tripid %in% 'GU1701',393),
                     dataset_id = replace(dataset_id,tripid %in% 'GU1702',394))
effort = effort %>% mutate(dataset_id = 412,
                           dataset_id = replace(dataset_id,tripid %in% 'GU1701',393),
                           dataset_id = replace(dataset_id,tripid %in% 'GU1702',394))


obs1 = obs[obs$dataset_id %in% 393,]
obs2 = obs[obs$dataset_id %in% 394,]
obs6 = obs[obs$dataset_id %in% 412,]

effort1 = effort[effort$dataset_id %in% 393,]
effort2 = effort[effort$dataset_id %in% 394,]
effort6 = effort[effort$dataset_id %in% 412,]
# ------------ #

# ------------ #
# exportS
# ------------ #
dir.out = "Z:/seabird_database/data_import/in_progress/EcoMon/ECOMON_2017"
write.csv(obs1, paste(dir.out,"GU1701_obs.csv",sep="/"))
write.csv(obs2, paste(dir.out,"GU1702_obs.csv",sep="/"))
write.csv(obs6, paste(dir.out,"GU1706_obs.csv",sep="/"))
write.csv(effort1, paste(dir.out,"GU1701_effort.csv",sep="/"))
write.csv(effort2, paste(dir.out,"GU1702_effort.csv",sep="/"))
write.csv(effort6, paste(dir.out,"GU1706_effort.csv",sep="/"))
# ------------ #
