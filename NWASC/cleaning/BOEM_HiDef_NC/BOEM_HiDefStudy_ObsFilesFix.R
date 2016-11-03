# --------------------------- # 
# fix errors in BOEM HiDef data
#
# created by Kaycee Coleman
# July 2015
# --------------------------- # 

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


## Camera 
# rename 
names(CameraData)[names(CameraData)=="Transect ID"] <- "source_transect_id"
names(CameraData)[names(CameraData)=="Animal ID"] <- "type"

CameraData$animal_age_tx = ""
ind = grep("juv", CameraData$type)
CameraData$animal_age_tx[ind] = "Juvenile"
CameraData$comments = ""
ind = grep("poss", CameraData$type)
CameraData$comments[ind] = paste(CameraData$comments[ind], "possible identification", sep="")

CameraData$original_species_tx = CameraData$type
CameraData$count = 1

## Camera species         
CameraData$type = tolower(CameraData$type)
#CameraData$type[CameraData$type == "large and sterna terns and herring gulls"]
CameraData$type[CameraData$type == "arctic tern"] = "ARTE"                              
#CameraData$type[CameraData$type == "b(poss)"]                                  
CameraData$type[CameraData$type == "bridled tern (poss)"] = "BRTE"            
CameraData$type[CameraData$type %in% c("caspain ten","caspian tern","poss caspian tern")] = "CATE"                            
CameraData$type[CameraData$type %in% c("cattle egret","cattle egret  (poss)","cattle egret (poss)",
                                       "poss cattle egret")] = "CAEG"                      
CameraData$type[CameraData$type %in% c("poss common tern","common tern")] = "COTE"                             
#CameraData$type[CameraData$type =="dark-colored"]                             
#CameraData$type[CameraData$type =="dark dot"]                                
#CameraData$type[CameraData$type %in% c("dolphin","poss dolphin","dolphin?")]                                  
#CameraData$type[CameraData$type =="dolphin/mola mola"] #mahi mahi or mola mola/ocean sunfish                       
CameraData$type[CameraData$type %in% c("egret","poss egret")] = "UNEG"                                   
CameraData$type[CameraData$type %in% c("fish?","poss fish")] = "FISH"                                   
CameraData$type[CameraData$type =="great black-backed gull"] = "GBBG"                  
CameraData$type[CameraData$type %in% c("great egret", "poss great egret")] = "GREG"                            
CameraData$type[CameraData$type %in% c("gull","gull (poss)","gull sp","gulls","poss gull")] = "UNGU"                                    
CameraData$type[CameraData$type %in% c("hammerhead","hammerhead?")] = "HASH"                              
CameraData$type[CameraData$type %in% c("poss hawksbill","hawksbill")] = "HATU"                              
CameraData$type[CameraData$type %in% c("heron","poss heron")] = "UNHE"                                    
CameraData$type[CameraData$type %in% c("herring gull","herring gull poss","juv herring gull","juv herring guul",
                                       "poss herring gull")] = "HERG"                          
CameraData$type[CameraData$type %in% c("large tern","large tern (poss)")] = "UNLT"                      
CameraData$type[CameraData$type %in% c(" laughing gull","laughing gull","laughing gull ","laughing gull (poss)",
                                       "laughing gulls","lauging gull","poss laughing gull")] = "LAGU"                             
CameraData$type[CameraData$type =="leatherback"] = "LETU"                           
CameraData$type[CameraData$type =="lesser black-backed gull"] = "LBBG"                 
CameraData$type[CameraData$type %in% c("loggerhead","loggerhead (poss)","turtle poss loggerhead",
                                       "poss loggerhead")] = "LOTU"                        
CameraData$type[CameraData$type =="magnificent frigatebird"] = "MAFR"                
CameraData$type[CameraData$type =="mahimahi"] = "MAMA"                                 
CameraData$type[CameraData$type =="mola mola"] = "MOLA"                                
CameraData$type[CameraData$type %in% c("northern gannet?","poss northern gannet")] = "NOGA"                        
CameraData$type[CameraData$type %in% c("osprey","poss osprey")] = "OSPR"                                   
CameraData$type[CameraData$type %in% c("oyster catcher","oystercatcher")] = "AMOY"                            
CameraData$type[CameraData$type %in% c("brown pelican","brown pelican (poss)","pelican-brown","pelican - brown",
                                       "poss brown pelican","juv brown pelican","poss pelican-brown")] = "BRPE"                         
CameraData$type[CameraData$type %in% c("poss. bird", "poss bird")] = "UNBI"                              
CameraData$type[CameraData$type =="poss black scoter"] = "BLSC"                      
CameraData$type[CameraData$type =="poss bt grackle"] = "BTGR"                          
CameraData$type[CameraData$type =="poss cormorant"] = "UNCO"                      
CameraData$type[CameraData$type =="poss duck"] = "UNDU"  
CameraData$type[CameraData$type =="poss gb heron"] = "GBHE"                           
#CameraData$type[CameraData$type =="poss green"]                              
CameraData$type[CameraData$type %in% c("poss green turtle","green turtle")] = "GRTU"                        
CameraData$type[CameraData$type %in% c("poss kemp's ridley","poss kemps","kemps")] = "KRST"                               
CameraData$type[CameraData$type =="poss pelican"] = "PELI"                            
CameraData$type[CameraData$type =="poss petrel"] = "UNPE"                            
CameraData$type[CameraData$type =="poss red-winged blackbird"] = "RWBL"                       
CameraData$type[CameraData$type =="poss shearwater"] = "UNSH"                       
CameraData$type[CameraData$type =="poss shorebird sanderling"] = "SAND"               
CameraData$type[CameraData$type %in% c("poss shorebird","poss small shorebird", "poss small shorebirds",
                                       "mixed shorebird flock")] = "SHOR"                   
CameraData$type[CameraData$type =="poss spotted dolphin"] = "SPDO"                     
CameraData$type[CameraData$type =="possible kestrel"] = "AMKE"                        
CameraData$type[CameraData$type =="ray"] = "UNRA"                                     
#CameraData$type[CameraData$type =="red throated diver"]                       
CameraData$type[CameraData$type %in% c("royal tern","royal tern ","royal tern (poss)","royal terns","tern - royal",
                                       "poss royal tern")] = "ROYT"                              
CameraData$type[CameraData$type %in% c("sandwich tern", "sandwich tern poss")] = "SATE"
CameraData$type[CameraData$type %in% c("scoter","poss scoter")] = "UNSC"                                 
CameraData$type[CameraData$type %in% c("sea turtle","poss sea turtle","turtle","poss turtle")] = "TURT"                               
CameraData$type[CameraData$type %in% c("shark","shark?","poss shark")] = "SHAR"                                   
CameraData$type[CameraData$type %in% c("small tern","small tern (poss)","poss small tern")] = "UNST"                       
CameraData$type[CameraData$type %in% c("sooty tern","sooty tern (poss)","poss sooty tern")] = "SOTE"                       
CameraData$type[CameraData$type %in% c("sterna sp","sterna tern","sterna tern (poss)","tern sterna",
                                       "tern sterna poss","poss sterna tern","tern","tern (poss)",
                                       "terns","poss tern")] = "UNTE"                       
CameraData$type[CameraData$type %in% c("storm-petrel?","storm petrel")] = "UNSP"                           
CameraData$type[CameraData$type %in% c("tricolored heron","poss tricolor heron")] = "TRHE"                         
CameraData$type[CameraData$type %in% c("unknown","unknown ","debris or pelican sitting down?")] = "UNKN"                                
CameraData$type[CameraData$type =="whale?"] = "UNWH"                                  
CameraData$type[CameraData$type =="white ibis"] = "WHIB"                              
#CameraData$type[CameraData$type %in% c("white tip?","whitetip","whitetip?")]  


# remove duplicates
ind = grep(")", CameraData$Animal)
duplicates = CameraData[ind,]
#CameraData = CameraData[!ind,]
# --------------------------- # 


# --------------------------- # 
# added to database
# --------------------------- # 
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

spplist = toupper(spplist) # change correct code to uppercase
fieldData$species = tolower(fieldData$species)

fieldData = data.frame(cbind(species = common_name, spp_type = spplist), stringsAsFactors = FALSE) %>% distinct %>%
  left_join(fieldData, ., by = "species") %>% rowwise %>% mutate(type = replace(type, is.na(type), spp_type)) %>%
  as.data.frame
# fix 'type' where wrongfully coded as BEG/END count due to key words in comments
fieldData$type[which(fieldData$type != fieldData$spp_type)] = fieldData$spp_type[which(fieldData$type != fieldData$spp_type)]
rm(common_name,spplist, Species_Information, name)
fieldData = fieldData %>% select(-spp_type)

# from comments 
fieldData$type[fieldData$ID == "1994"] = "BAIT"

# fixed mixed
toAdd = fieldData[fieldData$ID %in% c("3059"),] 
toAdd$ID = "3059.5" 
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
# some of these will have already been fixed by the addition of more words in the starts/ends queries
fieldData$type[fieldData$ID %in% c("590","678","702","710","717","725","731","733","735","855","901","999",
                                   "1060","1076","1191","1213","1297","2061","2075","2483",
                                   "2517","2519","2521","2523","2525","2527","2530","2532",
                                   "2532","2534","2534","2536","2538","2540","2544","2546",
                                   "2546","2548","2548","2550","2550","2552","2552","2554",
                                   "2554","2556","2556","2558","2560","2560","2564","2568",
                                   "2571","2573","2576","2579","2581","2584","2586","2588",
                                   "2632","2634","2636","2639","2641","2643","2646","2652",
                                   "2654","2656","2658","2663","2669","2671","2676","2680","2683",
                                   "2873","2911")] = "ENDCNT"
fieldData$type[fieldData$ID %in% c("679","703","711","718","726","732","736","856","902","910",
                                   "1000","1061","1298","1360","2145","2467","2551","2565",
                                   "2574","2582","2631","2652","2925")] = "BEGCNT"
fieldData$type[fieldData$ID %in% c("728","729","756","757","773","1788","1802","1803","1805",
                                   "1812","1813","1820","1831","1834","1914","1951","1952",
                                   "1955","1962","1984","2114","2133","2255","2256","2470",
                                   "2502","2516","2518","2520","2522","2524","2526","2528",
                                   "2529","2531","2533","2535","2537","2539","2541","2542",
                                   "2545","2547","2549","2553","2555","2557","2559","2561",
                                   "2563","2565","2569","2572","2577","2580","2585","2586",
                                   "2587","2633","2635","2637","2640","2642","2647","2648",
                                   "2652","2655","2657","2659","2664","2670","2672","2677","2681",
                                   "2683","2799","2800","2801","2802","2803","2804","2878",
                                   "2881","2882","2953","3009","3032","3033","3034","3035",
                                   "3036","3037","3038","3039")] = "COMMENT"


# contact provider about ID 3009 (Chon), missing_sp marked yes

# check if event #1 == BEGCNT
#unique(sort(fieldData$type[fieldData$event_number == 1]))
fieldData$type[fieldData$event_number == 1 & fieldData$type == "COMMENT"] = "BEGCNT" # correct comments that should be BEGCNT
#fieldData[fieldData$event_number == 1 & fieldData$type != "BEGCNT",]
# --------------------------- # 


# --------------------------- # 
# add begin count for pause in transect
# --------------------------- # 
toAdd = fieldData[fieldData$ID %in% c("2023"),] 
toAdd$ID = "2022.5"     
toAdd$type = "BEGCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added BEGCNT"
toAdd$offline = 1
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("2026"),] 
toAdd$ID = "2026.5"     
toAdd$type = "ENDCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added ENDCNT"
toAdd$offline = 1
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("2644"),] 
toAdd$ID = "2643.5"     
toAdd$type = "BEGCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added BEGCNT"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("2874"),] 
toAdd$ID = "2873.5"     
toAdd$type = "BEGCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added BEGCNT after transect pause"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("2912"),] 
toAdd$ID = "2911.5" 
toAdd$type = "BEGCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added BEGCNT after transect pause"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

#toAdd = fieldData[fieldData$ID %in% c("3032"),] 
#toAdd$ID = "3031.5" 
#toAdd$type = "BEGCNT"
#toAdd$species = ""
#toAdd$behavior = ""
#toAdd$number_individuals = ""
#toAdd$comments = "added BEGCNT for chum flyover"
#fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("3049"),] 
toAdd$ID = "3049.5" 
toAdd$type = "ENDCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added ENDCNT for chum flyover"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("2131"),] 
toAdd$ID = "2131.5" 
toAdd$type = "ENDCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added ENDCNT"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("2562"),] 
toAdd$ID = "2562.5" 
toAdd$type = "ENDCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added ENDCNT"
fieldData = rbind(fieldData, toAdd); rm(toAdd)

toAdd = fieldData[fieldData$ID %in% c("2653"),] 
toAdd$ID = "2652.5" 
toAdd$type = "BEGCNT"
toAdd$species = ""
toAdd$behavior = ""
toAdd$number_individuals = ""
toAdd$comments = "added BEGCNT"
fieldData = rbind(fieldData, toAdd); rm(toAdd)
# --------------------------- # 

# --------------------------- #
# fieldData time
# --------------------------- # 
fieldData$"year_"[fieldData$"year_" == 11] = 2011
# fix time stamps and 
# add lat and long to observations
df <- data.frame(date = fieldData$obs_time_rd, 
                 hr = as.numeric(format(fieldData$obs_time_rd, format = "%H")),
                 min = as.numeric(format(fieldData$obs_time_rd, format = "%M")),
                 sec = as.numeric(format(fieldData$obs_time_rd, format = "%S"))) #satellite_GPS_time,
fieldData = rename(fieldData, year = year_, month = month_)
fieldData$obs_dt = ISOdatetime(fieldData$year, fieldData$month, fieldData$day, df$hr, df$min, df$sec) #Y m d H M S
rm(df)
# --------------------------- # 


# --------------------------- # 
# CREW
# --------------------------- # 
fieldData$observers = sub("^\\s+", "", tolower(paste(fieldData$obs_first_name, fieldData$obs_last_name, sep = "_")))
fieldData$observers[fieldData$observers == "allison_mac connell"] = "allison_macconnell"
fieldData$observers[fieldData$observers == "mary jo_barkaszi"] = "maryjo_barkaszi"
fieldData$observers[fieldData$observers == "na_na"] = NA
#fieldData$crew[fieldData$crew == "erik_haney"] = "eric_haney" # probably???????????????????????
# --------------------------- # 


# --------------------------- # 
# platform
# --------------------------- # 
fieldData$platform = tolower(fieldData$platform)
# --------------------------- # 


# --------------------------- # 
# count
# --------------------------- # 
names(fieldData)[names(fieldData) == "number_individuals"] = "count"
# --------------------------- # 


# --------------------------- # 
# remove unneccessary and/or unused fields
# --------------------------- # 
names(fieldData)[names(fieldData) == "Data-sheet ID"] = "DataSheet_ID"
names(fieldData)[names(fieldData) == "Start Transect"] = "Stransect"
names(fieldData)[names(fieldData) == "End Transect"] = "Etransect"
names(fieldData)[names(fieldData) == "Transect ID"] = "source_transect_id"
fieldData = fieldData %>% select(-Observers, -missing_sp, -F26, -obs_time_rd,
                                 -cue_type_start_stop, -start_time_sheet,
                                 -end_time_sheet, -page_number, -page_total,
                                 -DataSheet_ID, -Stransect, -Etransect,
                                 -obs_first_name, -obs_last_name)
# --------------------------- # 


# --------------------------- # 
# split data before fixing transects
# --------------------------- # 
fieldData = fieldData %>% rename(original_species_tx = species, distance_to_animal = distance) %>% 
  select(-year,-month,-day,-satellite_GPS_time) %>%
  mutate(travel_direction = replace(travel_direction, travel_direction=="n/a", NA), 
         travel_direction = toupper(travel_direction))

boatObs = fieldData[fieldData$platform=="voyager",] %>% arrange(ID, obs_dt)
planeObs = fieldData[fieldData$platform=="vplane",] %>% arrange(ID, obs_dt)
#rm(fieldData)
# --------------------------- # 


# --------------------------- # 
# fix transects where NA
# --------------------------- # 
#boatObs$source_transect_id[boatObs$type == "BEGCNT"]
#boatObs$source_transect_id[boatObs$type == "ENDCNT"]

# all happened in the same month and year so can sort by day since date has time
#boatObs %>% mutate(key = paste(day,observers,sep="_")) %>% 
#                     select(key, day,observers,type,source_transect_id,comments,ID,obs_dt) %>% group_by(key) #%>% 
                     #summarise(tran = median(source_transect_id, na.rm = TRUE))

boatObs = boatObs[-(which(boatObs$ID %in% c(2114,2528))),] # remove duplicate


# Cant use fill since most of the BEGCNTs are NA
old = boatObs$source_transect_id
boatObs$source_transect_id[boatObs$ID %in% c(2118:2121,2124,2522:2524,2516:2518)] = 9
boatObs$source_transect_id[boatObs$ID %in% c(2132:2136,2519:2520,2525,2526:2527,2521)] = 10
boatObs$source_transect_id[boatObs$ID %in% c(2160:2178,2534,2535,2536,2529,2530)] = 20
boatObs$source_transect_id[boatObs$ID %in% c(2179:2182,2537,2531)] = 21
boatObs$source_transect_id[boatObs$ID %in% c(2565,2568,2559,2560)] = 32
boatObs$source_transect_id[boatObs$ID %in% c(2569:2570,2561,2499:2511)] = 33
boatObs$source_transect_id[boatObs$ID %in% c(2574,2582)] = 38
boatObs$source_transect_id[boatObs$ID %in% c(2467:2482)] = 39
boatObs$source_transect_id[boatObs$ID %in% c(2869,2914)] = 48
boatObs$source_transect_id[boatObs$ID %in% c(2894)] = 49
boatObs$source_transect_id[boatObs$ID %in% c(2659,2663,2672,2676)] = 52
boatObs$source_transect_id[boatObs$ID %in% c(2670,2681)] = 53

#boatObs$comments[boatObs$source_transect_id != old] = paste(boatObs$comments[boatObs$source_transect_id != old],
#                                                            "; changed TRANSECT from ",
#                                                            old[boatObs$source_transect_id != old], sep = "")

# possibly???????
#boatObs$offline[boatObs$ID %in% c(2791:2805,2656,2657,2648,2877:2893,3049.5,3032:3039,2677:2680,2664:2669,2188:2253)] = 2
# it seems that offline points dont have GPS points assosiated with them
# --------------------------- # 

# --------------------------- #
# fix plane errors
# --------------------------- #
planeObs$type[planeObs$ID %in% c(756, 773, 1914, 1962,728, 1805, 1820, 1831)] = "ENDCNT"
planeObs$type[planeObs$ID %in% c(1788, 1803, 1813)] = "COMMENT"
planeObs$type[planeObs$ID == 733] = "ROYT"

planeObs$offline[planeObs$ID %in% c(1820, 1256, 1831, 1914)] = 0 

planeObs$source_transect_id[planeObs$ID == 2782] = 42
planeObs$source_transect_id[planeObs$ID == 2786] = 43
planeObs$source_transect_id[planeObs$ID == 2811] = 46
# --------------------------- # 

# --------------------------- #
# mark chumming as offline
# --------------------------- # 
boatObs$comments = tolower(boatObs$comments)
ind = grep("chum", boatObs$comments)
boatObs$chum = 0
boatObs$chum[ind] = 1
ind = c(2680,2669,2656,2641,2576,2579,2588,2634,2552,2554,2556,2558, 2136,2562.5,2571)
boatObs$chum[boatObs$ID %in% ind] = 1
boatObs$comments[boatObs$ID %in% ind] = paste(boatObs$comments[boatObs$ID %in% ind], "; chum", sep="")

# fill in inbetween BEG and END
ind = filter(boatObs, type == "BEGCNT")
ind$segment = seq.int(nrow(ind))
boatObs = left_join(boatObs, select(ind, segment, ID), by="ID") %>% as.data.frame %>% 
  mutate(segment = na.locf(segment)) %>% group_by(segment) %>% 
  mutate(chum = ifelse(chum[1] == 1, 1, 0)) %>% as.data.frame

# mark when aerial obs happened after chumming
planeObs$comments = tolower(planeObs$comments)
ind = grep("chum", planeObs$comments)
planeObs$chum = 0
planeObs$chum[ind] = 1

ind = c(1255, 2773:2776, 2083, 2084)
planeObs$chum[planeObs$ID %in% ind] = 1
planeObs$comments[planeObs$ID %in% ind] = paste(planeObs$comments[planeObs$ID %in% ind], "; chum", sep="")

# mark chumming as offline
planeObs$offline[planeObs$chum == 1] = 1

test = left_join(planeObs, select(boatObs, chum, obs_dt), by="obs_dt") %>% as.data.frame 
  

# --------------------------- # 


# --------------------------- #
## GPS
# --------------------------- # 
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/@lat"] = "lat"
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/@lon"] = "long"
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/time"] = "time"
GPSdata$platform = tolower(GPSdata$platform)

df <- data.frame(date = GPSdata$GPS_time_rd, 
                 hr = as.numeric(format(GPSdata$GPS_time_rd, format = "%H")),
                 min = as.numeric(format(GPSdata$GPS_time_rd, format = "%M")),
                 sec = as.numeric(format(GPSdata$GPS_time_rd, format = "%S")))
GPSdata$obs_dt = ISOdatetime(GPSdata$year_, GPSdata$month_, GPSdata$day, df$hr, df$min, df$sec) #Y m d H M S
rm(df)

# take lat and lon from GPS
GPSdata2 = GPSdata %>% filter(platform=="voyager") %>% select(lat, long, time, obs_dt) 
test.b = left_join(boatObs,GPSdata2,by="obs_dt")
#test = right_join(GPSdata2,boatObs,by="obs_dt")

GPSdata2 = GPSdata %>% filter(platform=="vplane") %>% select(lat, long, time, obs_dt) 
test.p = left_join(planeObs,GPSdata2,by="obs_dt")
# --------------------------- # 


# --------------------------- # 
# Camera data
# --------------------------- # 
# add lat/lon
test = CameraData %>% rename(Time = Timestamp) %>%
  inner_join(., select(GPSdata,-Altitude,-ID), by = c("Date","Time"))
# --------------------------- # 
