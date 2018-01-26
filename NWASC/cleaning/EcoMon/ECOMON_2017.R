# ------------ #
# ECOMON 2017 data
# GU1701
# GU1702
# GU1706
# ------------ #


# ------------ #
# load packages
# ------------ #
require(dplyr)
require(readxl)
require(odbc)
# ------------ #


# ------------ #
# load data
# ------------ #
obs <- read_excel("Z:/seabird_database/datasets_received/EcoMon/ECOMON_2017/EcomonSeabirdSightings2017.xlsx")
effort <- read_excel("Z:/seabird_database/datasets_received/EcoMon/ECOMON_2017/EcomonSeabirdEffort2017.xlsx")
# ------------ #


# ------------ #
# fix errors
# ------------ #
names(obs) = tolower(names(obs))
names(effort) = tolower(names(effort))

obs$original_species_tx = paste(obs$species,obs$comname,obs$sciname,sep="_")

# look up species errors
db <- dbConnect(odbc::odbc(), driver='SQL Server', server='ifw-dbcsqlcl1', database='NWASC')
spplist = dbGetQuery(db,"select * from lu_species2")

tmp <- !obs$species %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$species[tmp]))

obs$species[obs$species %in% "BASW"] = "BARS" #Barn swallow
obs$species[obs$species %in% "LEST"] = "LETE" #least tern
obs$species[obs$species %in% "LHSP"] = "UNSP" #Leach's/Hartcourt's storm-petrel
obs$species[obs$species %in% "PASS"] = "UNPA" 
obs$species[obs$species %in% "RWBB"] = "RWBL" #Red-winged blackbird
obs$species[obs$species %in% "STTE"] = "CATE" #Common/Arctic tern
obs$species[obs$species %in% "TRPE"] = "HEPE" #Trinidad petrel aka Herald Petrel
obs$species[obs$species %in% "WTTB"] = "WTTR" #White-tailed tropicbird

# split time and date

# ------------ #


# ------------ #
# split by survey and assign id
# ------------ #
# ------------ #
