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

boat.obs$dataChange[grep("vessel", boat.obs$SPECIES1)] = 
  paste(boat.obs$dataChange[grep("vessel", boat.obs$SPECIES1)],
  "; Changed SPECIES1 from ", boat.obs$SPECIES1[grep("vessel", boat.obs$SPECIES1)], sep ="")                                          
boat.obs$dataChange[grep("seal",boat.obs$SPECIES1)] = 
  paste(boat.obs$dataChange[grep("seal",boat.obs$SPECIES1)],
  "; Changed SPECIES1 from ", boat.obs$SPECIES1[grep("seal",boat.obs$SPECIES1)], sep ="")                                          
boat.obs$dataChange[grep("ray",boat.obs$SPECIES1)] = 
  paste(boat.obs$dataChange[grep("ray",boat.obs$SPECIES1)],
  "; Changed SPECIES1 from ", boat.obs$SPECIES1[grep("ray",boat.obs$SPECIES1)], sep ="")                                          
boat.obs$dataChange[grep("porp",boat.obs$SPECIES1)] = 
  paste(boat.obs$dataChange[grep("porp",boat.obs$SPECIES1)],
  "; Changed SPECIES1 from ", boat.obs$SPECIES1[grep("porp",boat.obs$SPECIES1)], sep ="") 

boat.obs$dataChange[which(boat.obs$NOTES == "pomarine jaeger")] = 
  paste(boat.obs$dataChange[which(boat.obs$NOTES == "pomarine jaeger")],
        "Changed SPECIES1 from NA ", sep ="; ") 

# CHANGE SPECIES1
boat.obs$SPECIES1[grep("vessel", boat.obs$SPECIES1)] = "BOCF"
boat.obs$SPECIES1[grep("seal",boat.obs$SPECIES1)] = "UNSE"
boat.obs$SPECIES1[grep("ray",boat.obs$SPECIES1)] = "UNRA"
boat.obs$SPECIES1[grep("porp",boat.obs$SPECIES1)] = "INPO"

boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Passerine species")] = "UNPA"                                          
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "American Woodcock")] = "AMWO"                    
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Black Duck")] = "ABDU"                                          
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Tern sp.")] = "UNTE"                                                   
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Gull sp.")] = "UNGU"                                                  
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Loon sp.")] = "UNLO"                                               
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Scoter sp.")] = "UNSC"                                             
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Sandpiper sp.")] = "USAN"                                                 
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Duck sp.")] = "UNDU"                                               
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Sandpiper")] = "USAN"                                                 
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Petrel sp.")] = "UNPE"                                                   
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Corm sp.")] = "UNCO" #Cormorant?                                                
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Sanderling")] = "SAND"                                               
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Plover sp.")] = "UNPL"                                           
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Yellowlegs sp.")] = "UNYE"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Leatherback turtle")] = "LETU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Albacore tuna school")] = "ALTU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Ruddy Turnstone")] = "RUTU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Harbor Porpoise")] = "HAPO"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "porpoise")] = "UNPO"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Unidentified Scoter")] = "UNSC"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Jaeger spp.")] = "UNJA"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Scaup spp.")] = "SCAU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "co murre")] = "COMU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "alcid")] = "UNAL"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "jaeger sp")] = "UNJA"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "sparrow sp")] = "SPAR"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "unknown pass")] = "UNPA" # passerine?
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "unid sandpip")] = "USAN"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "willet")] = "WILL"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "passarine sp")] = "UNPA"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "horned grebe")] = "HOGR"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "co murrs")] = "COMU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "cco murre")] = "COMU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "co murre")] = "COMU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "alcid sp.")] = "UNAL"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Red-breasted Merganser")] = "RBME"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "RED-")] =  "RBME"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "Bonaparte's Gull")] = "BOGU"
boat.obs$SPECIES1[which(boat.obs$NOTES == "pomarine jaeger")] = "POJA"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "murre sp.")] = "UNMU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "sanderlings")] = "SAND"


# Check NOTES for SPECIES and NO errors and mixed flocks
notes = cbind(boat.obs$SPECIES1[!is.na(boat.obs$NOTES)], 
              boat.obs$NO[!is.na(boat.obs$NOTES)], 
              boat.obs$NOTES[!is.na(boat.obs$NOTES)],
              boat.obs$dataChange[!is.na(boat.obs$NOTES)])
#view the notes
rm(notes)

## FIX SPECIES AND COUNT ERRORS 
## BASED ON NOTES
boat.obs$SPECIES1[which(is.na(boat.obs$SPECIES1) & boat.obs$NOTES == "unidentified gull")] = "UNGU" 
boat.obs$SPECIES1[which(is.na(boat.obs$SPECIES1) & boat.obs$NOTES == "unidentified gulls")] = "UNGU"   
boat.obs$SPECIES1[which(is.na(boat.obs$SPECIES1) & boat.obs$NOTES == "3 BLSC/2 SUSC" & boat.obs$NO == "5")] = "BLSC"
boat.obs$SPECIES1[which(is.na(boat.obs$SPECIES1) & boat.obs$NOTES == "3 BLSC/2 SUSC" & boat.obs$NO == "5")] = "SUSC"
boat.obs$NO[boat.obs$SPECIES1 == "BLSC" & boat.obs$NOTES == "3 BLSC/2 SUSC" & boat.obs$NO == "5"] = "3"
boat.obs$NO[boat.obs$SPECIES1 == "SUSC" & boat.obs$NOTES == "3 BLSC/2 SUSC" & boat.obs$NO == "5"] = "2"
boat.obs$SPECIES1[is.na(boat.obs$SPECIES1) & boat.obs$NO == "20" & boat.obs$NOTES == "linked to gulls below. Foraging along with 67gulls"]  = "NOGA"                           
boat.obs$SPECIES1[is.na(boat.obs$SPECIES1) & boat.obs$NO == "67" & boat.obs$NOTES == "linked to 20 NOGA above"] = "UNGU" 
boat.obs$NO[boat.obs$SPECIES1 == "HEGU" & is.na(boat.obs$NO) & 
                    boat.obs$NOTES == "32 hegu/8 gbbg  loose flock on water w/ large flock of ltdu; flushed south"] = "32" 
boat.obs$NO[boat.obs$SPECIES1 == "GBBG" &  
              boat.obs$NOTES == "32 hegu/8 gbbg  loose flock on water w/ large flock of ltdu; flushed south"] = "8" 
boat.obs$SPECIES1[boat.obs$SPECIES1 == "Bonaparte's Gull" & is.na(boat.obs$NO) &
                  boat.obs$NOTES == "Linked to 7 NOGA in foraging flock. 9 rbgu/8 bogu. surface feeding"] = "8"          

boat.obs$NO[which(boat.obs$SPECIES1 == "HAPO" & is.na(boat.obs$NO) 
                  & boat.obs$NOTES == "~25 hp in large pod feeding  ; Changed SPECIES1 from Harbor Porpoise")] = "25"
boat.obs$NO[which(boat.obs$SPECIES1 == "HAPO" & is.na(boat.obs$NO) 
                  & boat.obs$NOTES == "5 harbor porpoises feeding  ; Changed SPECIES1 from Harbor Porpoise")] = "5"
boat.obs$NO[which(boat.obs$SPECIES1 == "HAPO" & is.na(boat.obs$NO) 
                  & boat.obs$NOTES == "2 harbor porpoises feeding  ; Changed SPECIES1 from Harbor Porpoise")] = "2"
boat.obs$NO[which(boat.obs$SPECIES1 == "HAPO" & is.na(boat.obs$NO) 
                  & boat.obs$NOTES == "6 harbor porpoises feeding  ; Changed SPECIES1 from Harbor Porpoise")] = "6"
boat.obs$NO[which(boat.obs$SPECIES1 == "HAPO" & is.na(boat.obs$NO) 
                  & boat.obs$NOTES == "5 harbor porpoises feeding")] = "5"

## ADDING ADDITIONAL ROWS BASED ON NOTES
## IF THE SECOND SPECIES WAS RECORDED IN THE SPECIES2 COLUMN THAT WOULD BE IN DATACHANGE
## THE ROWS NEXT TO THESE WERE CHECKED FOR THE ADDITIONAL SPECIES LISTED BUT WERE NOT FOUND
## AND THEREFORE THE ADDITIONAL SPECIES WERE ADDED UNDER THE ASSUMPTION THEY ARE NOT RECORDED 
# 
boat.obs$dataChange[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall")],
                            "Split NOTES '16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, 
                 boat.obs[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "25" & boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall"),],
                 boat.obs[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "25" & boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall"),])                 
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "25" & 
              boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall")][1] = "16"
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "25" & 
                    boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall")][1] = "4"
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "25" & 
                    boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall")][1] = "5"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "4" & 
                    boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall")][1] = "LAGU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "5" & 
                    boat.obs$NOTES == "16 HEGU/4 LAGU/5 UNGU in loose, scattered flock in slick from sewer outfall")][1] = "UNGU"
# 
boat.obs$dataChange[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")],
                            "Split NOTES 'following fishing vessel/22 HEGU/19 LAGU/1 GBBG' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, 
                 boat.obs[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "42" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG"),],
                 boat.obs[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "42" & boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG"),])                 
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "42" & 
                    boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")][1] = "22"
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "42" & 
                    boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")][1] = "19"
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "42" & 
                    boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")][1] = "1"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "19" & 
                         boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")] = "LAGU"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NO == "1" & 
                         boat.obs$NOTES == "following fishing vessel/22 HEGU/19 LAGU/1 GBBG")] = "GBBG"                    
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)")],
                            "Split NOTES '44 total (4 unidentified gulls/39 Laughing Gull)' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, 
                 boat.obs[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)"),])
boat.obs$NO[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)")][2] = "4"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "44 total (4 unidentified gulls/39 Laughing Gull)")][2] = "UNGU"
#
boat.obs$dataChange[which(boat.obs$NOTES == "13 total (8 HEGU, 3 GBBG, 2 LAGU)")] = 
  paste(boat.obs$dataChange[which(boat.obs$NOTES == "13 total (8 HEGU, 3 GBBG, 2 LAGU)")],
        "Split NOTES '13 total (8 HEGU, 3 GBBG, 2 LAGU)' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, boat.obs[which(boat.obs$NOTES == "13 total (8 HEGU, 3 GBBG, 2 LAGU)"),],
                 boat.obs[which(boat.obs$NOTES == "13 total (8 HEGU, 3 GBBG, 2 LAGU)"),])
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "13 total (8 HEGU, 3 GBBG, 2 LAGU)")][2] = "3"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "13 total (8 HEGU, 3 GBBG, 2 LAGU)")][2] = "GBBG"
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "13 total (8 HEGU, 3 GBBG, 2 LAGU)")][2] = "2"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "13 total (8 HEGU, 3 GBBG, 2 LAGU)")][2] = "LAGU"
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "5 total (2 COTE, 3 LAGU)")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "5 total (2 COTE, 3 LAGU)")],
        "Split NOTES '5 total (2 COTE, 3 LAGU)' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, boat.obs[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "5 total (2 COTE, 3 LAGU)"),])
boat.obs$NO[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "5 total (2 COTE, 3 LAGU)")][2] = "3"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "5 total (2 COTE, 3 LAGU)")][2] = "LAGU"
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat")],
        "Split NOTES '7 ungu/1 cote circling party boat' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, boat.obs[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat"),])
boat.obs$NO[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat")][1] = "7"
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "UNGU" & boat.obs$NOTES == "7 ungu/1 cote circling party boat")][2] = "COTE"
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "small flock of 9 COTE/1 LAGU")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "small flock of 9 COTE/1 LAGU")],
        "Split NOTES 'small flock of 9 COTE/1 LAGU' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, boat.obs[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "small flock of 9 COTE/1 LAGU"),])
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "small flock of 9 COTE/1 LAGU")][2] = "LAGU"
boat.obs$NO[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "small flock of 9 COTE/1 LAGU")] = "1"
#
boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "medium sized flock of 18 COTE and 1 LAGU feeding on bait fish")] = 
  paste(boat.obs$dataChange[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "medium sized flock of 18 COTE and 1 LAGU feeding on bait fish")],
        "Split NOTES 'medium sized flock of 18 COTE and 1 LAGU feeding on bait fish' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, boat.obs[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "medium sized flock of 18 COTE and 1 LAGU feeding on bait fish"),])
boat.obs$SPECIES1[which(boat.obs$SPECIES1 == "COTE" & boat.obs$NOTES == "medium sized flock of 18 COTE and 1 LAGU feeding on bait fish")][2] = "LAGU"
boat.obs$NO[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "medium sized flock of 18 COTE and 1 LAGU feeding on bait fish")] = "1"
# 
boat.obs$dataChange[which(boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU")] = 
  paste(boat.obs$dataChange[which(boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU")],
        "Split NOTES 'loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU' to add SPECIES1 & NO", sep = "; ")
boat.obs = rbind(boat.obs, 
                 boat.obs[which(boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU"),],
                 boat.obs[which(boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU"),])
boat.obs$SPECIES1[which(boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU")][1] = "HEGU"
boat.obs$SPECIES1[which(boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU")][2] = "GBBG"
boat.obs$SPECIES1[which(boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU")][3] = "RBGU"
boat.obs$NO[which(boat.obs$SPECIES1 == "HEGU" & boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU")] = "7"
boat.obs$NO[which(boat.obs$SPECIES1 == "LAGU" & boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU")] = "7"
boat.obs$NO[which(boat.obs$SPECIES1 == "RBGU" & boat.obs$NOTES == "loose large flock/ flight height and direction variable. 7 HEGU, 7GBBG, 11 RBGU")] = "11"

              
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
#                  [303,] "HEGU"              NA    "32 hegu/8 gbbg  loose flock on water w/ large flock of ltdu; flushed south"     
#                  [304,] "BLSC"              "1"   "85 ltdu/1 blsc on water"                                                        
#                  [305,] "horned grebe"      NA    "dove on approach"                                                               
#                  [306,] "HEGU"              NA    "32 hegu/8 gbbg  loose flock on water w/ large flock of ltdu; flushed south"     
#                  [307,] "BLSC"              "1"   "85 ltdu/1 blsc on water"                                                        
#                  [308,] "horned grebe"      NA    "dove on approach"  


#### TRANSECTS
changes = c("2N,2S", "t2n", "t2s", "2n", "2s", 
            "3N,3S", "t3n", "t3s", "3n", "3s", 
            "4N,4S", "t4n", "t4s", "4n", "4s",
            "5N,5S", "t5n", "t5s", "5n", "5s", 
            "6N,6S", "t6n", "t6s", "6n", "6s", 
            "7N,7S", "t7n", "t7s", "7n", "7s",
            "8N,8S", "t8n", "t8s", "8n", "8s", 
            "9N,9S", "t9n", "t9s", "9n", "9s",
            "10N,10S", "t10n", "t10s", "10n", "10s", "t10",
            "11N,11S", "t11n", "t11s", "11n", "11s", 
            "12N,12S", "t12n", "t12s", "12n", "12s")
for (a in 1:length(changes)) {
  boat.transect$dataChange[which(boat.transect$TRANSECT == changes[a])] = 
    paste(boat.transect$dataChange[which(boat.transect$TRANSECT == changes[a])],
          "; Changed TRANSECT from ", changes[a], sep ="") 
}
rm(changes, a)

boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("2N,2S","t2n","t2s","2n","2s")] = "2"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("3N,3S","t3n","t3s","3n","3s")] = "3"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("4N,4S","t4n","t4s","4n","4s")] = "4"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("5N,5S","t5n","t5s","5n","5s")] = "5"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("6N,6S","t6n","t6s","6n","6s")] = "6"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("7N,7S","t7n","t7s","7n","7s")] = "7"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("8N,8S","t8n","t8s","8n","8s")] = "8"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("9N,9S","t9n","t9s","9n","9s")] = "9"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("10N,10S","t10n","t10s","10n","10s","t10")] = "10"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("11N,11S","t11n","t11s","11n","11s")] = "11"
boat.transect$TRANSECT[boat.transect$TRANSECT %in% c("12N,12S","t12n","t12s","12n","12s")] = "12"


##### NEXT STEPS. CHANGE THE NA's TO TRANSECT NUMBERS BASED ON LOCATION (INTERP EXISTING POINTS TO GET A LINE) AND TIME
