# --------------------------------- #
# StatOil ME Hywind BOEM
#
# created July 2016, Kaycee Coleman
# --------------------------------- #

require(geosphere) # used in fixSeconds function
require(parallel) # used to make a cluster
require(rgdal) # for writeOGR
require(zoo) # fill in missing points
require(xlsx) # read excel file
require(dplyr) # 
require(data.table) # combine lists into dataframe, when not equal
require(RODBC) # odbcConnect

# DEFINE SURVEY, CHANGE THIS!!!
surveyFolder = "BOEM_StatoilME/HywindME_BOEM_Statoil_20140115"
yearLabel = "HWME_Spatial_forBOEM_2012-2013"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress/StatOil", dir), sep = "/") 
speciesPath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/"

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))

# SET PATH TO R FILE THAT FIXES DATA ERRORS
errfix.file <- file.path(dir.out, paste(gsub("-","",yearLabel), "_ObsFilesFix.R", sep = ""))

# ---------------------------------------------------------------------------- #
# STEP 1: READ IN RAW OBSERVATION DATA (in this case, mixed with track data)
# ---------------------------------------------------------------------------- #
code <- odbcConnectExcel2007(xls.file = paste(dir.in, "/", yearLabel, ".xlsx", sep=""))
s1 <- sqlFetch(code, "Statoil_Hywind_Maine_Year_1")
s2 <- sqlFetch(code, "Statoil_Hywind_Maine_Year_2")
odbcClose(code); rm(code)
s2 = s2 %>% select(-F31,-F32,-F33,-F34,-F35,-F36,-F37,-F38)
s1 = s1 %>% select(-Cor_inflock) #no difference from __in_Flock
obs = rbind(s1,s2)
rm(s1,s2)

# shapefile
sf <- readOGR(dsn = file.path(paste(dir.in,"/To BOEM_Statoil_20140115/Hywind_Maine_AvianSurveys_2012-2013/",sep="")), 
              layer = "Statoil_BioSightings_2012_2013")
sfdf=as.data.frame(sf)
names(sfdf)[names(sfdf) == "X__in_Flock"] <- "__in_Flock"
sfdf = sfdf %>% select(-F25,-F26,-F27,-Cor_infloc,-coords.x1,-coords.x2)  
obs = rbind(obs, sfdf); rm(sfdf)
names(obs)[names(obs) == "SpeciesCor"] <- "type"
obs = obs[!is.na(obs$type),]
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 2: OUTPUT COAST SURVEY DATA; FIX OBSERVATION FILE ERRORS
# ---------------------------------------------------------------------------- #
# REMOVE SPACES IN CERTAIN COLUMNS
obs <- commonErrors(obs)
obs <- fixMixed(obs) 

if (!file.exists(errfix.file)) {
  warning("Error fix R file is missing and will not be sourced.")
} else source(errfix.file, local = TRUE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 3: build transect
plot(obs$lon,obs$lat, xlim = c(-69.59,-69.47), ylim = c(43.48,43.55))
test = obs %>% select(lon, lat) %>% mutate(lon = as.numeric(lon), lat = as.numeric(lat))
test = test[test$lat>=43.48 & test$lat<=43.55,]
test = test$lon>c(-69.59) & test$lon<=c(-69.47)
approx(test$lon, test$lat, method="constant")
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 5: OUTPUT DATA 
# ---------------------------------------------------------------------------- #
save.image(paste(dir.out, "/", yearLabel, ".Rdata",sep=""))
write.csv(obs, file=paste(dir.out,"/", yearLabel,".csv", sep=""), row.names=FALSE)
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# STEP 6: SUMMARY
# ---------------------------------------------------------------------------- #
# CREATE DATA PROCESSING SUMMARY FILE
sink(file.path(dir.out, "dataProcessingSummary.txt"))
cat("Survey data folder:", dir.in, "\n\n")
cat("Error fix R file used:", errfix.file, "\n\n")
cat("\n\nFiles used:\n")
paste(dir.in, "/", yearLabel, ".xlsx", sep="")
cat("\nData points read:\n")
print(length(obs$date))
cat("Data processing completed on", date(), "\n")
sink()


