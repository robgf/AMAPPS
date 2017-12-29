# --------------------- #
# NOAA/ NMFS/ NEFSC AMAPPS boat 2017
# Date Created: 12/2017
# Author: K. Coleman
# --------------------- #


# --------------------- #
# load packages
# --------------------- #
require(rgdal)
require(lubridate)
require(RODBC)
require(ggplot2)
require(zoo)
require(dplyr)
library(readxl)
library(odbc)
# --------------------- #


# --------------------- #
# get data
# --------------------- #
obs <- read_excel("Z:/seabird_database/datasets_received/NOAA NMFS/NEFSC_AMAPPS_ship_2017/HRS1701SeabirdSightExport.xlsx")
track <- read_excel("Z:/seabird_database/datasets_received/NOAA NMFS/NEFSC_AMAPPS_ship_2017/HRS1701SeabirdEffortExport.xlsx")
# --------------------- #


# --------------------- #
# fix errors
# --------------------- #
# check species
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
spplist = dbGetQuery(db,"select * from lu_species")

tmp <- !obs$SPECIES %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$SPECIES[tmp]))

#obs$SPECIES[obs$SPECIES %in% "AGPL"] = "" 
#obs$SPECIES[obs$SPECIES %in% "AMRS"] = "" 
#obs$SPECIES[obs$SPECIES %in% "CEWA"] = "" 
#obs$SPECIES[obs$SPECIES %in% "GCFC"] = "" 

obs$SPECIES[obs$SPECIES %in% "DUCK"] = "UNDU" 
obs$SPECIES[obs$SPECIES %in% "PASS" & obs$COMMENTS %in% c("unid warbler","warbler sp.")] = "UNWA" 
obs$SPECIES[obs$SPECIES %in% "PASS" & obs$COMMENTS %in% c("likely brown-headed cowbird")] = "BHCO" 
obs$SPECIES[obs$SPECIES %in% "PASS"] = "UNPA" 
#obs$SPECIES[obs$SPECIES %in% "PLOV"] = "UNPL" 
