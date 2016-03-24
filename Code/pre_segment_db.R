# Operations to prepare data in NWASC database for segmentation
# Creates and stores dataframe 'segmentable' to be passed to 'segment' function

# Optionally creates and stores table 'empty_cf' of estimated correction factors
# for datasets where empty transects exist but their locations are unknown

# Kyle Dettloff
# 12-18-2015
# Updated 03-22-2016 to include spatial transect information

# load packages
suppressMessages(library(broom))
suppressMessages(library(dplyr))
suppressMessages(library(tidyr))
suppressMessages(library(lubridate))
suppressMessages(library(zoo))
suppressMessages(library(geosphere))

# read in observation and transect tables
suppressMessages(library(RODBC))
conn = odbcConnectAccess2007("Q:/Kyle_Working_Folder/Segmentation/seabird_database.mdb")
obs = sqlFetch(conn, "observations", as.is = TRUE)
track = sqlFetch(conn, "transects", as.is = TRUE)
close(conn)

# read in transect shapefile
setwd("Q:/Kyle_Working_Folder/ArcGIS")
suppressMessages(library(maptools))
shape = readShapeSpatial("transect_lines")

preSegment = function(observations, transects, shapefile, est.correction = FALSE) {
  
  # process transect shapefile
  trans = tidy(shapefile)
  lines_raw = trans %>% select(-piece, -group) %>% group_by(id) %>%
    mutate(Long = lead(long, default = last(long), order_by = order),
           Lat = lead(lat, default = last(lat), order_by = order)) %>%
    rowwise() %>% mutate(distance = distVincentySphere(c(long, lat), c(Long, Lat)) / 1852) %>%
    ungroup() %>% select(-Long, -Lat) %>% group_by(id) %>%
    mutate(total_dist = sum(distance),
           trans_dist_eff = distVincentySphere(c(first(long), first(lat)), c(last(long), last(lat))) / 1852,
           error = (total_dist - trans_dist_eff) / total_dist) %>%
    select(long, lat, trans_dist_eff, error) %>%
    mutate(lon_start = first(long), lat_start = first(lat), lon_end = last(long), lat_end = last(lat)) %>%
    select(-long, -lat) %>% distinct() %>% ungroup() %>%
    mutate(transect_id = shape@data$transect_i, dataset_id = shape@data$dataset_id,
           start_dt = as.character(shape@data$start_dt), start_tm = as.character(shape@data$start_tm),
           end_dt = as.character(shape@data$end_dt), end_tm = as.character(shape@data$end_tm))
  lines = lines_raw %>% filter(error < 0.025) %>% select(-error, -id)
  # join observations with transects from shapefile
  empty_sp = setdiff(lines$transect_id, observations$transect_id)
  observations_sp = observations %>% select(transect_id, dataset_id, obs_dt, obs_start_tm, spp_cd,
                                            obs_count_intrans_nb, obs_count_general_nb, seastate_beaufort_nb, lat, lon) %>%
    filter(transect_id %in% lines$transect_id) %>%
    full_join(., lines, by = c("transect_id", "dataset_id")) %>%
    mutate(obs_dt = ymd_hms(obs_dt), obs_start_tm = ymd_hms(obs_start_tm), start_tm = hms(start_tm), end_tm = hms(end_tm),
           start_dt = ymd(start_dt), end_dt = ymd(end_dt)) %>%
    mutate(obs_start_tm = update(obs_start_tm, year = year(obs_dt), month = month(obs_dt), day = day(obs_dt)),
           start_tm = update(start_dt, hour = hour(start_tm), minute = minute(start_tm), second = second(start_tm)),
           end_tm = update(end_dt, hour = hour(end_tm), minute = minute(end_tm), second = second(end_tm))) %>%
    select(-start_dt, -end_dt) %>%
    group_by(dataset_id, transect_id) %>%
    mutate(in_trans = as.character(ifelse(start_tm > first(obs_start_tm) | end_tm < last(obs_start_tm), "Out", "In"))) %>%
    filter(in_trans != "Out" | is.na(in_trans)) %>%
    select(-in_trans, -obs_start_tm, -start_tm, -end_tm) %>%
    mutate(obs_count_intrans_nb = replace(obs_count_intrans_nb, transect_id %in% empty_sp, 0),
           obs_count_general_nb = replace(obs_count_general_nb, transect_id %in% empty_sp, 0)) %>%
    rowwise() %>%
    mutate(trans_bearing = mean(c(bearing(c(lon_start, lat_start), c(lon_end, lat_end)),
                                  finalBearing(c(lon_start, lat_start), c(lon_end, lat_end))))) %>%
    mutate(dist_cum = distVincentySphere(c(lon_start, lat_start), c(lon, lat)) / 1852) %>%
    ungroup() %>% select(-lon_end, -lat_end) %>%
    filter(round(dist_cum, 3) <= round(trans_dist_eff, 3) | is.na(dist_cum)) %>%
    mutate(count = ifelse(is.na(obs_count_intrans_nb), obs_count_general_nb, obs_count_intrans_nb)) %>%
    select(-obs_count_general_nb, -obs_count_intrans_nb) %>%
    mutate(count = ifelse(spp_cd == "NONE", 0, ifelse(is.na(count), 1, count))) %>%
    mutate(spp_cd = replace(spp_cd, count == 0, "NONE")) %>%
    left_join(., transects[, c("dataset_id", "transect_id", "transect_width_nb")], by = c("dataset_id", "transect_id")) %>%
    rename(strip_width = transect_width_nb, beaufort = seastate_beaufort_nb)
  
  # narrow tables to contain only unprocessed data
  observations = observations %>% filter(!(transect_id %in% lines_raw$transect_id))
  transects = transects %>% filter(!(transect_id %in% lines_raw$transect_id))
  
  # find transects with no observations
  empty_trans = setdiff(transects$transect_id, observations$transect_id)
  # merge observations with transect information, insert zero counts on empty transects
  # convert separate date and time columns into single datetime variables
  tmp = full_join(observations, transects, by = c("transect_id", "dataset_id")) %>%
    filter(!is.na(transect_id), !(is.na(start_tm) & is.na(end_tm) & is.na(transect_time_min_nb) & is.na(transect_distance_nb) &
                                  is.na(time_from_midnight_start) & is.na(time_from_midnight_stop))) %>%
    select(transect_id, dataset_id, obs_dt, obs_start_tm, start_dt, start_tm, end_dt, end_tm,
           transect_time_min_nb, transect_distance_nb, traversal_speed_nb, time_from_midnight_start, time_from_midnight_stop,
           lat, lon, heading_tx.y, spp_cd, obs_count_intrans_nb, obs_count_general_nb, transect_width_nb, seastate_beaufort_nb.x) %>%
    group_by(dataset_id, transect_id) %>% arrange(obs_start_tm) %>% ungroup() %>%
    mutate(obs_count_intrans_nb = replace(obs_count_intrans_nb, transect_id %in% empty_trans, 0),
           obs_count_general_nb = replace(obs_count_general_nb, transect_id %in% empty_trans, 0)) %>%
    mutate(obs_dt = ymd_hms(obs_dt), obs_start_tm = ymd_hms(obs_start_tm), start_tm = ymd_hms(start_tm),
           end_tm = ymd_hms(end_tm), start_dt = ymd_hms(start_dt), end_dt = ymd_hms(end_dt)) %>%
    mutate(obs_start_tm = update(obs_start_tm, year = year(obs_dt), month = month(obs_dt), day = day(obs_dt)),
          start_tm = update(start_tm, year = year(start_dt), month = month(start_dt), day = day(start_dt)),
          end_tm = update(end_tm, year = year(end_dt), month = month(end_dt), day = day(end_dt))) %>%
    select(-start_dt, -end_dt) %>%
  # add new transect elapsed time, distance, and survey type columns based on all other available information when original values missing
  mutate(diff_tm_min = ifelse(Vectorize(isTRUE)(transect_time_min_nb < 0), NA,
                            ifelse(is.na(transect_time_min_nb) & !is.na(end_tm) & !is.na(start_tm),
                            ifelse(end_tm - start_tm >= 0, (end_tm - start_tm) / 60, NA),
                            ifelse(is.na(transect_time_min_nb) & (is.na(end_tm) | is.na(start_tm))
                                   & !is.na(time_from_midnight_stop) & !is.na(time_from_midnight_start),
                                   ifelse(time_from_midnight_stop >= time_from_midnight_start,
                                         (time_from_midnight_stop - time_from_midnight_start) / 60, NA), transect_time_min_nb)))) %>%
    mutate(traversal_speed_nb = ifelse(Vectorize(isTRUE)(traversal_speed_nb < 0), NA, traversal_speed_nb)) %>%
    mutate(trans_dist = ifelse(is.na(transect_distance_nb) & !is.na(traversal_speed_nb),
                               traversal_speed_nb * diff_tm_min / 60, transect_distance_nb)) %>%
    mutate(survey_type = ifelse(diff_tm_min > 0 | trans_dist > 0, "cts", "dts")) %>%
  # create new column containing interpolated transect distances and speeds calculated from time between observations
  # calculate cumulative distance between observations
  # flag cases where observations occur outside of transect bounds
    filter(survey_type == "cts") %>%
    select(-transect_time_min_nb, -transect_distance_nb, -survey_type) %>%
    mutate(time_from_midnight_start = obs_dt + seconds(time_from_midnight_start),
           time_from_midnight_stop = obs_dt + seconds(time_from_midnight_stop)) %>%
    group_by(dataset_id, transect_id) %>%
    mutate(start_tm = replace(start_tm, is.na(start_tm), time_from_midnight_start),
           end_tm = replace(end_tm, is.na(end_tm), time_from_midnight_stop)) %>%
    select(-time_from_midnight_start, -time_from_midnight_stop) %>%
    mutate(speed_interp = as.numeric(ifelse(is.na(traversal_speed_nb) & last(obs_start_tm) != first(obs_start_tm) &
                                   !(identical(c(first(lon), first(lat)), c(last(lon), last(lat)))),
                                 distVincentySphere(c(first(lon), first(lat)), c(last(lon), last(lat))) / 1852 /
                                   (as.numeric(last(obs_start_tm) - first(obs_start_tm)) / 60), traversal_speed_nb))) %>%
    select(-traversal_speed_nb) %>%
    mutate(speed_interp = replace(speed_interp, speed_interp > 200, NA)) %>%
    mutate(dist_cum = distVincentySphere(c(first(lon), first(lat)), cbind(lon, lat)) / 1852) %>%
    mutate(dist_interp = as.numeric(ifelse(is.na(trans_dist) | (trans_dist < max(dist_cum) & !is.na(max(dist_cum))),
                                           speed_interp * diff_tm_min / 60, trans_dist))) %>%
    select(-trans_dist) %>%
    mutate(in_trans = as.character(ifelse(start_tm > first(obs_start_tm) | end_tm < last(obs_start_tm), "Out", "In")))
 
#####################
  if (est.correction == TRUE) {
  # estimate proportion non-empty transect distance by dataset when empty transect locations unknown
    obj_empt = tmp %>% select(dist_interp) %>% group_by(dataset_id) %>% filter(transect_id %in% empty_trans) %>%
      summarise(mean_empt = mean(dist_interp, na.rm = TRUE), trans_empt = n_distinct(transect_id))
    obj_all = tmp %>% select(dist_interp) %>% distinct() %>% group_by(dataset_id) %>% filter(any(transect_id %in% empty_trans)) %>%
      summarise(mean_all = mean(dist_interp, na.rm = TRUE), trans_all = n_distinct(transect_id))
    empty_cf <<- data.frame(dataset_id = obj_all$dataset_id,
                            cf = 1 - obj_empt$mean_empt * obj_empt$trans_empt / (obj_all$mean_all * obj_all$trans_all))
  }
#####################
  
  # approximate lat/lon of transect endpoints using best available ancillary information, estimate total transect distance
  # discard impossible observations based on interpolated variables
  # create a single count column with in-transect data whenever available, general counts otherwise
  # this dataframe now contains all data that is "segmentable" in long form
  pre_segmentable = tmp %>% filter(in_trans != "Out" | is.na(in_trans)) %>% select(-in_trans) %>%
    mutate(start_tm_to_obs1 = as.numeric(ifelse(first(obs_start_tm) - first(start_tm) >= 0, first(obs_start_tm) - first(start_tm), NA)),
           end_tm_from_obsn = as.numeric(ifelse(first(end_tm) - last(obs_start_tm) >= 0, first(end_tm) - last(obs_start_tm), NA))) %>%
    select(-obs_start_tm, -start_tm, -end_tm) %>%
    mutate(dist_start_to_obs1 = as.numeric(ifelse(!is.na(diff_tm_min) & !is.na(start_tm_to_obs1) & start_tm_to_obs1 / diff_tm_min < 1,
                                                  dist_interp * start_tm_to_obs1 / diff_tm_min,
                                            ifelse(!is.na(speed_interp) & !is.na(start_tm_to_obs1),
                                                   speed_interp / 60 * start_tm_to_obs1,
                                             ifelse(first(dist_interp) - max(dist_cum) >= 0, runif(1, 0, first(dist_interp) - max(dist_cum)),
                                                    NA))))) %>%
    select(-start_tm_to_obs1) %>%
    mutate(dist_obsn_to_end = as.numeric(ifelse(!is.na(diff_tm_min) & !is.na(end_tm_from_obsn), dist_interp * end_tm_from_obsn / diff_tm_min,
                                     ifelse(!is.na(speed_interp) & !is.na(end_tm_from_obsn), speed_interp / 60 * end_tm_from_obsn,
                                            first(dist_interp) - max(dist_cum) - dist_start_to_obs1)))) %>%
    select(-diff_tm_min, -speed_interp, -end_tm_from_obsn) %>%
    mutate(heading = as.numeric(ifelse(!is.na(heading_tx.y), heading_tx.y, bearing(c(first(lon), first(lat)), cbind(lon, lat))))) %>%
    mutate(heading = replace(heading, heading == 180, NA)) %>%
    mutate(gps_interp = as.character(ifelse((max(heading, na.rm = TRUE) - min(heading, na.rm = TRUE)) < 15 |
                                            (max(heading, na.rm = TRUE) - min(heading, na.rm = TRUE)) > 345, "Yes", "No"))) %>%
    filter(gps_interp != "No" | is.na(gps_interp)) %>%
    select(-gps_interp, -heading_tx.y, -heading) %>%
    mutate(dist_cum = dist_cum + dist_start_to_obs1) %>%
    filter(max(dist_cum) + dist_obsn_to_end <= dist_interp) %>% select(-dist_interp) %>%
    mutate(heading_start = bearing(c(nth(lon, 2), nth(lat, 2)), c(first(lon), first(lat))),
           heading_end = bearing(c(nth(lon, length(lon) - 1), nth(lat, length(lat) - 1)), c(last(lon), last(lat)))) %>%
    mutate(coords_start = list(destPoint(c(first(lon), first(lat)), first(heading_start), first(dist_start_to_obs1) * 1852)),
           coords_end = list(destPoint(c(last(lon), last(lat)), first(heading_end), first(dist_obsn_to_end) * 1852))) %>%
    select(-dist_start_to_obs1, -heading_start, -heading_end) %>%
    mutate(lat_start = unlist(lapply(coords_start, `[[`, 2)), lon_start = unlist(lapply(coords_start, `[[`, 1)),
           lat_end = unlist(lapply(coords_end, `[[`, 2)), lon_end = unlist(lapply(coords_end, `[[`, 1))) %>%
    select(-coords_start, -coords_end) %>%
    mutate(trans_bearing = mean(c(bearing(c(first(lon_start), first(lat_start)), c(first(lon_end), first(lat_end))),
           finalBearing(c(first(lon_start), first(lat_start)), c(first(lon_end), first(lat_end)))))) %>%
    mutate(trans_dist_eff = distVincentySphere(c(first(lon_start), first(lat_start)), c(first(lon_end), first(lat_end))) / 1852) %>%
    filter(!is.na(trans_dist_eff), max(dist_cum) + first(dist_obsn_to_end) <= trans_dist_eff, trans_dist_eff != 0) %>%
    select(-dist_obsn_to_end, -lat_end, -lon_end) %>%
    mutate(count = ifelse(is.na(obs_count_intrans_nb), obs_count_general_nb, obs_count_intrans_nb)) %>%
    select(-obs_count_general_nb, -obs_count_intrans_nb) %>%
    mutate(count = ifelse(spp_cd == "NONE", 0, ifelse(is.na(count), 1, count))) %>%
    mutate(spp_cd = replace(spp_cd, count == 0, "NONE")) %>%
    rename(strip_width = transect_width_nb, beaufort = seastate_beaufort_nb.x)
  
  # combine all records (those with and without transect shapefiles)
  segmentable <<- bind_rows(pre_segmentable, observations_sp) %>% group_by(dataset_id, transect_id)
}

### run function
preSegment(obs, track, shape)
