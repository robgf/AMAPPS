#-------------------#
# QA/QC of standard survey data on Stellwagen Bank
#-------------------#


#-------------------#
# run Stellwagen_2012to2015 to get data
#-------------------#
source("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/Stellwagen/Stellwagen_2012to2015.R")
rm(obs_ww, track_ss, obs_ss, obs_other)
#-------------------#


#-------------------#
# formatting
#-------------------#
# fix behavior, age, etc
obs_standard = obs_standard %>% 
  #select(-Association) %>% 
  mutate(behavior = 44,
         behavior = replace(behavior, behavior_tx %in% "Diving", 7),    
         behavior = replace(behavior, behavior_tx %in% "Feeding", 9),    
         behavior = replace(behavior, behavior_tx %in% "Flying", 13),     
         behavior = replace(behavior, behavior_tx %in% "Milling", 21),    
         behavior = replace(behavior, behavior_tx %in% "Other", 23),      
         behavior = replace(behavior, behavior_tx %in% "Pattering", 42),
         behavior = replace(behavior, behavior_tx %in% "Piracy", 24),     
         behavior = replace(behavior, behavior_tx %in% "Sitting", 35),
         age = 5, 
         age = replace(age, animal_age_tx %in% "Adult", 1),        
         age = replace(age, animal_age_tx %in% "Immature", 6),     
         age = replace(age, animal_age_tx %in% "Juvenile", 2),     
         age = replace(age, animal_age_tx %in% "Unidentified", 5),
         assosciation = as.character(Association_tx),
         assosciation = replace(assosciation, assosciation %in% "Cetaceans ","UNCE"),
         assosciation = replace(assosciation, assosciation %in% "Fish school","BAIT"),
         assosciation = replace(assosciation, assosciation %in% "Fishing vessel", "BOFI"),    
         assosciation = replace(assosciation, assosciation %in% "Floating weed", "MACR"),            
         assosciation = replace(assosciation, assosciation %in% "Line in sea/convergence ", "OCFR"),   
         assosciation = replace(assosciation, assosciation %in% "None",NA),                     
         assosciation = replace(assosciation, assosciation %in% "Other-Put in comments" & Comments %in% "Suspected good bait fish","BAIT"),   
         assosciation = replace(assosciation, assosciation %in% "Other-Put in comments" & Comments %in% "with grey seal","GRSE")) %>%
  rename(count=N_Individuals) %>% 
  select(-Port,-Vessel,-Recorder,-Effort,-Protocol,-Weather,-WXNotes,-date_time,-Plumage)


#-----------# 
# match to transects
#-----------# 
cl <- makeCluster(as.numeric(detectCores()-1))
clusterExport(cl, "SL", envir = environment())
invisible(clusterEvalQ(cl, c(library(geosphere),
                             library(dplyr),
                             subFunc <- function(lat, lon) {
                               ab = as.data.frame(dist2Line(p = cbind(as.numeric(lon),as.numeric(lat)), line = SL, distfun = distVincentyEllipsoid))
                               ab = mutate(ab, distance = replace(distance, distance>500, NA), ID = replace(ID, is.na(distance), NA))
                               return(ab)
                             })))

d <- parRapply(cl, obs_standard, function(x) subFunc(x[16],x[17]))
stopCluster(cl) 

d <- as.data.frame(matrix(unlist(d), ncol = 4, byrow = TRUE)) # distance(m), long, lat, line ID
names(d) = c("distance","lon","lat","transect")
d = mutate(d, transect = names(SL)[transect])

obs_standard = cbind(obs_standard, d$transect) %>% 
  rename(transect = 'd$transect') %>%
  mutate(offline = replace(offline, is.na(transect),1))
rm(d)

ggplot(obs_standard,aes(Longitude,Latitude,col=as.character(transect)))+geom_point()+theme_bw()
#
# track standard
#
# cl <- makeCluster(as.numeric(detectCores()-1))
# clusterExport(cl, "SL", envir = environment())
# invisible(clusterEvalQ(cl, c(library(geosphere),
#                              library(dplyr),
#                              subFunc <- function(lat, lon) {
#                                ab = as.data.frame(dist2Line(p = cbind(as.numeric(lon),as.numeric(lat)), line = SL, distfun = distVincentyEllipsoid))
#                                return(ab)
#                              })))
# 
# d <- parRapply(cl, y, function(x) subFunc(x[1],x[2]))
# stopCluster(cl)
# 
# d <- as.data.frame(matrix(unlist(d), ncol = 4, byrow = TRUE)) # distance(m), long, lat, line ID
# names(d) = c("distance","lon","lat","transect")
# d = mutate(d, transect = names(SL)[transect],
#            distance = replace(distance, distance>200, NA), 
#            transect = replace(transect, is.na(distance), NA))
# 
# y = cbind(y, d$transect) %>%
#   rename(transect = 'd$transect') %>%
#   mutate(offline = NA, 
#          offline = replace(offline, is.na(transect), 1))
# rm(d)
# ggplot(y,aes(Longitude,Latitude,col=transect))+geom_point()+theme_bw()


#-----------------#
# break by date
#-----------------#
rm(x,y,z)
n = 2
date.list =  unique(obs_standard$date)
x = obs_standard[obs_standard$date %in% date.list[n],]
y = track_standard[track_standard$date %in% date.list[n],]

# remove duplicates (ID and time)
# check if they are valid first, or duplicated just for association
x[duplicated(x[,c("spp","time","count","Beaufort","animal_age_tx")]),]
x = x[!duplicated(x[,c("spp","time","count","Beaufort","animal_age_tx")]),]

# check for any existing effort from notes
z = x %>% filter(spp %in% c("BEGCNT","ENDCNT"), !is.na(transect))
ggplot()+geom_point(data = y, aes(x=Longitude, y=Latitude),col="lightgrey")+
  geom_point(data = z, aes(x=Longitude, y=Latitude),col="red")

#require(FNN)
ref_lat_lon = cbind(trans$Latitude, trans$Longitude)
latlon = cbind(y$Latitude, y$Longitude)
nns <- get.knnx(ref_lat_lon, latlon, k=1) #k=10 produced the same matches so might as well k=1
#nns returns a list with 1:nn.index (indices of the matched points) and 2:nn.dist (distances for each of those points)
sum.nn = nns %>% as.data.frame() %>% 
  mutate(ID = seq(1:length(nn.dist))) %>%
  group_by(nn.index) %>% 
  summarise(key = ID[which.min(nn.dist)]) %>%
  mutate(time = y$time[key],
         transect = nn.index,
         transect = replace(transect,nn.index %in% c(15,16),"16to15"),
         transect = replace(transect,nn.index %in% c(13,14),"13to14"),
         transect = replace(transect,nn.index %in% c(11,12),"12to11"),
         transect = replace(transect,nn.index %in% c(9,10),"9to10"),
         transect = replace(transect,nn.index %in% c(7,8),"8to7"),
         transect = replace(transect,nn.index %in% c(5,6),"5to6"),
         transect = replace(transect,nn.index %in% c(3,4),"4to3"),
         transect = replace(transect,nn.index %in% c(1,2),"1to2"),
         spp = NA,
         spp = replace(spp, nn.index %in% c(15),
                       ifelse(time[nn.index %in% 15] < time[nn.index %in% 16],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(16),
                       ifelse(time[nn.index %in% 15] > time[nn.index %in% 16],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(14),
                       ifelse(time[nn.index %in% 14] < time[nn.index %in% 13],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(13),
                       ifelse(time[nn.index %in% 14] > time[nn.index %in% 13],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(11),
                       ifelse(time[nn.index %in% 11] < time[nn.index %in% 12],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(12),
                       ifelse(time[nn.index %in% 11] > time[nn.index %in% 12],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(10),
                       ifelse(time[nn.index %in% 10] < time[nn.index %in% 9],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(9),
                       ifelse(time[nn.index %in% 10] > time[nn.index %in% 9],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(7),
                       ifelse(time[nn.index %in% 7] < time[nn.index %in% 8],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(8),
                       ifelse(time[nn.index %in% 7] > time[nn.index %in% 8],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(6),
                       ifelse(time[nn.index %in% 6] < time[nn.index %in% 5],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(5),
                       ifelse(time[nn.index %in% 6] > time[nn.index %in% 5],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(3),
                       ifelse(time[nn.index %in% 3] < time[nn.index %in% 4],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(4),
                       ifelse(time[nn.index %in% 3] > time[nn.index %in% 4],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(2),
                       ifelse(time[nn.index %in% 2] < time[nn.index %in% 1],
                              "BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(1),
                       ifelse(time[nn.index %in% 2] > time[nn.index %in% 1],
                              "BEGCNT","ENDCNT")),
         Latitude = y$Latitude[key],
         Longitude = y$Longitude[key]) %>% 
  arrange(time)
sum.nn

# add spp to track
#require(zoo)
y = y %>% mutate(spp = "WAYPNT", transect = NA, offline = 1)
y$spp[sum.nn$key] = sum.nn$spp
y$transect[sum.nn$key] = sum.nn$transect
y$offline[c(sum.nn$key[1]:sum.nn$key[2],sum.nn$key[3]:sum.nn$key[4],
            sum.nn$key[5]:sum.nn$key[6],sum.nn$key[7]:sum.nn$key[8],
            sum.nn$key[9]:sum.nn$key[10],sum.nn$key[11]:sum.nn$key[12],
            sum.nn$key[13]:sum.nn$key[14],sum.nn$key[15]:sum.nn$key[16])]=0
y$transect[y$offline %in% 0] = na.locf(y$transect[y$offline %in% 0])

ggplot(y, aes(Longitude, Latitude, col=as.character(transect)))+
  geom_point()+
  geom_point(data = x[x$offline %in% 0,], aes(x=Longitude, y = Latitude, col=as.character(transect)))

# correct for real BEG/END points
z$zkey = paste(z$spp, z$transect, sep = "_")
y$zkey = paste(y$spp, y$transect, sep = "_")
if(any(y$zkey %in% z$zkey)) {
  y$spp[y$zkey %in% z$zkey] = "WAYPNT"
  for(a in seq(1:length(y$time[y$zkey %in% z$zkey]))) {
    if(z$spp[a] %in% "BEGCNT" & y$time[y$zkey %in% z$zkey[a]] < z$time) {
      y$offline[y$zkey %in% z$zkey[a]] = 1
      y$transect[y$zkey %in% z$zkey[a]] = NA
    }
    if(z$spp[a] %in% "ENDCNT" & y$time[y$zkey %in% z$zkey[a]] > z$time) {
      y$offline[y$zkey %in% z$zkey[a]] = 1
      y$transect[y$zkey %in% z$zkey[a]] = NA
    }
  };     rm(a)
  # if(z$spp[a] %in% "ENDCNT" & y$time[y$zkey %in% z$zkey[a]] < z$time) 
  # just change to WAYPNT, transect is correct
}
rm(z)
y = select(y, -zkey)

# then move start/stop from obs to track
x = mutate(x, offline = ifelse(spp %in% c("BEGCNT","ENDCNT") & !is.na(transect),0,offline))
y = bind_rows(y, filter(x, spp %in% c("BEGCNT","ENDCNT"))) %>% 
  arrange(time) %>%
  dplyr::select(Latitude, Longitude, date, time, spp, offline, transect)
x = filter(x, !spp %in% c("BEGCNT","ENDCNT"))

ggplot(y, aes(Longitude, Latitude, col=as.character(transect)))+
  geom_point()+
  geom_point(data = y[y$spp %in% "BEGCNT",], aes(x = Longitude, y = Latitude),  col = "green")+
  geom_point(data = y[y$spp %in% "ENDCNT",], aes(x = Longitude, y = Latitude),  col = "red")+
  theme_bw()

# make sure there is an even number of BEG/END counts
y %>% filter(spp %in% c("BEGCNT","ENDCNT")) %>% group_by(transect) %>% 
  summarise(n=n()) %>% filter(!is.na(transect), n %% 2 !=0 )

# check for any on transect counts without a transect
any(x$offline %in% 0 & is.na(x$transect))

# export
write.csv(x, paste(dir.out, "/standard_obs_", as.character(y$date[n]), sep=""))
write.csv(y, paste(dir.out, "/standard_track_", as.character(y$date[n]), sep=""))
