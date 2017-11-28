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
world <- map_data("world")
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
ECSAS2$spp_cd[ECSAS2$original_spp_tx %in% "hydrobatidae"] = "UNSP"

pacific.species = c("aethia cristatella","aethia psittacula",
                    "aethia pusilla","brachyramphus brevirostris",
                    "callorhinus ursinus","cepphus columba",
                    "eschrichtius robustus","eumetopias jubatus",
                    "fratercula corniculata","gavia adamsii",
                    "histriophoca fasciata",
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
#
# ------------------ # 


# ------------------ # 
# plot
# ------------------ # 
ggplot()+geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+
  coord_fixed(xlim = c(-180,0), ylim = c(25,80), ratio = 1.3)+
  theme_bw()+
  geom_point(data=ECSAS2,aes(x=longitude,y=latitude,col=original_spp_tx))+
  theme(legend.position="none")
# ------------------ # 

# #searching for ECOMON dates
ECSAS2$date = as.Date(ECSAS2$date,format = "%Y-%m-%d")
# theres no 2016 data so pointless to check the 2016 cruises
# PC1607
# https://www.nefsc.noaa.gov/HydroAtlas/2016/AUG_ECOMON_PC1607/CRUISE_REPORT_2016007PC.pdf
# 08 to 19 August 2016 (NC-RI)
#sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2016-08-08",format = "%Y-%m-%d"):as.Date("2016-08-19",format = "%Y-%m-%d")]))
# 
# GU1608
# https://www.nefsc.noaa.gov/HydroAtlas/2016/MAY_ECOMON_GU1608/CRUISE_REPORT_2016008GU.pdf
# 21 May to 20 June 2016 (MAB-GOM)
#sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2016-05-21",format = "%Y-%m-%d"):as.Date("2016-06-20",format = "%Y-%m-%d")]))
# 
# HB1502
# https://www.nefsc.noaa.gov/HydroAtlas/2015/MAY_ECOMON_HB1502/CRUISE_REPORT_2015002HB.pdf
# 19 May to 3 June 2015 (GOM)
sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2015-05-19",format = "%Y-%m-%d"):as.Date("2015-06-03",format = "%Y-%m-%d")]))
x = sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2015-05-19",format = "%Y-%m-%d"):as.Date("2015-06-03",format = "%Y-%m-%d")]))
dat = ECSAS2[ECSAS2$date %in% x,]
p = ggplot()+geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+
  coord_fixed(xlim = c(-180,0), ylim = c(25,80), ratio = 1.3)+
  theme_bw()+
  geom_point(data=dat,aes(x=longitude,y=latitude))+
  xlab("Longitude")+ylab("Latitude")+ggtitle("MAY_ECOMON_HB1502")
p 
ggsave(filename = "Z:/seabird_database/data_import/in_progress/ECSAS/MAY_ECOMON_HB1502.png",plot=p)
# 
# GU1506
# https://www.nefsc.noaa.gov/HydroAtlas/2015/OCT_ECOMON_GU1506/CRUISE_REPORT_2015006GU.pdf
# 12 to 26 October 2015 (MAB to GOM)
#sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2015-10-12",format = "%Y-%m-%d"):as.Date("2015-10-26",format = "%Y-%m-%d")]))
# 
# GU1401
# https://www.nefsc.noaa.gov/HydroAtlas/2014/MAR_ECOMON_GU1401/CRUISE_REPORT_2014001GU.pdf
# 28 February to 9 March 2014 (GB to GOM)
sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2014-02-28",format = "%Y-%m-%d"):as.Date("2014-03-09",format = "%Y-%m-%d")]))
x = sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2014-02-28",format = "%Y-%m-%d"):as.Date("2014-03-09",format = "%Y-%m-%d")]))
dat = ECSAS2[ECSAS2$date %in% x,]
p = ggplot()+geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+
  coord_fixed(xlim = c(-180,0), ylim = c(25,80), ratio = 1.3)+
  theme_bw()+
  geom_point(data=dat,aes(x=longitude,y=latitude))+
  xlab("Longitude")+ylab("Latitude")+ggtitle("MAR_ECOMON_GU1401")
p 
ggsave(filename = "Z:/seabird_database/data_import/in_progress/ECSAS/MAR_ECOMON_GU1401.png",plot=p)
# 
# GU1302
# https://www.nefsc.noaa.gov/HydroAtlas/2013/JUN_ECOMON_GU1302/CRUISE_REPORT_2013002GU.pdf
# 9 June to 24 June 2013 (MAB to GOM)
sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2013-06-09",format = "%Y-%m-%d"):as.Date("2013-06-24",format = "%Y-%m-%d")]))
x = sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2013-06-09",format = "%Y-%m-%d"):as.Date("2013-06-24",format = "%Y-%m-%d")]))
dat = ECSAS2[ECSAS2$date %in% x,]
p = ggplot()+geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+
  coord_fixed(xlim = c(-180,0), ylim = c(25,80), ratio = 1.3)+
  theme_bw()+
  geom_point(data=dat,aes(x=longitude,y=latitude))+
  xlab("Longitude")+ylab("Latitude")+ggtitle("JUN_ECOMON_GU1302")
p 
ggsave(filename = "Z:/seabird_database/data_import/in_progress/ECSAS/JUN_ECOMON_GU1302.png",plot=p)
# 
# GU1305
# https://www.nefsc.noaa.gov/HydroAtlas/2013/NOV_ECOMON_GU1305/CRUISE_REPORT_2013005GU.pdf
# 07 November to 26 November 2013 (MAB to GOM)
sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2013-11-07",format = "%Y-%m-%d"):as.Date("2013-11-26",format = "%Y-%m-%d")]))
x = sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2013-11-07",format = "%Y-%m-%d"):as.Date("2013-11-26",format = "%Y-%m-%d")]))
dat = ECSAS2[ECSAS2$date %in% x,]
p = ggplot()+geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+
  coord_fixed(xlim = c(-180,0), ylim = c(25,80), ratio = 1.3)+
  theme_bw()+
  geom_point(data=dat,aes(x=longitude,y=latitude))+
  xlab("Longitude")+ylab("Latitude")+ggtitle("NOV_ECOMON_GU1305")
p 
ggsave(filename = "Z:/seabird_database/data_import/in_progress/ECSAS/NOV_ECOMON_GU1305.png",plot=p)
# 
# DEL1102
# https://www.nefsc.noaa.gov/HydroAtlas/2011/FEB_ECOMON_DEL1102/CRUISE_REPORT_2011002DE.pdf
# 1 to 18 February 2011 (MAB to GOM)
sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2011-02-01",format = "%Y-%m-%d"):as.Date("2011-02-08",format = "%Y-%m-%d")]))
x = sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2011-02-01",format = "%Y-%m-%d"):as.Date("2011-02-08",format = "%Y-%m-%d")]))
dat = ECSAS2[ECSAS2$date %in% x,]
p = ggplot()+geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+
  coord_fixed(xlim = c(-180,0), ylim = c(25,80), ratio = 1.3)+
  theme_bw()+
  geom_point(data=dat,aes(x=longitude,y=latitude))+
  xlab("Longitude")+ylab("Latitude")+ggtitle("FEB_ECOMON_DEL1102")
p 
ggsave(filename = "Z:/seabird_database/data_import/in_progress/ECSAS/FEB_ECOMON_DEL1102.png",plot=p)
# 
# DEL1105
# https://www.nefsc.noaa.gov/HydroAtlas/2011/JUN_ECOMON_DEL1105/CRUISE_REPORT_2011005DE.pdf
# 2 to 21 June 2011 (MAB to GOM)
#sort(unique(ECSAS2$date[ECSAS2$date %in% as.Date("2011-06-02",format = "%Y-%m-%d"):as.Date("2011-06-21",format = "%Y-%m-%d")]))


