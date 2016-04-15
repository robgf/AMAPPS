# Operations to prepare data in NWASC database for segmentation
# Creates and stores dataframe 'segmentable' to be passed to 'segment' function

# seg.min argument defines minimum segment length

# Optionally creates and stores table 'empty_cf' of estimated correction factors
# for datasets where empty transects exist but their locations are unknown

# Kyle Dettloff
# 12-18-2015
# Updated 03-22-2016 to include spatial transect information
# Revised 04-02-2016

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
tran = sqlFetch(conn, "transects", as.is = TRUE)
dataset = sqlFetch(conn, "dataset_list", as.is = TRUE)
close(conn)
rm(conn)
detach(package:RODBC)

# read in transect shapefile
setwd("Q:/Kyle_Working_Folder/ArcGIS/Transects")
suppressMessages(library(maptools))
shape = readShapeSpatial("transect_lines")

preSegment = function(observations, transects, dataset, shapefile, seg.min = 0.5, est.correction = FALSE) {
  
  # get survey type and survey method information
  survey_vars = dataset %>% select(dataset_id, survey_type_cd, survey_method_cd, survey_width_m)
  
  # process transect shapefile
  trans = tidy(shapefile)
  lines_raw = trans %>% select(-c(piece, group)) %>% group_by(id) %>%
    mutate(Long = lead(long, default = last(long), order_by = order),
           Lat = lead(lat, default = last(lat), order_by = order)) %>%
    rowwise() %>% mutate(distance = distVincentySphere(c(long, lat), c(Long, Lat)) / 1852) %>%
    ungroup() %>% select(-c(Long, Lat)) %>% group_by(id) %>%
    mutate(total_dist = sum(distance),
           trans_dist_eff = distVincentySphere(c(first(long), first(lat)), c(last(long), last(lat))) / 1852,
           error = (total_dist - trans_dist_eff) / total_dist) %>%
    select(long, lat, trans_dist_eff, error) %>%
    mutate(lon_start = first(long), lat_start = first(lat), lon_end = last(long), lat_end = last(lat)) %>%
    select(-c(long, lat)) %>% distinct() %>% ungroup() %>%
    mutate(transect_id = shape@data$transect_i, dataset_id = shape@data$dataset_id,
           start_dt = as.character(shape@data$start_dt), start_tm = as.character(shape@data$start_tm),
           end_dt = as.character(shape@data$end_dt), end_tm = as.character(shape@data$end_tm)) %>%
    left_join(., survey_vars, by = "dataset_id")
  lines = lines_raw %>% filter(survey_type_cd %in% c("a", "b"), survey_method_cd %in% c("cts", "dts"), error < 0.025) %>%
    select(-c(error, id))
  # join observations with transects from shapefile
  empty_sp = setdiff(lines$transect_id, observations$transect_id)
  observations_sp = observations %>% select(transect_id, dataset_id, obs_dt, obs_start_tm, spp_cd,
                                            obs_count_intrans_nb, obs_count_general_nb, seastate_beaufort_nb, lat, lon) %>%
    filter(transect_id %in% lines$transect_id) %>%
    full_join(., lines, by = c("transect_id", "dataset_id")) %>%
    mutate(obs_dt = ymd_hms(obs_dt), obs_start_tm = ymd_hms(obs_start_tm), start_tm = hms(start_tm), end_tm = hms(end_tm),
           start_dt = ymd(start_dt), end_dt = ymd(end_dt)) %>%
    mutate(obs_start_tm = as.POSIXct(update(obs_start_tm, year = year(obs_dt), month = month(obs_dt), day = day(obs_dt))),
           start_tm = as.POSIXct(update(start_dt, hour = hour(start_tm), minute = minute(start_tm), second = second(start_tm))),
           end_tm = as.POSIXct(update(end_dt, hour = hour(end_tm), minute = minute(end_tm), second = second(end_tm)))) %>%
    select(-c(start_dt, end_dt)) %>%
    group_by(dataset_id, transect_id) %>%
    mutate(in_trans = as.character(ifelse(start_tm > first(obs_start_tm) | end_tm < last(obs_start_tm), "Out", "In"))) %>%
    filter(in_trans != "Out" | is.na(in_trans)) %>%
    select(-c(in_trans, obs_start_tm, start_tm, end_tm)) %>%
    mutate(obs_count_intrans_nb = replace(obs_count_intrans_nb, transect_id %in% empty_sp, 0),
           obs_count_general_nb = replace(obs_count_general_nb, transect_id %in% empty_sp, 0)) %>%
    rowwise() %>%
    mutate(trans_bearing = bearing(c(lon_start, lat_start), c(lon_end, lat_end), sphere = TRUE)) %>%
    mutate(dist_cum = distVincentySphere(c(lon_start, lat_start), c(lon, lat)) / 1852) %>%
    ungroup() %>% select(-c(lon_end, lat_end)) %>%
    filter(round(dist_cum, 3) <= round(trans_dist_eff, 3) | is.na(dist_cum), trans_dist_eff >= seg.min) %>%
    mutate(count = ifelse(is.na(obs_count_intrans_nb), obs_count_general_nb, obs_count_intrans_nb)) %>%
    select(-c(obs_count_general_nb, obs_count_intrans_nb)) %>%
    mutate(count = ifelse(spp_cd == "NONE", 0, ifelse(is.na(count), 1, count))) %>%
    mutate(spp_cd = replace(spp_cd, count == 0, "NONE")) %>%
    mutate(survey_type_cd = ifelse(survey_type_cd == "a", "aerial", ifelse(survey_type_cd == "b", "boat", NA))) %>%
    mutate(shape_avail = "Yes") %>%
    rename(transect_width_m = survey_width_m, beaufort = seastate_beaufort_nb, survey_type = survey_type_cd, survey_method = survey_method_cd)
  
  # narrow tables to contain only unprocessed data (those without spatial information)
  observations = observations %>% filter(!(transect_id %in% lines_raw$transect_id))
  transects = transects %>% filter(!(transect_id %in% lines_raw$transect_id)) %>%
    left_join(., survey_vars, by = "dataset_id")
  
  # find transects with no observations
  empty_trans = setdiff(transects$transect_id, observations$transect_id)
  # merge observations with transect information, insert zero counts on empty transects
  # remove transects with all observations at a single point (if no transect specific information is available)
  # convert separate date and time columns into single datetime variables
  tmp = full_join(observations, transects, by = c("transect_id", "dataset_id")) %>%
    filter(!is.na(transect_id), survey_type_cd %in% c("a", "b"), survey_method_cd %in% c("cts", "dts"),
           !(is.na(start_tm) & is.na(end_tm) & is.na(transect_time_min_nb) & is.na(transect_distance_nb) &
               is.na(time_from_midnight_start) & is.na(time_from_midnight_stop))) %>%
    select(transect_id, dataset_id, obs_dt, obs_start_tm, start_dt, start_tm, end_dt, end_tm,
           transect_time_min_nb, transect_distance_nb, traversal_speed_nb, time_from_midnight_start, time_from_midnight_stop,
           lat, lon, heading_tx.y, spp_cd, obs_count_intrans_nb, obs_count_general_nb, survey_width_m, seastate_beaufort_nb.x,
           survey_type_cd, survey_method_cd) %>%
    group_by(dataset_id, transect_id) %>% arrange(obs_start_tm) %>% ungroup() %>%
    # convert headings to be consistent with geosphere package
    mutate(heading_tx.y = as.numeric(heading_tx.y), heading_tx.y = ifelse(heading_tx.y > 360, heading_tx.y / 10, heading_tx.y),
           heading_tx.y = ifelse(heading_tx.y > 180, heading_tx.y - 360, heading_tx.y)) %>%
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
  # create new column containing interpolated transect distances and speeds calculated from time between observations
  # calculate cumulative distance between observations
  # flag cases where observations occur outside of transect bounds
    filter(diff_tm_min > 0 | trans_dist > 0) %>%
    select(-transect_time_min_nb, -transect_distance_nb) %>%
    mutate(time_from_midnight_start = obs_dt + seconds(time_from_midnight_start),
           time_from_midnight_stop = obs_dt + seconds(time_from_midnight_stop)) %>%
    group_by(dataset_id, transect_id) %>%
    mutate(start_tm = replace(start_tm, is.na(start_tm), time_from_midnight_start),
           end_tm = replace(end_tm, is.na(end_tm), time_from_midnight_stop)) %>%
    select(-time_from_midnight_start, -time_from_midnight_stop) %>%
    mutate(speed_interp = as.numeric(ifelse(is.na(traversal_speed_nb) & last(obs_start_tm) != first(obs_start_tm) &
                                   !identical(c(first(lon), first(lat)), c(last(lon), last(lat))),
                                   distVincentySphere(c(first(lon), first(lat)), c(last(lon), last(lat))) / 1852 /
                                   (as.numeric(last(obs_start_tm) - first(obs_start_tm)) / 60), traversal_speed_nb))) %>%
    select(-traversal_speed_nb) %>%
    mutate(speed_interp = replace(speed_interp, speed_interp > 200, NA)) %>%
    mutate(dist_cum = ifelse(identical(c(first(lon), first(lat)), c(last(lon), last(lat))), 0,
                             distVincentySphere(c(first(lon), first(lat)), cbind(lon, lat)) / 1852)) %>%
    mutate(dist_interp = as.numeric(ifelse(is.na(trans_dist) | (trans_dist < max(dist_cum) & !is.na(max(dist_cum))),
                                           speed_interp * diff_tm_min / 60, trans_dist))) %>%
    select(-trans_dist) %>%
    filter(n_distinct(lon, lat) > 2 | !is.na(dist_interp) & !is.na(heading_tx.y)) %>%
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
  # if all observations occur at a single point, randomly assign a location on transect
  # discard impossible observations based on interpolated variables
  # create a single count column with in-transect data whenever available, general counts otherwise
  # this dataframe now contains all data that is "segmentable" in long form
  pre_segmentable = tmp %>% filter(in_trans == "In" | is.na(in_trans)) %>% select(-in_trans) %>%
    mutate(start_tm_to_obs1 = as.numeric(ifelse(first(obs_start_tm) - first(start_tm) >= 0, first(obs_start_tm) - first(start_tm), NA)),
           end_tm_from_obsn = as.numeric(ifelse(first(end_tm) - last(obs_start_tm) >= 0, first(end_tm) - last(obs_start_tm), NA))) %>%
    select(-obs_start_tm, -start_tm, -end_tm) %>%
    mutate(dist_start_to_obs1 =
             as.numeric(ifelse(!is.na(diff_tm_min) & !is.na(start_tm_to_obs1) & start_tm_to_obs1 / diff_tm_min < 1,
                               dist_interp * start_tm_to_obs1 / diff_tm_min,
                               ifelse(!is.na(speed_interp) & !is.na(start_tm_to_obs1),
                                      speed_interp / 60 * start_tm_to_obs1,
                                      ifelse(first(dist_interp) - max(dist_cum) >= 0, runif(1, 0, first(dist_interp) - max(dist_cum)),
                                             NA))))) %>% select(-start_tm_to_obs1) %>%
    mutate(dist_obsn_to_end =
             as.numeric(ifelse(!is.na(diff_tm_min) & !is.na(end_tm_from_obsn), dist_interp * end_tm_from_obsn / diff_tm_min,
                               ifelse(!is.na(speed_interp) & !is.na(end_tm_from_obsn), speed_interp / 60 * end_tm_from_obsn,
                                      first(dist_interp) - max(dist_cum) - dist_start_to_obs1)))) %>%
    select(-diff_tm_min, -speed_interp, -end_tm_from_obsn) %>%
    mutate(lat_first = first(lat), lon_first = first(lon)) %>%
    mutate(heading = as.numeric(ifelse(!is.na(heading_tx.y), heading_tx.y, ifelse(row_number() == 1, NA,
                                       bearing(c(first(lon), first(lat)), cbind(lon, lat), sphere = TRUE))))) %>%
    rowwise() %>%
    mutate(heading = replace(heading, is.na(heading_tx.y) & !is.na(heading) & identical(c(lon_first, lat_first), c(lon, lat)), NA)) %>%
    select(-lat_first, -lon_first) %>% ungroup() %>% group_by(dataset_id, transect_id) %>%
    mutate(gps_diff = max(heading, na.rm = TRUE) - min(heading, na.rm = TRUE)) %>%
    filter(gps_diff < 10 | gps_diff > 360 - 10 | is.na(gps_diff)) %>%
    select(-gps_diff, -heading_tx.y) %>%
    mutate(dist_cum = dist_cum + dist_start_to_obs1) %>%
    filter(max(dist_cum) + dist_obsn_to_end <= dist_interp) %>% select(-dist_interp) %>%
    group_by(dataset_id, transect_id, lat, lon) %>% mutate(num = n()) %>% group_by(dataset_id, transect_id) %>%
    mutate(heading_start = as.numeric(ifelse(n_distinct(lon, lat) < 3 & heading >= 180, heading - 180,
                                             ifelse(n_distinct(lon, lat) < 3 & heading < 180, heading + 180,
                                                    bearing(c(nth(lon, first(num) + 1), nth(lat, first(num) + 1)),
                                                            c(first(lon), first(lat)), sphere = TRUE)))),
           heading_end = as.numeric(ifelse(n_distinct(lon, lat) < 3 , heading,
                                           bearing(c(nth(lon, length(lon) - last(num)), nth(lat, length(lat) - last(num))),
                                                   c(last(lon), last(lat)), sphere = TRUE)))) %>%
    select(-heading, -num) %>%
    filter(!is.na(heading_start), !is.na(heading_end)) %>%
    mutate(coords_start = list(destPoint(c(first(lon), first(lat)), first(heading_start), first(dist_start_to_obs1) * 1852)),
           coords_end = list(destPoint(c(last(lon), last(lat)), first(heading_end), first(dist_obsn_to_end) * 1852))) %>%
    select(-dist_start_to_obs1, -heading_start, -heading_end) %>%
    mutate(lat_start = unlist(lapply(coords_start, `[[`, 2)), lon_start = unlist(lapply(coords_start, `[[`, 1)),
           lat_end = unlist(lapply(coords_end, `[[`, 2)), lon_end = unlist(lapply(coords_end, `[[`, 1))) %>%
    select(-coords_start, -coords_end) %>%
    filter(!is.na(lon_start), !is.na(lat_start), !is.na(lon_end), !is.na(lat_end)) %>%
    mutate(trans_bearing = mean(bearing(c(first(lon_start), first(lat_start)), c(first(lon_end), first(lat_end)), sphere = TRUE))) %>%
    mutate(trans_dist_eff = distVincentySphere(c(first(lon_start), first(lat_start)), c(first(lon_end), first(lat_end))) / 1852) %>%
    filter(!is.na(trans_dist_eff), max(dist_cum) + first(dist_obsn_to_end) <= trans_dist_eff, trans_dist_eff >= seg.min) %>%
    select(-dist_obsn_to_end, -lat_end, -lon_end) %>%
    mutate(count = ifelse(is.na(obs_count_intrans_nb), obs_count_general_nb, obs_count_intrans_nb)) %>%
    select(-obs_count_general_nb, -obs_count_intrans_nb) %>%
    mutate(count = ifelse(spp_cd == "NONE", 0, ifelse(is.na(count), 1, count))) %>%
    mutate(spp_cd = replace(spp_cd, count == 0, "NONE")) %>%
    mutate(survey_type_cd = ifelse(survey_type_cd == "a", "aerial", ifelse(survey_type_cd == "b", "boat", NA))) %>%
    mutate(shape_avail = "No") %>%
    rename(transect_width_m = survey_width_m, beaufort = seastate_beaufort_nb.x, survey_type = survey_type_cd, survey_method = survey_method_cd)
  
  # combine all records (those with and without transect shapefiles)
  segmentable <<- bind_rows(pre_segmentable, observations_sp) %>% group_by(dataset_id, transect_id)
}

### run function
preSegment(obs, tran, dataset, shape)
# remove large objects to free memory
rm(obs, tran, dataset, shape)
