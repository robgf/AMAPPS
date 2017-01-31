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
surveyFolder = "EcoMon_12"

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
obs = read.csv(file.path(dir.in, "ecomon_sept_oct_2012_corrected_1_31_2017_TPW.csv")) 

# change names to lowercase
colnames(obs) = tolower(names(obs))

# merge comments
obs = obs %>% mutate(comments_tx = paste(comment_1, comment_2, sep = "; ")) %>% 
  select(-comment_1, -comment_2)
obs$comments_tx[obs$comments_tx %in% "NA; NA"] = NA

# add file name
obs$datafile = "ecomon_sept_oct_2012_corrected_1_31_2017_TPW.csv"
#---------------------#
  

#---------------------#
# fix time
#---------------------#
obs$yyyy[obs$fid == 67974] = 2012
obs = mutate(obs, date_time = as.POSIXct(paste(paste(yyyy, mm_1, dd, sep="/")," ", 
                                               paste(hh, mm, ss_s, sep=":")), 
                                         format="%Y/%m/%d %H:%M:%S")) %>% 
  select(-yyyy,-mm,-dd,-hh,-mm_1,-ss_s) %>% 
  mutate(date = sapply(strsplit(as.character(date_time), " "), head, 1), 
         time = sapply(strsplit(as.character(date_time), " "), tail, 1))
#---------------------#


#---------------------#
# break apart obs and track
#---------------------#  
obs = obs %>% rename(source_transect_id = transect, start_stop = field34) %>% 
  mutate(start_stop = as.character(start_stop), start_stop = gsub(" ", "", start_stop, fixed = TRUE),
         spp = as.character(spp))
obs$spp[obs$start_stop %in% "start"] = "BEGCNT"
obs$spp[obs$start_stop %in% "stop"] = "ENDCNT"

# fix starts/stops
obs$spp[obs$fid %in% 5] = "ENDCNT" # add end
obs$spp[obs$fid %in% 6] = "BEGCNT" # add start
obs$spp[obs$fid %in% 5107] = "ENDCNT" # add end
obs$spp[obs$fid %in% 5108] = "BEGCNT" # add start
obs$spp[obs$fid %in% 10384] = "ENDCNT" # add end
obs$spp[obs$fid %in% 10386] = "BEGCNT" # add start
obs$spp[obs$fid %in% 13720] = "ENDCNT" # add end
obs$spp[obs$fid %in% 13721] = "BEGCNT" # add start
obs$spp[obs$fid %in% 19077] = "ENDCNT" # add end
obs$spp[obs$fid %in% 19079] = "BEGCNT" # add start
obs$spp[obs$fid %in% 28810] = "ENDCNT" # add end
obs$spp[obs$fid %in% 28811] = "BEGCNT" # add start
obs$spp[obs$fid %in% 29106] = "ENDCNT" # add end
obs$spp[obs$fid %in% 29107] = "BEGCNT" # add start
obs$spp[obs$fid %in% 29134] = "ENDCNT" # add end
obs$spp[obs$fid %in% 29135] = "BEGCNT" # add start
obs$spp[obs$fid %in% 29710] = "ENDCNT" # add end
obs$spp[obs$fid %in% 29711] = "BEGCNT" # add start
obs$spp[obs$fid %in% 42079] = "ENDCNT" # add end
obs$spp[obs$fid %in% 42081] = "BEGCNT" # add start
obs$spp[obs$fid %in% 43171] = "ENDCNT" # add end
obs$spp[obs$fid %in% 43172] = "BEGCNT" # add start
obs$spp[obs$fid %in% 43186] = "ENDCNT" # add end
obs$spp[obs$fid %in% 43187] = "BEGCNT" # add start
obs$spp[obs$fid %in% 44660] = "ENDCNT" # add end
obs$spp[obs$fid %in% 44662] = "BEGCNT" # add start
obs$spp[obs$fid %in% 48082] = "ENDCNT" # add end
obs$spp[obs$fid %in% 48083] = "BEGCNT" # add start
obs$spp[obs$fid %in% 50761] = "ENDCNT" # add end
obs$spp[obs$fid %in% 50763] = "BEGCNT" # add start
obs$spp[obs$fid %in% 66485] = "ENDCNT" # add end
obs$spp[obs$fid %in% 66486] = "BEGCNT" # add start
obs$spp[obs$fid %in% 83996] = "ENDCNT" # add end
obs$spp[obs$fid %in% 83997] = "BEGCNT" # add start
obs$spp[obs$fid %in% 88658] = "ENDCNT" # add end
obs$spp[obs$fid %in% 88659] = "BEGCNT" # add start
obs$spp[obs$fid %in% 88670] = "ENDCNT" # add end
obs$spp[obs$fid %in% 88671] = "BEGCNT" # add start
obs$spp[obs$fid %in% 88688] = "ENDCNT" # add end
obs$spp[obs$fid %in% 88689] = "BEGCNT" # add start
obs$spp[obs$fid %in% 88800] = "ENDCNT" # add end
obs$spp[obs$fid %in% 89194] = "ENDCNT" # add end
obs$spp[obs$fid %in% 89195] = "BEGCNT" # add start
obs$spp[obs$fid %in% 89206] = "ENDCNT" # add end
obs$spp[obs$fid %in% 89207] = "BEGCNT" # add start
obs$spp[obs$fid %in% 89661] = "ENDCNT" # add end
obs$spp[obs$fid %in% 89662] = "BEGCNT" # add start
obs$spp[obs$fid %in% 89759] = "ENDCNT" # add end
obs$spp[obs$fid %in% 89760] = "BEGCNT" # add start
obs$spp[obs$fid %in% 89880] = "ENDCNT" # add end
obs$spp[obs$fid %in% 89881] = "BEGCNT" # add start
obs$spp[obs$fid %in% 89908] = "ENDCNT" # add end
obs$spp[obs$fid %in% 89909] = "BEGCNT" # add start
obs$spp[obs$fid %in% 97748] = "ENDCNT" # add end
obs$spp[obs$fid %in% 97749] = "WAYPNT" # remove
obs$spp[obs$fid %in% 97945] = "ENDCNT" # add end
obs$spp[obs$fid %in% 97947] = "BEGCNT" # add start
obs$spp[obs$fid %in% 99335] = "ENDCNT" # add end
obs$spp[obs$fid %in% 99337] = "BEGCNT" # add start
obs$spp[obs$fid %in% 100615] = "ENDCNT" # add end
obs$spp[obs$fid %in% 100619] = "WAYPNT" # remove
obs$spp[obs$fid %in% 106105] = "ENDCNT" # add end
obs$spp[obs$fid %in% 106107] = "BEGCNT" # add start
obs$spp[obs$fid %in% 106398] = "ENDCNT" # add end
obs$spp[obs$fid %in% 106399] = "BEGCNT" # add start
obs$spp[obs$fid %in% 17670] = "ENDCNT" # add end
obs$spp[obs$fid %in% 17671] = "BEGCNT" # add start
obs$spp[obs$fid %in% 39375] = "ENDCNT" # add end
obs$spp[obs$fid %in% 39377] = "BEGCNT" # add start
obs$spp[obs$fid %in% 88193] = "ENDCNT" # add end
obs$spp[obs$fid %in% 88194] = "BEGCNT" # add start

obs$spp[obs$fid %in% 22402] = "ENDCNT" # switch 
obs$spp[obs$fid %in% 22403] = "BEGCNT" # switch 
obs$spp[obs$fid %in% 48078] = "ENDCNT" # switch 
obs$spp[obs$fid %in% 48079] = "BEGCNT" # switch 
obs$spp[obs$fid %in% 69455] = "WAYPNT" # remove
obs$spp[obs$fid %in% 74857] = "WAYPNT" # remove
obs$spp[obs$fid %in% 102326] = "ENDCNT" # switch 
obs$spp[obs$fid %in% 102327] = "BEGCNT" # switch 
obs$spp[obs$fid %in% 62382] = "BEGCNT" # switch 

# copy 88801 for BEGCNT since 88800 is further away and 88802 is a second too late
to.add = obs[obs$fid %in% 88801,] 
to.add$spp = "BEGCNT" # add start
to.add$fid = 88800.5
obs = bind_rows(obs, to.add) %>% arrange(fid)

# make the start/stops that were added defined by the user
obs$type[obs$spp %in% c("BEGCNT","ENDCNT")] = "USER"

# split
track = obs %>% filter(type %in% "GPS") %>% select(-type) %>% rename(type = spp) %>% arrange(fid)
obs = obs %>% filter(type %in% "USER") %>% select(-type) %>% rename(type = spp) %>% arrange(fid)
track$type = "WAYPNT"
#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)
  
obs$original_species_tx = obs$type
  
tmp <- !obs$type %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp])); rm(tmp)

obs$type[obs$type %in% c("BHVI", "CCSP", "WEED")] = "UNKN" 
obs$type[obs$type %in% "ERBA"] = "REBA"  
obs$type[obs$type %in% "GBBU"] = "GBBG"  
obs$type[obs$type %in% "UNJS"] = "UNJA"  
#---------------------#
  

#---------------------#
# other obs edits
#---------------------#
# remove empty cells
obs$type[obs$type %in% " "] = NA
obs = obs[!is.na(obs$type),]



# assign piece names as transect names
to.add = obs %>% select(type, fid) %>% filter(type %in% "BEGCNT") %>% 
  mutate(piece = seq(1:n()))
obs = left_join(obs, to.add, by=c("fid","type"))  
rm(to.add)
obs$piece = na.locf(obs$piece)

# check if there is only one BEG/END per piece
obs %>% select(fid, type, date, time, piece) %>% 
  filter(type %in% c("BEGCNT","ENDCNT")) %>% group_by(piece) %>% 
  summarize(n = n()) %>% filter(n %% 2 != 0 )
#---------------------#


#---------------------#
# fix track
#---------------------#
# move BEG/END from obs to track
to.add = obs %>% filter(type %in% c("BEGCNT", "ENDCNT", "WAYPNT"))
obs = obs %>% filter(!type %in% c("BEGCNT", "ENDCNT", "WAYPNT"))
track = bind_rows(track, to.add) %>% arrange(fid)
rm(to.add)
track$piece = na.locf(track$piece)

#get rid of unused columns
track = select(track, -count, -behavior, -plumage, -age, -original_species_tx, -start_stop)
track = rename(track, visibility_tx = visib, seastate = beaufort, index = fid, 
               point_type = type, track_tm = time, track_dt = date, track_lon = longitude, 
               track_lat = latitude)
track = track %>% mutate(source_transect_id = paste(source_transect_id, piece, sep="_")) %>% select(-piece)
#---------------------#


# ---------------------#
# rename obs
# ---------------------#
obs = rename(obs, index = fid, behavior_tx = behavior, travel_direction_tx = direction, 
             distance_to_animal_tx = distance, plumage_tx = plumage, age_tx = age, 
             seastate_beaufort_nb = beaufort, visibility_tx = visib, spp_cd = type, 
             angle_from_observer_nb = ang, temp_lat = latitude, temp_lon = longitude)
obs = select(obs, -start_stop, -date_time)
obs = obs %>% mutate(source_transect_id = paste(source_transect_id, piece, sep="_")) %>% select(-piece)
# ---------------------#


# ---------------------#
# inspect problem pieces
# ---------------------#
timediff = difftime(track$date_time[1:dim(track)[1]-1], track$date_time[2:dim(track)[1]], units="secs") 
timediff = c(0, as.vector(as.numeric(timediff)))
timediff[abs(timediff)<50]=NA
track$timediff = timediff; rm(timediff)
track %>% filter(abs(timediff)>50 & !point_type %in% c("BEGCNT","ENDCNT"))

n = 137

x = track %>% filter(piece==n) %>% 
  select(index, point_type, track_lat, track_lon, track_dt, track_tm, piece, timediff)
  
plot(track$track_lon[track$piece==n], track$track_lat[track$piece==n], col="grey")
points(track$track_lon[track$piece==n & track$point_type == "BEGCNT"], 
       track$track_lat[track$piece==n & track$point_type == "BEGCNT"], col="green", pch=16)
points(track$track_lon[track$piece==n & track$point_type == "ENDCNT"], 
       track$track_lat[track$piece==n & track$point_type == "ENDCNT"], col="red", pch=16)

points(x$track_lon[x$index==90645], x$track_lat[x$index==90645], pch=16)
# ---------------------#


#---------------------#
# make transect
#---------------------#
transect = track %>% 
  select(track_lat, track_lon, track_dt, source_transect_id, point_type, 
         track_tm, visibility_tx, seastate, datafile, index) %>% 
  mutate(type = as.character(point_type)) %>% 
  filter(point_type %in% c("BEGCNT","ENDCNT")) %>%  
  mutate(source_transect_id = factor(source_transect_id)) %>% 
  group_by(source_transect_id) %>%   arrange(index) %>%
  summarize(start_lon = first(track_lon), start_lat = first(track_lat), 
            end_lon = last(track_lon), end_lat = last(track_lat),
            start_tm = first(track_tm),end_tm = last(track_tm),
            end_dt = first(track_dt), visibility_tx = mean(as.numeric(visibility_tx), na.rm=TRUE),
            seastate_beaufort_nb = mean(seastate, na.rm=TRUE), 
            datafile = first(datafile)) %>% 
  mutate(start_dt = end_dt) %>% 
  mutate(transect_time_min_nb = difftime(as.POSIXct(paste(end_dt, end_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
                                         as.POSIXct(paste(start_dt, start_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
                                         units = "mins")) %>% rowwise %>% 
  mutate(distance =  distHaversine(c(start_lon,start_lat), c(end_lon,end_lat))) 
transect$transect_width_nb = 300
transect$transversal_speed_nb = 10 
transect$comments_tx = "Transect numbers are simply the order in which they occurred, not defined by supplier. Speed is assumed to be ~10 knots/hr"
#---------------------#
