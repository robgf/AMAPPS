#-------------- #
# clean ME data
# prepare it for NWASC
# ------------- #


# ------------- #
# packages
# ------------- #
require(RODBC)
require(dplyr)
require(stringr)
# ------------- #


# ------------- #
# data
# ------------- #
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received/Maine_gov/AvianDataDatabase_120616.accdb")
data = sqlFetch(db,"Northwest Atlantic Seabird Catalog Data_MCMI 2016")
odbcClose(db)
# ------------- #


# ------------- #
# data corrections
# ------------- #
names(data) = str_replace_all(string=names(data), pattern=" ", repl="")
data = mutate(data, original_species_tx = SpeciesCode,
              Position = ifelse(Position %in% "Starboard","r","l"),
              Observer = as.character(Observer),
              Observer = ifelse(Observer %in% "Barkalow, Ethan","EB",
                                ifelse(Observer %in% "Doughty, Kate","KD",
                                       ifelse(Observer %in% "Enterline, Claire","CE",
                                              ifelse(Observer %in% "Garvey, Samantha","SG",
                                                     ifelse(Observer %in% "Hill, Jenna","JH","IO"))))))# "Ozmon, Ivy" )
# fix distance
colnames(data)[17]="distance_m"
data$distance_m[data$distance_m %in% 100090]=1000

# fix other names with ()
colnames(data)[33]="GPSSpeed_mps"#GPSSpeed(mps)"
colnames(data)[34]="GPSHeading_degrees"#GPSHeading(degrees)"
colnames(data)[35]="GPSAltitudeAccuracy_m"#GPSAltitudeAccuracy(m)"
colnames(data)[36]="GPSAccuracy_m" #"GPSAccuracy(m)"
colnames(data)[37]="GPSAltitude_m" #"GPSAltitude(m)"
# ------------- #


# ------------- #
# summarize estimated transect info
# ------------- #
t1 = data %>% dplyr::select(TransectID,TransectStarted,TransectEnded,
                                   GPSLongitude,GPSLatitude,ObservationTimestamp) %>% 
  group_by(TransectID) %>% filter(row_number()==1) %>% 
  arrange(ObservationTimestamp) %>% rename(startLon=GPSLongitude,
                                      startLat=GPSLatitude,
                                      firstObservation = ObservationTimestamp)
tn = data %>% dplyr::select(TransectID,TransectStarted,TransectEnded,
                            GPSLongitude,GPSLatitude,ObservationTimestamp) %>% 
  group_by(TransectID) %>% filter(row_number()==n()) %>% 
  arrange(ObservationTimestamp) %>% rename(endLon=GPSLongitude,
                                      endLat=GPSLatitude,
                                      lastObservation = ObservationTimestamp)
# estimated transect start and end locations
est.transects = full_join(t1,dplyr::select(tn,TransectID,endLat,endLon,lastObservation),by="TransectID")
rm(t1,tn)

# only looking at known transect start and stop times
transects = dplyr::select(est.transects,TransectID,TransectStarted,TransectEnded) %>% 
  rename(source_transect_id = TransectID) %>% 
  mutate(start_tm = sapply(strsplit(as.character(TransectStarted)," "),tail,1),
         end_tm = sapply(strsplit(as.character(TransectEnded)," "),tail,1), 
         start_dt = sapply(strsplit(as.character(TransectStarted)," "),head,1), 
         end_dt = sapply(strsplit(as.character(TransectEnded)," "),head,1)) %>% 
  dplyr::select(-TransectStarted,-TransectEnded)

# missing end times for these transects
# c(2,6,9,14,19,23,29,33,45,46,48,52,56,59,61,64,65,68,69,71,73,75,77,79,80,82,84,91)
# ------------- #


# ------------- #
# define species codes off itis #, check that common names are the same
# ------------- #
# ------------- #


# ------------- #
# define behavior,age ids
# ------------- #
#Behavior
data = mutate(data, age_id = Age,
              age_id = replace(age_id,"Carrying fish",16),
              age_id = replace(age_id,"Dead",6),
              age_id = replace(age_id,"Diving",7),
              age_id = replace(age_id,"Feeding",9),
              age_id = replace(age_id,"Flying",13),
              age_id = replace(age_id,"Following",14),
              age_id = replace(age_id,"Kleptoparasitizing",24),
              age_id = replace(age_id,"Milling",21),
              age_id = replace(age_id,c("Taking Off","Pattering"),42),
              age_id = replace(age_id,"Plunge Diving",8),
              age_id = replace(age_id,"Sitting",35))            

#Age
"Adult"=1       
"Immature"=6    
"Juvenile"=2    
"subadult"=7    
"Third year","Fifth year","First cycle","First year","Fourth year"  

#Sex
"Female"=1  
"Male"=2    
"Unknown"=5
# ------------- #


# ------------- #
# rename
# ------------- #
data = data %>% 
  mutate(obs_dt=sapply(strsplit(as.character(ObservationTimestamp)," "),head,1),
         obs_tm=,sapply(strsplit(as.character(ObservationTimestamp)," "),tail,1))
  rename(source_observation_id=ObservationID,
         source_transect_id=TransectID,
         obs_lat = GPSLatitude,
         obs_lon = GPSLongitude,
         original_species_tx = paste(SpeciesCode,SpeciesCommonName,SpeciesITISNumber,sep=" ; "),
         obs_count_intrans_nb = Count,
         observer_tx = Observer,
         observer_position = Position,
         plumage_tx = Plumage,
         heading_tx = GPSHeading_degrees,
         distance_to_animal_tx = paste(distance_m,"meter(s)",sep=" "),
         angle_from_observer_nb = Degree,
         associations_tx = LinkedwithObservationID,
         visibility_tx = Visibility,
         seastate_beaufort_nb = BeaufortID,
         cloud_cover_tx = Weather,
         observer_comments = paste(ObservationComment,BehaviorDescription,sep=" ; "))
# ------------- #


# ------------- #
# export
# ------------- #
# ------------- #
