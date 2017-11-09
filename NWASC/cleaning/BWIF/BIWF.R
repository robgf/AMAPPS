# -------------------------------- #
# QA/QC Deepwater Wind Block Island
# -------------------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(rgdal) # read shapefiles
require(dplyr)
library(readxl)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "BIWF"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
# -------------------------------- #


# -------------------------------- #
# load boat data and transects
# -------------------------------- #
data = read_excel(paste(dir.in,"2016-11-09_BIWF OFFSHORE AVIAN DATA 0709 - 0610.xls",sep="/"))
hd.data = read_excel(paste(dir.in,"2016-11-09_BIWF Full Year HD Aerial Data.xlsx",sep="/"), 
                         sheet = "12 month HD data Avian Only")
ons.data = odbcConnectExcel2007(paste(dir.in,"2016-11-09_BIWF ONS 0709 - 0610.xlsx",sep="/"))
on.avian = sqlFetch(ons.data, "DATA - ONSHORE AVIAN")
on.weather = sqlFetch(ons.data, "ONSHORE WEATHER")
on.pt = sqlFetch(ons.data, "PT-Weather Avgs")
on.cormmet = sqlFetch(ons.data, "Corm and Met")
on.dist = sqlFetch(ons.data, "Data for Distance")
odbcCloseAll()
rm(ons.data)

bat.data = read_excel(paste(dir.in,"2016-11-09_BIWF BATS SUMMER 2009.xls",sep="/"))                                                                                                                               
bio.data = read_excel(paste(dir.in,"2016-11-09_BIWF Biological Survey Data Summer Fall 2009 Tt.xls",sep="/"))                                                                                                     
#metadata = read.table(paste(dir.in,"2016-11-09_BIWF_AvianBat_MetaData.xlsx",sep="/"),header="TRUE")                                                                                                                             
raptor.data = read_excel(paste(dir.in,"2018-11-09_BIWF RAPTOR DATA 2009 - 2010.xls",sep="/"))                                                                                                                    

#radar.merlin = readOGR(dir.in,'BIWF_MERLIN_Radar_Location')
#radar.vesper = readOGR(dir.in,'BIWF_VESPER_Radar_Location')
#radar.ns = readOGR(dir.in,'BIWF_MERLIN_Radar_Nearshore_VSR')
#radar.off = readOGR(dir.in,'BIWF_MERLIN_Radar_Offshore_HSR')
#radar.on = readOGR(dir.in,'BIWF_MERLIN_Radar_Onshore_VSR')
bat.pt = readOGR(dir.in,'BIWF_Offshore_Active_Bat_Sampling_Point')
bat.trans = readOGR(dir.in,'BIWF_Offshore_Active_Bat_Sampling_Transect')
hd.trans = readOGR(dir.in,'BIWF_Offshore_Aerial_HD_Video_Strip_Transects')
trans.segs = readOGR(dir.in,'BIWF_Offshore_Boat-Based_Avian_Survey_Transect_Segments')
trans = readOGR(dir.in,'BIWF_Offshore_Boat-Based_Avian_Survey_Transects')
#bat.pt.on = readOGR(dir.in,'BIWF_Onshore_Active_Bat_Sampling_Points')
#avian.on.mon.pt = readOGR(dir.in,'BIWF_Onshore_Avian_Acoustic_Monitoring_Points')
#bat.on.trans = readOGR(dir.in,'BIWF_Onshore_Bat_Survey_Transects')
#bat.on.pass = readOGR(dir.in,'BIWF_Onshore_Passive_Bat_Sampling_Points')
#raptor.on = readOGR(dir.in,'BIWF_Onshore_Raptor_Migration_Survey_Points')
avian.on.cov = readOGR(dir.in,'BIWF_Onshore_Sea_Watch_Avian_Survey_Coverage')
avian.on.surv.pt = readOGR(dir.in,'BIWF_Onshore_Sea_Watch_Avian_Survey_Points')

# -------------------------------- #



# -------------------------------- #
# fix species
# -------------------------------- #
db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

# -------------------------------- #


