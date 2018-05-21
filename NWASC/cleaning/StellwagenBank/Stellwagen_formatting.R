# format Stellwagen data for import

require(dplyr)
require(zoo)
require(geosphere)

dir.in = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/Stellwagen"

format.data <- function(data,data_track) {
  data = data %>%
  rename(behavior_id=behavior,
         age_id=age,
         distance_to_animal_tx=Range,
         flight_height_tx=Flight_Height,
         angle_from_observer_nb=Bearing) %>% 
  mutate(distance_to_animal_tx = paste(distance_to_animal_tx, "(m)",sep=" "),
         distance_to_animal_tx = replace(distance_to_animal_tx, distance_to_animal_tx %in% "NA (m)", NA),
         #observer_tx = replace(observer_tx, observer_tx %in% 'Heather Jenkins',"HJ"),
         sex_id=5) %>%
  select(-Association)

break.at.each.stop = filter(data_track, spp %in% c("BEGCNT"), !offline %in% 1) %>%
  group_by(transect) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(transect, X, start.stop.index, date)
ssi = left_join(data_track, break.at.each.stop, by="X") %>% 
  select(-transect.y) %>% rename(source_transect_id = transect.x) %>% 
  mutate(start.stop.index = as.numeric(start.stop.index))  %>% 
  select(X,source_transect_id,start.stop.index) %>% 
  group_by(source_transect_id) %>% 
  mutate_all(funs(na.locf(., na.rm=FALSE))) %>% 
  ungroup %>%
  mutate(newkey = paste(source_transect_id, start.stop.index, sep="_")) %>% 
  mutate(newkey = ifelse(newkey=="NA_NA", NA, newkey)) %>%
  select(-start.stop.index)
new.key = left_join(data_track, select(ssi,X,newkey), by="X") %>% 
  filter(!is.na(newkey))

# grouped by new key to avoid counting time and distance traveled between breaks
new.df = new.key %>% group_by(newkey)  %>% 
  mutate(lagged.lon = lead(Longitude, default = last(Longitude), order_by = time),
         lagged.lat = lead(Latitude, default = last(Latitude), order_by = time)) %>%
  rowwise() %>% 
  mutate(distance = distVincentySphere(c(Longitude, Latitude), c(lagged.lon, lagged.lat))) %>%
  select(-lagged.lon, -lagged.lat) %>%  
  group_by(newkey) %>%  
  summarise(source_transect_id = first(transect),
            transect_distance_nb = sum(distance, na.rm=TRUE),
            temp_start_lon = first(Longitude),
            temp_stop_lon = last(Longitude),
            temp_start_lat = first(Latitude),
            temp_stop_lat = last(Latitude),
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

return(data, data_track, data_transect)
}

# run one by one to check for import errors

# data = read.csv(paste(dir.in,"/standard_obs_2012-08-09", sep=""), header=T)
# data_track = read.csv(paste(dir.in,"/standard_track_2012-08-09", sep=""), header=T)
# id = 182 #DONE
# 
# data = read.csv(paste(dir.in,"/standard_obs_2012-10-24", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/standard_track_2012-10-24", sep=""), header=T)
# id = 183 #DONE
# 
# data = read.csv(paste(dir.in,"/standard_obs_2013-01-03", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/standard_track_2013-01-03", sep=""), header=T)
# id = 184 #DONE
# 
# data = read.csv(paste(dir.in,"/standard_obs_2013-04-05", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/standard_track_2013-04-05", sep=""), header=T)
# id = 185 #DONE
# 
# data = read.csv(paste(dir.in,"/standard_obs_2013-06-05", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/standard_track_2013-06-05", sep=""), header=T)
# id = 186  #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2013-08-15", sep=""), header=T)   
# data_track = read.csv(paste(dir.in,"/standard_track_2013-08-15", sep=""), header=T)
# id = 187 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2013-10-21", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/standard_track_2013-10-21", sep=""), header=T)
# id = 188 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2014-04-21", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/standard_track_2014-04-21", sep=""), header=T)
# id = 189 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2014-06-02", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/standard_track_2014-06-02", sep=""), header=T)
# id = 190 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2014-08-04", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/standard_track_2014-08-04", sep=""), header=T)
# id = 191 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2014-09-15", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/standard_track_2014-09-15", sep=""), header=T)
# id = 192 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2014-10-20", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/standard_track_2014-10-20", sep=""), header=T)
# id = 193 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2014-12-16", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/standard_track_2014-12-16", sep=""), header=T)
# id = 194 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2015-06-05", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/standard_track_2015-06-05", sep=""), header=T)
# id = 195 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2015-08-05", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/standard_track_2015-08-05", sep=""), header=T)
# id = 196 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2015-09-28", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/standard_track_2015-09-28", sep=""), header=T)
# id = 197 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2015-10-27", sep=""), header=T)   
# data_track = read.csv(paste(dir.in,"/standard_track_2015-10-27", sep=""), header=T)
# id = 198 #DONE
#   
# data = read.csv(paste(dir.in,"/standard_obs_2015-12-26", sep=""), header=T)   
# data_track = read.csv(paste(dir.in,"/standard_track_2015-12-26", sep=""), header=T)
# id = 199 #DONE
  
#"standard_obs_NA"                    


#(95,19,'StellwagenBankNMS_Jun2012','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),	
#(200,19,'StellwagenBankNMS_Aug2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
#(201,19,'StellwagenBankNMS_Sep2011a','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),--two surveys in Sep.
#(202,19,'StellwagenBankNMS_Sep2011b','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),--two surveys in Sep.
#(203,19,'StellwagenBankNMS_Dec2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
#(204,19,'StellwagenBankNMS_Oct2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),


# data = read.csv(paste(dir.in,"/ss_obs_2012-06-08", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/ss_track_2012-06-08", sep=""), header=T)
# id = 224 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2012-08-09", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/ss_track_2012-08-09", sep=""), header=T)
# id = 225 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2012-10-24", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/ss_track_2012-10-24", sep=""), header=T)
# id = 226 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2013-01-03", sep=""), header=T)     
# data_track = read.csv(paste(dir.in,"/ss_track_2013-01-03", sep=""), header=T)
# id = 227 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2013-04-05", sep=""), header=T)   
# data_track = read.csv(paste(dir.in,"/ss_track_2013-04-05", sep=""), header=T)
# id = 228 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2013-06-05", sep=""), header=T)   
# data_track = read.csv(paste(dir.in,"/ss_track_2013-06-05", sep=""), header=T)
# id = 229 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2013-08-15", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/ss_track_2013-08-15", sep=""), header=T)
# id = 230 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2013-10-21", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/ss_track_2013-10-21", sep=""), header=T)
# id = 231 #DONE
# 
# data = read.csv(paste(dir.in,"/ss_obs_2014-04-21", sep=""), header=T)    
# data_track = read.csv(paste(dir.in,"/ss_track_2014-04-21", sep=""), header=T)
# id = 232 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2014-06-02", sep=""), header=T)    
# data_track = read.csv(paste(dir.in,"/ss_track_2014-06-02", sep=""), header=T)
# id = 233 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2014-08-04", sep=""), header=T)     
# data_track = read.csv(paste(dir.in,"/ss_track_2014-08-04", sep=""), header=T)
# id = 234 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2014-09-15", sep=""), header=T)   
# data_track = read.csv(paste(dir.in,"/ss_track_2014-09-15", sep=""), header=T)
# id = 235 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2014-10-20", sep=""), header=T)   
# data_track = read.csv(paste(dir.in,"/ss_track_2014-10-20", sep=""), header=T)
# id = 236 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2014-12-16", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/ss_track_2014-12-16", sep=""), header=T)
# id = 237 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2015-06-05", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/ss_track_2015-06-05", sep=""), header=T)
# id = 238 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2015-08-05", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/ss_track_2015-08-05", sep=""), header=T)
# id = 239 #DONE
#   
data = read.csv(paste(dir.in,"/ss_obs_2015-09-28", sep=""), header=T)
data_track = read.csv(paste(dir.in,"/ss_track_2015-09-28", sep=""), header=T)
id = 240 #DONE
#time fix
data_track$time = as.character(data_track$time)
hr = sapply(strsplit(data_track$time,":"),head,1)
mi = substr(data_track$time,4,5)
sec = sapply(strsplit(data_track$time,":"),tail,1)
hr[hr %in% "20"]="08"
hr[hr %in% "21"]="09"
hr[hr %in% "22"]="10"
hr[hr %in% "23"]="11"
data_track$time = paste(hr,mi,sec,sep=":")
 
# data = read.csv(paste(dir.in,"/ss_obs_2015-10-27", sep=""), header=T)  
# data_track = read.csv(paste(dir.in,"/ss_track_2015-10-27", sep=""), header=T)
# id = 241 #DONE
#   
# data = read.csv(paste(dir.in,"/ss_obs_2015-12-26", sep=""), header=T) 
# data_track = read.csv(paste(dir.in,"/ss_track_2015-12-26", sep=""), header=T)
# id = 242 #DONE
