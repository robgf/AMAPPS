# format Stellwagen data for import

require(dplyr)

dir.in = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/Stellwagen"

data = data %>%
  rename(behavior_id=behavior,
         age_id=age,
         distance_to_animal_tx=Range,
         flight_height_tx=Flight_Height,
         angle_from_observer_nb=Bearing) %>% 
  mutate(distance_to_animal_tx = paste(distance_to_animal_tx, "(m)",sep=" "),
         sex_id=5) %>%
  select(-Association)

break.at.each.stop = filter(data_track, spp %in% c("BEGCNT"), !offline %in% 1) %>%
  group_by(transect) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(transect, x, start.stop.index, date)
ssi = left_join(data_track, break.at.each.stop, by="x") %>% 
  select(-transect.y) %>% rename(source_transect_id = transect.x) %>% 
  mutate(start.stop.index = as.numeric(start.stop.index))  %>% 
  select(x,source_transect_id,start.stop.index) %>% 
  group_by(source_transect_id) %>% 
  mutate_all(funs(na.locf(., na.rm=FALSE))) %>% 
  ungroup %>%
  mutate(newkey = paste(source_transect_id, start.stop.index, sep="_")) %>% 
  mutate(newkey = ifelse(newkey=="NA_NA", NA, newkey)) %>%
  select(-start.stop.index)
new.key = left_join(data_track, select(ssi,x,newkey), by="x") %>% 
  filter(!is.na(newkey))

# grouped by new key to avoid counting time and distance traveled between breaks
new.df = new.key %>% group_by(newkey)  %>% 
  mutate(lagged.lon = lead(longitude, default = last(longitude), order_by = time),
         lagged.lat = lead(latitude, default = last(latitude), order_by = time)) %>%
  rowwise() %>% 
  mutate(distance = distVincentySphere(c(longitude, latitude), c(lagged.lon, lagged.lat))) %>%
  select(-lagged.lon, -lagged.lat) %>%  
  group_by(newkey) %>%  
  summarise(source_transect_id = first(transect),
            transect_distance_nb = sum(distance, na.rm=TRUE),
            temp_start_lon = first(longitude),
            temp_stop_lon = last(longitude),
            temp_start_lat = first(latitude),
            temp_stop_lat = last(latitude),
            start_dt = as.character(first(date)),
            end_dt = as.character(last(date)),
            start_tm = first(time), 
            end_tm = last(time)) %>%
  as.data.frame() %>% rowwise() %>% 
  mutate(transect_time_min_nb = difftime(as.POSIXct(paste(end_dt, end_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
                                         as.POSIXct(paste(start_dt, start_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
                                         # mutate(transect_time_min_nb = difftime(as.POSIXct(paste(end_dt, end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                         #                                        as.POSIXct(paste(start_dt, start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                         units = "mins"))   %>%
  as.data.frame %>% arrange(start_dt, source_transect_id)
#
data_transect = new.df %>% 
  group_by(source_transect_id,start_dt)  %>% 
  arrange(start_dt,start_tm) %>% 
  summarise(temp_start_lon = first(temp_start_lon),
            temp_stop_lon = last(temp_stop_lon),
            temp_start_lat = first(temp_start_lat),
            temp_stop_lat = last(temp_stop_lat),
            #start_dt = as.character(first(start_dt)),
            end_dt = as.character(last(end_dt)),
            start_tm = first(start_tm), 
            end_tm  = last(end_tm),
            transect_time_min_nb = sum(transect_time_min_nb),
            transect_distance_nb = sum(transect_distance_nb))  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id) %>%
  mutate(transect_distance_nb = replace(transect_distance_nb,transect_distance_nb==0,NA)) %>% 
  filter(source_transect_id %in% c("12to11","13to14","16to15","1to2","4to3","5to6","8to7","9to10"))

rm(new.df, new.key, ssi, break.at.each.stop)


# run one by one

data = read.csv(paste(dir.in,"/standard_obs_2012-08-09", sep=""), header=T)
data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
id = 182 #DONE

data = read.csv(paste(dir.in,"/standard_obs_2012-10-24", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/standard_track_2012-10-24", sep=""), header=T)
id = 183

data = read.csv(paste(dir.in,"/standard_obs_2013-01-03", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/standard_track_2013-01-03", sep=""), header=T)
id = 184

data = read.csv(paste(dir.in,"/standard_obs_2013-04-05", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/standard_track_2013-04-05", sep=""), header=T)
id = 185

data = read.csv(paste(dir.in,"/standard_obs_2013-06-05", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/standard_track_2013-06-05", sep=""), header=T)
id = 186
  
data = read.csv(paste(dir.in,"/standard_obs_2013-08-15", sep=""), header=T)   
data_track = read.csv(paste(dir.in,"/standard_track_2013-08-15", sep=""), header=T)
id = 187
  
data = read.csv(paste(dir.in,"/standard_obs_2013-10-21", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/standard_track_2013-10-21", sep=""), header=T)
id = 188
  
data = read.csv(paste(dir.in,"/standard_obs_2014-04-21", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/standard_track_2014-04-21", sep=""), header=T)
id = 189
  
data = read.csv(paste(dir.in,"/standard_obs_2014-06-02", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/standard_track_2014-06-02", sep=""), header=T)
id = 190
  
data = read.csv(paste(dir.in,"/standard_obs_2014-08-04", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/standard_track_2014-08-04", sep=""), header=T)
id = 191
  
data = read.csv(paste(dir.in,"/standard_obs_2014-09-15", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/standard_track_2014-09-15", sep=""), header=T)
id = 192
  
data = read.csv(paste(dir.in,"/standard_obs_2014-10-20", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
id = 193
  
data = read.csv(paste(dir.in,"/standard_obs_2014-12-16", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
id = 194
  
data = read.csv(paste(dir.in,"/standard_obs_2015-06-05", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
id = 195
  
data = read.csv(paste(dir.in,"/standard_obs_2015-08-05", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
id = 196
  
data = read.csv(paste(dir.in,"/standard_obs_2015-09-28", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
id = 197
  
data = read.csv(paste(dir.in,"/standard_obs_2015-10-27", sep=""), header=T)   
data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
id = 198
  
data = read.csv(paste(dir.in,"/standard_obs_2015-12-26", sep=""), header=T)   
data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
id = 199
  
"standard_obs_NA"                    


#(95,19,'StellwagenBankNMS_Jun2012','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),	
#(200,19,'StellwagenBankNMS_Aug2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
#(201,19,'StellwagenBankNMS_Sep2011a','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),--two surveys in Sep.
#(202,19,'StellwagenBankNMS_Sep2011b','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),--two surveys in Sep.
#(203,19,'StellwagenBankNMS_Dec2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
#(204,19,'StellwagenBankNMS_Oct2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),


data = read.csv(paste(dir.in,"/ss_obs_2012-06-08", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 224
  
data = read.csv(paste(dir.in,"/ss_obs_2012-08-09", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 225
  
data = read.csv(paste(dir.in,"/ss_obs_2012-10-24", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 226
  
data = read.csv(paste(dir.in,"/ss_obs_2013-01-03", sep=""), header=T)     
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 227
  
data = read.csv(paste(dir.in,"/ss_obs_2013-04-05", sep=""), header=T)   
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 228
  
data = read.csv(paste(dir.in,"/ss_obs_2013-06-05", sep=""), header=T)   
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 229
  
data = read.csv(paste(dir.in,"/ss_obs_2013-08-15", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 230
  
data = read.csv(paste(dir.in,"/ss_obs_2013-10-21", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 231

data = read.csv(paste(dir.in,"/ss_obs_2014-04-21", sep=""), header=T)    
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 232
  
data = read.csv(paste(dir.in,"/ss_obs_2014-06-02", sep=""), header=T)    
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 233
  
data = read.csv(paste(dir.in,"/ss_obs_2014-08-04", sep=""), header=T)     
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 234
  
data = read.csv(paste(dir.in,"/ss_obs_2014-09-15", sep=""), header=T)   
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 235
  
data = read.csv(paste(dir.in,"/ss_obs_2014-10-20", sep=""), header=T)   
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 236
  
data = read.csv(paste(dir.in,"/ss_obs_2014-12-16", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 237
  
data = read.csv(paste(dir.in,"/ss_obs_2015-06-05", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 238
  
data = read.csv(paste(dir.in,"/ss_obs_2015-08-05", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 239
  
data = read.csv(paste(dir.in,"/ss_obs_2015-09-28", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 240
  
data = read.csv(paste(dir.in,"/ss_obs_2015-10-27", sep=""), header=T)  
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 241
  
data = read.csv(paste(dir.in,"/ss_obs_2015-12-26", sep=""), header=T) 
data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
id = 242
