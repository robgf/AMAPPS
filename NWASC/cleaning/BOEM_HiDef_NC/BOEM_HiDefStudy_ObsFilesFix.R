
# --------------------------------------------- #
#                     STEP 1                    #
#          FIX INCORRECT TYPE CODINGS           #
# --------------------------------------------- #

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
spplist = ifelse(common_name == "green turtle", "GRST", spplist)
spplist = ifelse(common_name == "unidentified turtle species", "UIST", spplist)
spplist = ifelse(common_name == "loggerhead turtle", "LOST", spplist)
spplist = ifelse(common_name == "kemps' ridley turtle", "KRST", spplist)
spplist = ifelse(common_name == "hawksbill turtle", "HATU", spplist)
spplist = ifelse(common_name == "leatherback turtle", "LEST", spplist)

spplist = ifelse(common_name == "unidentified bird species", "UNBI", spplist)      
spplist = ifelse(common_name %in% c("laridae species","larinae species") , "UNGU", spplist) #unidentified Gull??? #typo unidentified Gull???               
spplist = ifelse(common_name == "calidris species", "UNCA", spplist) #new unidentified Calidris              
spplist = ifelse(common_name == "dowitcher species", "DOWI", spplist)              
spplist = ifelse(common_name == "chelonidae species", "UIST", spplist) #unidentified sea trutle?            
spplist = ifelse(common_name == "delphinidae species", "UNDO", spplist) #unidentified dolphin           
spplist = ifelse(common_name == "sterna species", "UNTE", spplist) #unidentified tern                
spplist = ifelse(common_name == "stercorarius species", "UNSK", spplist) #unidentified skua      
spplist = ifelse(common_name == "unidentified shorebird species", "SHOR", spplist)
spplist = ifelse(common_name == "phalaropus species", "UNPH", spplist)             
spplist = ifelse(common_name == "hydrobatidae species", "UNSP", spplist) #unidentified storm petrel    
spplist = ifelse(common_name == "unidentified warbler species", "UNWA", spplist)  
spplist = ifelse(common_name == "unidentified raptor species", "UNRP", spplist)  
spplist = ifelse(common_name == "unidentified passerine species", "UNPA", spplist)
spplist = ifelse(common_name == "stenella species", "UNSN", spplist)           
spplist = ifelse(common_name == "sphyrna species", "HASH", spplist) #Hammerhead shark spp.        
spplist = ifelse(common_name == "unidentified elasmobranch", "UNEL", spplist)  
spplist = ifelse(common_name == "stenula species", "ZOOP", spplist)  #zooplankton            
spplist = ifelse(common_name == "thalasseus species", "UNTE", spplist) #unidentified tern    

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
# stenella species", "UNSN", spplist)     
# unidentified raptor species", "UNRP"
# true's beaked whale", "TBWH"
# cownose ray", "CNRA"
# blainville's beaked whale", "BBWH"
# gervais' beaked whale", "GBWH"
# calidris species", "UNCA"

# might need to split up Thalasseus and Sterna (UNTE)











