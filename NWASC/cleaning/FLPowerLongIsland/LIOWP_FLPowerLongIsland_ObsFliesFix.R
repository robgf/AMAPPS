#--------------------------#
# Fix errors in FLPower Long Island data
#--------------------------#

#-----------------#
# Fix initial transect and general data errors
#-----------------#
# remove NAs
boat.transect = boat.transect[!is.na(boat.transect$Latitude),]
boat.obs = boat.obs[!is.na(boat.obs$Latitude),]
boat.point.ge = boat.point.ge[!is.na(boat.point.ge$Latitude),]
boat.point.ge = boat.point.ge[boat.point.ge$Comment != "Comment",] 

# pull transect info out
boat.obs$index = seq.int(nrow(boat.obs))
boat.obs$SPECIES1 = as.character(boat.obs$SPECIES1)
tmp = boat.obs[boat.obs$SPECIES1 %in% c("10n","10s","11n","11s","12n","12s","2n","2ss",
                                        "3n","3s","4s","5s","6n","6s","7n","7s","8n",
                                        "8s","9n","9s","t4","2s","4n","5n","5S","6N",
                                        "12","10 n", "T11N"),]
tmp$SPECIES1[tmp$SPECIES1 == "t4"] = 4 
tmp$SPECIES1[tmp$SPECIES1 == "T11N"] = 11 
tmp$TRANSECT = as.numeric(strsplit(as.character(tmp$SPECIES1), "[^0-9]+"))
boat.obs$TRANSECT[tmp$index] = tmp$TRANSECT

for(a in 1:(nrow(tmp)-1)) {
  if(tmp$TRANSECT[a] == tmp$TRANSECT[a+1] & tmp$filename[a] == tmp$filename[a+1]) {
    if(tmp$index[a+1]-tmp$index[a]-1 >= 1) {
      boat.obs$TRANSECT[(tmp$index[a]+1):(tmp$index[a+1]-1)] = replicate(tmp$index[a+1]-tmp$index[a]-1, tmp$TRANSECT[a])
      boat.obs$SPECIES1[tmp$index[a]] = "BEGCNT"
      boat.obs$SPECIES1[tmp$index[a+1]] = "ENDCNT"
    }
  }
}

# remove incorrect information
boat.obs$NO[tmp$index] = NA
boat.obs$AGE[tmp$index] = NA
boat.obs$SEX[tmp$index] = NA
boat.obs$DIRECTION[tmp$index] = NA
boat.obs$SPECIES2[tmp$index] = NA

# fix transects that dont have start and stops
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_071105" & boat.obs$GPS_Time == "03:40:03pm"):
                    which(boat.obs$filename == "Final_raw_data_071105" & boat.obs$GPS_Time == "03:59:47pm")] = 10 
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "02:29:59pm"):
                    which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "03:33:19pm")] = 6
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "03:40:55pm"):
                    which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "04:10:39pm")] = 4
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "04:53:11pm"):
                    which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:16:23pm")] = 2
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:24:23pm"):
                    which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:44:59pm")] = 8 
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:04:55pm"):
                    which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:25:55pm")] = 9 
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:31:11pm"):
                    which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:57:27pm")] = 10 
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "07:05:27pm"):
                    which(boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "07:31:43pm")] = 11 
#-----------------#


#-----------------#
# fix species errors 
#-----------------#
if (!"dataChange" %in% colnames(boat.obs)) {boat.obs$dataChange = ""}
boat.obs$SPECIES1 = as.character(boat.obs$SPECIES1)
boat.obs$SPECIES2 = as.character(boat.obs$SPECIES2)
boat.obs$original_species_tx = paste(boat.obs$SPECIES1, " ; ", boat.obs$SPECIES2, sep = "")

# split entries with letters and numbers
# create new rows for those entries
boat.obs$dataChange[!is.na(boat.obs$SPECIES1) & !is.na(boat.obs$SPECIES2)] = 
  paste(boat.obs$dataChange[!is.na(boat.obs$SPECIES1) & !is.na(boat.obs$SPECIES2)],
        "ADDED new row for SPECIES2", sep = "; ")

new = boat.obs[!is.na(boat.obs$SPECIES1) & !is.na(boat.obs$SPECIES2),] # only when there is more than one species
boat.obs$SPECIES2[!is.na(boat.obs$SPECIES1) & !is.na(boat.obs$SPECIES2)] = NA
new$SPECIES1 = new$SPECIES2
new$SPECIES2 = NA
new$NO = NA
new$AGE = "UNKNOWN"
new$AGE[grepl("adult",new$SPECIES1)] = "ADULT"
new$AGE[grepl("subadult",new$SPECIES1)] = "SUBADULT"
new$AGE[grepl("juv",new$SPECIES1)] = "JUVENILE"
new$SEX = NA
new$NO <- as.numeric(str_extract(new$SPECIES1, "[0-9]+"))
new = new[new$SPECIES1 != "-",]
new = new[new$SPECIES1 != "--",]
new$index = as.numeric(new$index) + 0.0001

# add rows for multiples and fix mixed
new = rbind(new, new[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2",], new[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2",])
new = rbind(new, new[new$SPECIES1 == "rbgu 6 hegu 6",])
new = rbind(new, new[new$SPECIES1 == "GBBG 3/UNGU 2",])
new$dataChange[new$SPECIES1 == "GBBG 3/UNGU 2"] = paste(new$dataChange[new$SPECIES1 == "GBBG 3/UNGU 2"], 
                                                        "Changed SPECIES1 from GBBG 3/UNGU 2", sep = "; ")
new$dataChange[new$SPECIES1 == "rbgu 6 hegu 6"] = paste(new$dataChange[new$SPECIES1 == "rbgu 6 hegu 6"], 
                                                        "Changed SPECIES1 from rbgu 6 hegu 6", sep = "; ")
new$dataChange[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2"]= paste(new$dataChange[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2"], 
                                                              "Changed SPECIES1 from hegu 2 bogu 4 gbbg 2", sep = "; ")
new$NO[new$SPECIES1 == "GBBG 3/UNGU 2"][1] = 3
new$SPECIES1[new$SPECIES1 == "GBBG 3/UNGU 2"][1] = "GBBG"
new$NO[new$SPECIES1 == "GBBG 3/UNGU 2"] = 2
new$SPECIES1[new$SPECIES1 == "GBBG 3/UNGU 2"] = "UNGU"
new$NO[new$SPECIES1 == "rbgu 6 hegu 6"][1] = 6
new$SPECIES1[new$SPECIES1 == "rbgu 6 hegu 6"][1] = "RBGU"
new$NO[new$SPECIES1 == "rbgu 6 hegu 6"] = 6
new$SPECIES1[new$SPECIES1 == "rbgu 6 hegu 6"] = "HEGU"
new$NO[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2"][1] = 2
new$SPECIES1[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2"][1] = "HEGU"
new$NO[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2"][1] = 4
new$SPECIES1[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2"][1] = "BOGU"
new$NO[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2"] = 2
new$SPECIES1[new$SPECIES1 == "hegu 2 bogu 4 gbbg 2"] = "GBBG"


# remove extra characters
new$SPECIES1[grep("/",new$SPECIES1)] = substr(new$SPECIES1[grep("/",new$SPECIES1)], 1, 4)
new$SPECIES1[grep("-",new$SPECIES1)] = substr(new$SPECIES1[grep("-",new$SPECIES1)], 1, 4)
new$SPECIES1[new$AGE != "UNKNOWN"] = substr(new$SPECIES1[new$AGE != "UNKNOWN"], 1, 4)
new$NO[grep("one bird",new$SPECIES1)] = 1
new$SPECIES1[grep("one bird",new$SPECIES1)] = substr(new$SPECIES1[grep("one bird",new$SPECIES1)], 1, 4)

#split species codes with numbers
new$SPECIES1[new$SPECIES1 == "murre sp 1"] = "UNMU"
new$SPECIES1[!is.na(as.numeric(str_extract(new$SPECIES1, "[0-9]+")))] = 
  toupper(substr(new$SPECIES1[!is.na(as.numeric(str_extract(new$SPECIES1, "[0-9]+")))],1,4))

# merge
boat.obs = rbind(boat.obs, new)
rm(new)

# CHANGE SPECIES1 "NA" if there is a SPECIES2 code
ind = which(is.na(boat.obs$SPECIES1) & !is.na(boat.obs$SPECIES2))
boat.obs$dataChange[ind] = paste(boat.obs$dataChange[ind], "changed SPECIES1 from NA", sep = "; ")
boat.obs$SPECIES1[ind] = boat.obs$SPECIES2[ind]
boat.obs$SPECIES2[ind] = NA
rm(ind)
  
boat.obs = rbind(boat.obs, boat.obs[which(boat.obs$SPECIES1 == "blsc susc"),])
boat.obs$dataChange[which(boat.obs$SPECIES1 == "blsc susc")] = paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "blsc susc")],
                                                                     "Changed SPECIES1 from blsc susc", sep ="; ") 
boat.obs$dataChange[which(boat.obs$SPECIES1 == "blsc susc")] = paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "blsc susc")],
                                                                     "Changed NO from 70", sep ="; ") 
boat.obs$NO[which(boat.obs$SPECIES1 == "blsc susc")] = 35 #assumed 50/50 CHECK THIS???????????????????????????
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "blsc susc")][1] = "BLSC"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "blsc susc")] = "SUSC"

# Deal with unknown species, remove the rest
boat.obs$SPECIES1 = as.character(boat.obs$SPECIES1)
boat.obs$SPECIES1[boat.obs$NOTES == "ship was com. fishing  vessel/birds following"] = "BOCF"
boat.obs$SPECIES1[boat.obs$NOTES == "pomarine jaeger"] = "POJA"
unknown = boat.obs[is.na(boat.obs$SPECIES1),]
boat.obs = boat.obs[!is.na(boat.obs$SPECIES1),]


# CHANGE SPECIES1 code to uppercase
boat.obs$SPECIES1[nchar(boat.obs$SPECIES1) == 4] = 
  toupper(boat.obs$SPECIES1[nchar(boat.obs$SPECIES1) == 4]) 

# FIX FLOCK NUMBER (IF NEEDED) WHERE THE NUMBER INCLUDED BOTH SPECIES
# HAD TO READ THE "NOTES" COLUMN FOR THIS
boat.obs$dataChange[which(boat.obs$NOTES == "flock of 7 (5 SUSC/2 BLSC)" & boat.obs$SPECIES1 == "SUSC")] = 
  paste(boat.obs$dataChange[which(boat.obs$NOTES == "flock of 7 (5 SUSC/2 BLSC)" & boat.obs$SPECIES1 == "SUSC")], 
        "Changed NO from 7", sep = "; ")
boat.obs$NO[which(boat.obs$NOTES == "flock of 7 (5 SUSC/2 BLSC)" & boat.obs$SPECIES1 == "SUSC")] = "5"

boat.obs$dataChange[which(boat.obs$NOTES == "1LAGU/1 GBBG" & boat.obs$SPECIES1 == "GBBG")]  = 
  paste(boat.obs$dataChange[which(boat.obs$NOTES == "1LAGU/1 GBBG" & boat.obs$SPECIES1 == "GBBG")], 
        "Changed NO from 2", sep = "; ")
boat.obs$NO[which(boat.obs$NOTES == "1LAGU/1 GBBG" & boat.obs$SPECIES1 == "GBBG")]  = "1"

boat.obs$dataChange[which(boat.obs$NOTES == "Linked to 7 NOGA in foraging flock. 9 rbgu/8 bogu. surface feeding" & boat.obs$SPECIES1 == "RBGU")]  = 
  paste(boat.obs$dataChange[which(boat.obs$NOTES == "Linked to 7 NOGA in foraging flock. 9 rbgu/8 bogu. surface feeding" & boat.obs$SPECIES1 == "RBGU")], 
        "Changed NO from 17", sep = "; ")
boat.obs$dataChange[which(boat.obs$NOTES == "Linked to 7 NOGA in foraging flock. 9 rbgu/8 bogu. surface feeding" & boat.obs$SPECIES1 == "Bonaparte's Gull")]  = 
  paste(boat.obs$dataChange[which(boat.obs$NOTES == "Linked to 7 NOGA in foraging flock. 9 rbgu/8 bogu. surface feeding" & boat.obs$SPECIES1 == "Bonaparte's Gull")], 
        "Changed NO from NA", sep = "; ")
boat.obs$NO[which(boat.obs$NOTES == "Linked to 7 NOGA in foraging flock. 9 rbgu/8 bogu. surface feeding" & boat.obs$SPECIES1 == "RBGU")]  = 9
boat.obs$NO[which(boat.obs$NOTES == "Linked to 7 NOGA in foraging flock. 9 rbgu/8 bogu. surface feeding" & boat.obs$SPECIES1 == "Bonaparte's Gull")]  = 8

boat.obs$NO[which(boat.obs$NOTES == "32 hegu/8 gbbg  loose flock on water w/ large flock of ltdu; flushed south" & boat.obs$SPECIES1 == "GBBG")] = 8
boat.obs$SPECIES2[which(boat.obs$NOTES == "32 hegu/8 gbbg  loose flock on water w/ large flock of ltdu; flushed south" & boat.obs$SPECIES1 == "GBBG")] = NA
boat.obs$NO[which(boat.obs$NOTES == "32 hegu/8 gbbg  loose flock on water w/ large flock of ltdu; flushed south" & boat.obs$SPECIES1 == "HEGU")] = 32

boat.obs$NO[which(boat.obs$NOTES == "85 ltdu/1 blsc on water" & boat.obs$SPECIES1 == "LTDU")] = 85

boat.obs$NO[boat.obs$SPECIES1 == "porp 2"] = 2


# combine the point ge data
boat.point.ge$SPECIES1 = as.character(boat.point.ge$Comment)
boat.point.ge$original_species_tx = boat.point.ge$SPECIES1
boat.point.ge$TRANSECT = as.numeric(str_extract(boat.point.ge$TRANSECT, "[0-9]+"))
boat.point.ge$NO = 1
boat.point.ge$NO[boat.point.ge$Comment == "2 comm fiishing vessels  3mi w"] = 2
boat.point.ge$NO[boat.point.ge$Comment == "porp 2"] = 2
boat.point.ge$NO[boat.point.ge$Comment == "3 comm vessels     west of posit"] = 3
boat.point.ge$NO[boat.point.ge$Comment == "35-40 rays"] = 35
boat.point.ge$SPECIES1[boat.point.ge$Comment == "35-40 rays"] = "UNRA"
boat.point.ge = rename(boat.point.ge, NOTES = Comment)
boat.point.ge$dataChange = paste(boat.point.ge$dataChange, "TYPE Changed from ", boat.point.ge$NOTES)
# format
boat.point.ge$Latitude = as.numeric(boat.point.ge$Latitude)
boat.point.ge$Longitude = as.numeric(boat.point.ge$Longitude)
boat.point.ge$TRANSECT = as.character(boat.point.ge$TRANSECT)
boat.point.ge$NO = as.character(boat.point.ge$NO)
boat.point.ge = select(boat.point.ge,-F1,-F2,-F3,-F4,-F5,-F6,-F7)
boat.point.ge$GPS_Date = as.character(boat.point.ge$GPS_Date)
# fix Date first, make time PCXT but have to leave as character for edits below
#x = sapply(str_split(boat.obs$GPS_Date," "),tail,1)
#x[x %in% "00:00:00"] = NA #I dont think these time are correct
boat.obs$GPS_Date = sapply(str_split(boat.obs$GPS_Date," "),head,1)
boat.obs$GPS_Date[boat.obs$filename %in% "Final_raw_data_101804"] = "2004-10-18"
boat.obs$Datafile[boat.obs$filename %in% "Final_raw_data_101804"] = "R101807A.cor"
boat.obs$GPS_DateTime = as.POSIXct(paste(boat.obs$GPS_Date, boat.obs$GPS_Time, sep= " "), format = "%Y-%m-%d %I:%M:%S%p")
boat.point.ge$GPS_DateTime = as.POSIXct(paste(boat.point.ge$GPS_Date, boat.point.ge$GPS_Time, sep= " "), format = "%Y-%m-%d %I:%M:%S%p")
# join 
boat.obs$offline = 0 
boat.point.ge$offline = 1 
boat.obs = bind_rows(boat.obs, boat.point.ge)
# add index numbers based on last in group 
boat.obs = boat.obs %>% mutate(fn_t = paste(filename, TRANSECT, GPS_Date, sep="_")) %>%
  mutate(GPS_Date = as.POSIXct(GPS_Date, format = "%Y-%m-%d")) %>%
  group_by(fn_t) %>% arrange(GPS_Date, GPS_DateTime, index) %>% as.data.frame %>% mutate(index = 1:length(SPECIES1))
rm(boat.point.ge)

# remove duplicates
#boat.obs = boat.obs[!duplicated(boat.obs[c()]),]

# Change Species Code
if (!"dataChange" %in% colnames(boat.obs)) {boat.obs$dataChange = ""}
boat.obs$NO = as.character(boat.obs$NO)
boat.obs$NOTES = as.character(boat.obs$NOTES)


# DataChange comments
changes = c("Passerine species", "American Woodcock", "Black Duck", "Tern sp.", "Gull sp.",
            "Loon sp.", "Scoter sp.", "Sandpiper sp.", "Duck sp.", "Sandpiper", "Petrel sp.", 
            "Corm sp.", "Sanderling", "Plover sp.", "Yellowlegs sp.", "Leatherback turtle", 
            "Albacore tuna school", "Harbor Porpoise", "porpoise", "Unidentified Scoter", 
            "Jaeger spp.", "Scaup spp.", "co murre", "alcid", "jaeger sp", "sparrow sp", 
            "unknown pass", "unid sandpip", "willet", "passarine sp", "horned grebe", 
            "co murrs", "cco murre", "co murre", "alcid sp.", "Red-breasted Merganser", 
            "RED-", "Bonaparte's Gull", "murre sp.", "sanderlings")
for (a in 1:length(changes)) {
boat.obs$dataChange[which(boat.obs$SPECIES1 == changes[a])] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == changes[a])],
  "; Changed SPECIES1 from ", changes[a], sep ="") 
}
rm(changes, a)

boat.obs$dataChange[grep(" vessel ", boat.obs$SPECIES1)] = 
  paste(boat.obs$dataChange[grep(" vessel ", boat.obs$SPECIES1)],
  "; Changed SPECIES1 from ", boat.obs$SPECIES1[grep(" vessel ", boat.obs$SPECIES1)], sep ="")                                          
boat.obs$dataChange[grep("seal",boat.obs$SPECIES1)] = 
  paste(boat.obs$dataChange[grep(" seal ",boat.obs$SPECIES1)],
  "; Changed SPECIES1 from ", boat.obs$SPECIES1[grep("seal",boat.obs$SPECIES1)], sep ="")                                          
boat.obs$dataChange[grep("ray",boat.obs$SPECIES1)] = 
  paste(boat.obs$dataChange[grep(" ray ",boat.obs$SPECIES1)],
  "; Changed SPECIES1 from ", boat.obs$SPECIES1[grep("ray",boat.obs$SPECIES1)], sep ="")                                          
boat.obs$dataChange[grep("porp",boat.obs$SPECIES1)] = 
  paste(boat.obs$dataChange[grep(" porp ",boat.obs$SPECIES1)],
  "; Changed SPECIES1 from ", boat.obs$SPECIES1[grep("porp",boat.obs$SPECIES1)], sep ="") 

boat.obs$dataChange[which(boat.obs$NOTES == "pomarine jaeger")] = 
  paste(boat.obs$dataChange[which(boat.obs$NOTES == "pomarine jaeger")],
        "Changed SPECIES1 from NA ", sep ="; ") 

# CHANGE SPECIES1
boat.obs$SPECIES1 = as.character(boat.obs$SPECIES1)
boat.obs$SPECIES1[grep(" vessel ", boat.obs$SPECIES1)] = "BOCF"
boat.obs$SPECIES1[grep("seal ",boat.obs$SPECIES1)] = "UNSE"
boat.obs$SPECIES1[grep("ray ",boat.obs$SPECIES1)] = "UNRA"

boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "BASW"] = "BARS"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "BLBR"] = "BRAN"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "RWSW"] = "ROSW"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "American Woodcock"] = "AMWO"                    
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Black Duck"] = "ABDU"                                          
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Tern sp."] = "UNTE"                                                   
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Gull sp."] = "UNGU"                                                  
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Loon sp."] = "UNLO"                                               
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("SCSP","Scoter sp.")] = "UNSC"                                             
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("Sandpiper sp.","sandpiper 2","Sandpiper","unid sandpip", "UNSA")] = "USAN"                                                 
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Duck sp."] = "UNDU"                                               
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Petrel sp."] = "UNPE"                                                   
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Corm sp."] = "UNCO" #Cormorant?                                                
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("sanderlings","Sanderling")] = "SAND"                                               
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Plover sp."] = "UNPL"                                           
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Yellowlegs sp."] = "UNYE"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Leatherback turtle"] = "LETU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Albacore tuna school"] = "ALTU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Ruddy Turnstone"] = "RUTU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("Harbor Porpoise","har por 1000  w","harbor porpoise")] = "HAPO"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("porpoise","porpoise 1, 800 feet west","porp","PORP","porp 2")] = "UNPO"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Unidentified Scoter"] = "UNSC"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("Jaeger spp.","jaeger sp")] = "UNJA"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Scaup spp."] = "SCAU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("co murrs","co murre","cco murre","co murre","co  murre")] = "COMU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("alcid sp.","alcid")] = "UNAL"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("sparrow sp","unidentified sparrow")] = "SPAR"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("passarine sp","unknown pass","Passerine species")] = "UNPA" # passerine?
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "willet"] = "WILL"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "horned grebe"] = "HOGR"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("RED-","Red-breasted Merganser")] = "RBME"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Bonaparte's Gull"] = "BOGU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "murre sp."] = "UNMU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "shearwater sp"] = "UNSH"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Cliff Swallow"] = "CLSW"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "loggerhead turtle"] = "LOTU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("party boat 1 mi se","party boat 500 ft  nw",
                                           "party boats 4 1/2 mile se")] = "BOFI"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("2 comm fiishing vessels  3mi w",
                                           "3 comm vessels     west of posit","com fish boat",
                                           "com fish vessel/approx 1,000 e", "com fishing ves 1mi south",
                                           "com fishing ves 3 mi sw","com. fishing vessel/approx .5 mi",
                                           "com. fishing vessel/approx .5 mi from survey vessel",
                                           "comm. squid vessel/1,000 ft nw","comm. vessel/2 mi. sw of boat",
                                           "commercial fishing vessel","Commercial fishing vessel")] = "BOCF"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "mixed flock"] = "UNBI"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "basw  1"] = "BASW"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% "Scoter spp."] = "UNSC"

# Check NOTES for SPECIES and NO errors and mixed flocks
#notes = cbind(boat.obs$SPECIES1[!is.na(boat.obs$NOTES)], 
#              boat.obs$NO[!is.na(boat.obs$NOTES)], 
#              boat.obs$NOTES[!is.na(boat.obs$NOTES)],
#              boat.obs$dataChange[!is.na(boat.obs$NOTES)])
#view the notes
#rm(notes)

## FIX SPECIES AND COUNT ERRORS 
## BASED ON NOTES

## ADDING ADDITIONAL ROWS BASED ON NOTES
## IF THE SECOND SPECIES WAS RECORDED IN THE SPECIES2 COLUMN THAT WOULD BE IN DATACHANGE
## THE ROWS NEXT TO THESE WERE CHECKED FOR THE ADDITIONAL SPECIES LISTED BUT WERE NOT FOUND
## AND THEREFORE THE ADDITIONAL SPECIES WERE ADDED UNDER THE ASSUMPTION THEY ARE NOT RECORDED 
# 
boat.obs$dataChange[grep("16 HEGU/4 LAGU/5 UNGU in loose,",boat.obs$NOTES)] = 
  paste(boat.obs$dataChange[grep("16 HEGU/4 LAGU/5 UNGU in loose,",boat.obs$NOTES)],
                            " Split NOTES '16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall' to add SPECIES1 & NO", sep = "; ")
new = rbind(boat.obs[grep("16 HEGU/4 LAGU/5 UNGU in loose,",boat.obs$NOTES),], boat.obs[grep("16 HEGU/4 LAGU/5 UNGU in loose,",boat.obs$NOTES),])                 
new$index[1] = as.numeric(new$index[1]) + 0.0001
new$index[2] = as.numeric(new$index[2]) + 0.0002
new$NO[1] = 4
new$NO[2] = 5
new$SPECIES1[1] = "LAGU"
new$SPECIES1[2] = "UNGU"
boat.obs$NO[grep("16 HEGU/4 LAGU/5 UNGU in loose,",boat.obs$NOTES)] = 16
boat.obs = rbind(boat.obs, new); rm(new)
# 
boat.obs$dataChange[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")],
                            "Split NOTES 'following fishing vessel/22 HEGU/19 LAGU/1 GBBG' to add SPECIES1 & NO", sep = "; ")
new = rbind(boat.obs[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG"),], 
            boat.obs[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG"),])                 
new$index[1] = as.numeric(new$index[1]) + 0.0001
new$index[2] = as.numeric(new$index[2]) + 0.0002
new$NO[1] = 19
new$NO[2] = 1
new$SPECIES1[1] = "LAGU"
new$SPECIES1[2] = "GBBG"
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")] = 22
boat.obs = rbind(boat.obs, new); rm(new)                  
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)")],
                            "Split NOTES '44 total (4 unidentified gulls/39 Laughing Gull)' to add SPECIES1 & NO", sep = "; ")
new = boat.obs[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)"),]
new$index = as.numeric(new$index) + 0.0001
new$NO = 4
new$SPECIES1 = "UNGU"
boat.obs$NO[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)")] = 39
boat.obs = rbind(boat.obs, new); rm(new)                  
#
boat.obs$dataChange[grep("13 total",boat.obs$NOTES)] = 
  paste(boat.obs$dataChange[grep("13 total",boat.obs$NOTES)],
        "Split NOTES '13 total (8 HEGU, 3 GBBG, 2 LAGU)' to add SPECIES1 & NO", sep = "; ")
new = rbind(boat.obs[grep("13 total",boat.obs$NOTES),], 
            boat.obs[grep("13 total",boat.obs$NOTES),])                 
new$index[1] = as.numeric(new$index[1]) + 0.0001
new$index[2] = as.numeric(new$index[2]) + 0.0002
new$NO[1] = 2
new$NO[2] = 3
new$SPECIES1[1] = "LAGU"
new$SPECIES1[2] = "GBBG"
boat.obs = rbind(boat.obs, new); rm(new)                  
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "5 total (2 COTE, 3 LAGU)")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "5 total (2 COTE, 3 LAGU)")],
        "Split NOTES '5 total (2 COTE, 3 LAGU)' to add SPECIES1 & NO", sep = "; ")
new = boat.obs[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "5 total (2 COTE, 3 LAGU)"),]
new$NO = "3"
new$index = as.numeric(new$index) + 0.0001
new$SPECIES1 = "LAGU"
boat.obs = rbind(boat.obs, new); rm(new)  
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat")],
        "Split NOTES '7 ungu/1 cote circling party boat' to add SPECIES1 & NO", sep = "; ")
new = boat.obs[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat"),]
new$NO = "1"
new$SPECIES1 = "COTE"
new$index = as.numeric(new$index) + 0.0001
boat.obs$NO[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat")] = "7"
boat.obs = rbind(boat.obs, new); rm(new) 
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "small flock of 9 COTE/1 LAGU")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "small flock of 9 COTE/1 LAGU")],
        "Split NOTES 'small flock of 9 COTE/1 LAGU' to add SPECIES1 & NO", sep = "; ")
new = boat.obs[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "small flock of 9 COTE/1 LAGU"),]
new$SPECIES1 = "LAGU"
new$NO = "1"
new$index = as.numeric(new$index) + 0.0001
boat.obs = rbind(boat.obs, new); rm(new) 
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "medium sized flock of 18 COTE and 1 LAGU feeding on bait fish")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "medium sized flock of 18 COTE and 1 LAGU feeding on bait fish")],
        "Split NOTES 'medium sized flock of 18 COTE and 1 LAGU feeding on bait fish' to add SPECIES1 & NO", sep = "; ")
new = boat.obs[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "medium sized flock of 18 COTE and 1 LAGU feeding on bait fish"),]
new$SPECIES1 = "LAGU"
new$NO = "1"
new$index = as.numeric(new$index) + 0.0001
boat.obs = rbind(boat.obs, new); rm(new) 
# 
boat.obs$dataChange[grep("3 BLSC/2 SUSC",boat.obs$NOTES)]  = paste(boat.obs$dataChange[grep("3 BLSC/2 SUSC",boat.obs$NOTES)],
                                                                   "Added new row for 3 BLSC/2 SUSC", sep = "; ")
new = boat.obs[grep("3 BLSC/2 SUSC",boat.obs$NOTES),] 
new$SPECIES1 = "BLSC"
new$SPECIES1 = "3"
new$index = as.numeric(new$index) + 0.0001
boat.obs$NO[boat.obs$SPECIES1 == "3 BLSC/2 SUSC"] = "2"
boat.obs = rbind(boat.obs, new); rm(new)
#
boat.obs$dataChange[grep("7 HEGU, 7GBBG, 11 RBGU",boat.obs$NOTES)] = paste(boat.obs$dataChange[grep("7 HEGU, 7GBBG, 11 RBGU",boat.obs$NOTES)],
                                                                           "Split NOTES '7 HEGU, 7GBBG, 11 RBGU' to add SPECIES1 & NO", sep = "; ")
new = rbind(boat.obs[grep("7 HEGU, 7GBBG, 11 RBGU",boat.obs$NOTES),], 
            boat.obs[grep("7 HEGU, 7GBBG, 11 RBGU",boat.obs$NOTES),])                 
new$index[1] = as.numeric(new$index[1]) + 0.0001
new$index[2] = as.numeric(new$index[2]) + 0.0002
new$NO[1] = 7
new$NO[2] = 7
new$SPECIES1[1] = "HERG"
new$SPECIES1[2] = "GBBG"
boat.obs$NO[boat.obs$SPECIES1 == "7 HEGU, 7GBBG, 11 RBGU"] = 11
boat.obs$SPECIES1[boat.obs$SPECIES1 == "7 HEGU, 7GBBG, 11 RBGU"] = "RBGU"
boat.obs = rbind(boat.obs, new); rm(new)

              
###
### MARKED FOR FURTHER INVESTIGATION ...
###
  
# boat.obs[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "unidentified gull species"),]
# boat.obs[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "medium flock/hegus pirating cote"),]
# boat.obs[which(boat.obs$SPECIES1 == "NOGA" & boat.obs$NOTES == "gbbg har noga/plunge dive"),]
# boat.obs[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "associated w/ com fish vessel/mixed HEGU/RBGU",]
# boat.obs$SPECIES1[is.na(boat.obs$SPECIES1) & boat.obs$NOTES == "large loose flock/feeding on bait fish. Composed of HEGU, GBBG, LAGU, RBGU"] 

#FIX 3x
#                  "HEGU"              NA    "32 hegu/8 gbbg  loose flock on water w/ large flock of ltdu; flushed south"     
#                  [301,] "BLSC"              "1"   "85 ltdu/1 blsc on water"                                                        
#                  [302,] "horned grebe"      NA    "dove on approach"                                                               
#
#-----------------#

#-----------------#
# IN SPECIES1, need to be changed to BEG or END counts
#-----------------#
x = boat.obs$filename[boat.obs$SPECIES1 %in% c("10n","10s","11s","12n","2s","3s","4s","6n","6s","7n","7s","8n","8s","9s","T11N")]
x = boat.obs[boat.obs$filename %in% x,]
boat.obs$SPECIES1[boat.obs$SPECIES1 == "10s" & boat.obs$Datafile == "R071107B.cor"]= "ENDCNT"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "7s" & boat.obs$Datafile == "R041611A.cor"]= "ENDCNT"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "6s" & boat.obs$Datafile == "R041611A.cor"]= "BEGCNT"                 
boat.obs$SPECIES1[boat.obs$SPECIES1 == "4s" & boat.obs$Datafile == "R041611A.cor"]= "BEGCNT"     
boat.obs$SPECIES1[boat.obs$SPECIES1 == "2s" & boat.obs$Datafile == "R041611A.cor"]= "BEGCNT"     
boat.obs$SPECIES1[boat.obs$SPECIES1 == "8n" & boat.obs$Datafile == "R041611A.cor"]= "BEGCNT"     
boat.obs$SPECIES1[boat.obs$SPECIES1 == "9s" & boat.obs$Datafile == "R041611A.cor"]= "BEGCNT"     
boat.obs$SPECIES1[boat.obs$SPECIES1 == "10n" & boat.obs$Datafile == "R041611A.cor"]= "BEGCNT"     
boat.obs$SPECIES1[boat.obs$SPECIES1 == "11s" & boat.obs$Datafile == "R041611A.cor"]= "BEGCNT"  
boat.obs$SPECIES1[boat.obs$SPECIES1 == "12n" & boat.obs$Datafile == "R041611A.cor"]= "BEGCNT"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "8s" & boat.obs$Datafile == "R092110A.cor"]= "BEGCNT" 
boat.obs$SPECIES1[boat.obs$SPECIES1 == "8n" & boat.obs$Datafile == "R092110A.cor"]= "ENDCNT"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "7s" & boat.obs$Datafile == "R092712A.cor"]= "BEGCNT" 
boat.obs$SPECIES1[boat.obs$SPECIES1 == "7n" & boat.obs$Datafile == "R092712A.cor"]= "ENDCNT"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "6n" & boat.obs$Datafile == "R092712A.cor"]= "BEGCNT" 
boat.obs$SPECIES1[boat.obs$SPECIES1 == "12n" & boat.obs$Datafile == "R101910A.cor"]= "ENDCNT"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "6n" & boat.obs$Datafile == "R101910A.cor"]= "BEGCNT" 
boat.obs$SPECIES1[boat.obs$SPECIES1 == "3s" & boat.obs$Datafile == "R102908A.COR"]= "ENDCNT"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "4s" & boat.obs$filename == "Final_raw_data_101804"]= "BEGCNT"
boat.obs$TRANSECT[which(boat.obs$SPECIES1 == "11s" & boat.obs$filename == "Final_raw_data_102805"):
                    which(boat.obs$SPECIES1 == "T11N" & boat.obs$filename == "Final_raw_data_102805")] = 11
boat.obs$SPECIES1[boat.obs$SPECIES1 == "T11N" & boat.obs$filename == "Final_raw_data_102805"] = "ENDCNT"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "11s" & boat.obs$filename == "Final_raw_data_102805"] = "BEGCNT"
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_092705" & boat.obs$GPS_Time == "05:46:14pm"):
                    which(boat.obs$filename == "Final_raw_data_092705" & boat.obs$GPS_Time == "06:01:58pm")] = 6
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_101905" & boat.obs$GPS_Time == "10:44:58am"):
                    which(boat.obs$filename == "Final_raw_data_101905" & boat.obs$GPS_Time == "11:07:31am")] = 12
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_101905" & boat.obs$GPS_Time == "03:50:33pm")] = 6
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_102904" & boat.obs$GPS_Time == "10:51:34am"):
                    which(boat.obs$filename == "Final_raw_data_102904" & boat.obs$GPS_Time == "11:17:38am")] = 3
boat.obs$TRANSECT[which(boat.obs$filename == "Final_raw_data_101804" & boat.obs$GPS_Time == "10:26:39am"):
                    which(boat.obs$filename == "Final_raw_data_101804" & boat.obs$GPS_Time == "10:50:25am")] = 4

boat.obs$TRANSECT = as.character(boat.obs$TRANSECT)

# fix mislabeled transects (must run in order!!)
boat.obs$dataChange = as.character(boat.obs$dataChange)

boat.obs$dataChange[boat.obs$TRANSECT %in% "1" & boat.obs$filename %in% "Final_raw_summer04"] = "Changed TRANSECT from 1; Changed filename to _v2 since there were two transect 2's"
boat.obs$filename[boat.obs$TRANSECT %in% "1" & boat.obs$filename %in% "Final_raw_summer04"] = "Final_raw_summer04_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "1" & boat.obs$filename %in% "Final_raw_summer04_v2"] = "2"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "1" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Changed TRANSECT from 1; Changed filename to _v2 since there were 3 transect 2's"
boat.obs$filename[boat.obs$TRANSECT %in% "1" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Final_raw_Spring_data_04b_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "1" & boat.obs$filename %in% "Final_raw_Spring_data_04b_v2"] = "2"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "1A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "1A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                              " Changed TRANSECT from 1; Changed filename to _v3 since there were 3 transect 2's", sep = ";")
boat.obs$filename[boat.obs$TRANSECT %in% "1A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Final_raw_Spring_data_04b_v3"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "1A" & boat.obs$filename %in% "Final_raw_Spring_data_04b_v3"] = "2"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "4" & boat.obs$filename %in% "Final_raw_Spring_data_04b" & boat.obs$Latitude < 40.56] = "Changed TRANSECT from 4; Changed filename to _v2 since there were multiple transect 4's"
boat.obs$filename[boat.obs$TRANSECT %in% "4" & boat.obs$filename %in% "Final_raw_Spring_data_04b" & boat.obs$Latitude < 40.56] = "Final_raw_Spring_data_04b_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "4" & boat.obs$filename %in% "Final_raw_Spring_data_04b_v2"] = "3"
# 
boat.obs$dataChange[boat.obs$TRANSECT %in% "4" & boat.obs$filename %in% "Final_raw_summer04" & 
                      boat.obs$Longitude <(-73.36) & boat.obs$Latitude <40.56] = "Changed TRANSECT from 4; Changed filename to _v2 since there were two transect 4's"
boat.obs$filename[boat.obs$TRANSECT %in% "4" & boat.obs$filename %in% "Final_raw_summer04" & 
                    boat.obs$Longitude <(-73.36) & boat.obs$Latitude <40.56] = "Final_raw_summer04_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "4" & boat.obs$filename %in% "Final_raw_summer04_v2" & 
                    boat.obs$Longitude <(-73.36) & boat.obs$Latitude <40.56] = "3"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "5" & boat.obs$filename %in% "Final_raw_summer04" & 
                      boat.obs$Longitude <(-73.34) & boat.obs$Latitude <40.54] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "5" & boat.obs$filename %in% "Final_raw_summer04" & 
                                                                                                             boat.obs$Longitude <(-73.34) & boat.obs$Latitude <40.54], 
                                                                                       "; Changed TRANSECT from 5; Changed filename to _v2 since there were two transect 5's", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "5" & boat.obs$filename %in% "Final_raw_summer04" & 
                    boat.obs$Longitude <(-73.34) & boat.obs$Latitude <40.54] = "Final_raw_summer04_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "5" & boat.obs$filename %in% "Final_raw_summer04_v2" & 
                    boat.obs$Longitude <(-73.34) & boat.obs$Latitude <40.54] = "4"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "5" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "5" & boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                           "; Changed TRANSECT from 5 and filename to _v2 since there were multiple transect 5's", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "5" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Final_raw_Spring_data_04b_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "5" & boat.obs$filename %in% "Final_raw_Spring_data_04b_v2"] = "4"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_Spring_data_04b"], 
                                                                                                           "; Changed TRANSECT from 6 and filename to _v3 since there were multiple transect 4's", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Final_raw_Spring_data_04b_v3"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_Spring_data_04b_v3"] = "4"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude <(-73.35)] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude <(-73.35)],
                                                                                                                                   "; Changed TRANSECT from 6, Changed filename to _v3", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude <(-73.35)] = "Final_raw_summer04_v3"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_summer04_v3" & boat.obs$Longitude <(-73.35)] = "4"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_data_081105" & 
  !boat.obs$GPS_Time %in% c("02:23:11pm","02:29:59pm","02:31:15pm","02:37:27pm","02:42:23pm",
                  "02:46:39pm","02:49:59pm","02:53:07pm","02:54:15pm","02:56:11pm","02:56:55pm")] = "Changed TRANSECT from 6"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "6" & boat.obs$filename %in% "Final_raw_data_081105" & 
           !boat.obs$GPS_Time %in% c("02:23:11pm","02:29:59pm","02:31:15pm","02:37:27pm","02:42:23pm",
                                     "02:46:39pm","02:49:59pm","02:53:07pm","02:54:15pm","02:56:11pm","02:56:55pm")] = "5"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "7" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "7" & boat.obs$filename %in% "Final_raw_Spring_data_04b"], 
                                                                                                           "; Changed TRANSECT from 7", sep = " ")
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "7" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "5"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "7" & boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude<(-73.33)] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "7" & boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude<(-73.33)],
                                                                                                    "Changed TRANSECT from 7; Changed filename to _v2", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "7" & boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude<(-73.33)] = "Final_raw_summer04_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "7" & boat.obs$filename %in% "Final_raw_summer04_v2" & boat.obs$Longitude<(-73.33)] = "5"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "2A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "2A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                            "; Changed TRANSECT from 2A", sep = " ")
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "2A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "3"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "3A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "3A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                            "; Changed TRANSECT from 3A", sep = " ")
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "3A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "4"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "4A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "4A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                            "; Changed TRANSECT from 4A", sep = " ")
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "4A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "5"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "5A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "5A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                            "; Changed TRANSECT from 5A", sep = " ")
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "5A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "6"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "6A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "6A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                            "; Changed TRANSECT from 6A", sep = " ")
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "6A" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "7"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "8" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "8" & boat.obs$filename %in% "Final_raw_Spring_data_04b"], 
                                                                                                           "; Changed TRANSECT from 8", sep = " ")
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "8" & boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "5"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "8" & boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude>(-73.35)] = "Changed TRANSECT from 8"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "8" & boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude>(-73.35)] = "5"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "9"& boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude>(-73.35)] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "9"& boat.obs$filename=="Final_raw_summer04" & boat.obs$Longitude>(-73.35)],
                                                                                                                             "; Changed TRANSECT from 9; Changed filename to _v2", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "9"& boat.obs$filename %in% "Final_raw_summer04" & boat.obs$Longitude>(-73.35)] = "Final_raw_summer04_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "9"& boat.obs$filename %in% "Final_raw_summer04_v2" & boat.obs$Longitude>(-73.35)] = "6"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "9"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "9"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] ,
                                                                                                      "Changed TRANSECT from 9", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "9"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Final_raw_Spring_data_04b_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "9"& boat.obs$filename %in% "Final_raw_Spring_data_04b_v2"] = "6"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "10"& boat.obs$filename %in% "Final_raw_summer04"& boat.obs$Longitude>(-73.35)] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "10"& boat.obs$filename %in% "Final_raw_summer04"& boat.obs$Longitude>(-73.35)],
                                                                                                                             "; Changed TRANSECT from 1-; Changed filename to _v3", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "10"& boat.obs$filename %in% "Final_raw_summer04"& boat.obs$Longitude>(-73.35)] = "Final_raw_summer04_v3"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "10"& boat.obs$filename %in% "Final_raw_summer04_v3"& boat.obs$Longitude>(-73.35)] = "6"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "10"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "10"& boat.obs$filename %in% "Final_raw_Spring_data_04b"], 
                                                                                                       "; Changed TRANSECT from 1-; Changed filename to _v3", sep = " ")
boat.obs$filename[boat.obs$TRANSECT %in% "10"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Final_raw_Spring_data_04b_v3"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "10"& boat.obs$filename %in% "Final_raw_Spring_data_04b_v3"] = "6"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "11"& boat.obs$filename %in% "Final_raw_summer04"] = "Changed TRANSECT from 11"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "11"& boat.obs$filename %in% "Final_raw_summer04"] = "7"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "11"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "11"& boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                             "; Changed TRANSECT from 11")
boat.obs$filename[boat.obs$TRANSECT %in% "11"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Final_raw_Spring_data_04b_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "11"& boat.obs$filename %in% "Final_raw_Spring_data_04b_v2"] = "7"
#
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "12"& boat.obs$filename %in% "Final_raw_summer04"] = "Changed TRANSECT from 12; Changed filename to _v2"
boat.obs$filename[boat.obs$TRANSECT %in% "12"& boat.obs$filename %in% "Final_raw_summer04"] = "Final_raw_summer04_v2"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "12"& boat.obs$filename %in% "Final_raw_summer04_v2"] = "7"
#
boat.obs$dataChange[boat.obs$TRANSECT %in% "12"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] = paste(boat.obs$dataChange[boat.obs$TRANSECT %in% "12"& boat.obs$filename %in% "Final_raw_Spring_data_04b"],
                                                                                                             "; Changed TRANSECT from 12")
boat.obs$filename[boat.obs$TRANSECT %in% "12"& boat.obs$filename %in% "Final_raw_Spring_data_04b"] = "Final_raw_Spring_data_04b_v3"
boat.obs$TRANSECT[boat.obs$TRANSECT %in% "12"& boat.obs$filename %in% "Final_raw_Spring_data_04b_v3"] = "7"

# remove N and S from transect
boat.obs$TRANSECT = as.numeric(str_extract(boat.obs$TRANSECT, "[0-9]+"))

# check if each transect has a BEG and END count
# if not, need to grab the first or last in the series
# but look in the transect file to make sure if there is a 
# defined start aside from the first location in the series

#fix date
boat.transect$GPS_Date = sapply(strsplit(as.character(boat.transect$GPS_Date), split = " "),head,1)
boat.transect$GPS_Date[boat.transect$filename %in% "Final_raw_data_071105"] = "2005-07-11"
boat.obs$GPS_Date[boat.obs$filename %in% "Final_raw_data_071105"] = "2005-07-11"
# add begend from transects table
boat.transect$TRANSECT = as.character(boat.transect$TRANSECT)
boat.transect$TRANSECT = as.numeric(str_extract(boat.transect$TRANSECT, "[0-9]+"))
boat.transect = boat.transect %>% mutate(fn_t = paste(filename, TRANSECT, GPS_Date, sep="_")) %>% 
  mutate(GPS_DateTime = as.POSIXct(paste(boat.transect$GPS_Date, boat.transect$GPS_Time, sep= " "), format = "%Y-%m-%d %I:%M:%S%p")) %>% 
  mutate(index = 1:length(GPS_Date)) %>% group_by(fn_t) %>% arrange(GPS_DateTime, index) %>% mutate(SPECIES1 = NA) %>%
  mutate_each(funs(ifelse(row_number()==1,"BEGCNT","ENDCNT")), SPECIES1) %>% as.data.frame
ind = boat.transect %>% select(fn_t) %>% group_by(fn_t) %>% summarize(n = n()) %>% filter(n==1)
boat.transect$SPECIES1[boat.transect$fn_t %in% ind$fn_t] = "CNT" #not sure if its BEG or END yet
# fix transects
boat.transect$TRANSECT[boat.transect$fn_t %in% "GPS_06-01-2006_11_2006-06-01" & 
                         boat.transect$GPS_Time %in% "01:59:42pm"] = "12"
boat.transect$fn_t[boat.transect$fn_t %in% "GPS_06-01-2006_11_2006-06-01" & 
                         boat.transect$GPS_Time %in% "01:59:42pm"] = "GPS_06-01-2006_12_2006-06-01"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_06-01-2006_12_2006-06-01" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_050305_8_2005-05-03" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_042805_12_2005-04-28" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_042105_12_2005-04-21" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_06-01-2006_7_2006-06-01" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_05-25-2006_11_2006-05-25" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_04-25-2006_5_2006-04-25" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_04-18-2006_11_2006-04-18" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_04-11-2006_12_2006-04-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_03-01-2006_4_2006-03-01" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_02-16-2006_5_2006-02-16" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_12-21-2005_7_2005-12-21" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_12-15-2005_12_2005-12-15" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_11-28-2005_2_2005-11-28" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$fn_t[boat.transect$fn_t %in% "GPS_11-28-2005_3_2005-11-28" & 
                         boat.transect$GPS_Time %in% "01:34:12pm"] = "GPS_11-28-2005_2_2005-11-28"
boat.transect$TRANSECT[boat.transect$fn_t %in% "GPS_11-28-2005_2_2005-11-28" & 
                         boat.transect$GPS_Time %in% "01:34:12pm"] = "2"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_11-18-2005_11_2005-11-18" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$TRANSECT[boat.transect$fn_t %in% "GPS_11-18-2005_1_2005-11-18" & 
                         boat.transect$GPS_Time %in% "09:09:37am"] = "11"
boat.transect$fn_t[boat.transect$fn_t %in% "GPS_11-18-2005_1_2005-11-18" & 
                     boat.transect$GPS_Time %in% "09:09:37am"] = "GPS_11-18-2005_11_2005-11-18"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_11-18-2005_11_2005-11-18" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_11-18-2005_12_2005-11-18" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_051005_7_2005-05-10" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_061505_7_2005-06-15" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_071105_5_2005-07-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_071105_6_2005-07-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_072705_12_2005-07-27" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_092705_6_2005-09-27" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_101804_4_2004-10-18" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_101905_12_2005-10-19" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_101905_6_2005-10-19" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_102904_3_2004-10-29" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_072705_6_2005-07-27" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_4_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_2_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_8_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_9_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_10_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_11_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_12_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_7_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_081105_6_2005-08-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "BEGCNT"
boat.transect$SPECIES1[boat.transect$fn_t %in% "Final_raw_data_071105_10_2005-07-11" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$TRANSECT[boat.transect$fn_t %in% "GPS_04-25-2006_3_2006-04-25" & 
                         boat.transect$GPS_Time %in% "10:51:02am"] = "5"
boat.transect$fn_t[boat.transect$fn_t %in% "GPS_04-25-2006_3_2006-04-25" & 
                         boat.transect$GPS_Time %in% "10:51:02am"] = "GPS_04-25-2006_5_2006-04-25"

#duplicates/kinda
boat.transect[boat.transect$fn_t %in% "GPS_05-17-2006_10_2006-05-17" & 
                boat.transect$SPECIES1 %in% "BEGCNT",] = NA
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_05-17-2006_10_2006-05-17" & 
                         boat.transect$SPECIES1 %in% "ENDCNT" & boat.transect$GPS_Time %in% "12:56:02pm"] = "BEGCNT"
boat.transect[boat.transect$fn_t %in% "GPS_05-17-2006_10_2006-05-17" & 
                boat.transect$SPECIES1 %in% "ENDCNT",] = NA
boat.transect$SPECIES1[boat.transect$fn_t %in% "GPS_05-17-2006_1_2006-05-17" & 
                         boat.transect$SPECIES1 %in% "CNT"] = "ENDCNT"
boat.transect$fn_t[boat.transect$fn_t %in% "GPS_05-17-2006_1_2006-05-17" & 
                     boat.transect$GPS_Time %in% "01:25:32pm"] = "GPS_05-17-2006_10_2006-05-17"
boat.transect = boat.transect[!is.na(boat.transect$fn_t),]
boat.transect$index=NA
x = select(boat.transect, TRANSECT, GPS_DateTime, GPS_Date, GPS_Time, Datafile, Latitude, Longitude, filename, SPECIES1, fn_t) %>%
  mutate(GPS_Date = as.POSIXct(GPS_Date, format = "%Y-%m-%d"))
boat.obs =  boat.obs %>% mutate(fn_t = paste(filename, TRANSECT, GPS_Date, sep="_")) #redo after fixed errors
boat.obs$fn_t_c = paste(boat.obs$fn_t, boat.obs$SPECIES1, sep="_")
boat.obs$fn_t_c[!boat.obs$SPECIES1 %in% c("BEGCNT","ENDCNT")] = NA
x$fn_t_c = paste(x$fn_t, x$SPECIES1, sep="_")
ind = sort(unique(x$fn_t_c[!x$fn_t_c %in% boat.obs$fn_t_c])) #BEG or END in transect table not in obs
x = x[x$fn_t_c %in% ind,]
# add index for x 
ind_ind = boat.obs %>% select(fn_t, index) %>% group_by(fn_t) %>% 
  summarise(min_ind = min(as.numeric(index)),max_ind = max(as.numeric(index)))
x$dataChange = NA
for (a in 1:length(x$fn_t)) {
  b = x$fn_t[a]
  if(any(ind_ind$fn_t %in% b)) {
    if(any(x$fn_t %in% b & x$SPECIES1 %in% "BEGCNT")) {
      x$index[x$fn_t %in% b & x$SPECIES1 %in% "BEGCNT"] = as.numeric(ind_ind$min_ind[ind_ind$fn_t %in% b]) - 0.00001
    }
    if(any(x$fn_t %in% b & x$SPECIES1 %in% "ENDCNT")) {
      x$index[x$fn_t %in% b & x$SPECIES1 %in% "ENDCNT"] = as.numeric(ind_ind$max_ind[ind_ind$fn_t %in% b]) + 0.00001
    }
    x$dataChange[x$fn_t %in% b & x$SPECIES1 %in% c("ENDCNT","BEGCNT")] = "Added from transect table"
  }
}                                                                            

# combine and arrange based on time for the rest and make a new index
x$TRANSECT = as.numeric(x$TRANSECT)
boat.obs = bind_rows(boat.obs, x) %>% arrange(GPS_Date, index, GPS_DateTime) 

#geo-reference online points that have NA as transect (AvG was not correct, have to visualize)
library(sp)
l2 = cbind(c(-73.3945,-73.3752),c(40.613,40.51893))
l3 = cbind(c(-73.381,-73.3625),c(40.616,40.522))  
l4 = cbind(c(-73.368,-73.348),c(40.62,40.525))  
l5 = cbind(c(-73.353,-73.334),c(40.622,40.526))  
l6 = cbind(c(-73.3388,-73.32),c(40.6175,40.52828))  
l7 = cbind(c(-73.324,-73.305),c(40.615,40.52868))  
l8 = cbind(c(-73.409,-73.39),c(40.610,40.518))  
l9 = cbind(c(-73.423,-73.40404),c(40.605,40.517))  
l10 = cbind(c(-73.436,-73.419),c(40.603,40.516))  
l11 = cbind(c(-73.44927,-73.43212),c(40.598,40.515))  
l12 = cbind(c(-73.462,-73.44459),c(40.59452,40.512))  

Sl2 <- Line(l2)
Sl3 <- Line(l3)
Sl4 <- Line(l4)
Sl5 <- Line(l5)
Sl6 <- Line(l6)
Sl7 <- Line(l7)
Sl8 <- Line(l8)
Sl9 <- Line(l9)
Sl10 <- Line(l10)
Sl11 <- Line(l11)
Sl12 <- Line(l12)

S2 <- Lines(list(Sl2), ID = "2")
S3 <- Lines(list(Sl3), ID = "3")
S4 <- Lines(list(Sl4), ID = "4")
S5 <- Lines(list(Sl5), ID = "5")
S6 <- Lines(list(Sl6), ID = "6")
S7 <- Lines(list(Sl7), ID = "7")
S8 <- Lines(list(Sl8), ID = "8")
S9 <- Lines(list(Sl9), ID = "9")
S10 <- Lines(list(Sl10), ID = "10")
S11 <- Lines(list(Sl11), ID = "11")
S12 <- Lines(list(Sl12), ID = "12")

rm(l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12)

SL <- SpatialLines(list(S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12))
survey_design = SpatialLinesDataFrame(SL, data.frame(Transect = c("2","3","4","5","6","7","8","9","10","11","12"), 
                                                     row.names = c("2","3","4","5","6","7","8","9","10","11","12")))

#grab data where Transect is NA
x = boat.obs[is.na(boat.obs$TRANSECT),]
x = x[x$offline == 0,] #ignore offline points
# find closest line
coordinates(x) = cbind(x$Longitude, x$Latitude)
boat.obs$TRANSECT[boat.obs$index %in% x$index] = as.character(apply(gDistance(x,survey_design, byid=TRUE), 2, function(X) rownames(m)[order(X)][1]))  
boat.obs$dataChange[boat.obs$index %in% x$index] = paste(boat.obs$dataChange[boat.obs$index %in% x$index],
                                                         "; Changed TRANSECT from NA", sep = " ")
boat.obs = mutate(boat.obs, fn_t = paste(filename, TRANSECT, GPS_Date, sep="_")) 
  
#remove transects that already have beg and end
boat.obs2 = boat.obs
ind = sort(unique(boat.obs$fn_t[boat.obs$SPECIES1 %in% c("BEGCNT","ENDCNT")]))
boat.obs2 = boat.obs2[!boat.obs2$fn_t %in% ind,] 

# create beg end for those that dont have them 
x = boat.obs2 %>% filter(!is.na(TRANSECT)) %>% group_by(fn_t) %>% filter(row_number()==1) %>% 
  select(fn_t, SPECIES1, GPS_Date, GPS_Time, Datafile, Latitude, Longitude, filename, TRANSECT, index) %>%
  mutate(SPECIES1 = "BEGCNT") %>% mutate(index = as.numeric(index) - 0.0001) %>% as.data.frame() 
xx = boat.obs2 %>% filter(!is.na(TRANSECT)) %>% mutate(fn_t = paste(filename, TRANSECT, GPS_Date, sep="_")) %>% 
  group_by(fn_t) %>% filter(row_number()==n()) %>% 
  select(fn_t, SPECIES1, GPS_Date, GPS_Time, Datafile, Latitude, Longitude, filename, TRANSECT, index) %>%
  mutate(SPECIES1 = "ENDCNT") %>% mutate(index = as.numeric(index) + 0.0001) %>% as.data.frame() 
new = rbind(x,xx) 
new = arrange(new, index)
boat.obs = bind_rows(boat.obs, new) %>% arrange(index)
rm(boat.obs2,new,x,xx)

# fix transects that have a BEG or and END but not both
is.odd <- function(x) x %% 2 != 0
ind = boat.obs %>% filter(SPECIES1 %in% c("BEGCNT","ENDCNT","CNT")) %>% group_by(fn_t) %>% 
  summarise(n=n()) %>% filter(is.odd(n))



 + ============================================== PICK UP HERE ==================================== + 

  
  
    
#-----------------#


#-----------------#
# TRANSECTS
#-----------------#

# format to have start time, end time etc... 




#--------------------------------------------------------------------------- #
# Plane
#----------------------------------------------------------------------------#

# remove NAs
plane.obs = select(plane.obs, -F17,-F18,-F19,-F20,-F21)
plane.point.ge = select(plane.point.ge, -F1,-F2,-F3,-F4,-F5,-F6,-F7)
plane.obs = plane.obs[!is.na(plane.obs$Latitude),]
plane.point.ge = plane.point.ge[!is.na(plane.point.ge$Latitude),]

# combine point.ge and obs
plane.point.ge = rename(plane.point.ge, NOTES = Comment)
plane.point.ge$NOTES = as.character(plane.point.ge$NOTES)
plane.point.ge$SPECIES1 = plane.point.ge$NOTES
plane.point.ge$NO = 1
plane.point.ge$NO[plane.point.ge$SPECIES1 %in% "2 porp"] = 2
plane.point.ge$SPECIES1[plane.point.ge$SPECIES1 %in% c("2 porp","1 porp","porp")] = "UNPO"
plane.obs = bind_rows(plane.obs, plane.point.ge)
rm(plane.point.ge)

# fix species
plane.obs$SPECIES1 = as.character(plane.obs$SPECIES1)
plane.obs$SPECIES2 = as.character(plane.obs$SPECIES2)
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "SCSP"] = "UNSC"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "SPSP"] = "WISP"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "UNSA"] = "USAN"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "BLBR"] = "BRAN"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "seal"] = "UNSE"             
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "mola"] = "MOLA"            
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "turtle"] ="TURT"            
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "Loggerhead turtle"] = "LOTU"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "Passerine species"] = "UNPA"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "leatherback turtle"] = "LETU"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "Swallow sp."] = "SWAL"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "Tern sp."] = "UNTE"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "Gull sp."] = "UNGU"
plane.obs$SPECIES1[plane.obs$SPECIES1 %in% "Unidentified shorebird"] = "SHOR"
plane.obs$SPECIES2[plane.obs$SPECIES2 %in% c("a;lcid","alcid","allcid")] = "UNAL"
plane.obs$SPECIES1[!is.na(plane.obs$SPECIES2)] = plane.obs$SPECIES2[!is.na(plane.obs$SPECIES2)] 
plane.obs = select(plane.obs, -SPECIES2)

#transect
plane.obs$TRANSECT = as.numeric(str_extract(plane.obs$TRANSECT, "[0-9]+"))

# pull transect info out
plane.obs$index = seq.int(nrow(plane.obs))
tmp = plane.obs[plane.obs$SPECIES1 %in% c("10n","10s","11n","11s","12n","12s","13n",
                                          "13s","14n","14s","15n","15s","16n","16s",
                                          "17n","17s","18n","18s","19n","19s","1n",
                                          "1s","2n","2s","3n","3s","4n","4s","5n",
                                          "5s","6n","6s","7n","7s","8n","8s","9n","9s"),]
tmp$TRANSECT = as.numeric(strsplit(as.character(tmp$SPECIES1), "[^0-9]+"))
plane.obs$SPECIES1 = as.character(plane.obs$SPECIES1)

for(a in 1:(nrow(tmp)-1)) {
  if(tmp$TRANSECT[a] == tmp$TRANSECT[a+1] & tmp$filename[a] == tmp$filename[a+1]) {
    if(tmp$index[a+1]-tmp$index[a]-1 >= 1) {
      plane.obs$TRANSECT[(tmp$index[a]+1):(tmp$index[a+1]-1)] = replicate(tmp$index[a+1]-tmp$index[a]-1, tmp$TRANSECT[a])
      plane.obs$SPECIES1[tmp$index[a]] = "BEGCNT"
      plane.obs$SPECIES1[tmp$index[a+1]] = "ENDCNT"
    }
  }
}

# remove incorrect information
plane.obs$NO[tmp$index] = NA
plane.obs$AGE[tmp$index] = NA
plane.obs$SEX[tmp$index] = NA
plane.obs = plane.obs[!plane.obs$index %in% tmp$index,]
plane.obs$index = seq.int(nrow(plane.obs))
rm(tmp)

# fix transects that didnt have a BEG and END
plane.obs$filename = as.character(plane.obs$filename)
plane.obs$GPS_Time = as.character(plane.obs$GPS_Time)
plane.obs$TRANSECT[plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "12:44:25pm"]:
                     plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "12:45:24pm"]] = 16
plane.obs$TRANSECT[plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "12:25:43pm"]:
                     plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "12:28:40pm"]] = 12
plane.obs$TRANSECT[plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "12:16:19pm"]:
                     plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "12:19:40pm"]] = 10
plane.obs$TRANSECT[plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "12:02:42pm"]:
                     plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "12:05:42pm"]] = 7
plane.obs$TRANSECT[plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "11:49:25am"]:
                     plane.obs$index[plane.obs$filename == "Final_raw_data_101304" & plane.obs$GPS_Time == "11:52:31am"]] = 4
plane.obs$TRANSECT[plane.obs$index[plane.obs$filename == "Final_aerial_data_103105" & plane.obs$GPS_Time == "11:27:55pm"]:
                     plane.obs$index[plane.obs$filename == "Final_aerial_data_103105" & plane.obs$GPS_Time == "11:30:48pm"]] = 19
plane.obs$TRANSECT[plane.obs$index[plane.obs$filename == "Final_aerial_data_103105" & plane.obs$GPS_Time == "10:59:04am"]:
                     plane.obs$index[plane.obs$filename == "Final_aerial_data_103105" & plane.obs$GPS_Time == "11:00:03pm"]] = 13

# Pull species from NOTES when SPECIES 1 == NA
plane.obs$SPECIES1[plane.obs$NOTES %in% "swallow"] = "SWAL"
plane.obs$SPECIES1[grep("3 UNTE/5 UNGU",plane.obs$NOTES)] = "UNTE"
plane.obs$SPECIES1[grep("3 UNTE/5 UNGU",plane.obs$NOTES)] = "UNGU"
plane.obs$NO[grep("3 UNTE/5 UNGU",plane.obs$NOTES)] = 3
plane.obs$NO[grep("3 UNTE/5 UNGU",plane.obs$NOTES)] = 5

# Pull from NOTES to fix miscodings
new = plane.obs[plane.obs$NOTES %in% "9 GBBG/2 UNGU following fishing boat",]                                                                                                                              
new$index = new$index + 0.001
new$NO = 9
new$SPECIES1 = "GBBG"
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Flock of 12 (10 NOGA, 2 UNGU)",]                                                                                                                              
new$index = new$index + 0.001
new$NO = 2
new$SPECIES1 = "UNGU"
plane.obs$NO[plane.obs$NOTES %in% "Flock of 12 (10 NOGA, 2 UNGU)"] = 10
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Flock of 2 (1 NOGA/1 HEGU)",] 
new$index = new$index + 0.001
new$NO = 1
new$SPECIES1 = "HEGU"
plane.obs$NO[plane.obs$NOTES %in% "Flock of 2 (1 NOGA/1 HEGU)"] = 1
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Flock of 20 (13 NOGA/7 UNGU) in zones 1 and 2",] 
new$index = new$index + 0.001
new$NO = 7
new$SPECIES1 = "UNGU"
plane.obs$NO[plane.obs$NOTES %in% "Flock of 20 (13 NOGA/7 UNGU) in zones 1 and 2"] = 13
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Flock of 20 (5 NOGA/15 UNGU) In all zones",] 
new$index = new$index + 0.001
new$NO = 5
new$SPECIES1 = "NOGA"
plane.obs$NO[plane.obs$NOTES %in% "Flock of 20 (5 NOGA/15 UNGU) In all zones"] = 15
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Flock of 40 (25 NOGA/15 UNGU). In all zones",] 
new$index = new$index + 0.001
new$NO = 15
new$SPECIES1 = "UNGU"
plane.obs$NO[plane.obs$NOTES %in% "Flock of 40 (25 NOGA/15 UNGU). In all zones"] = 25
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Flock of 8 (7 UNGU/1 NOGA)",] 
new$index = new$index + 0.001
new$NO = 1
new$SPECIES1 = "NOGA"
plane.obs$NO[plane.obs$NOTES %in% "Flock of 8 (7 UNGU/1 NOGA)"] = 7
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Large flock of 100 (80 UNGU/20 NOGA). Zones 2,3. 4:1 water to flight.",] 
new$index = new$index + 0.001
new$NO = 80
new$SPECIES1 = "UNGU"
plane.obs$NO[plane.obs$NOTES %in% "Large flock of 100 (80 UNGU/20 NOGA). Zones 2,3. 4:1 water to flight."] = 20
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Large flock of UNGU/NOGA. 3:1 ration NOGA to UNGU. IN all zones",] 
new$index = new$index + 0.001
new$NO = 30
new$SPECIES1 = "UNGU"
plane.obs$NO[plane.obs$NOTES %in% "Large flock of UNGU/NOGA. 3:1 ration NOGA to UNGU. IN all zones"] = 10
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Large flock of UNGU/NOGA. 75 NOGA/8 UNGU in all zones. Approximately 10 NOGA in flight",] 
new$index = new$index + 0.001
new$NO = 8
new$SPECIES1 = "UNGU"
plane.obs$NO[plane.obs$NOTES %in% "Large flock of UNGU/NOGA. 75 NOGA/8 UNGU in all zones. Approximately 10 NOGA in flight"] = 75
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Large flock of UNGU/NOGA. Approximately 3:1 NOGA to UNGU. Approximately 3:1 birds on water to birds in flight. In all zones",] 
new$index = new$index + 0.001
new$NO = 49
new$SPECIES1 = "NOGA"
plane.obs$NO[plane.obs$NOTES %in% "Large flock of UNGU/NOGA. Approximately 3:1 NOGA to UNGU. Approximately 3:1 birds on water to birds in flight. In all zones"] = 16
plane.obs = rbind(plane.obs, new)
rm(new)
#
new = plane.obs[plane.obs$NOTES %in% "Unidentified Tern species",] 
new$index = new$index + 0.001
new$NO = 8
new$SPECIES1 = "UNGU"
plane.obs$NO[plane.obs$NOTES %in% "Large flock of UNGU/NOGA. 75 NOGA/8 UNGU in all zones. Approximately 10 NOGA in flight"] = 75
plane.obs = rbind(plane.obs, new)
rm(new)
#
plane.obs = arrange(plane.obs, index)
