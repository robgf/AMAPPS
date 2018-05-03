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
n = 17 # 17 does not have a track to go with obs
date.list =  unique(obs_standard$date)
x = obs_standard[obs_standard$date %in% date.list[n],] 
y = track_standard[track_standard$date %in% date.list[n],]

ggplot(x,aes(Longitude,Latitude,col=as.character(transect)))+geom_point()+theme_bw()


# remove duplicates (ID and time)
# check if they are valid first, or duplicated just for association
x[duplicated(x[,c("spp","time","count","Beaufort","animal_age_tx","Range","Comments","Flight_Direction")]),]

if(any(duplicated(x[,c("spp","time","count","Beaufort","animal_age_tx","Range","Comments","Flight_Direction")]))) {
  x = x[!duplicated(x[,c("spp","time","count","Beaufort","animal_age_tx","Range","Comments","Flight_Direction")]),]
}

# check for any existing effort from notes
z = x %>% filter(spp %in% c("BEGCNT","ENDCNT"), !is.na(transect))
if(dim(z)[1]>0){
  ggplot()+geom_point(data = y, aes(x=Longitude, y=Latitude),col="lightgrey")+
  geom_point(data = z, aes(x=Longitude, y=Latitude),col="red")+theme_bw()
}

#specific fixes
if(all(as.character(x$date) %in% c("2015-10-27","2015-12-26","2015-09-28"))){
  hr = sapply(strsplit(y$time,":"),head,1)
  y$time = ifelse(hr %in% c("12","01","02","03","04","05"), 
                  format(strptime(paste(y$time," PM",sep=""), format='%I:%M:%S %p'), '%H:%M:%S'),
                  format(strptime(paste(y$time," AM",sep=""), format='%I:%M:%S %p'), '%H:%M:%S'))
  y = y %>% arrange(time)
}



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
                       ifelse(time[nn.index %in% 15] < time[nn.index %in% 16],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(16),
                       ifelse(time[nn.index %in% 15] > time[nn.index %in% 16],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(14),
                       ifelse(time[nn.index %in% 14] < time[nn.index %in% 13],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(13),
                       ifelse(time[nn.index %in% 14] > time[nn.index %in% 13],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(11),
                       ifelse(time[nn.index %in% 11] < time[nn.index %in% 12],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(12),
                       ifelse(time[nn.index %in% 11] > time[nn.index %in% 12],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(10),
                       ifelse(time[nn.index %in% 10] < time[nn.index %in% 9],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(9),
                       ifelse(time[nn.index %in% 10] > time[nn.index %in% 9],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(7),
                       ifelse(time[nn.index %in% 7] < time[nn.index %in% 8],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(8),
                       ifelse(time[nn.index %in% 7] > time[nn.index %in% 8],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(6),
                       ifelse(time[nn.index %in% 6] < time[nn.index %in% 5],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(5),
                       ifelse(time[nn.index %in% 6] > time[nn.index %in% 5],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(3),
                       ifelse(time[nn.index %in% 3] < time[nn.index %in% 4],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(4),
                       ifelse(time[nn.index %in% 3] > time[nn.index %in% 4],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(2),
                       ifelse(time[nn.index %in% 2] < time[nn.index %in% 1],"BEGCNT","ENDCNT")),
         spp = replace(spp, nn.index %in% c(1),
                       ifelse(time[nn.index %in% 2] > time[nn.index %in% 1],"BEGCNT","ENDCNT")),
         Latitude = y$Latitude[key],
         Longitude = y$Longitude[key]) %>% 
  arrange(time)
sum.nn


# add spp to track
#require(zoo)
y = y %>% mutate(spp = "WAYPNT", transect = NA, offline = 1)
y$spp[sum.nn$key] = sum.nn$spp
y$transect[sum.nn$key] = sum.nn$transect
y$Comments=NA
y$Comments[sum.nn$key] = "Estimated effort"
y$offline[c(sum.nn$key[1]:sum.nn$key[2],sum.nn$key[3]:sum.nn$key[4],
            sum.nn$key[5]:sum.nn$key[6],sum.nn$key[7]:sum.nn$key[8],
            sum.nn$key[9]:sum.nn$key[10],sum.nn$key[11]:sum.nn$key[12],
            sum.nn$key[13]:sum.nn$key[14],sum.nn$key[15]:sum.nn$key[16])]=0
y$transect[y$offline %in% 0] = na.locf(y$transect[y$offline %in% 0])


if(all(as.character(x$date) %in% "2013-09-20")){
  transect.list=c("16to15", "13to14","12to11","9to10",
                  "8to7", "5to6", "4to3", "1to2")  
  y = x %>% 
    filter(transect %in% transect.list) %>% 
    arrange(transect, time) %>% 
    group_by(transect) %>% 
    filter(row_number()==1 | 
             row_number()==n()) %>% 
    mutate(spp = ifelse(row_number()==1,"BEGCNT","ENDCNT")) %>%
    ungroup() %>% 
    mutate(offline=0,Comment="estimated effort") %>%
    select(-count,-Range,-animal_age_tx,-behavior_tx,-plumage_tx,-behavior,-age)
}

ggplot(y, aes(Longitude, Latitude, col=as.character(transect)))+
  geom_point()+theme_bw()+
  geom_point(data = x[x$offline %in% 0,], aes(x=Longitude, y = Latitude, col=as.character(transect)))

# specific fixes
if(any(as.character(z$date) %in% "2015-08-05" & z$transect %in% "9to10")) {
  y$spp[y$transect %in% "9to10" & y$time %in% "11:54:50"]="ENDCNT"
  y$Comments[y$transect %in% "9to10" & y$time %in% "11:54:50"]="Estimated effort"
  y$offline[y$time>y$time[y$transect %in% "9to10" & y$spp %in% "ENDCNT"][1] & y$time<z$time] = 1
  y$transect[y$time>y$time[y$transect %in% "9to10" & y$spp %in% "ENDCNT"][1] & y$time<z$time] = NA
  x$Comments[x$time>y$time[y$transect %in% "9to10" & y$spp %in% "ENDCNT"][1] & x$time<z$time] = "Changed to offline due to estimated effort"
  x$offline[x$time>y$time[y$transect %in% "9to10" & y$spp %in% "ENDCNT"][1] & x$time<z$time] = 1
  x$transect[x$time>y$time[y$transect %in% "9to10" & y$spp %in% "ENDCNT"][1] & x$time<z$time] = NA
}
if(any(as.character(z$date) %in% "2012-06-08" & z$transect %in% "16to15" & z$spp %in% "ENDCNT")) {
  # 16to15 ENDCNT: lists off-effort without an on-effort comment, no speed information to say when above 6 knots again. changed to comment
  x$Comments[x$transect %in% "16to15" & x$spp %in% "ENDCNT"] = "off effort, below 6 knots; Changed from ENDCNT due to no recording of when on effort started again. Needs adressing"
  x$spp[x$transect %in% "16to15" & x$spp %in% "ENDCNT"] = "COMMENT"
  z$spp[z$transect %in% "16to15" & z$spp %in% "ENDCNT"] = "COMMENT"
}
if(any(as.character(z$date) %in% "2012-08-09")){
  y$offline[y$transect %in% "1to2" & y$time>"15:45:45" & y$time<"15:47:47"] = 1
  y$transect[y$transect %in% "1to2" & y$time>"15:45:45" & y$time<"15:47:47"] = NA
  x$offline[x$transect %in% "1to2" & x$time>"15:45:45" & x$time<"15:47:47"] = 1
  x$transect[x$transect %in% "1to2" & x$time>"15:45:45" & x$time<"15:47:47"] = NA
  z$spp[z$transect %in% "1to2" & z$time %in% c("15:45:45","15:47:47")] = NA
  z$offline[z$transect %in% "1to2" & z$time %in% c("15:45:45","15:47:47")] = 0
  
  y$spp[y$transect %in% "16to15" & y$spp %in% "BEGCNT"] = "WAYPNT"
  y$spp[y$transect %in% "16to15" & y$time %in% "11:39:55"] = "BEGCNT"
  y$offline[y$transect %in% "16to15" & y$time < "11:39:55"] = 1
  y$transect[y$transect %in% "16to15" & y$time < "11:39:55"] = NA
  y$Comments[y$transect %in% "16to15" & y$time %in% "11:39:55"] = "Estimated effort"
  z$spp[z$transect %in% "16to15" & z$spp %in% "ENDCNT" & z$time < "11:00:00"] = NA
  x$spp[x$transect %in% "16to15" & x$spp %in% "ENDCNT" & x$time < "11:00:00"] = 1
}
if(any(as.character(x$date) %in% "2013-01-03")){
  y$offline[y$transect %in% "16to15" & y$time<"16:10:26"] = 1
  y$transect[y$transect %in% "16to15" & y$time<"16:10:26"] = NA
  x$offline[x$transect %in% "16to15" & x$time<"16:10:26"] = 1
  x$transect[x$transect %in% "16to15" & x$time<"16:10:26"] = NA

  x$spp[x$time %in% "16:10:26"]="BEGCNT"
#   
#   z$spp[z$transect %in% "16to15" & z$time %in% c("15:45:45","15:47:47")] = NA
#   z$offline[z$transect %in% "16to15" & z$time %in% c("15:45:45","15:47:47")] = 0
}

if(any(as.character(x$date) %in% "2015-10-27")){
  z = filter(z, !time %in% c("10:30:14","10:35:57","10:47:35","10:50:27"))
  y$transect[y$time > "10:30:14" & y$time < "10:35:57"] = NA
  y$offline[y$time > "10:30:14" & y$time < "10:35:57"] = 1
  y$offline[y$time > "10:47:35" & y$time < "10:50:27"] = 1
  y$transect[y$time > "10:47:35" & y$time < "10:50:27"] = NA
}

if(any(as.character(x$date) %in% "2015-12-26")){
  y$transect[y$time > "14:16:00" & y$time < "14:29:27"] = NA
  y$offline[y$time > "14:16:00" & y$time < "14:29:27"] = 1

  y$transect[y$time > "15:21:34" & y$time < "15:23:10"] = NA
  y$offline[y$time > "15:21:34" & y$time < "15:23:10"] = 1
  
  z = filter(z, !time %in% c("14:16:00","14:29:27","15:21:34","15:23:10"))
}


off.list = c("2to4","3to5","6to8","7to9","10to12","11to13","14to16")
if(any(x$transect %in% off.list)){
  x$offline[x$transect %in% off.list] = 1
  x$Comments = as.character(x$Comments)
  x$Comments[x$transect %in% off.list] = ifelse(!is.na(x$Comments[x$transect %in% off.list]),
                                                        paste(x$Comments[x$transect %in% off.list],
                                                              "Changed to offline", sep = "; "),
                                                        "Changed to offline")
  #x$transect[x$transect %in% off.list] = NA
  z$transect[z$transect %in% off.list] = NA
}

# correct for real BEG/END points
if(dim(z)[1]>0){
  z = filter(z, !is.na(transect)) %>% mutate(zkey = paste(spp, transect, sep = "_"))
  y$zkey = paste(y$spp, y$transect, sep = "_")
  if(any(y$zkey %in% z$zkey)) {
    for(a in seq(1:length(y$time[y$zkey %in% z$zkey]))) {
      if(any(z$spp[a] %in% "BEGCNT" & y$time[y$zkey %in% z$zkey[a]] < z$time[a])) {
        y$offline[y$time > y$time[y$spp %in% "BEGCNT" & y$transect %in% z$transect[a]] & y$time < z$time[a]] = 1
        y$transect[y$time > y$time[y$spp %in% "BEGCNT" & y$transect %in% z$transect[a]] & y$time < z$time[a]] = NA
        y$offline[y$zkey %in% z$zkey[a]] = 1
        y$transect[y$zkey %in% z$zkey[a]] = NA
        y$spp[y$zkey %in% z$zkey[a]] = "WAYPNT"
      }
#      if(z$spp[a] %in% "BEGCNT" & y$time[y$zkey %in% z$zkey[a]] > z$time[a]) {
#
#      }
      if(any(z$spp[a] %in% "ENDCNT" & y$time[y$zkey %in% z$zkey[a]] < z$time[a])) {
       y$offline[y$time > y$time[y$spp %in% "BEGCNT" & y$transect %in% z$transect[a]] &
                   y$time < z$time[a]] = 0
       y$transect[y$time > y$time[y$spp %in% "BEGCNT" & y$transect %in% z$transect[a]] &
                   y$time < z$time[a]] = as.character(z$transect[a])
       y$offline[y$zkey %in% z$zkey[a]] = 1
       y$transect[y$zkey %in% z$zkey[a]] = NA
       y$spp[y$zkey %in% z$zkey[a]] = "WAYPNT"
      }
      if(any(z$spp[a] %in% "ENDCNT" & y$time[y$zkey %in% z$zkey[a]] > z$time[a])){
        y$offline[y$time < y$time[y$spp %in% "ENDCNT" & y$transect %in% z$transect[a]] & y$time > z$time[a]] = 1
        y$transect[y$time < y$time[y$spp %in% "ENDCNT" & y$transect %in% z$transect[a]] & y$time > z$time[a]] = NA
        y$offline[y$zkey %in% z$zkey[a]] = 1
        y$transect[y$zkey %in% z$zkey[a]] = NA
        y$spp[y$zkey %in% z$zkey[a]] = "WAYPNT"
      }
    } ;     rm(a)
    }
  y = select(y, -zkey)
}
t = z$transect[a]
ggplot(y[y$transect %in% t,], aes(Longitude, Latitude))+geom_point(col="lightgrey")+
  theme_bw()+
  geom_point(data = y[y$transect %in% t & y$spp %in% "BEGCNT",], aes(x=Longitude, y=Latitude), shape=7, col="green")+
  geom_point(data = y[y$transect %in% t & y$spp %in% "ENDCNT",], aes(x=Longitude, y=Latitude), shape=7, col="red")+
  geom_point(data = x[x$transect %in% t & x$offline %in% 0,], aes(x=Longitude, y=Latitude), col="blue")+
  geom_point(data = x[x$transect %in% t & x$spp %in% "ENDCNT",], aes(x=Longitude, y=Latitude), shape = 3, col="indianred")+
  geom_point(data = x[x$transect %in% t & x$spp %in% "BEGCNT",], aes(x=Longitude, y=Latitude), shape = 3, col="darkgreen")+
  geom_point(data = x[x$transect %in% t & !x$offline %in% 0,], aes(x=Longitude, y=Latitude), shape=7, col="yellow")+
  geom_point(data = z[z$transect %in% t & z$spp %in% "BEGCNT",], aes(x=Longitude, y=Latitude), col="cyan")+
  geom_point(data = z[z$transect %in% t & z$spp %in% "ENDCNT",], aes(x=Longitude, y=Latitude), col="magenta")


# fix unlabeled offline
transect.list = as.character(unique(y$transect[!is.na(y$transect)]))
x = x %>% mutate(offline = ifelse(transect %in% transect.list & is.na(offline),0,offline),
                 offline = ifelse(!transect %in% transect.list & is.na(offline),1,offline))

# then move start/stop from obs to track
x = mutate(x, offline = ifelse(spp %in% c("BEGCNT","ENDCNT") & !is.na(transect),0,offline))
y = bind_rows(y, filter(x, spp %in% c("BEGCNT","ENDCNT"))) %>% 
  arrange(time) %>%
  dplyr::select(Latitude, Longitude, date, time, spp, offline, transect,Comments)
x = filter(x, !spp %in% c("BEGCNT","ENDCNT"))

# make sure there is an even number of BEG/END counts
y %>% filter(spp %in% c("BEGCNT","ENDCNT")) %>% group_by(transect) %>% 
  summarise(n=n()) %>% filter(!is.na(transect), n %% 2 !=0 )

# check for any on transect counts without a transect
any(x$offline %in% 0 & is.na(x$transect))

# relabel any points outside of BEG/END as offline
for(a in seq(1:length(transect.list))) {
  if(length(y$spp[y$transect %in% transect.list[a] & y$spp %in% c("BEGCNT","ENDCNT")])==2) { # dont want to run this with more than one end/beg point on the line
    if(any(x$transect %in% transect.list[a] & x$time > y$time[y$transect %in% transect.list[a] & y$spp %in% "ENDCNT"]|
           x$transect %in% transect.list[a] & x$time < y$time[y$transect %in% transect.list[a] & y$spp %in% "BEGCNT"])) {
      x$offline[x$transect %in% transect.list[a] & x$time > y$time[y$transect %in% transect.list[a] & y$spp %in% "ENDCNT"]] = 1
      x$offline[x$transect %in% transect.list[a] & x$time < y$time[y$transect %in% transect.list[a] & y$spp %in% "BEGCNT"]] = 1
      x$transect[x$transect %in% transect.list[a] & x$time > y$time[y$transect %in% transect.list[a] & y$spp %in% "ENDCNT"]] = NA
      x$transect[x$transect %in% transect.list[a] & x$time < y$time[y$transect %in% transect.list[a] & y$spp %in% "BEGCNT"]]= NA
    }
  }
}

if(any(y$spp %in% c("BEGCNT","ENDCNT") & y$transect %in% off.list & y$offline %in% 0)){
  y$Comments[y$spp %in% c("BEGCNT","ENDCNT") & 
               y$transect %in% off.list & 
               y$offline %in% 0]=paste(y$Comment[y$spp %in% c("BEGCNT","ENDCNT") & 
                                                   y$transect %in% off.list & 
                                                   y$offline %in% 0],
                                       "; Changed to offline", sep="")
  y$offline[y$spp %in% c("BEGCNT","ENDCNT") & y$transect %in% off.list & y$offline %in% 0]=1
}

ggplot(y, aes(Longitude, Latitude, col=as.character(transect)))+
  geom_point()+
  geom_point(data = y[y$spp %in% "BEGCNT" & y$offline %in% 0,], aes(x = Longitude, y = Latitude),  col = "green", shape = 7)+
  geom_point(data = y[y$spp %in% "ENDCNT" & y$offline %in% 0,], aes(x = Longitude, y = Latitude),  col = "red", shape = 7)+
  geom_point(data = x[x$offline %in% 0,], aes(Longitude, Latitude, col=as.character(transect)))+
  geom_point(data = x[!x$offline %in% 0,], aes(Longitude, Latitude),col="tan")+
  theme_bw()

# export
write.csv(x, paste(dir.out, "/standard_obs_", as.character(y$date[n]), sep=""))
write.csv(y, paste(dir.out, "/standard_track_", as.character(y$date[n]), sep=""))
