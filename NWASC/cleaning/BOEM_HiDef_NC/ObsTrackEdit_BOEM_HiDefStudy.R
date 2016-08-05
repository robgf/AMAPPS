# ------------------------------------------------------------------------- #
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
#
# ------------------------------------------------------------------------- #

# ------------------------------------------------------------------------- #
# DEFINE SURVEY, CHANGE THIS!!!
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
# ------------------------------------------------------------------------- #

# ------------------------------------------------------------------------- #
# STEP 1: Load data
# ------------------------------------------------------------------------- #
database = odbcConnectAccess2007(file.path(dir.in, "N_Carolina_data_2011_3 platforms_for DBigger.accdb")) 
spptbl = sqlFetch(database, "All_taxa_tbl", stringsAsFactors = FALSE)
fieldData = sqlFetch(database, "field_data_tbl")
fieldData = fieldData[order(fieldData$ID),]
enviroData = sqlFetch(database, "environ_data_tbl", stringsAsFactors = FALSE)
GPSdata = sqlFetch(database, "GPS_tbl")

## Ignore Camera data for now as it is priority 3 and might require additional formating
# CameraGPSdata = sqlFetch(database, "Camera GPS data")
# CameraData = sqlFetch(database, "Camera target data")

# list of codes used by BOEM
Species_Information = sqlQuery(database, 
  paste("SELECT All_taxa_tbl.species_code, All_taxa_tbl.common_name, All_taxa_tbl.species, bird_list_AOU_NAm_tbl.*
         FROM bird_list_AOU_NAm_tbl 
         RIGHT JOIN All_taxa_tbl 
         ON bird_list_AOU_NAm_tbl.common_name = All_taxa_tbl.common_name;"))

starts = rbind(sqlQuery(database, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%start%'));")),
               sqlQuery(database, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%began%'));")),
               sqlQuery(database, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%begin%'));")))
# exclude ID 2662 this section might be cut...

ends = rbind(sqlQuery(database, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                      FROM field_data_tbl 
                                      WHERE (((field_data_tbl.comments) Like '%end%'));")), 
             sqlQuery(database, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                      FROM field_data_tbl 
                                      WHERE (((field_data_tbl.comments) Like '%stop%'));")))
transit = rbind(sqlQuery(database, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%transit%'));")),
                sqlQuery(database, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                        FROM field_data_tbl 
                                        WHERE (((field_data_tbl.comments) Like '%off effort%'));")))
transect = rbind(sqlQuery(database, paste("SELECT field_data_tbl.comments, field_data_tbl.ID 
                                      FROM field_data_tbl 
                                      WHERE (((field_data_tbl.comments) Like '%transect%'));")))
# close database
odbcCloseAll()

# exclude ID 1889 
ends = ends[ends$ID != 1889,]

# create BEG and END Counts
#fieldData$type = NA
#fieldData$type[fieldData$ID %in% ends$ID] = "ENDCNT"
#fieldData$type[fieldData$ID %in% starts$ID] = "BEGCNT"
#rm(ends,starts)

# create offline (1) / online (0)
fieldData$offline = ""
fieldData$offline[fieldData$ID %in% transit$ID] = 1
fieldData$offline[fieldData$ID %in% transect$ID] = 0
rm(transect,transit)
# ------------------------------------------------------------------------- #

# ------------------------------------------------------------------------- #
# STEP 2: RESTRUCTURE DATA
# ------------------------------------------------------------------------- #

# --------------------------- # 
## GPS
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/@lat"] = "lat"
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/@lon"] = "long"
names(GPSdata)[names(GPSdata) == "/trk/trkseg/trkpt/time"] = "time"
GPSdata$platform = tolower(GPSdata$platform)
# --------------------------- # 

# --------------------------- # 
## Species Information
# edit the table to consolidate
Species_Information$scientific_name = as.character(Species_Information$scientific_name)
Species_Information$scientific_name[is.na(Species_Information$scientific_name) & !is.na(Species_Information$species)] = 
  as.character(Species_Information$species[is.na(Species_Information$scientific_name) & !is.na(Species_Information$species)])
Species_Information$common_name = as.character(Species_Information$common_name)
Species_Information$commonc_name[is.na(Species_Information$common_name) & !is.na(Species_Information$common_name.1)] = 
  as.character(Species_Information$common_name.1[is.na(Species_Information$common_name) & !is.na(Species_Information$common_name.1)])
drops <- c("french_name","E","I","H","A","N","M","species","ID", "common_name.1")
Species_Information = Species_Information[,!(names(Species_Information) %in% drops)]

common_name = tolower(Species_Information$common_name)
spplist = as.character(Species_Information$species_code)

# list of codes we are using
codes = odbcConnectExcel2007(file.path(dbpath, "NWASC_codes.xlsx"), readOnly = TRUE) 
name <- sqlFetch(codes,"codes")
odbcCloseAll()

if (!file.exists(errfix.file)) {
  warning("Error fix R file is missing and will not be sourced.")
} else source(errfix.file, local = TRUE)

tmp = !spplist %in% name$spp_cd
cat("Found", sum(tmp), "out of",  length(spplist), "entries with non-matching AOU code(s).\n\n")
# spplist[!spplist %in% name$spp_cd]

Species_Information$spp = spplist
fieldData$species = tolower(fieldData$species)

#df = data.frame(cbind(species = common_name, spp_type = spplist), stringsAsFactors = FALSE)
#test = left_join(fieldData, df, by = "species") %>% rowwise %>% mutate(type = replace(type, is.na(type), spp_type))

# test = data.frame(cbind(species = common_name, spp_type = spplist), stringsAsFactors = FALSE) %>%
#        left_join(fieldData, ., by = "species") %>% rowwise %>% mutate(type = replace(type, is.na(type), spp_type)) %>% data.frame

fieldData$type = ""
for (a in 1:length(fieldData$species)) {
  fieldData$type[a] = spplist[fieldData$species[a] == common_name]
}
fieldData$type[fieldData$ID %in% ends$ID] = "ENDCNT"
fieldData$type[fieldData$ID %in% starts$ID] = "BEGCNT"
rm(ends,starts)

# errors (some were in the middle of transects, rather than at the end)
fieldData$type[fieldData$ID == c("590","678","702","710","717","725","731","735",
                                 "733","855","901","999","1060","1076","1191",
                                 "1213", "1297")] = "ENDCNT"
fieldData$type[fieldData$ID == c("679","703","711","718","726","732","736","856",
                                 "902","910","1000","1061","1298","1360")] = "BEGCNT"
fieldData$type[fieldData$ID == c("1788") = "COMMENT"

# --------------------------- # 

# --------------------------- # 
## Observation
  if (is.null(fieldData$dataChange)) {
    fieldData$dataChange <- ""
    fieldData$dataError <- "" }

  # add species codes to field data table
  b = tolower(Species_Information$common_name)
  c = tolower(fieldData$species)
  for (a in 1:length(Species_Information[,1])) {
    fieldData$spp_cd[c == b[a]] = Species_Information$species_code[a]
  }

  fieldData$crew = sub("^\\s+", "", tolower(paste(fieldData$obs_first_name, fieldData$obs_last_name, sep = "_")))
  fieldData$crew[fieldData$crew == "allison_mac connell"] = "allison_macconnell"
  fieldData$crew[fieldData$crew == "mary jo_barkaszi"] = "maryjo_barkaszi"
  #fieldData$crew[fieldData$crew == "erik_haney"] = "eric_haney" # probably???????????????????????
  drops = c("obs_first_name", "obs_last_name", "End Transect", "Start Transect", "missing_sp")
  fieldData = fieldData[,!(names(fieldData) %in% drops)]
  fieldData$platform = tolower(fieldData$platform)

  # BEGCNT and ENDCNT
  # is.na(fieldData$spp_cd[which(fieldData$ID %in% ends$ID)]) #check
  # is.na(fieldData$spp_cd[which(fieldData$ID %in% starts$ID)]) #check
  fieldData$spp_cd[which(fieldData$ID %in% ends$ID)] = "ENDCNT"
  fieldData$spp_cd[which(fieldData$ID %in% starts$ID)] = "BEGCNT"
  rm(starts,ends)
  # add BEGCNT after ENDCNT if there is a NA directly after
  


####################### FIX THIS #######################################




a = which(fieldData$spp_cd == "ENDCNT") - 1
  b = which(is.na(fieldData$spp_cd))
  c = b-a
  fieldData$dataChange[)] = 
    paste(fieldData$dataChange[which(is.na(fieldData$spp_cd[a+1]))],
          "; Changed SPP_CD from NA based ENDCNT", sep = "")
  fieldData$spp_cd[which(is.na(fieldData$spp_cd[a+1]))] ="BEGCNT"
  # add BEGCNT after ENDCNT if there is a NA directly after
  a = which(fieldData$spp_cd == "BEGCNT")
  fieldData$dataChange[which(is.na(fieldData$spp_cd[a-1]))] = 
    paste(fieldData$dataChange[which(is.na(fieldData$spp_cd[a-1]))],
          "; Changed SPP_CD from NA based BEGCNT", sep = "")
  fieldData$spp_cd[which(is.na(fieldData$spp_cd[a-1]))] ="ENDCNT"


  # cut unnecessary columns
  #fieldData$comments[!is.na(fieldData$F26)] = paste(fieldData$comments[!is.na(fieldData$F26)], 
  #                                                  fieldData$F26[!is.na(fieldData$F26)], sep ="; ")
  drops <- c("Observers", "Data-sheet ID", "F26")
  fieldData = fieldData[,!(names(fieldData) %in% drops)]

  # fix time stamps and 
  # add lat and long to observations
  library(lubridate)
  df <- data.frame(date = fieldData$obs_time_rd, #satellite_GPS_time,
                   hr = as.numeric(format(fieldData$obs_time_rd, format = "%H")),
                   min = as.numeric(format(fieldData$obs_time_rd, format = "%M")),
                   sec = as.numeric(format(fieldData$obs_time_rd, format = "%S")))
  fieldData$year_[fieldData$year_ == 11] = 2011
  fieldData$date = ISOdatetime(fieldData$year_, fieldData$month_, fieldData$day, df$hr, df$min, df$sec) #Y m d H M S
   
  rm(df)
  df <- data.frame(date = GPSdata$GPS_time_rd,
                   hr = as.numeric(format(GPSdata$GPS_time_rd , format = "%H")),
                   min = as.numeric(format(GPSdata$GPS_time_rd , format = "%M")),
                   sec = as.numeric(format(GPSdata$GPS_time_rd , format = "%S")))
  GPSdata$date = ISOdatetime(GPSdata$year_, GPSdata$month_, GPSdata$day, df$hr, df$min, df$sec) #Y m d H M S
  rm(df)

  # create time index
# this does not get everything....
  for (a in 1: length(fieldData$date)) {
    fieldData$lat[a] = GPSdata$lat[fieldData$date[a] == GPSdata$date & fieldData$platform[a] == GPSdata$platform]
    fieldData$long[a] = GPSdata$long[fieldData$date[a] == GPSdata$date & fieldData$platform[a] == GPSdata$platform]
  }

    
  # fill in spots were transect number is missing using event number, but if all NA's can't fix now
  a = which(fieldData$event_number == 1)
  old = fieldData$"Transect ID"
  for (b in 2:length(a)) {
    c = a[b-1]:(a[b]-1)
    fieldData$"Transect ID"[c] = median(fieldData$"Transect ID"[c], na.rm = TRUE)
    if (length(which(old[c] != fieldData$"Transect ID"[c])) != 0) {
      d = which(old[c] != fieldData$"Transect ID"[c])
      fieldData$dataChange[c[d]] = paste(fieldData$dataChange[c[d]], "; TRANSECT ID changed from ", old[c[d]], sep = "")
    }
  }
  fieldData$"Transect ID" = as.character(fieldData$"Transect ID")

  

## Crew

  Crew_Information = data.frame(matrix(nrow = length(unique(fieldData$crew)), ncol = 3))
  colnames(Crew_Information) = c("crew","obs_first_name","obs_last_name")
  Crew_Information$crew = unique(fieldData$crew)
  
  a = strsplit(Crew_Information$crew,"_")
  b  <- matrix(unlist(a), ncol=2, byrow=TRUE)
  Crew_Information$obs_first_name = b[,1]
  Crew_Information$obs_last_name = b[,2]
  Crew_Information$obs_first_name[Crew_Information$obs_first_name == "maryjo"] = "mary jo"
  Crew_Information$obs_last_name[Crew_Information$obs_last_name == "macconnell"] = "mac connell"
  rm(a,b)
  
  # Capitalize names
  capwords <- function(s, strict = FALSE) {
    cap <- function(s) paste(toupper(substring(s, 1, 1)),
  {s <- substring(s, 2); if(strict) tolower(s) else s},
                             sep = "", collapse = " " )
    sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
  }
  Crew_Information$obs_first_name = capwords(Crew_Information$obs_first_name)
  Crew_Information$obs_last_name = capwords(Crew_Information$obs_last_name)
  
  # remove Na row
  Crew_Information = Crew_Information[Crew_Information$crew != "na_na",]

## Behavior
  fieldData$behavior = tolower(fieldData$behavior)
  Behaviors = data.frame(matrix(nrow = length(unique(fieldData$behavior)), ncol = 2))
  colnames(Behaviors) = c("code","action")
  Behaviors$action = unique(fieldData$behavior)

  
  Behaviors = Behaviors[order(Behaviors$code),]

  #fieldData$comments[!is.na(fieldData$behavior)] = paste(fieldData$comments[!is.na(fieldData$behavior)],
  #                                                       fieldData$behavior[!is.na(fieldData$behavior)], 
  #                                                       sep = "; behavior defined ")
  #fieldData$behavior[which(fieldData$behavior %in% fieldData$action)] = Behaviors$code

## Environmental
  # holding off on this for now...visability in fieldData should be enough for db



# ------------------------------------------------------------------------- #
# STEP 3: FIND ERRORS AND FIX DATA
# ------------------------------------------------------------------------- #
obs = fieldData
obs$type = obs$species
obs$count = obs$number_individuals

# SET INPUT/OUTPUT DIRECTORY PATHS
dir.in <- inpath 
dir.out <- path
speciesPath = dbpath
dbpath <- dbpath

# SET PATH TO R FILE THAT FIXES DATA ERRORS
errfix.file <- file.path(dir.out, paste(yearLabel, "_ObsFilesFix.R", sep = ""))

# SOURCE R FUNCTIONS
source(file.path(dir, "_Rfunctions/sourceDir.R"))
sourceDir(file.path(dir, "_Rfunctions"))
# ---------------------------------------------------------------------------- #
# STEP 3a: OUTPUT COAST SURVEY DATA; FIX OBSERVATION FILE ERRORS
# ---------------------------------------------------------------------------- #

if (!file.exists(errfix.file)) {
  warning("Error fix R file is missing and will not be sourced.")
} else source(errfix.file, local = TRUE)
# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# STEP 3b: CHECK OBSERVATION FILES FOR ERRORS, DOCUMENT IN .CSV FILE
# ---------------------------------------------------------------------------- #
obs <- errorCheckObsFiles(obs, dir.out, error.flag = TRUE)

# STOP IF ERRORS STILL EXIST IN OBSERVATION FILES
if (obs[["errorStatus"]] == 1) {
  stop("Errors still exist in observation files. These must be fixed before continuing.")
} else obs <- obs[["data"]]

# SUMMARIZE CERTAIN DATA COLUMNS
tmp <- !is.na(obs$count) & obs$offline == 0 & 
  !(obs$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH"))
if (!is.null(obs$band)) {
  out.obssum <- summary(obs[tmp, c("lat", "long", "sec", "GPSerror", "count", "band")])
} else {
  out.obssum <- summary(obs[tmp, c("lat", "long", "sec", "GPSerror", "count")])
}
# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# STEP 3c: RE-ORGANIZE OBSERVATION AND TRACK DATA INTO SEPARATE LISTS CONTAINING 
#         UNIQUE DATA FRAMES - ONE DATA FRAME FOR EACH COMBINATION OF OBSERVER 
#         AND DAY
# ---------------------------------------------------------------------------- #
# RE-ORGANIZE OBSERVATION DATA
obs$key <- paste(obs$crew, obs$seat, obs$year, obs$month, obs$day, sep = "_")
obs <- split(obs, list(obs$key))

# RE-ORGANIZE TRACK DATA
track$key <- paste(track$crew, track$seat, track$year, track$month, track$day, sep = "_")
track <- split(track, list(track$key))
# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# STEP 3d: FIX MISSING SECONDS VALUES IN OBSERVATION FILES
# ---------------------------------------------------------------------------- #
obs <- lapply(setNames(names(obs), names(obs)), function(x) fixSeconds(obs[[x]], track[[x]]))
# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# STEP 3e: ADD BEG/END POINTS WHERE NEEDED IN OBSERVATION FILES
# ---------------------------------------------------------------------------- #
obs <- suppressMessages(lapply(obs, addBegEnd_obs))
# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# STEP 3f: COMBINE OBSERVATION FILES & TRACK FILES, OUTPUT EDITED
#         TRACK FILES CONTAINING ONLY SURVEY SEGMENTS (WITH OBSERVATIONS)
# ---------------------------------------------------------------------------- #
obstrack <- lapply(setNames(names(obs), names(obs)), function(x) {
  alt <- names(track)[sapply(strsplit(names(track), "_"), function(y) all(y[-2] == strsplit(x, "_")[[1]][-2]))]
  combineObsTrack(obs[[x]], track[[x]], track[[alt[alt != x][1]]])
})
obstrack <- do.call(rbind.data.frame, obstrack)
obstrack <- obstrack[order(obstrack$crew, obstrack$seat, obstrack$year, obstrack$month, 
                           obstrack$day, obstrack$sec, obstrack$index), ]
row.names(obstrack) <- NULL
obstrack$ID <- as.numeric(row.names(obstrack))
# ---------------------------------------------------------------------------- #

###################################################################################




#new = sqlQuery(database, paste("SELECT field_data_tbl.*, All_taxa_tbl.species_code, bird_list_AOU_NAm_tbl.scientific_name
#FROM (field_data_tbl INNER JOIN All_taxa_tbl ON field_data_tbl.species = All_taxa_tbl.common_name) INNER JOIN bird_list_AOU_NAm_tbl ON field_data_tbl.species = bird_list_AOU_NAm_tbl.common_name;"))



# ------------------------------------------------------------------------- #
# STEP 3: FIX OBSERVATION FILE ERRORS
# look at yearlab_AOUErrors.xlsx and yearlab_ObsFileErrors.xlsx for help
# ------------------------------------------------------------------------- #

# ------------------------------------------------------------------------- #
# seperate boat (Voyager) from plane (Vplane)
boat = 
plane = 


if(platform == "Vplane") {
  
} else if (platform == "Voyager") {
  
} else


  
  
  
  
  
  
  # ------------------------------------------------------------------------- #
Observations = data.frame(matrix(ncol = 54))
colnames(Observations) = c("observation_id", "transect_id", "dataset_id", "local_obs_id", "local_transect_id",
                          "source_obs_id", "source_transect_id", "source_dataset_id", "obs_dt", "obs_start_tm", 
                          "observers_tx", "original_species_tx", "spp_cd", "obs_count_intrans_nd", "obs_count_general_nb", 
                          "animal_age_tx", "plumage_tx", "behavior_tx", "travel_direction_tx", "flight_height_tx",
                          "distance_to_animal_tx", "angle_from_observer_nb", "visibility_tx", "weather_tx", "seastate_beaufort_nb",
                          "wind_speed_tx", "wind_dir_tx", "seasurface_tempc_nb", "comments_tx", "animal_sex_tx",
                          "obs_end_tm", "cloud_cover_tx", "association_tx", "who_created_tx", "who_created",
                          "date_created", "boem_lease_block_id", "whole_transect", "temp_lat", "temp_lon", 
                          "date_imported", "who_imported", "salinity_ppt_nb", "admin_notes", "platform_tx",
                          "station_tx", "survey_type", "heading_tx", "wave_height_tx", "obs_position",
                          "glare_tx", "whitecaps_tx", "visit","time_from_midnight")

Transect = data.frame(matrix(ncol = 21))
colnames(Transect) = c("transect_id", "dataset_id", "source_transect_id", "source_dataset_id", "start_dt",
                       "start_tm", "end_dt", "end_tm", "transect_time_min_nb", "transect_distance_nb", 
                       "traversal_speed_nb", "transect_width_nb", "observers_tx", "visability_tx", "weather_tx", 
                       "seastate_beaufort_nb", "windspeed_tx", "wind_dir_tx", "seasurface_tempc_nb", "comments_tx",
                       "track_gs")

odbcCloseAll()
# ------------------------------------------------------------------------- #

Observations$platform_tx = platform

# information for production_dataset table
# can be found in "FWS IAA Phase II list revised 07.01.2015" spreadsheet (most recent on google drive)

## ariel (Vplane)
#dataset_id = 144
#survey_type_cd = "a"
#survey_method_cd = NULL
#dataset_type_cd = NULL
#original_dataset_id = NULL
#metadata_tx = NULL
#source_dataset_id = "BOEMHighDef_NC2011Aerial"

## boat (voyager)
#dataset_id = 143
#survey_type_cd = "b"
#survey_method_cd = NULL
#dataset_type_cd = NULL
#original_dataset_id = NULL
#metadata_tx = NULL
#source_dataset_id = "BOEMHighDef_NC2011Boat"
# ------------------------------------------------------------------------- #














# observation



