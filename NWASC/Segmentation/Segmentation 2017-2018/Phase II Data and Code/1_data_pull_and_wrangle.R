library(dplyr)
library(lubridate)
library(readr)
MassCEC.target.ids = c(135,161,162)

#obseervation read csv
observation <- observation <- read_csv("rework_Mass_CEC/Phase II Data and Code/observation.csv",
                                        col_types = cols(obs_dt = col_date(format = "%m/%d/%Y")))
observation$transect_id = as.integer(observation$transect_id)
observation = SppCp_Fix(observation) %>% filter(dataset_id %in% MassCEC.target.ids)


#View(observation)


#track read csv
track <- track <- read_csv("rework_Mass_CEC/Phase II Data and Code/track.csv",
                           col_types = cols(track_dt = col_date(format = "%m/%d/%Y"))) %>%
  filter(dataset_id %in% MassCEC.target.ids)
track$transect_id = as.integer(track$transect_id)

#View(track)


#transect read csv
transect <- transect <- read_csv("rework_Mass_CEC/Phase II Data and Code/transect.csv",
                                 col_types = cols(start_dt = col_date(format = "%m/%d/%Y")))%>%
  filter(dataset_id %in% MassCEC.target.ids)
transect$transect_id = as.integer(transect$transect_id)

#View(transect)

#pull datset table
dataset <- read_csv("rework_Mass_CEC/Phase II Data and Code/dataset.csv",
                    col_types = cols(abstract = col_skip(),
                                     action_required = col_skip(), action_taken = col_skip(),
                                     admin_notes = col_skip(), area_covered_km2 = col_skip(),
                                     at_usgs = col_skip(), comments = col_skip(),
                                     dataset_id = col_integer(), dataset_type_cd = col_skip(),
                                     date_created = col_skip(), discrete_time_unit = col_skip(),
                                     end_date = col_skip(), funded = col_skip(),
                                     import_notes = col_skip(), in_db = col_skip(),
                                     keywords = col_skip(), meta_std = col_skip(),
                                     noaa_import_priority = col_skip(),
                                     noaa_priority = col_skip(), number_of_records = col_skip(),
                                     parent_project = col_skip(), planned_speed_knots = col_skip(),
                                     progress = col_skip(), purpose = col_skip(),
                                     qual_rpt = col_skip(), resp_party = col_skip(),
                                     share_level = col_skip(), source_dataset_id = col_skip(),
                                     sponsors = col_skip(), start_date = col_skip(),
                                     subject = col_skip(), survey_method_cd = col_character(),
                                     survey_type_cd = col_character(),
                                     survey_width_m = col_skip(), title = col_skip(),
                                     url_program = col_skip(), usgs_priority = col_skip(),
                                     version = col_skip(), who_created = col_skip())) %>% filter(dataset_id %in% MassCEC.target.ids)





#roll_up double observation tansects
target_id = c(MassCEC.target.ids)
lookup_table = Create.transect.revision.lookup()
transect = roll_up_transect(transect, lookup_table)
track = roll_up_track(track, lookup_table)
observation = roll_up_observation(observation, lookup_table)


# transects
cts.dat1 = transect %>%
  select(start_dt, end_dt, dataset_id,
         source_dataset_id, source_transect_id, transect_id, start_tm, end_tm,
         transect_width_nb, time_from_midnight_start, time_from_midnight_stop) %>%
  rename(segmented_transect_id = source_transect_id)

cts.dat2 = dataset

cts.dat = left_join(cts.dat1,cts.dat2, by ="dataset_id")

# observations
obs.pre = observation %>% select(transect_id, temp_lat, temp_lon, spp_cd, obs_count_intrans_nb) %>% #, source_dataset_id
  rename(lat = temp_lat, long = temp_lon, count = obs_count_intrans_nb) %>%
  mutate(count = ifelse(is.na(count) & !is.na(spp_cd), 1, count)) %>%
  filter(spp_cd != "NONE", count >= 0, !is.na(lat), !is.na(long))

obs.pre = keep_only_known_birds(obs.pre)

# tracks vars created tracks$ : lat, long, transect_id, dataset_id, piece, source_transect_id, order
shp.pre = track %>% select(track_lat, track_lon, transect_id, dataset_id, piece) %>%
  rename(lat = track_lat, long = track_lon) %>%
  mutate(piece = replace(piece, is.na(piece), 1)) %>%
  arrange(transect_id, piece) %>%
  group_by(transect_id, piece) %>%
  #filter(!(transect_id %in% obs.missing$transect_id)) %>%
  filter(!is.na(transect_id)) %>%
  filter(!is.na(lat) & !is.na(long)) %>%
  mutate(order = seq.int(n())) %>%
  #filter(dataset_id == 115) %>%
  ungroup
shp.pre = shp.pre ## %>% drop_na(transect_id)

 #rm(obs.missing)

 # rm(observation)
 # rm(track)
 # rm(transect)
