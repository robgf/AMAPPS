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
#db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
#name = sqlFetch(db, "lu_species")
#odbcCloseAll()

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

CameraData$original_species_tx = paste(CameraData$type, CameraData$Animal, sep = "; ")
CameraData$count = 1

## Camera species         
CameraData$type = tolower(CameraData$type)
CameraData$type[CameraData$type == "large and sterna terns and herring gulls"] = "GUTE" #unid small gull or tern
CameraData$type[CameraData$type == "arctic tern"] = "ARTE"                              
CameraData$type[CameraData$type == "bridled tern (poss)"] = "BRTE"            
CameraData$type[CameraData$type %in% c("caspain ten","caspian tern","poss caspian tern")] = "CATE"                            
CameraData$type[CameraData$type %in% c("cattle egret","cattle egret  (poss)","cattle egret (poss)",
                                       "poss cattle egret")] = "CAEG"                      
CameraData$type[CameraData$type %in% c("poss common tern","common tern")] = "COTE"                             
CameraData$type[CameraData$type %in% c("dolphin","poss dolphin","dolphin?")] = "UNDO"                                  
CameraData$type[CameraData$type %in% c("egret","poss egret")] = "UNEG"                                   
CameraData$type[CameraData$type %in% c("fish?","poss fish","dolphin/mola mola")] = "FISH"                                   
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
CameraData$type[CameraData$type %in% c("poss. bird", "poss bird","dark-colored","b(poss)")] = "UNBI"                              
CameraData$type[CameraData$type =="poss black scoter"] = "BLSC"                      
CameraData$type[CameraData$type =="poss bt grackle"] = "BTGR"                          
CameraData$type[CameraData$type =="poss cormorant"] = "UNCO"                      
CameraData$type[CameraData$type =="poss duck"] = "UNDU"  
CameraData$type[CameraData$type =="poss gb heron"] = "GBHE"                           
CameraData$type[CameraData$type %in% c("poss green turtle","green turtle","poss green")] = "GRTU"                        
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
CameraData$type[CameraData$type =="red throated diver"] = "RTLO"                       
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
CameraData$type[CameraData$type %in% c("unknown","unknown ","debris or pelican sitting down?","dark dot")] = "UNKN"                                
CameraData$type[CameraData$type =="whale?"] = "UNWH"                                  
CameraData$type[CameraData$type =="white ibis"] = "WHIB"                              
CameraData$type[CameraData$type %in% c("white tip?","whitetip","whitetip?")] = "OWTS"  

# add generics based of "Animal" column
CameraData$type[CameraData$ID == 293] = "TURT" 
CameraData$type[CameraData$ID == 1808] = "SHAR" 
CameraData$type[CameraData$ID == 1991] = "UNRA" 
CameraData$type[CameraData$ID == 3076] = "UNBI" 

# remove duplicates
ind = c(grep(")", CameraData$Animal),grep("-", CameraData$Animal))
duplicates = CameraData[ind,]
CameraData = CameraData[-ind,]
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

fieldData = data.frame(cbind(species = common_name, spp_type = spplist), stringsAsFactors = FALSE) %>% 
  distinct %>% left_join(fieldData, ., by = "species") %>% rowwise %>% 
  mutate(type = replace(type, is.na(type), spp_type)) %>%
  as.data.frame
# fix 'type' where wrongfully coded as BEG/END count due to key words in comments
fieldData$type[which(fieldData$type != fieldData$spp_type)] = fieldData$spp_type[which(fieldData$type != fieldData$spp_type)]
rm(common_name,spplist, Species_Information)
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
fieldData$date_time = ISOdatetime(fieldData$year, fieldData$month, fieldData$day, df$hr, df$min, df$sec) #Y m d H M S
rm(df)

names(fieldData)[names(fieldData) == "Start Transect"] = "Stransect"
names(fieldData)[names(fieldData) == "End Transect"] = "Etransect"
names(fieldData)[names(fieldData) == "Transect ID"] = "source_transect_id"
names(fieldData)[names(fieldData) == "Data-sheet ID"] = "DatasheetID"
names(fieldData)[names(fieldData) == "number_individuals"] = "count"

fieldData$platform = tolower(fieldData$platform)
# --------------------------- # 


# --------------------------- # 
# CREW
# --------------------------- # 
fieldData$observers = sub("^\\s+", "", tolower(paste(fieldData$obs_first_name, fieldData$obs_last_name, sep = "_")))
fieldData$observers[fieldData$observers == "allison_mac connell"] = "allison_macconnell"
fieldData$observers[fieldData$observers == "mary jo_barkaszi"] = "maryjo_barkaszi"
fieldData$observers[fieldData$observers == "na_na"] = NA
fieldData$observers[fieldData$observers == "erik_haney"] = "eric_haney" 

## change to initials to protect PII
fieldData$observers[fieldData$observers == "allison_macconnell"] = "AM"    
fieldData$observers[fieldData$observers == "caleb_gordon"] = "CG"          
fieldData$observers[fieldData$observers == "christy_harrington"]= "CH"    
fieldData$observers[fieldData$observers == "david_hartgrove"] = "DH"       
fieldData$observers[fieldData$observers == "eric_haney"] = "EH"           
fieldData$observers[fieldData$observers == "julia_willmott"] = "JW"        
fieldData$observers[fieldData$observers == "maryjo_barkaszi"] = "MB"       
fieldData$observers[fieldData$observers == "mitchell_harris"]= "MH"      
fieldData$observers[fieldData$observers == "rachel_hardee"] = "RaH"         
fieldData$observers[fieldData$observers == "richard_holt"] = "RiH"          
fieldData$observers[fieldData$observers == "wes_biggs"] = "WB"

# mixed obs
fieldData$observers[fieldData$observers == "haney_biggs"] = "EH/WB" 
fieldData$observers[fieldData$observers == "willmott_biggs/gordon"] = "JW/WB/CG"
fieldData$observers[fieldData$observers %in% c("julia_gordon","willmott_gordon")] = "JW/CG"

fieldData = select(fieldData, -obs_first_name, -obs_last_name, -Observers)
# --------------------------- # 


# --------------------------- # 
# split data before fixing transects
# --------------------------- # 
fieldData = fieldData %>% mutate(original_species_tx = paste(species, DatasheetID, sep = "; ")) %>%
  rename(distance_to_animal = distance) %>% 
  select(-year,-month,-day,-satellite_GPS_time, -obs_time_rd, -species, -DatasheetID, -F26) %>%
  mutate(travel_direction = replace(travel_direction, travel_direction=="n/a", NA), 
         travel_direction = toupper(travel_direction))
fieldData$original_species_tx[fieldData$original_species_tx %in% c("NA; NA","NA; 0")] = NA

boatObs = fieldData[fieldData$platform=="voyager",] %>% arrange(ID, date_time)
planeObs = fieldData[fieldData$platform=="vplane",] %>% arrange(ID, date_time)
rm(fieldData)
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
#old = boatObs$source_transect_id
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

#boatObs$comments[!boatObs$source_transect_id %in% old] = paste(boatObs$comments[boatObs$source_transect_id != old],
#                                                            "; changed TRANSECT from ",
#                                                            old[boatObs$source_transect_id != old], sep = "")
# possibly???????
#boatObs$offline[boatObs$ID %in% c(2791:2805,2656,2657,2648,2877:2893,3049.5,3032:3039,2677:2680,2664:2669,2188:2253)] = 2
# it seems that offline points dont have GPS points assosiated with them
# --------------------------- # 

# --------------------------- #
# fix plane type and transect errors
# --------------------------- #
planeObs$type[planeObs$ID %in% c(756, 773, 1914, 1962,728, 1805, 1820, 1831)] = "ENDCNT"
planeObs$type[planeObs$ID %in% c(1788, 1803, 1813)] = "COMMENT"
planeObs$type[planeObs$ID == 733] = "ROYT"

planeObs$offline[planeObs$ID %in% c(1820, 1256, 1831, 1914)] = 0 
planeObs$offline[planeObs$ID %in% c(2023,2025,2026)]=1

planeObs$source_transect_id[planeObs$ID %in% c(1840,1793,558)] = 1
planeObs$source_transect_id[planeObs$ID == 559] = 2
planeObs$source_transect_id[planeObs$ID %in% c(1851,1801,469,468,467,568)] = 4
planeObs$source_transect_id[planeObs$ID %in% c(1864,1833,1888,543)] = 8
planeObs$source_transect_id[planeObs$ID %in% c(1912,1914,573)]=11
planeObs$source_transect_id[planeObs$ID %in% c(1969,1941,818,973,974)] = 22
planeObs$source_transect_id[planeObs$ID %in% c(1051,1955,1962,1980,1987,889,909)] = 25
planeObs$source_transect_id[planeObs$ID %in% c(1028,1029,1979)] = 24
planeObs$source_transect_id[planeObs$ID %in% c(1237:1249,1290:1297,2033,2051)] = 28
planeObs$source_transect_id[planeObs$ID == 2052] = 29
planeObs$source_transect_id[planeObs$ID == 2073] = 34
planeObs$source_transect_id[planeObs$ID %in% c(2724,2733)] = 40
planeObs$source_transect_id[planeObs$ID %in% c(2726,2734)] = 41
planeObs$source_transect_id[planeObs$ID == 2782] = 42
planeObs$source_transect_id[planeObs$ID == 2786] = 43
planeObs$source_transect_id[planeObs$ID %in% c(2838,2854,2811)] = 46
planeObs$source_transect_id[planeObs$ID == 2977] = 50
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
boatObs$offline[boatObs$chum == 1] = 1
boatObs$offline[boatObs$offline != 1 & boatObs$chum == 0] = 0
boatObs = select(boatObs, -chum)

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
planeObs$offline[planeObs$ID == 1805] = 0 # endcount to go offline
planeObs$offline[planeObs$offline != 1 & planeObs$chum == 0] = 0
# --------------------------- # 


# --------------------------- #
## GPS
# --------------------------- # 
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/@lat"] = "lat"
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/@lon"] = "long"
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/time"] = "time"
GPSdata$platform = tolower(GPSdata$platform)

df <- data.frame(date = GPSdata$time, 
                 hr = as.numeric(format(GPSdata$time, format = "%H")),
                 min = as.numeric(format(GPSdata$time, format = "%M")),
                 sec = as.numeric(format(GPSdata$time, format = "%S")))
GPSdata$date_time = ISOdatetime(GPSdata$year_, GPSdata$month_, GPSdata$day, df$hr, df$min, df$sec) #Y m d H M S
rm(df)
GPSdata = select(GPSdata, -time, -GPS_time_rd)

# creat function to find closets timestamp
#require(data.table) 
closest.time.point = function(time, reference.time, n) { 
  # where time is a scalar and reference.time is a vector
  # n is the amount of seconds you want to be closest to (ex. 120 for two min, <5, etc.)
  # less than 5 min, and still transect start and stop locations are missing in GPSdata
  x = ifelse(any(abs(difftime(time, reference.time, units="secs"))<=n),
             which.min(abs(difftime(time, reference.time))),
             NA)
  return(x)
}

# find closest lat and lon from GPS
boatGPS = GPSdata[GPSdata$platform=="voyager",]
planeGPS = GPSdata[GPSdata$platform=="vplane",]

planeObs  = planeObs %>% 
  mutate(date_time = as.POSIXct(date_time,format="%Y-%m-%d %H:%M:%S")) %>% rowwise %>% 
  mutate(ind = closest.time.point(date_time, GPSdata$date_time, 5)) %>% as.data.frame %>%
  mutate(lat = GPSdata$lat[ind], 
         lon = GPSdata$long[ind]) %>% select(-ind)

boatObs  = boatObs %>% 
  mutate(date_time = as.POSIXct(date_time,format="%Y-%m-%d %H:%M:%S")) %>% rowwise %>% 
  mutate(ind = closest.time.point(date_time, GPSdata$date_time, 180)) %>% as.data.frame %>%
  mutate(lat = GPSdata$lat[ind], 
         lon = GPSdata$long[ind]) %>% select(-ind)
# --------------------------- # 


# --------------------------- # 
# make boat and plane transect tables
# --------------------------- # 
boatTransects = boatObs %>% mutate(source_transect_id = paste(source_transect_id, observers, sep="_")) %>%
  group_by(source_transect_id) %>% filter(row_number()==1 | row_number()==n()) %>% as.data.frame %>%
  select(date_time, type, source_transect_id, lat, lon) %>% 
  filter(type %in% c("BEGCNT","ENDCNT")) %>% group_by(source_transect_id) %>%
  summarize(start_dt = first(date_time), end_dt = last(date_time),
            start_lat = first(lat), end_lat = last(lat),
            start_lon = first(lon), end_lon = last(lon)) %>% as.data.frame %>% arrange(start_dt)

planeTransects = planeObs %>% mutate(source_transect_id = paste(source_transect_id, observers, sep="_")) %>%
  group_by(source_transect_id) %>% filter(row_number()==1 | row_number()==n()) %>% as.data.frame %>%
  select(date_time, type, source_transect_id, lat, lon) %>% 
  filter(type %in% c("BEGCNT","ENDCNT")) %>% group_by(source_transect_id) %>%
  summarize(start_dt = first(date_time), end_dt = last(date_time),
            start_lat = first(lat), end_lat = last(lat),
            start_lon = first(lon), end_lon = last(lon)) %>% as.data.frame %>% arrange(start_dt)
# --------------------------- # 


# --------------------------- # 
# Camera data
# --------------------------- # 
# time errors
CameraData$Timestamp = as.character(CameraData$Timestamp)
CameraData$Timestamp[CameraData$ID == 3356] = "13:59:47:508.226" #13:5:47:508.226
CameraData$Timestamp[CameraData$ID == 3620] = "14:16:03:651.146" #14:16::03:651.146
CameraData$Timestamp[CameraData$ID == 3621] = "14:16:03:651.146" #14:16::03:651.146
CameraData$Timestamp[CameraData$ID == 3022] = "13:37:50:516.867" #13:37:50:516.867 error in date time, odd, trying to recopy the time in hopes to not fix it later

CameraGPSdata =  mutate(CameraGPSdata, date_time = paste(Date, substr(Time, 1, 8), sep = " "))
CameraGPSdata = CameraGPSdata[duplicated(CameraGPSdata$date_time)==FALSE,]
CameraData = CameraData %>% dplyr::rename(Time = Timestamp)  %>% 
  mutate(date_time = paste(Date, substr(Time, 1, 8), sep = " ")) 

#CameraData$Timestamp[CameraData$ID == 680] #NA unknown
#CameraData$Timestamp[CameraData$ID == 212] #NA unknown
#CameraData$Timestamp[CameraData$ID == 1873] #NA unknown
#CameraData$Timestamp[CameraData$ID == 2004]  #NA unknown
  
# add lat/lon
CameraGPSdata = CameraGPSdata %>% mutate(date_time = as.POSIXct(date_time,format="%Y-%m-%d %H:%M:%S"))
#test = left_join(CameraData, select(CameraGPSdata,-Altitude,-ID, -Time, -Date), by = "date_time")

# if location is still NA, find closest observation (within a few seconds)
CameraData  = CameraData %>% 
  mutate(date_time = as.POSIXct(date_time,format="%Y-%m-%d %H:%M:%S")) %>% rowwise %>% 
  mutate(ind = closest.time.point(date_time, CameraGPSdata$date_time, 120)) %>% as.data.frame %>%
  mutate(lat = CameraGPSdata$Latitude[ind], 
         lon = CameraGPSdata$Longitude[ind]) %>% select(-ind)

# --------------------------- # 


# --------------------------- # 
# Camera transect from report
CameraTransect = as.data.frame(matrix(ncol=12, nrow=110, data = NA))
names(CameraTransect) = c("date", "segment_type", "start_tm", "end_tm", "location", "altitude_m", "resolution_cm", 
                          "swath_width_m", "polarizer", "gyrostabilizer", "camera_angle_d", "camera")
CameraTransect$date = c(rep("2011-05-11", 12),rep("2011-05-12", 9),rep("2011-05-13", 10),rep("2011-05-14", 6),
                        rep("2011-05-15", 11), rep("2011-05-16",11), rep("2011-05-17",9),rep("2011-05-18", 27),
                        rep("2011-05-19",9),rep("2011-05-20",6))
CameraTransect$camera_angle_d = c(rep(0, 3), rep(15, 15), rep(44, 3), rep(15, 13),
                                  rep(44, 25), NA, NA, rep(15, 21), rep(44, 28))
CameraTransect$camera = c(rep("area-scan",104),rep("line-scan",6))
CameraTransect$gyrostabilizer = c(rep("no", 59), NA, NA, rep("yes", 49))
CameraTransect$polarizer = c(rep("yes", 7),rep("no", 5), rep("yes", 6),
                             rep("no", 36), rep("yes", 5), NA, NA, rep("no", 49))
CameraTransect$location = c("docks","coast","offshore","docks","offshore","chum boat","offshore","coast",
                            "docks", rep("coast",3),"ocean and docks","coast","docks","offshore","chum boat",
                            "offshore", "docks","coast", rep("docks",2), rep("coast",2), "docks", "chum boat",
                            rep("coast",4),"docks","docks and ocean", "coast", "chum boat", "ocean", rep("chum boat",2),
                            "bird island", "docks", "ocean", "coast", "docks", rep("bird island", 2), "docks",
                            "offshore","chum boat",rep("bird island",3), "docks","coast","docks","bird island",
                            "docks","offshore","chum boat", "barge","bird island", "docks","water tower",
                            "bird island","docks","coast","docks", "water tower",  rep("bird island", 5), 
                            rep("docks", 2), rep("water tower", 3), rep("lighthouse", 2),
                            rep("bird island", 2), "offshore","chum boat", rep("bird island", 3), rep("docks", 3),
                            rep("water tower", 3), "circle", rep("bird island", 2), "light house", "circle", 
                            rep("bird island",2), "docks", rep("bird island", 3), "offshore", "chum boat", 
                            rep("docks", 2), "bird island", "ocean", "offshore", "chum boat")
CameraTransect$start_tm = c("10:00","10:13","11:00","13:00","13:05","13:53","14:07","15:00",
                            "15:02","15:00","16:07","17:29","09:30","09:40","12:40","12:54","13:20",
                            "13:30","15:10","15:21","16:51","09:17","09:25","10:45","10:50","14:59",
                            "15:25","16:08","16:17","16:23","16:48","08:49","09:10","10:25","11:45","12:13","13:00",
                            "09:15","09:30","09:45","09:50","11:06","11:10","12:28","12:45","12:50","13:20","14:00",
                            "09:20","09:55","10:00","10:13","11:13","11:25","12:26","12:45","13:14","14:00","14:15",
                            "12:51","12:59","13:40","14:00","14:05","15:04","15:10","15:15","15:23",
                            "09:00","09:15","09:30","09:50","10:00","10:12","10:17","10:20","10:25","10:30","12:00",
                            "12:20","12:39","13:08","15:30","15:50","16:00",rep("16:15",3),rep("16:40",3),"18:45",
                            "19:00","19:15","19:30",
                            "07:15","07:30","07:45","09:00","09:30","09:45","10:00","11:30","12:15",
                            "09:39","10:00","10:20","10:30","12:25","13:09")
CameraTransect$end_tm = c("10:13","11:00","11:45","13:05","13:52","14:07","14:30","15:00",
                          "15:02","16:30","17:29","17:39",
                          "09:40","11:46","12:50","13:20","13:30","14:00","15:20","16:51","16:55",
                          "09:25","10:45","10:50","11:33","15:25","16:08","16:17","16:23","16:45","17:00",
                          "09:10","10:25","10:36","12:13","13:00","13:15",
                          "09:30","09:45","09:50","11:06","11:10","11:29","12:45","12:50","13:16","13:55","14:32",
                          "09:55","10:00","10:13","11:13","11:25","11:34","12:45","13:14","13:54","14:15","14:40",
                          "12:59","13:07","14:00","14:05","15:04","15:10","15:15","15:23","15:30",
                          "09:15","09:30","09:50","10:00","10:12","10:15","10:17","10:20","10:25","10:30",
                          "12:20","12:38","13:08","13:22","15:50","16:00",rep("16:15",4),rep("16:40",3),"18:45",
                          "19:00","19:15","19:30",
                          "07:15","07:30","07:45","09:00","09:30","09:45","10:00","12:14","13:01",
                          "09:39","10:00","10:20","10:30","13:09","13:41")
CameraTransect$altitude_m = c(rep(600,3),rep(450,9), rep(1000,3), "1200-1600 (clouds)",rep(600,2), rep(425,3), 
                              rep(1000,2),"450-600 (clouds)", 1000, rep(1200,2), 1000, 600, rep(1200,2), rep(1000,3), 
                              rep("300-450",2), 600, 332, rep(433,3), 400, 433, rep(731,3), rep(433,2), 733, 900, 
                              rep(733,2), rep(900,2), rep(733,5), NA, NA, rep(600,6), 1000, 600, 1000, rep(1200,2), 
                              rep(1000,2), 1200, rep(600,2), rep(1000,5), 433, 719, rep(863,2), 719, rep(433,2), 
                              719, 863, 719, 863, rep(719,3), 863, 719, rep(863,2), 719, 433, rep(863, 2), rep(433,6))
CameraTransect$segment_type = c("reference object flyover", "transect", "short transect","reference object flyover",
                                "transect","target flyover","transect", rep("reference object flyover",3),
                                "transect", rep("reference object flyover",2),"transect","reference object flyover",
                                "transect","target flyover","transect","reference object flyover","transect",
                                rep("reference object flyover",2),rep("transect",2),"reference object flyover",
                                "target flyover",rep("transect",4),rep("reference object flyover",2), "transect",
                                "target flyover","reference object flyover",rep("target flyover",3),
                                rep("reference object flyover",2), "transect","reference object flyover",
                                rep("target flyover",2), "reference object flyover",'transect',
                                "target flyover","reference object flyover",rep("target flyover",2),
                                "reference object flyover","transect","reference object flyover",
                                "target flyover","reference object flyover","transect",rep("target flyover",3),
                                "reference object flyover",rep("target flyover",2),"reference object flyover",
                                "transect","reference object flyover",rep("target flyover",6),
                                rep("reference object flyover",2), rep("target flyover",6),"bird island3_1000m_15Tilt",
                                "transect",rep("target flyover",4),rep("reference object flyover",3),
                                rep("target flyover",3),"reference object flyover",rep("target flyover",3),
                                "reference object flyover",rep("target flyover",2),"reference object flyover",
                                rep("target flyover",3),"transect","target flyover",rep("reference object flyover",2),
                                "target flyover","reference object flyover","transect","target flyover")
CameraTransect$resolution_cm = c(rep(2,3),rep(1,9),rep(2.5,3),"3-1.5",rep(1.5,5),rep(2.5,2),"1-1.5",2.5,
                                 rep(3,2),2.5,1.5,rep(3,2),rep(2.5,3),1,1.5,2.1,1,rep(1.5,3),1.4,1.5,rep(2.5,3),
                                 rep(1.5,2),2.5,3,rep(2.5,2),rep(3,2),rep(2.5,5),NA,NA,rep(1.5,6),2.5,1.5,
                                 2.5,rep(3,2),rep(2.5,2),3,rep(1.5,2),rep(2.5,5),1.5,2.5,rep(3,2),2.5,rep(1.5,2),
                                 2.5,3,2.5,3,rep(2.5,3),3,2.5,2,3,2.5,1.5,rep(3,2),rep(1.5,6))       
CameraTransect$swath_width_m = c(rep(98,3),rep(49,4),rep(50,5),rep(121,3),"146-73",rep(73,5),rep(121,2),
                                 "73-50",121,rep(146,2),121,73, rep(146,2),rep(121,3),49,73,102,49,
                                 rep(73,3),69,73,rep(121,3),rep(73,2),121,146,rep(121,2),rep(146,2),rep(121,5),
                                 NA,NA, rep(73,6),121,73,121,rep(146,2),rep(121,2),146,rep(73,2),rep(121,5),
                                 73,121,rep(146,2),121,rep(73,2),121,146,121,146,rep(121,3),146,121,97,146,121,73,
                                 rep(146,2),rep(61,6))

## Get GPS points
CameraTransect  = CameraTransect %>% 
  mutate(start_date_tm = paste(CameraTransect$date, CameraTransect$start_tm, sep=" ")) %>%
  mutate(start_date_tm = as.POSIXct(start_date_tm,format="%Y-%m-%d %H:%M")) %>%
  mutate(end_date_tm = paste(CameraTransect$date, CameraTransect$end_tm, sep=" ")) %>%
  mutate(end_date_tm = as.POSIXct(end_date_tm,format="%Y-%m-%d %H:%M")) %>% rowwise %>%
  mutate(start_ind = closest.time.point(start_date_tm, CameraGPSdata$date_time, 120),
         end_ind = closest.time.point(end_date_tm, CameraGPSdata$date_time, 120)) %>% as.data.frame %>%
  mutate(start_lat = CameraGPSdata$Latitude[start_ind], 
         start_lon = CameraGPSdata$Longitude[start_ind],
         end_lat = CameraGPSdata$Latitude[end_ind],
         end_lon = CameraGPSdata$Longitude[end_ind]) %>% select(-start_ind, -end_ind, -end_date_tm, -start_date_tm)
  
## transect == online, no chumming. All else should be excluded. 
# relate Camera Data to Camera Transect to mark offline data
CameraTransect = CameraTransect %>% 
  mutate(start_date_time = as.POSIXct(paste(date, start_tm, sep=" "),format="%Y-%m-%d %H:%M"), 
         end_date_time = as.POSIXct(paste(date, end_tm, sep=" "),format="%Y-%m-%d %H:%M")) 
#CameraTransect$transect_ID = row_number

CameraData = CameraData %>% rowwise %>% 
  mutate(start_ind = closest.time.point(date_time, CameraTransect$start_date_time, 90)) %>% 
  as.data.frame %>% mutate(segment_type = paste(CameraTransect$segment_type[start_ind],
                                                CameraTransect$location[start_ind], sep="; ")) %>%
  select(-start_ind) 
CameraData$segment_type[CameraData$segment_type=="NA; NA"] = NA

# --------------------------- # 


# --------------------------- #
# remove unnecessary columns
# --------------------------- #
boatObs = select(boatObs, -page_number,-page_total,-platform,-start_time_sheet,-end_time_sheet,-cue_type_start_stop,
                 -Stransect,-Etransect,-missing_sp) 
planeObs = select(planeObs, -page_number,-page_total,-platform,-start_time_sheet,-end_time_sheet,-cue_type_start_stop,
                 -Stransect,-Etransect,-missing_sp,-chum)
CameraData = select(CameraData, -Date, -Time)


boatObs = boatObs %>% arrange(segment, date_time)
# --------------------------- #

