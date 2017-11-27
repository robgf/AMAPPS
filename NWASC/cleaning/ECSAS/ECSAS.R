# ------------------ # 
# ECSAS data from OBIS
# ------------------ # 


# ------------------ # 
# load packages
# ------------------ # 
require(dplyr)
require(readr)
require(ggplot2)
require(maps)
# ------------------ # 


# ------------------ # 
# load data
# ------------------ # 
ECSAS = read_csv("C:/Users/kecoleman/Downloads/0ae8aa839715f30cf2428c5436754a2185d77108.zip")
#world <- map_data("world")
# ------------------ # 


# ------------------ # 
# format data
# ------------------ # 
ECSAS2 = dplyr::select(ECSAS, id, eventDate, decimalLongitude, decimalLatitude,
               originalscientificname, behavior, eventTime, individualCount) %>% 
  rename(source_id = id, longitude = decimalLongitude,latitude = decimalLatitude,
         original_spp_tx = originalscientificname, time=eventTime, 
         count = individualCount, date = eventDate) %>% 
  mutate(date = sapply(strsplit(as.character(date)," "),head,1), 
         behavior = sapply(strsplit(as.character(behavior),": "),tail,1), 
         time = sapply(strsplit(as.character(time),"Z"),head,1)) %>%
  as.data.frame()

# species
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

ECSAS2$original_spp_tx = tolower(ECSAS2$original_spp_tx)
spplist$sciname = tolower(spplist$sciname)

tmp <- !ECSAS2$original_spp_tx %in% spplist$sciname
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(ECSAS2$original_spp_tx[tmp]))

# define species codes
ECSAS2 = left_join(ECSAS2, dplyr::select(spplist,sciname,spp_cd),by=c("original_spp_tx" = "sciname"))

# enter those that don't directly match
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "cetacea"] = "UNCE"
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "sterna"] = "UNTE"
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "alcidae"] = "UNAL"
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "pinnipedia"] = "UNSE"
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "larus"] = "UNGU"
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "gaviidae"] = "UNLO" 
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "anas carolinensis"] = "GWTE"          
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "balaenopteridae"] = "UNRO"          
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "melanitta"] = "UNSC"                 
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% c("phalacrocoracidae","phalacrocorax")] = "UNCO"        
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "physeter catodon"] = "SPWH"          
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "procellariiformes"] = "UNPR"         
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "pterodroma"] = "UNPT"  
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "phocoenidae"] = "UNDO" 
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "puffinus lherminieri"] = "AUSH"    
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "uria"] = "UNMU"
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% c("stercorariidae", "stercorarius")] = "UNSK"   
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "somateria"] = "UNEI" 
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "branta"] = "UGOO" #or add unidentified branta                   
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "anatidae"] = "UDGS"                  
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "diomedeidae"] = "UALB"                
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "oceanodroma"] = "UNPE"                
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "puck"]  = "UNKN" #seems to be an error

pacific.species = c("aethia cristatella","aethia psittacula",
                    "aethia pusilla","brachyramphus brevirostris",
                    "callorhinus ursinus","cepphus columba",
                    "eschrichtius robustus","eumetopias jubatus",
                    "fratercula corniculata","gavia adamsii",
                    "histriophoca fasciata","hydrobatidae",
                    "lagenorhynchus obliquidens","phoca largha",
                    "phocoenoides dalli","phoebastria immutabilis",
                    "phoebastria nigripes","pterodroma inexpectata",
                    "sterna aleutica","synthliboramphus antiquus",
                    "pterodroma ultima", "rhodostethia rosea",
                    "rissa brevirostris", "sterna albifrons") 
tmp <- is.na(ECSAS2$spp_cd) & !ECSAS2$original_spp_tx %in% pacific.species
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(ECSAS2$original_spp_tx[tmp]))

### still need to address
# "balaena mysticetus"  ##need to add bowhead whale       
# "delphinapterus leucas" ##need to add beluga whale    
# "fregetta"
# "phalaropus"                
# "puffinus"                   
# "rissa" # need to add unidentified kittiwake?                     
# "sternidae"                 
# "synthliboramphus"           
# ------------------ # 


# ------------------ # 
# plot
# ------------------ # 
# ggplot()+geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+ 
#   coord_fixed(xlim = c(-180,0), ylim = c(25,80), ratio = 1.3)+
#   theme_bw()+
#   geom_point(data=ECSAS2,aes(x=longitude,y=latitude,col=original_spp_tx))+
#   theme(legend.position="none")
# ------------------ # 
