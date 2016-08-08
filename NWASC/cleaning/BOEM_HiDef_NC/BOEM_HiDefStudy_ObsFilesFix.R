# --------------------------- #
# species errors
# fix incorrect type codings
# --------------------------- #

## Species Information
# edit the table to consolidate
Species_Information$scientific_name = as.character(Species_Information$scientific_name)
Species_Information$scientific_name[is.na(Species_Information$scientific_name) & !is.na(Species_Information$species)] = 
  as.character(Species_Information$species[is.na(Species_Information$scientific_name) & !is.na(Species_Information$species)])
Species_Information$common_name = as.character(Species_Information$common_name)
Species_Information$commonc_name[is.na(Species_Information$common_name) & !is.na(Species_Information$common_name.1)] = 
  as.character(Species_Information$common_name.1[is.na(Species_Information$common_name) & !is.na(Species_Information$common_name.1)])
drops <- c("french_name","E","I","H","A","N","M","species","ID", "common_name.1")
Species_Information = Species_Information[,!(names(Species_Information) %in% drops)]

common_name = tolower(Species_Information$common_name)
spplist = as.character(Species_Information$species_code)

# list of codes we are using
codes = odbcConnectExcel2007(file.path(dbpath, "NWASC_codes.xlsx"), readOnly = TRUE) 
name <- sqlFetch(codes,"codes")
odbcCloseAll()

#species_code
spplist = ifelse(common_name == "humpback whale", "HUWH", spplist)
spplist = ifelse(common_name == "cuvier's beaked whale", "CBWH", spplist)
spplist = ifelse(common_name == "bottlenose dolphin", "BODO", spplist)
spplist = ifelse(common_name == "rough toothed dolphin", "RTDO", spplist)
spplist = ifelse(common_name == "spinner dolphin", "SPDO", spplist)
spplist = ifelse(common_name == "atlantic spotted dolphin", "ASDO", spplist)
spplist = ifelse(common_name == "striped dolphin", "SPDO", spplist)
spplist = ifelse(common_name == "pygmy sperm whale", "PSWH", spplist)
spplist = ifelse(common_name == "minke whale", "MIWH", spplist)
spplist = ifelse(common_name == "fin Whale", "FIWH", spplist)
spplist = ifelse(common_name == "common dolphin", "UNCD", spplist)
spplist = ifelse(common_name == "north atlantic right Whale", "RIWH", spplist) #same as Right Whale
spplist = ifelse(common_name == "pygmy killer Whale", "PKWH", spplist)
spplist = ifelse(common_name == "shortfinned pilot whale", "SFWH", spplist)
spplist = ifelse(common_name == "longfinned pilot whale", "LFPW", spplist)
spplist = ifelse(common_name == "sowerby's beaked whale", "SBWH", spplist)
spplist = ifelse(common_name == "dwarf sperm whale", "DSWH", spplist)
spplist = ifelse(common_name == "clymene dolphin", "CLDO", spplist)
spplist = ifelse(common_name == "atlantic white-sided dolphin", "WSDO", spplist) #same as white sided dolphin
spplist = ifelse(common_name == "blainville's beaked whale", "BBWH", spplist) 
spplist = ifelse(common_name == "gervais' beaked whale", "GBWH", spplist) 
spplist = ifelse(common_name == "sperm Whale", "SPWH", spplist)
spplist = ifelse(common_name == "killer whale", "KIWH", spplist)
spplist = ifelse(common_name == "pantropical spotted dolphin", "PSDO", spplist)
spplist = ifelse(common_name == "harp seal", "HRPS", spplist)
spplist = ifelse(common_name == "harbor seal", "HASE", spplist)
spplist = ifelse(common_name == "harbor porpoise", "HAPO", spplist)
spplist = ifelse(common_name == "true's beaked whale", "TBWH", spplist) 
spplist = ifelse(common_name == "risso's dolphin", "RIDO", spplist)
spplist = ifelse(common_name == "false killer whale", "FKWH", spplist)
spplist = ifelse(common_name == "mahi mahi", "MAMA", spplist)
spplist = ifelse(common_name == "shark species", "SHAR", spplist)
spplist = ifelse(common_name == "cownose ray", "CNRA", spplist) 
spplist = ifelse(common_name == "unidentified ray species", "UNRA", spplist)
spplist = ifelse(common_name == "unidentified bait fish", "BAIT", spplist) #same as bait ball
spplist = ifelse(common_name == "sunfish", "MOLA", spplist)
spplist = ifelse(common_name == "manta ray", "MARA", spplist)
spplist = ifelse(common_name == "green turtle", "GRTU", spplist)
spplist = ifelse(common_name == "unidentified turtle species", "TURT", spplist)
spplist = ifelse(common_name == "loggerhead turtle", "LOTU", spplist)
spplist = ifelse(common_name == "kemps' ridley turtle", "KRST", spplist)
spplist = ifelse(common_name == "hawksbill turtle", "HATU", spplist)
spplist = ifelse(common_name == "leatherback turtle", "LETU", spplist)

spplist = ifelse(common_name == "unidentified bird species", "UNBI", spplist)      
spplist = ifelse(common_name %in% c("laridae species","larinae species") , "UNGU", spplist) #unidentified Gull??? #typo unidentified Gull???               
spplist = ifelse(common_name == "calidris species", "UNCA", spplist) #new unidentified Calidris              
spplist = ifelse(common_name == "dowitcher species", "DOWI", spplist)              
spplist = ifelse(common_name == "chelonidae species", "UNCH", spplist) #new, unidentified cheloniidae
spplist = ifelse(common_name == "delphinidae species", "UNDO", spplist) #unidentified dolphin           
spplist = ifelse(common_name == "sterna species", "UNTE", spplist) #unidentified tern                
spplist = ifelse(common_name == "stercorarius species", "UNSK", spplist) #unidentified skua      
spplist = ifelse(common_name == "unidentified shorebird species", "SHOR", spplist)
spplist = ifelse(common_name == "phalaropus species", "UNPH", spplist)             
spplist = ifelse(common_name == "hydrobatidae species", "UNSP", spplist) #unidentified storm petrel    
spplist = ifelse(common_name == "unidentified warbler species", "UNWA", spplist)  
spplist = ifelse(common_name == "unidentified raptor species", "UNRP", spplist)  
spplist = ifelse(common_name == "unidentified passerine species", "UNPA", spplist)
spplist = ifelse(common_name == "stenella species", "SPDO", spplist)           
spplist = ifelse(common_name == "sphyrna species", "HASH", spplist) #Hammerhead shark spp.        
spplist = ifelse(common_name == "unidentified elasmobranch", "UNEL", spplist)  
spplist = ifelse(common_name == "stenula species", "ZOOP", spplist)  #zooplankton            
spplist = ifelse(common_name == "thalasseus species", "UNTE", spplist) #unidentified tern    
spplist = ifelse(common_name == "fin whale", "FIWH", spplist)
spplist = ifelse(common_name == "north atlantic right whale", "RIWH", spplist)
spplist = ifelse(common_name == "pygmy killer whale", "PKWH", spplist)       
spplist = ifelse(common_name == "sperm whale", "SPWH", spplist)

spplist = ifelse(spplist == "BlSt", "BNST", spplist)
spplist = ifelse(spplist == "YeNi", "YCNH", spplist)
spplist = ifelse(spplist == "BlNi", "BCNH", spplist)
spplist = ifelse(spplist == "ShDo", "SBDO", spplist) 
spplist = ifelse(spplist == "WhSa", "WRSA", spplist)
spplist = ifelse(spplist == "LiBl", "LBHE", spplist)
spplist = ifelse(spplist == "Wh", "WHIM", spplist)
spplist = ifelse(spplist == "GrBl", "GBHE", spplist)
spplist = ifelse(spplist == "LeSc", "LESC", spplist)
spplist = ifelse(spplist == "PiGr", "PBGR", spplist)
spplist = ifelse(spplist == "ReLo", "RTLO", spplist)
spplist = ifelse(spplist == "ReMe", "RBME", spplist)
spplist = ifelse(spplist == "BlPe", "BCPE", spplist)
spplist = ifelse(spplist == "GrTe", "GWTE", spplist)
spplist = ifelse(spplist == "NoSh", "NSHO", spplist)
spplist = ifelse(spplist == "BlTe", "BWTE", spplist)
spplist = ifelse(spplist == "AmBl", "ABDU", spplist)
spplist = ifelse(spplist == "CaGo", "CANG", spplist)
spplist = ifelse(spplist == "BaSt", "BRSP", spplist)
spplist = ifelse(spplist == "HeGu", "HERG", spplist)
spplist = ifelse(spplist == "AmWh", "AWPE", spplist) 
spplist = ifelse(spplist == "WhTr", "WTTR", spplist)
spplist = ifelse(spplist == "LeSt", "LESP", spplist)
spplist = ifelse(spplist == "BlSt", "BBSP", spplist)
spplist = ifelse(spplist == "SwSt", "SWIS", spplist)
spplist = ifelse(spplist == "EuSt", "EUSP", spplist)
spplist = ifelse(spplist == "FEAS", "FEPE", spplist)
spplist = ifelse(spplist == "ReTr", "RBTR", spplist)
spplist = ifelse(spplist == "TrSw", "TRES", spplist)
spplist = ifelse(spplist == "BaSw", "BANS", spplist)
spplist = ifelse(spplist == "PrWa", "PROW", spplist)
spplist = ifelse(spplist == "ReBl", "RWBL", spplist)
spplist = ifelse(spplist == "BoGr", "BTGR", spplist) 
spplist = ifelse(spplist == "BaSw", "BARS", spplist)
spplist = ifelse(spplist == "RiGu", "RBGU", spplist)
spplist = ifelse(spplist == "LeBl", "LBBG", spplist)
spplist = ifelse(spplist == "GrBl", "GBBG", spplist) 
spplist = ifelse(spplist == "GuTe", "GBTE", spplist)
spplist = ifelse(spplist == "BlWa", "BLBW", spplist)
spplist = ifelse(spplist == "RsTe", "ROST", spplist)
spplist = ifelse(spplist == "RoTe", "ROYT", spplist)
spplist = ifelse(spplist == "LoJa", "LTJA", spplist)
spplist = ifelse(spplist == "SoPo", "SPSK", spplist)
spplist = ifelse(spplist == "WiSt", "WISP", spplist)
spplist = ifelse(spplist == "DoCo", "DCCO", spplist)

# change correct code to uppercase
spplist = toupper(spplist)

# --------------------- #
# added to database
# --------------------- #
# Piping Plover, "PIPL"
# Wilson's Plover, "WIPL"
# Common Moorhen, "COMO"
# Roseate Spoonbill, "ROSP"
# White Ibis, "WHIB"
# Redish Egret, "REEG"
# Tricolored Heron, "TRHE"
# Short-billed Dowitcher, "SBDO"
# American Avocet, "AMAV"
# American White Pelican, "AWPE"
# unidentified elasmobranch, "UNEL"
# black skimmer, "BLSK"
# boat-tailed grackle, "BTGR"
# unidentified raptor species", "UNRP"
# true's beaked whale", "TBWH"
# cownose ray", "CNRA"
# blainville's beaked whale", "BBWH"
# gervais' beaked whale", "GBWH"
# calidris species", "UNCA"

# might need to split up Thalasseus and Sterna (UNTE)

fieldData$species = tolower(fieldData$species)

fieldData = data.frame(cbind(species = common_name, spp_type = spplist), stringsAsFactors = FALSE) %>% distinct %>%
  left_join(fieldData, ., by = "species") %>% rowwise %>% mutate(type = replace(type, is.na(type), spp_type)) %>%
  select(-spp_type) %>% as.data.frame
rm(common_name,spplist, Species_Information, name)

# fixed mixed
toAdd = fieldData[fieldData$ID %in% c("3059"),] 
toAdd$ID = 3059.5 
toAdd$type = "BODO"
toAdd$species = "bottlenose dolphin"
toAdd$behavior = ""
toAdd$number_individuals = 1
toAdd$comments = "added BODO from comments of ID 3059"
fieldData = rbind(fieldData, toAdd); rm(toAdd)
# --------------------------- #

# --------------------------- #
# BEG and END errors
# --------------------------- #

# errors (some were in the middle of transects, rather than at the end)
fieldData$type[fieldData$ID %in% c("590","678","702","710","717","725","731","735",
                                   "733","855","901","999","1060","1076","1191",
                                   "1213", "1297","2873","2911")] = "ENDCNT"
fieldData$type[fieldData$ID %in% c("679","703","711","718","726","732","736","856",
                                   "902","910","1000","1061","1298","1360","2925")] = "BEGCNT"
fieldData$type[fieldData$ID %in% c("1788","2878","2881","2882","2953","3009","3032",
                                   "3033","3034","3035","3036","3037","3038","3039")] = "COMMENT"
# contact provider about ID 3009 (Chon), missing_sp marked yes

# add begin count for pause in transect
toAdd = fieldData[fieldData$ID %in% c("2874"),] 
toAdd$ID = 2873.5     
toAdd$type = "BEGCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added BEGCNT after transect pause"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("2912"),] 
toAdd$ID = 2911.5 
toAdd$type = "BEGCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added BEGCNT after transect pause"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("3032"),] 
toAdd$ID = 3031.5 
toAdd$type = "BEGCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added BEGCNT for chum flyover"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("3049"),] 
toAdd$ID = 3049.5 
toAdd$type = "ENDCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added ENDCNT for chum flyover"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

# --------------------------- #
## GPS
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/@lat"] = "lat"
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/@lon"] = "long"
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/time"] = "date"
GPSdata$platform = tolower(GPSdata$platform)
# --------------------------- # 

# --------------------------- #
# time
fieldData$year_[fieldData$year_ == 11] = 2011
# fix time stamps and 
# add lat and long to observations
df <- data.frame(date = fieldData$obs_time_rd, #satellite_GPS_time,
                 hr = as.numeric(format(fieldData$obs_time_rd, format = "%H")),
                 min = as.numeric(format(fieldData$obs_time_rd, format = "%M")),
                 sec = as.numeric(format(fieldData$obs_time_rd, format = "%S")))
fieldData$date = ISOdatetime(fieldData$year_, fieldData$month_, fieldData$day, df$hr, df$min, df$sec) #Y m d H M S
rm(df)
#df <- data.frame(date = GPSdata$GPS_time_rd,
#                 hr = as.numeric(format(GPSdata$GPS_time_rd , format = "%H")),
#                 min = as.numeric(format(GPSdata$GPS_time_rd , format = "%M")),
#                 sec = as.numeric(format(GPSdata$GPS_time_rd , format = "%S")))
#GPSdata$date = ISOdatetime(GPSdata$year_, GPSdata$month_, GPSdata$day, df$hr, df$min, df$sec) #Y m d H M S
#rm(df)
# --------------------------- # 

# --------------------------- # 
# CREW
fieldData$crew = sub("^\\s+", "", tolower(paste(fieldData$obs_first_name, fieldData$obs_last_name, sep = "_")))
fieldData$crew[fieldData$crew == "allison_mac connell"] = "allison_macconnell"
fieldData$crew[fieldData$crew == "mary jo_barkaszi"] = "maryjo_barkaszi"
fieldData$crew[fieldData$crew == "na_na"] = NA
#fieldData$crew[fieldData$crew == "erik_haney"] = "eric_haney" # probably???????????????????????
fieldData = fieldData %>% select(-obs_first_name, -obs_last_name)
# --------------------------- # 

# --------------------------- # 
# platform
fieldData$platform = tolower(fieldData$platform)
# --------------------------- # 

# --------------------------- # 
# count
names(fieldData)[names(fieldData) == "number_individuals"] = "count"
# --------------------------- # 

# --------------------------- # 
# remove unneccessary fields
fieldData = fieldData %>% select(-Observers, missing_sp, -F26,-obs_time_rd,
                                 -cue_type_start_stop,-start_time_sheet,
                                 -end_time_sheet,-page_number,-page_total)
#
