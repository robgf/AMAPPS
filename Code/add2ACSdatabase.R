# ------------------------------------------------------------------------- #
# add2ACSdatabase.R
# formally Add2Database2.R
# Date Created: 2013-07-24
# Author: JBL
# edited Jan. 2016 by Kaycee Coleman
#
# Description: 
# This script adds the AMAPPS observations, tracks, etc. to the 
# Atlantic Coast Surveys accesss database and adds obs.misc 
# (e.g. marine mammals) to Atlantic_Coast_Surveys_MiscObservations.csv
# ------------------------------------------------------------------------- #


# SET DIRECTORIES
# ------------------------------------------------------------------------- #
yearLabel = "AMAPPS_2013_09" # CHANGE THIS!!!!!!!!!!!!
dir = paste("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/Surveys/AMAPPS/",
            yearLabel, sep="")
dbpath = "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"



# OBSERVATIONS TABLE
# ------------------------------------------------------------------------- #
obs = read.csv(file.path(dir, yearLabel, "_Observations.csv"), 
               stringsAsFactors = FALSE)

# GET SPECIES_INFORMATION TABLE FROM ATLANTIC COAST SURVEYS DATABASE
database = odbcConnectAccess2007(file.path(dbpath, "Atlantic_Coast_Surveys.accdb"))
Database_Species_Information = sqlFetch(database, "Species_Information", as.is = TRUE)
odbcCloseAll()

# CHECK TO MAKE SURE THERE ARE NO NON-SURVEY SPECIES IN OBSERVATIONS FILE
sort(unique(obs$Species))[which(!(sort(unique(obs$Species)) %in% sort(unique(Database_Species_Information$Species))))]

# ------------------------------------------------------------------------- #


# TRACKS TABLE
# ------------------------------------------------------------------------- #
tracks = read.csv(file.path(dir, paste(yearLabel,"_Tracks.csv"),sep=""), stringsAsFactors = FALSE)

# ------------------------------------------------------------------------- #


# TRANSECT INFORMATION TABLE
# ------------------------------------------------------------------------- #
ti = read.csv(file.path(dir, "DataProcessing/",yearLabel,"_Transect_Information.csv"), 
              stringsAsFactors = FALSE)
# ------------------------------------------------------------------------- #


# CREW INFORMATION TABLE
# ------------------------------------------------------------------------- #
ci = subset(ti, select = c(SurveyNbr, Crew, Seat, Obs))
ci = ci[!duplicated(ci), ]
ci = reshape(ci, timevar = "Seat", idvar = c("SurveyNbr", "Crew"), direction = "wide")
ci$PilInitials = ci$Obs.lf
ci$ObsInitials = ci$Obs.rf
ci$PilName = ""
ci$ObsName = ""
ci = ci[order(ci$SurveyNbr, ci$Crew), ]
ci = subset(ci, select = c(SurveyNbr, Crew, PilInitials, ObsInitials, PilName, ObsName))
# ------------------------------------------------------------------------- #


# SURVEY INFORMATION TABLE
# ------------------------------------------------------------------------- #
si = tracks
si$date = as.Date(paste(si$Month, si$Day, si$Year, sep = "/"), "%m/%d/%Y")
si.min = aggregate(date ~ SurveyNbr, min, data = si)
names(si.min) = gsub("date", "SurveyStartDt", names(si.min))
si.max = aggregate(date ~ SurveyNbr, max, data = si)
names(si.max) = gsub("date", "SurveyEndDt", names(si.max))
si = merge(si.min, si.max, all = TRUE)
si$SurveyDescription = ""
si = subset(si, select = c(SurveyNbr, SurveyDescription, SurveyStartDt, SurveyEndDt))
# ------------------------------------------------------------------------- #


# ADD DATA TO ATLANTIC COAST SURVEYS DATABASE
# ------------------------------------------------------------------------- #
database = odbcConnectAccess2007(file.path(dbpath, "Atlantic_Coast_Surveys.accdb"))
sqlSave(channel = database, dat = ci, tablename = "Crew_Information", append = TRUE, 
        rownames = FALSE, colnames = FALSE)
sqlSave(channel = database, dat = obs, tablename = "Observations", append = TRUE, 
        rownames = FALSE, colnames = FALSE)
sqlSave(channel = database, dat = si, tablename = "Survey_Information", append = TRUE, 
        rownames = FALSE, colnames = FALSE)
sqlSave(channel = database, dat = tracks, tablename = "Tracks", append = TRUE, 
        rownames = FALSE, colnames = FALSE)
sqlSave(channel = database, dat = ti, tablename = "Transect_Information", append = TRUE, 
        rownames = FALSE, colnames = FALSE)
odbcCloseAll()
# ------------------------------------------------------------------------- #


# IF ALL LOOKS OKAY, DELETE TEMPORARY FILES
#file.del = list.files(file.path(dir, "DataProcessing"))
#file.del = file.del[grep("temp_", file.del)]
#unlink(file.path(dir, "DataProcessing", file.del))


# ADD DATA TO ATLANTIC COAST SURVEYS GEODATABASE
# ------------------------------------------------------------------------- #
GetDatabase("Atlantic_Coast_Surveys")
write.dbf(Database_Observations, file.path(dir, "DataProcessing/temp/Database_Observations.dbf"))
write.dbf(Database_Tracks, file.path(dir, "DataProcessing/temp/Database_Tracks.dbf"))
Database_Transect_Information$StartDt = as.character(Database_Transect_Information$StartDt, format = "%m/%d/%Y")
Database_Transect_Information$EndDt = as.character(Database_Transect_Information$EndDt, format = "%m/%d/%Y")
Database_Transect_Information$GIS_ID2 = paste(Database_Transect_Information$SurveyNbr, 
                                              Database_Transect_Information$Transect, 
                                              Database_Transect_Information$Replicate, 
                                              Database_Transect_Information$Crew, 
                                              Database_Transect_Information$Seat, sep = "_")
write.dbf(Database_Transect_Information, file.path(dir, "DataProcessing/temp/Database_Transect_Information.dbf"))
# ------------------------------------------------------------------------- #


# RUN UpdateGeoDatabase.py SCRIPT IN ArcGIS
RunArcGISpy(file.path(dir, "DataProcessing/UpdateGeoDatabase.py"))
# --------------------------------------- #


# IF ALL LOOKS OKAY, DELETE TEMPORARY FILES
file.del = list.files(file.path(dir, "DataProcessing/temp"))
file.del = file.del[c(grep("temp_", file.del), grep("Database_", file.del))]
unlink(file.path(dir, "DataProcessing/temp", file.del))
