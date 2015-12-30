# ------------------------------------------------------------------------- #
# Add2Database2.R
# Date Created: 2013-07-24
# Author: JBL
#
# Description: 
# ------------------------------------------------------------------------- #


# OBSERVATIONS TABLE
# ------------------------------------------------------------------------- #
obs = read.csv(file.path(dir, "DataProcessing/temp_Observations.csv"), 
               stringsAsFactors = FALSE)

# GET SPECIES_INFORMATION TABLE FROM ATLANTIC COAST SURVEYS DATABASE
database = odbcConnectAccess2007(file.path(dbpath, "Atlantic_Coast_Surveys.accdb"))
Database_Species_Information = sqlFetch(database, "Species_Information", as.is = TRUE)
odbcCloseAll()

# CHECK TO MAKE SURE THERE ARE NO NON-SURVEY SPECIES IN OBSERVATIONS FILE
sort(unique(obs$Species))[which(!(sort(unique(obs$Species)) %in% sort(unique(Database_Species_Information$Species))))]

obs = obs[order(obs$SurveyNbr, obs$Transect, obs$Replicate, obs$Crew, obs$Seat, obs$Obs, 
                obs$Year, obs$Month, obs$Day, obs$Sec), ]
# ------------------------------------------------------------------------- #


# TRACKS TABLE
# ------------------------------------------------------------------------- #
tracks = read.csv(file.path(dir, "DataProcessing/temp_Tracks.csv"), stringsAsFactors = FALSE)
tracks$begend = 0
tracks$begend[grepl("BEG", tracks$Type)] = -1
tracks$begend[grepl("END", tracks$Type)] = 1
tracks$coch = 0
tracks$coch[tracks$Type == "COCH" & tracks$Condition == 0] = 1
tracks = tracks[order(tracks$SurveyNbr, tracks$Transect, tracks$Replicate, tracks$Crew, 
                      tracks$Seat, tracks$Obs, tracks$Year, tracks$Month, tracks$Day, 
                      tracks$Sec, tracks$begend, tracks$coch), ]
tracks$MissingTrackFile = NULL
tracks$begend = NULL
tracks$coch = NULL
# ------------------------------------------------------------------------- #


# TRANSECT INFORMATION TABLE
# ------------------------------------------------------------------------- #
ti = read.csv(file.path(dir, "DataProcessing/temp_Transect_Information.csv"), 
              stringsAsFactors = FALSE)
ti = ti[order(ti$SurveyNbr, ti$Transect, ti$Replicate, ti$Crew, ti$Seat, ti$Obs), ]
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


# ADD MISCELLANEOUS OBSERVATIONS TO Atlantic_Coast_Surveys_MiscObservations.csv DATA FILE
# ------------------------------------------------------------------------- #
obs.misc = read.csv(file.path(dbpath, "Atlantic_Coast_Surveys_MiscObservations.csv"), 
                    stringsAsFactors = FALSE)
obs.misc.add = read.csv(file.path(dir, "DataProcessing/temp_MiscObservations.csv"), 
                        stringsAsFactors = FALSE)
obs.misc = rbind(obs.misc, obs.misc.add)
obs.misc = obs.misc[order(obs.misc$SurveyNbr, obs.misc$Crew, obs.misc$Seat, obs.misc$Obs, 
                          obs.misc$Year, obs.misc$Month, obs.misc$Day, obs.misc$Sec), ]
write.csv(obs.misc, file.path(dbpath, "Atlantic_Coast_Surveys_MiscObservations.csv"), 
          row.names = FALSE, na = "")
# ------------------------------------------------------------------------- #


# ADD DISTANCE FLOWN BY OBSERVATION CONDITION TO Atlantic_Coast_Surveys_DistanceFlownByCondition.csv DATA FILE
# ------------------------------------------------------------------------- #
#dist = read.csv(file.path(dbpath, "Atlantic_Coast_Surveys_DistanceFlownByCondition.csv"), 
#                    stringsAsFactors = FALSE)
#dist.add = read.csv(file.path(dir, "DataProcessing/temp_DistanceFlownByCondition.csv"), 
#                    stringsAsFactors = FALSE)
#dist = rbind(dist, dist.add)
#dist = dist[order(dist$SurveyNbr, dist$Transect, dist$Replicate, dist$Crew, dist$Seat, dist$Obs), ]
#write.csv(dist, file.path(dbpath, "Atlantic_Coast_Surveys_DistanceFlownByCondition.csv"), 
#          row.names = FALSE, na = "")
# ------------------------------------------------------------------------- #


# ADD DATA TO ACWSD SEA DUCK DATABASE
# ------------------------------------------------------------------------- #
# GET SPECIES_INFORMATION TABLE FROM ACWSD SEA DUCK DATABASE
# database = odbcConnectAccess2007(file.path(dbpath, "ACWSD_SeaDuck.accdb"))
# Database_Species_Information = sqlFetch(database, "Species_Information", as.is = TRUE)
# odbcCloseAll()
# 
# sort(unique(obs$Species))[which(!(sort(unique(obs$Species)) %in% sort(unique(Database_Species_Information$Species))))]
# seaduck = Database_Species_Information$Species
# obs = subset(obs, Species %in% seaduck)
# 
# database = odbcConnectAccess2007(file.path(dbpath, "ACWSD_SeaDuck.accdb"))
# sqlSave(channel = database, dat = obs, tablename = "Observations", append = TRUE, 
#         rownames = FALSE, colnames = FALSE)
# sqlSave(channel = database, dat = tracks, tablename = "Tracks", append = TRUE, 
#         rownames = FALSE, colnames = FALSE)
# sqlSave(channel = database, dat = ti, tablename = "Transect_Information", append = TRUE, 
#         rownames = FALSE, colnames = FALSE)
# odbcCloseAll()
# ------------------------------------------------------------------------- #


# IF ALL LOOKS OKAY, DELETE TEMPORARY FILES
file.del = list.files(file.path(dir, "DataProcessing"))
file.del = file.del[grep("temp_", file.del)]
unlink(file.path(dir, "DataProcessing", file.del))


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


