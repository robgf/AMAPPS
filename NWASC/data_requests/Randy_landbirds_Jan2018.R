# --------------- #
# look at what landbirds are in the database
#
# date: Jan. 2018
# written by: K. Coleman
# --------------- #

# -------------- #
# load packages
# -------------- #
library(odbc)
library(RODBC)
library(sp)
library(maps)
library(ggmap)
library(maps)
library(dplyr)
library(lubridate)
# -------------- #


# -------------- #
# load data
# -------------- #

# get landbird species codes
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
landbirds = dbGetQuery(db,"select * from lu_species2 where species_type_id = 8")

# get old data
db <- dbConnect(odbc::odbc(),
                driver='SQL Server',
                server='ifw9mbmsvr008',
                database='SeabirdCatalog')

# call the observation, returning the geometry field as x and y columns.
old_obs = dbGetQuery(db,"select observation_id,transect_id,dataset_id,obs_dt,
                     spp_cd, obs_count_intrans_nb, obs_count_general_nb,
                     [Geometry].STY as Lat, 
                     [Geometry].STX as Long
                     from observation where spp_cd in ('AMCR','AMGO','AMKE','AMPI','AMRE',
                     'AMRO','ATSP','BAEA','BANO','BANS','BAOR','BAOW','BARS','BAWW','BBCU',
                     'BBWO','BCCH','BEKI','BGGN','BHCO','BLBW','BLJA','BLPW','BLVU','BOBO',
                     'BOCH','BOWA','BRBL','BRCR','BRTH','BTBW','BTGR','BTNW','BUTE','BWWA',
                     'CACH','CARW','CASW','CAWA','CEDW','CHIC','CHSP','CHSW','CLSW','CMWA',
                     'COGR','COHA','CONI','CORA','CORE','COYE','DEJU','DOWO','EABL','EAKI',
                     'EAME','EAPH','EASO','EATO','EUCD','EUST','EVGR','FALC','FICR','FISP',
                     'FOSP','GCFC','GCKI','GHOW','GRAJ','GRAK','GRCA','GRSP','HAWK','HAWO',
                     'HETH','HOFI','HOLA','HORE','HOSP','HOWA','HOWR','INBU','JUNC','LALO',
                     'LEOW','LISP','LONG','LOSH','MAWA','MAWR','MEAD','MERL','MODO','MOWA',
                     'MUSW','MYWA','NAWA','NHOW','NOBO','NOCA','NOFL','NOGO','NOHA','NOMO',
                     'NOPA','NOWA','NRWS','NSHR','NSTS','NSWO','OCWA','OROR','OSPR','OVEN',
                     'PAWA','PEFA','PHVI','PIGR','PISI','PIWA','PIWO','PRAW','PROW','PUFI',
                     'PUMA','RBGR','RBNU','RBWO','RCKI','RECR','REDP','REVI','RHWO','RITD',
                     'RLHA','RNEP','ROPI','ROSW','RSHA','RTHA','RTHU','RUBL','RUGR','RWBL',
                     'SAVS','SCRE','SCTA','SEOW','SEWR','SNBU','SNOW','SOSP','SPAR','SPGR',
                     'SPPI','SSHA','SWAL','SWSP','TEWA','TRES','TUTI','TUVU','UAHA','UNAM',
                     'UNBL','UNCR','UNFI','UNFL','UNHU','UNNI','UNOR','UNOW','UNPA','UNRP',
                     'UNTA','UNTH','UNVI','UNWA','USAC','USOW','VERM','VESP','WAPI','WBNU',
                     'WCSP','WEVI','WITU','WIWA','WIWR','WOTH','WTSP','WWCR','WWDO','YBCH',
                     'YBCU','YBFL','YBSA','YHBL','YRWA','YWAR')")

# identify column with coordinates
coordinates(old_obs) <- ~ Long + Lat

# set the projection, assume WGS84
proj4string(old_obs) <- CRS("+init=epsg:4326")

# turn back to dataframe
old_obs = as.data.frame(old_obs)

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlFetch(db, "observation")
dataset = sqlFetch(db, "dataset")
odbcClose(db)

obs = dplyr::rename(obs, Lat = temp_lat, Long = temp_lon) %>% 
  mutate(obs_dt = as.Date(obs_dt,format="m%/%d/%Y"),
         observation_id = observation_id + 804175) %>% 
  filter(spp_cd %in% landbirds$spp_cd) %>% rowwise %>% 
  mutate(obs_count_general_nb = replace(obs_count_general_nb,obs_count_general_nb==obs_count_intrans_nb,NA))

# combine old and new
# creat month column
dat = bind_rows(old_obs,obs) %>% 
  dplyr::select(spp_cd, Lat, Long, obs_dt, obs_count_intrans_nb, obs_count_general_nb, dataset_id) 

all_dat = bind_rows(old_obs,obs)
write.csv(all_dat,"Z:/seabird_database/data_sent/Randy_landbirds_Jan2018/observations.csv")

num_records = dat %>% group_by(spp_cd) %>% 
  summarize(num_records = length(spp_cd)) %>% 
  arrange(-num_records) %>% 
  left_join(.,dplyr::select(landbirds,common_name,genus,species,spp_cd),by="spp_cd")
write.csv(num_records,"Z:/seabird_database/data_sent/Randy_landbirds_Jan2018/num_records.csv")

# which species have no observations
landbirds$spp_cd[!landbirds$spp_cd %in% num_records$spp_cd]
#"CASW" & "GCFC" -> GCFC is in NOAA AMAPPS 2017 not in db yet

usa <- map_data("usa")
ggplot(data =usa) + geom_polygon(aes(x = long, y = lat, group = group), fill = "#669933", color = "#333300") + 
  coord_fixed(1.3) + coord_fixed(xlim = c(-82, -65),  ylim = c(25, 47), ratio = 1.3) + 
  geom_point(data = dat, aes(x = Long, y = Lat)) + theme_bw()

ggplot(data =usa) + geom_polygon(aes(x = long, y = lat, group = group), fill = "#669933", color = "#333300") + 
  coord_fixed(1.3) + coord_fixed(xlim = c(-77, -68.5),  ylim = c(39, 45), ratio = 1.3) +
  geom_point(data = dat[dat$spp_cd %in% "WITU",], aes(x = Long, y = Lat)) + theme_bw()+
  ggtitle("Wild Turkey")

