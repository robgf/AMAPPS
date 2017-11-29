# ------------------ #
# question from refuges via Caleb
# how much data is in the the NE Canyons & Seamounts Marine Nat Monument boundary
# which species
#
# copied from email: 
# They are looking for a list of species (and #s if possible) found in the 
# boundaries of the monument during surveys contained in the catalog.  
# If you are able to break these out annually, that would be great.  
# if not, just totals will be fine 
# 
# -- they are not needing to provide an estimate 
# of mean abundance/distribution within the boundaries.  They would also like some 
# measure of effort so they have a sense of how robust the info is.
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
# ------------------ #

# ------------------ #
# subset data
# ------------------ #
# create super basic polygon bounding box
canyon.coords = matrix(c(-68.212,40.122,
                  -68.268,40.527,
                  -67.628,40.600,
                  -67.578,40.207), 
                ncol = 2, byrow = TRUE)
canyon.coords = as.data.frame(canyon.coords)
names(canyon.coords)=c("coords.x1","coords.x2")
P1 = Polygon(canyon.coords)
canyon = SpatialPolygons(list(Polygons(list(P1), ID = "canyon")), 
                      proj4string=CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"))

seamount.coords = matrix(c(-66.931,38.865,
                    -65.943,39.939,
                    -67.722,40.044),
                  ncol = 2, byrow = TRUE)
seamount.coords = as.data.frame(seamount.coords)
names(seamount.coords)=c("coords.x1","coords.x2")

P2 = Polygon(seamount.coords)
seamount = SpatialPolygons(list(Polygons(list(P2), ID = "seamount")), 
                         proj4string=CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"))

# pull whats in the box
x = sp::over(fc,canyon)
canyon.data = as.data.frame(fc[!is.na(x),])

x = sp::over(fc,seamount)
seamount.data = as.data.frame(fc[!is.na(x),])

rm(x) 


# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
datalist <- sqlFetch(db, "dataset")
obs <- sqlFetch(db, "observation")
odbcClose(db)

# make spatial and pull whats in box
obs = filter(obs, !is.na(temp_lon), !is.na(temp_lat))
coordinates(obs) = ~temp_lon + temp_lat
proj4string(obs) <- CRS("+init=epsg:4326") # WGS 84
obs <- spTransform(obs, CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"))

x = sp::over(obs,canyon)
obs.canyon.data = as.data.frame(fc[!is.na(x),])

x = sp::over(obs,seamount)
obs.seamount.data = as.data.frame(fc[!is.na(x),])

# join old with new (just need spp, date, lon, lat, survey, counts)
obs.canyon.data = obs.canyon.data %>% 
  dplyr::select(obs_dt, coords.x1, coords.x2, 
                source_dataset_id, spp_cd, dataset_id,
                obs_count_intrans_nb,obs_count_general_nb) 
obs.seamount.data = obs.seamount.data%>% 
  dplyr::select(obs_dt, coords.x1, coords.x2, 
                source_dataset_id, spp_cd, dataset_id,
                obs_count_intrans_nb,obs_count_general_nb)
canyon.data = bind_rows(canyon.data,obs.canyon.data)
seamount.data = bind_rows(seamount.data,obs.seamount.data)

# create year
canyon.data = mutate(canyon.data,year=sapply(strsplit(as.character(obs_dt),"/"),head,1))
seamount.data = mutate(seamount.data,year=sapply(strsplit(as.character(obs_dt),"/"),head,1))

# filter out to share level 5
seamount.data = filter(seamount.data, dataset_id %in% datalist$dataset_id[datalist$share_level %in% 5])
canyon.data = filter(canyon.data, dataset_id %in% datalist$dataset_id[datalist$share_level %in% 5])

sort(unique(canyon.data$source_dataset_id))
sort(unique(seamount.data$source_dataset_id))
# ------------------ #


# ------------------ #
# species summary
# ------------------ #
canyon.species = as.data.frame(sort(unique(canyon.data$spp_cd)))
seamount.species = as.data.frame(sort(unique(seamount.data$spp_cd)))
names(canyon.species) = "spp_cd"
names(seamount.species) = "spp_cd"

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

canyon.species = left_join(canyon.species, spplist, by = "spp_cd") %>% 
  dplyr::select(-species_type_cd) %>% filter(!spp_cd %in% c("NONE","TRAN","UFFI"))
write.csv(canyon.species, file = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/canyon_species_codes.csv")

seamount.species = left_join(seamount.species, spplist, by = "spp_cd") %>% 
  dplyr::select(-species_type_cd) %>% filter(!spp_cd %in% c("NONE","TRAN","UFFI"))
write.csv(seamount.species, file = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/seamount_species_codes.csv")
# ------------------ #


# ------------------ #
# count summary
# ------------------ #
canyon.count = canyon.data %>% group_by(spp_cd) %>% 
  summarize(sum.intran.count = sum(obs_count_intrans_nb,na.rm=TRUE),
            sum.general.count = sum(obs_count_general_nb,na.rm=TRUE))
seamount.count = seamount.data %>% group_by(spp_cd) %>% 
  summarize(sum.intran.count = sum(obs_count_intrans_nb,na.rm=TRUE),
            sum.general.count = sum(obs_count_general_nb,na.rm=TRUE)) %>%
  filter(!spp_cd %in% "UFFI") #9999 as count most likely error

write.csv(seamount.count, file = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/seamount_species_counts.csv")
write.csv(canyon.count, file = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/canyon_species_counts.csv")

# ggplot(canyon.count,aes(x=sum.intran.count,
#                         y=reorder(spp_cd,sum.intran.count),col=spp_cd))+geom_point()+
#   xlab("On transect count")+
#   ylab("Species code")+theme_bw()+
#   ggtitle("Sum of on effort Canyon species counts across all years and surveys \n**not effort corrected")

p = ggplot(seamount.count,aes(x=sum.intran.count,
                          y=reorder(spp_cd,sum.intran.count),col=spp_cd))+geom_point()+
  xlab("On transect count")+
  ylab("Species code")+theme_bw()+theme(legend.position="none")+
  ggtitle("Sum of on effort Seamount species counts across all years and surveys \n**not effort corrected")
p 
ggsave(filename = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/Sum of on effort Seamount species counts.png",plot=p)

canyon.count = mutate(canyon.count, D = ifelse(sum.intran.count>100,"more than 100","less than 100"))
p = ggplot(canyon.count,
       aes(x=sum.intran.count,
           y=reorder(spp_cd,sum.intran.count),col=spp_cd))+
  geom_point()+ guides(fill=FALSE)+
  facet_grid(~D, scales = "free_x")+
  xlab("On transect count")+
  ylab("Species code")+theme_bw()+theme(legend.position="none")+
  ggtitle("Sum of on effort Canyon species counts across all years and surveys \n**not effort corrected")
p 
ggsave(filename = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/Sum of on effort Canyon species counts.png",plot=p)

p = ggplot(seamount.count,aes(x=sum.general.count,
                              y=reorder(spp_cd,sum.general.count),col=spp_cd))+geom_point()+
  xlab("Off transect count")+
  ylab("Species code")+theme_bw()+theme(legend.position="none")+
  ggtitle("Sum of off effort Seamount species counts across all years and surveys \n**not effort corrected")
p 
ggsave(filename = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/Sum of off effort Seamount species counts.png",plot=p)

p = ggplot(canyon.count,aes(x=sum.general.count,
                              y=reorder(spp_cd,sum.general.count),col=spp_cd))+geom_point()+
  xlab("Off transect count")+
  ylab("Species code")+theme_bw()+theme(legend.position="none")+
  ggtitle("Sum of off effort Canyon species counts across all years and surveys \n**not effort corrected")
p 
ggsave(filename = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/Sum of off effort Canyon species counts.png",plot=p)
# ------------------ #


# ------------------ #
# effort summary
# ------------------ #
canyon.effort = canyon.data %>% group_by(source_dataset_id) %>% 
  summarize(start.date = first(obs_dt), 
            end.date = last(obs_dt))
seamount.effort = seamount.data %>% group_by(source_dataset_id) %>% 
  mutate() %>%
  summarize(sum.days = sum(days,na.rm=TRUE))
# ------------------ #


# ------------------ #
# plots
# ------------------ #
p = ggplot()+
  geom_point(data = canyon.data,aes(x=coords.x1,y=coords.x2))+
  geom_point(data = seamount.data,aes(x=coords.x1,y=coords.x2))+
  geom_polygon(data = canyon.coords, aes(x=coords.x1,y=coords.x2), color = "darkgrey", fill=NA)+
  geom_polygon(data = seamount.coords, aes(x=coords.x1,y=coords.x2), color = "darkgrey", fill=NA)+
  coord_fixed(xlim = c(-68.2,-66), ylim = c(38.9,40.6), ratio = 1.3)+theme_bw()+
  xlab("Longitude")+ ylab("Latitude")+ ggtitle("All Observations")
p
ggsave(filename = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/all_observations.png",plot=p)

# by year
p = ggplot()+
  geom_point(data = canyon.data,aes(x=coords.x1,y=coords.x2,col=year))+
  geom_point(data = seamount.data,aes(x=coords.x1,y=coords.x2,col=year))+
  geom_polygon(data = canyon.coords, aes(x=coords.x1,y=coords.x2), color = "darkgrey", fill=NA)+
  geom_polygon(data = seamount.coords, aes(x=coords.x1,y=coords.x2), color = "darkgrey", fill=NA)+
  coord_fixed(xlim = c(-68.2,-66), ylim = c(38.9,40.6), ratio = 1.3)+theme_bw()+
  xlab("Longitude")+ ylab("Latitude")+ ggtitle("All Observations by Year")
p
ggsave(filename = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/all_observations_by_year.png",plot=p)

# by survey
p = ggplot()+
  geom_point(data = canyon.data,aes(x=coords.x1,y=coords.x2,col=source_dataset_id))+
  geom_point(data = seamount.data,aes(x=coords.x1,y=coords.x2,col=source_dataset_id))+
  geom_polygon(data = canyon.coords, aes(x=coords.x1,y=coords.x2), color = "darkgrey", fill=NA)+
  geom_polygon(data = seamount.coords, aes(x=coords.x1,y=coords.x2), color = "darkgrey", fill=NA)+
  coord_fixed(xlim = c(-68.2,-66), ylim = c(38.9,40.6), ratio = 1.3)+theme_bw()+
  xlab("Longitude")+ ylab("Latitude")+ ggtitle("All Observations by Survey")
p
ggsave(filename = "Z:/seabird_database/data_sent/NECanyonsSeamounts_Nov2017/all_observations_by_survey.png",plot=p)
# ------------------ #
