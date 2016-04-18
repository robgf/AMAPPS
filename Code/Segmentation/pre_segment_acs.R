# Operations to prepare data in Atlantic Coast Surveys database for segmentation
# Creates and stores dataframe 'segmentableAC' to be passed to 'segmentAC' function

# Kyle Dettloff
# 04-18-2015

suppressMessages(library(dplyr))
suppressMessages(library(tidyr))
suppressMessages(library(geosphere))
suppressMessages(library(zoo))

# read in observation and transect tables
suppressMessages(library(RODBC))
conn = odbcConnectAccess2007("Q:/DataBase/Atlantic_Coast_Surveys_Current.accdb")
observations = sqlFetch(conn, "Observations", as.is = TRUE)
transects = sqlFetch(conn, "Transect_Information", as.is = TRUE)
track = sqlFetch(conn, "Tracks", as.is = TRUE)
close(conn)
rm(conn)
detach(package:RODBC)

preSeg = function(observations, transects, track) {
  lines = track %>% filter(Type %in% c("BEGTRAN", "ENDTRAN")) %>%
    group_by(SurveyNbr, Transect, Replicate, Type, Crew, Year, Month) %>% summarise(Lat = mean(Lat), Long = mean(Long)) %>%
    unite(Lat_Long, Lat, Long) %>% spread(Type, Lat_Long) %>%
    separate(BEGTRAN, c("lat_start", "lon_start"), sep = "_", convert = TRUE) %>%
    separate(ENDTRAN, c("lat_end", "lon_end"), sep = "_", convert = TRUE)

  obs1 = observations %>% select(-c(Seat, Obs, Day, Sec, GpsError, Dist2Coast_m))
  trans = transects %>% group_by(SurveyNbr, Transect, Replicate) %>% summarise(DistFlown = mean(DistFlown))

  lines_trans = left_join(lines, trans, by = c("SurveyNbr", "Transect", "Replicate")) %>% rowwise() %>%
    mutate(trans_dist_eff = distVincentySphere(c(lon_start, lat_start), c(lon_end, lat_end)) / 1852,
           error = abs(DistFlown - trans_dist_eff) / DistFlown) %>% select(-DistFlown)

  segmentableAC <<- full_join(obs1, lines_trans, by = c("SurveyNbr", "Transect", "Replicate", "Crew", "Year", "Month")) %>%
    filter(error <= 0.05) %>% select(-error) %>% rowwise() %>%
    mutate(trans_bearing = bearing(c(lon_start, lat_start), c(lon_end, lat_end), sphere = TRUE)) %>%
    mutate(dist_cum = distVincentySphere(c(lon_start, lat_start), c(Long, Lat)) / 1852) %>%
    ungroup() %>% select(-c(lon_end, lat_end)) %>%
    filter(round(dist_cum, 3) <= round(trans_dist_eff, 3) | is.na(dist_cum)) %>%
    group_by(SurveyNbr, Transect, Replicate)
}

### run function
preSeg(observations, transects, track)
# remove objects to free memory
rm(observations, transects, track)
