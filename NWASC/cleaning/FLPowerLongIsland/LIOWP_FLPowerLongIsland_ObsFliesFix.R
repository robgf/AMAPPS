#--------------------------#
# Fix errors in FLPower Long Island data
#--------------------------#

#-----------------#
# Fix initial transect and general data errors
#-----------------#
# remove NAs
boat.obs = select(boat.obs, -F1,-F2,-F3,-F4,-F5,-F6,-F7)
boat.transect = boat.transect[!is.na(boat.transect$Latitude),]
boat.obs = boat.obs[!is.na(boat.obs$Latitude),]
boat.point.ge = boat.point.ge[!is.na(boat.point.ge$Latitude),]
boat.point.ge = boat.point.ge[boat.point.ge$Comment != "Comment",] 

# pull transect info out
boat.obs$index = seq.int(nrow(boat.obs))
tmp = boat.obs[boat.obs$SPECIES1 %in% c("10n","10s","11n","11s","12n","12s","2n","2ss",
                                        "3n","3s","4s","5s","6n","6s","7n","7s","8n",
                                        "8s","9n","9s","t4","2s","4n","5n","5S","6N",
                                        "12","10 n"),]
ind = which(tmp$SPECIES1 == "t4")  
tmp$SPECIES1[ind] = NA 
tmp$TRANSECT = as.numeric(strsplit(as.character(tmp$SPECIES1), "[^0-9]+"))
tmp$TRANSECT[ind] = 4

boat.obs$SPECIES1 = as.character(boat.obs$SPECIES1)

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
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_071105" & boat.obs$GPS_Time == "03:40:03pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_071105" & boat.obs$GPS_Time == "03:59:47pm"]] = 10 
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "02:29:59pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "03:33:19pm"]] = 6
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "03:40:55pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "04:10:39pm"]] = 4
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "04:53:11pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:16:23pm"]] = 2
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:24:23pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "05:44:59pm"]] = 8 
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:04:55pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:25:55pm"]] = 9 
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:31:11pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "06:57:27pm"]] = 10 
boat.obs$TRANSECT[boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "07:05:27pm"]:
                    boat.obs$index[boat.obs$filename == "Final_raw_data_081105" & boat.obs$GPS_Time == "07:31:43pm"]] = 11 
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

library(stringr)
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
# join
boat.point.ge$Latitude = as.numeric(boat.point.ge$Latitude)
boat.point.ge$Longitude = as.numeric(boat.point.ge$Longitude)
boat.point.ge$TRANSECT = as.character(boat.point.ge$TRANSECT)
boat.point.ge$NO = as.character(boat.point.ge$NO)
boat.obs = bind_rows(boat.obs, boat.point.ge)
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
boat.obs$SPECIES1[grep(" vessel ", boat.obs$SPECIES1)] = "BOCF"
boat.obs$SPECIES1[grep("seal ",boat.obs$SPECIES1)] = "UNSE"
boat.obs$SPECIES1[grep("ray ",boat.obs$SPECIES1)] = "UNRA"

boat.obs$SPECIES1[boat.obs$SPECIES1 == "American Woodcock"] = "AMWO"                    
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Black Duck"] = "ABDU"                                          
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Tern sp."] = "UNTE"                                                   
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Gull sp."] = "UNGU"                                                  
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Loon sp."] = "UNLO"                                               
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Scoter sp."] = "UNSC"                                             
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("Sandpiper sp.","sandpiper 2","Sandpiper","unid sandpip")] = "USAN"                                                 
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Duck sp."] = "UNDU"                                               
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Petrel sp."] = "UNPE"                                                   
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Corm sp."] = "UNCO" #Cormorant?                                                
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("sanderlings","Sanderling")] = "SAND"                                               
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Plover sp."] = "UNPL"                                           
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Yellowlegs sp."] = "UNYE"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Leatherback turtle"] = "LETU"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Albacore tuna school"] = "ALTU"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Ruddy Turnstone"] = "RUTU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("Harbor Porpoise","har por 1000  w","harbor porpoise")] = "HAPO"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("porpoise","porpoise 1, 800 feet west","porp","PORP","porp 2")] = "UNPO"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Unidentified Scoter"] = "UNSC"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("Jaeger spp.","jaeger sp")] = "UNJA"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Scaup spp."] = "SCAU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("co murrs","co murre","cco murre","co murre","co  murre")] = "COMU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("alcid sp.","alcid")] = "UNAL"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("sparrow sp","unidentified sparrow")] = "SPAR"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("passarine sp","unknown pass","Passerine species")] = "UNPA" # passerine?
boat.obs$SPECIES1[boat.obs$SPECIES1 == "willet"] = "WILL"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "horned grebe"] = "HOGR"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("RED-","Red-breasted Merganser")] = "RBME"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Bonaparte's Gull"] = "BOGU"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "murre sp."] = "UNMU"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "shearwater sp"] = "UNSH"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Cliff Swallow"] = "CLSW"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "loggerhead turtle"] = "LOTU"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("party boat 1 mi se","party boat 500 ft  nw",
                                           "party boats 4 1/2 mile se")] = "BOFI"
boat.obs$SPECIES1[boat.obs$SPECIES1 %in% c("2 comm fiishing vessels  3mi w",
                                           "3 comm vessels     west of posit","com fish boat",
                                           "com fish vessel/approx 1,000 e", "com fishing ves 1mi south",
                                           "com fishing ves 3 mi sw","com. fishing vessel/approx .5 mi",
                                           "com. fishing vessel/approx .5 mi from survey vessel",
                                           "comm. squid vessel/1,000 ft nw","comm. vessel/2 mi. sw of boat",
                                           "commercial fishing vessel","Commercial fishing vessel")] = "BOCF"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "mixed flock"] = "UNBI"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "basw  1"] = "BASW"
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Scoter spp."] = "UNSC"

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
#"10n"    "10s"    "11s"    "12n"    "2s"     "3s"     "4s"     "6n"     "6s"     "7n"     "7s"     "8n"     "8s"     "9s"  "T11N"
#-----------------#


#-----------------#
# TRANSECTS
#-----------------#
boat.transect$TRANSECT = as.numeric(str_extract(boat.transect$TRANSECT, "[0-9]+"))

# format to have start time, end time etc... 

##### NEXT STEPS. CHANGE THE NA's TO TRANSECT NUMBERS BASED ON LOCATION (INTERP EXISTING POINTS TO GET A LINE) AND TIME
