# -------------------------------- #
# Date Created: 7-2015
# Author: Kaycee Coleman
#
# Description: This program reads in the pilot and observer raw observation 
# files and creates a header row. It then checks for general errors & 
# BEGSEG/ENDSEG errors and outputs a .csv file documenting these errors 
# (ObsFiles_Errors.csv). It then fixes the observation file errors, reads in 
# the pilot and observer raw track files and creates a header row, compares 
# the track files to the observation files, and outputs the edited track 
# files containing only the survey segments.
# -------------------------------- #


# -------------------------------- #
# LOAD PACKAGES
# -------------------------------- #
require(RODBC) # odbcConnect
require(lubridate) #fix timestamps
require(zoo) #na.locf
require(dplyr) # 
# -------------------------------- #


# -------------------------------- #
# DEFINE SURVEY
# -------------------------------- #
surveyFolder = "BOEM_HiDef_NC"
yearLabel = "BOEM_HiDefStudy"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing"
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
speciesPath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/"

# SOURCE R FUNCTIONS
source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))

# SET PATH TO R FILE THAT FIXES DATA ERRORS
errfix.file <- file.path(dir.out, paste(yearLabel, "_ObsFilesFix.R", sep = ""))
# -------------------------------- #


# -------------------------------- #
# STEP 1: Load data
# -------------------------------- #
db = odbcConnectAccess2007(file.path(dir.in, "N_Carolina_data_2011_3 platforms_for DBigger.accdb")) 
spptbl = sqlFetch(db, "All_taxa_tbl", stringsAsFactors = FALSE)
fieldData = sqlFetch(db, "field_data_tbl")
fieldData = fieldData[order(fieldData$ID),]
enviroData = sqlFetch(db, "environ_data_tbl", stringsAsFactors = FALSE)
GPSdata = sqlFetch(db, "GPS_tbl")
CameraGPSdata = sqlFetch(db, "Camera GPS data")
CameraData = sqlFetch(db, "Camera target data")

# list of codes used by BOEM
Species_Information = sqlQuery(db, 
  paste("SELECT All_taxa_tbl.species_code, All_taxa_tbl.common_name, All_taxa_tbl.species, bird_list_AOU_NAm_tbl.*
         FROM bird_list_AOU_NAm_tbl 
         RIGHT JOIN All_taxa_tbl 
         ON bird_list_AOU_NAm_tbl.common_name = All_taxa_tbl.common_name;"))

starts = rbind(sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%start%'));")),
               sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%began%'));")),
               sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%begin%'));")),
               sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%resume%'));")))

ends = rbind(sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                      FROM field_data_tbl 
                                      WHERE (((field_data_tbl.comments) Like '%end%'));")), 
             sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                      FROM field_data_tbl 
                                      WHERE (((field_data_tbl.comments) Like '%stop%'));")))

transit = rbind(sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%transit%'));")),
                sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%off effort%'));")))
transect = rbind(sqlQuery(db, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                      FROM field_data_tbl 
                                      WHERE (((field_data_tbl.comments) Like '%transect%'));")))
# close database
odbcCloseAll()
# -------------------------------- #


# -------------------------------- #
# STEP 2: QA/QC
# -------------------------------- #
# exclude ID 2662 this section might be cut...
# starts = starts[ends$ID != 2662,]

# exclude ID 1889 
ends = ends[ends$ID != 1889,]

# create BEG and END Counts
fieldData$type = NA
fieldData$type[fieldData$ID %in% ends$ID] = "ENDCNT"
fieldData$type[fieldData$ID %in% starts$ID] = "BEGCNT"
rm(ends,starts)

# create offline (1) / online (0)
fieldData$offline = ""
fieldData$offline[fieldData$ID %in% transit$ID] = 1
fieldData$offline[fieldData$ID %in% transect$ID] = 0
rm(transect,transit)

if (!file.exists(errfix.file)) {
  warning("Error fix R file is missing and will not be sourced.")
} else source(errfix.file, local = TRUE)
# --------------------------- # 


# -------------------------------- #
# STEP 3: EXPORT DATA
# -------------------------------- #

## ariel (Vplane)
planeObs$dataset_id = 144
planeGPS$dataset_id = 144
planeObs$source_dataset_id = "BOEMHighDef_NC2011Aerial"
planeGPS$source_dataset_id = "BOEMHighDef_NC2011Boat"

## boat (voyager)
boatObs$dataset_id = 143
boatGPS$dataset_id = 143
boatObs$source_dataset_id = "BOEMHighDef_NC2011Boat"
boatGPS$source_dataset_id = "BOEMHighDef_NC2011Boat"

# camera
cameraObs$dataset_id = 169
cameraTransect$dataset_id = 169
CameraGPSdata$dataset_id = 169
cameraObs$source_dataset_id = "BOEMHighDef_NC2011Camera"
cameraTransect$source_dataset_id = "BOEMHighDef_NC2011Camera"
CameraGPSdata$source_dataset_id = "BOEMHighDef_NC2011Camera"

# workspace and cvs
save.image(paste(dir.out,"BOEMHiDef_NC2011.Rdata",sep="/"))

write.csv(planeObs, file=paste(dir.out,"BOEMHiDef_NC2011_aerial.csv",sep="/"), row.names = FALSE)
write.csv(planeGPS, file=paste(dir.out,"BOEMHiDef_NC2011_aerial_track.csv",sep="/"), row.names = FALSE)
write.csv(planeTransects, file=paste(dir.out,"BOEMHiDef_NC2011_aerial_transects.csv",sep="/"), row.names = FALSE)

write.csv(boatObs, file=paste(dir.out,"BOEMHiDef_NC2011_boat.csv",sep="/"), row.names = FALSE)
write.csv(boatGPS, file=paste(dir.out,"BOEMHiDef_NC2011_boat_track.csv",sep="/"), row.names = FALSE)
write.csv(boatTransects, file=paste(dir.out,"BOEMHiDef_NC2011_boat_transects.csv",sep="/"), row.names = FALSE)

write.csv(CameraData, file=paste(dir.out,"BOEMHiDef_NC2011_camera_obs.csv",sep="/"), row.names = FALSE)
write.csv(CameraTransect, file=paste(dir.out,"BOEMHiDef_NC2011_camera_transect.csv",sep="/"), row.names = FALSE)
write.csv(CameraGPSdata, file=paste(dir.out,"BOEMHiDef_NC2011_camera_track.csv",sep="/"), row.names = FALSE)
write.csv(duplicates, file=paste(dir.out,"BOEMHiDef_NC2011_camera_obs_deleted_duplicates.csv",sep="/"), row.names = FALSE)

# ------------------------------------------------------------------------- #



