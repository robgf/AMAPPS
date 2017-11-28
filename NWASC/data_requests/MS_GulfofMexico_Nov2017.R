# ------------------ #
# question from Meghan Sadlowski
# how much data is in the GOMex.
# which species
# ------------------ #

# ------------------ # 
# load packages
# ------------------ # 
require(dplyr)
require(ggplot2)
require(maps)
library(sp)
library(rgeos)
library(rgdal)
# ------------------ # 

# ------------------ #
# load geodb from Alli
# ------------------ #
fgdb <- "Z:/seabird_database/database_export/archive/seabird_database_export_boem_15July2014.gdb"

# List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list <- ogrListLayers(fgdb)
print(fc_list)

# Read the feature class
fc <- readOGR(dsn=fgdb,layer="observations")

# Determine the FC extent, projection, and attribute information
summary(fc)

# View the feature class
plot(fc)
# ------------------ #

# ------------------ #
# subset data
# ------------------ #
# create super basic polygon bounding box
coords = matrix(c(-80,25,
                  -82.5,30,
                  -100,30,
                  -100,20,
                  -80,20,
                  -80,25), 
                ncol = 2, byrow = TRUE)

coords = matrix(c(-80,25,-80,20,-100,20,-100,30,-82.5,30,-80,25), 
                ncol = 2, byrow = TRUE)
coords=as.data.frame(coords)
names(coords)=c("coords.x1","coords.x2")
P1 = Polygon(coords)
Ps1 = SpatialPolygons(list(Polygons(list(P1), ID = "a")), 
                      proj4string=CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"))
plot(Ps1, axes = TRUE)
rm(coords)

# proj4string(Ps1)
# proj4string(fc)

# pull whats in the box
x = sp::over(fc,Ps1)
gom_data = data[!is.na(x),]

sort(unique(gom_data$source_dataset_id))
# AMAPPS_FWS_Aerial_Preliminary_Summer2010 -> share level 5 
# AMAPPS_NOAA/NMFS_SEFSCBoat2011 -> share level 5          
# CSAP -> share level 5                                     
# SEFSC1992 -> share level 5                              
# SEFSC1998 -> share level 5

birds = as.data.frame(sort(unique(gom_data$spp_cd)))
names(birds) = "spp_cd"

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

birds = left_join(birds, spplist, by = "spp_cd")
birds = select(birds,-species_type_cd)
write.csv(birds, file = "Z:/seabird_database/data_sent/MeghanSadlowski_iPac_AKN_GoMex_Nov2017/species_codes_in_GulfOfMexico.csv")
  
# plot
world <- map_data("world")
p = ggplot(gom_data,aes(coords.x1,coords.x2))+geom_point()+
  geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+
  coord_fixed(xlim = c(-100,-79), ylim = c(20,35), ratio = 1.3)+
  xlab("Longitude")+ ylab("Latitude")+ ggtitle("Observations in the Gulf of Mexico")
p
ggsave(filename = "Z:/seabird_database/data_sent/MeghanSadlowski_iPac_AKN_GoMex_Nov2017/observations.png",plot=p)
# 
#ggplot(gom_data[gom_data$source_dataset_id %in% 'CSAP',],aes(coords.x1,coords.x2))+geom_point()+
#   geom_polygon(data = world, aes(x=long, y = lat,group=group), fill="forestgreen")+
#   coord_fixed(xlim = c(-100,-79), ylim = c(20,35), ratio = 1.3)
# ------------------ #
