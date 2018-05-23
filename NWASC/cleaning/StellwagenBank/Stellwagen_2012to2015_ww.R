#-------------------#
# QA/QC of WW and other survey data on Stellwagen Bank
#-------------------#


#-------------------#
# run Stellwagen_2012to2015 to get data
#-------------------#
source("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/Stellwagen/Stellwagen_2012to2015.R")
rm(track_ss, obs_ss, obs_standard, track_standard, trans)
#-------------------#

#-------------------#
# formatting
#-------------------#
# fix behavior, age, etc
obs_ww = obs_ww %>% 
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
         behavior = replace(behavior, behavior_tx %in% "Following",14),
         behavior = replace(behavior, behavior_tx %in% "Standing",38),
         age = 5, 
         age = replace(age, animal_age_tx %in% "Adult", 1),        
         age = replace(age, animal_age_tx %in% "Immature", 6),     
         age = replace(age, animal_age_tx %in% "Juvenile", 2),     
         age = replace(age, animal_age_tx %in% "Unidentified", 5)) %>% 
  rename(count=N_Individuals)# %>% 
  #select(-Port,-Vessel,-Recorder,-Effort,-Protocol,-Weather,-WXNotes,-date_time,-Plumage)



#-----------------#
# break by date
#-----------------#
rm(x,y,z)
n = 6
date.list =  unique(obs_ww$date)
x = obs_ww[obs_ww$date %in% date.list[n],] %>% arrange(time)

ggplot(x,aes(Longitude,Latitude))+geom_point()+theme_bw()

# remove duplicates (ID and time)
# check if they are valid first, or duplicated just for association
x[duplicated(x[,c("spp","time","count","Beaufort","animal_age_tx","Range","Comments","Flight_Direction")]),]

if(any(duplicated(x[,c("spp","time","count","Beaufort","animal_age_tx","Range","Comments","Flight_Direction")]))) {
  x = x[!duplicated(x[,c("spp","time","count","Beaufort","animal_age_tx","Range","Comments","Flight_Direction")]),]
}

# check for any existing effort from notes
z = x %>% filter(spp %in% c("BEGCNT","ENDCNT"))
if(dim(z)[1]>0){
  ggplot()+geom_point(data = x, aes(x=Longitude, y=Latitude),col="lightgrey")+
    geom_point(data = z, aes(x=Longitude, y=Latitude),col="red")+theme_bw()
}

# change effort comments to COMMENT when no effort information is available
# and all to off effort
if(all(is.na(x$Effort))){
  x$spp[(x$Comments %in% c("effort","off effort") & is.na(x$spp)) |
          x$spp %in% c("BEGCNT","ENDCNT")] = "COMMENT"
  x$offline=1
  ggplot()+
    geom_point(data = x[x$spp %in% "COMMENT",], aes(x=Longitude, y=Latitude),col="black",shape=7,size=5)+
    geom_point(data = x, aes(x=Longitude, y=Latitude, col=time))+
    theme_bw()+
    theme(legend.position="none")
}

# if there is effort
if(any(!is.na(x$Effort))) {
  x = x %>% mutate(offline = ifelse(Effort %in% 1,0,1),
                   offline = ifelse(spp %in% c("BEGCNT","ENDCNT"),0,offline))
  
  if(length(unique(x$Observer))>1){
    x$transect=NA
    x$transect[x$Observer %in% unique(x$Observer)[1]]=1
    x$transect[x$Observer %in% unique(x$Observer)[2]]=2
  }
  
  y = x %>% mutate(spp = ifelse(spp %in% c("BEGCNT","ENDCNT"),spp,"WAYPNT")) %>% 
    select(ID, time, spp, Comments, date, Observer, Beaufort, Latitude, Longitude, 
           weather_tx, glare_tx, cloud_cover_tx,offline, transect) %>% 
    mutate(Comments = as.character(Comments),
           Comments = ifelse(spp %in% c("BEGCNT","ENDCNT"),Comments,NA)) 
  x = filter(x, !spp %in% c("BEGCNT","ENDCNT"))
  
  ggplot()+
    geom_point(data = y[y$spp %in% "BEGCNT",], aes(x=Longitude, y=Latitude),col="green",shape=7,size=3)+
    geom_point(data = y[y$spp %in% "ENDCNT",], aes(x=Longitude, y=Latitude),col="red",shape=7,size=3)+
    geom_point(data = y, aes(x=Longitude, y=Latitude, col=transect))+
    geom_point(data = y[y$offline %in% 1,], aes(x=Longitude, y=Latitude),col="lightgrey")+
    theme_bw()+
    theme(legend.position="none")
}

# export
write.csv(x, paste(dir.out, "/ww_obs_", as.character(x$date[n]), sep=""))
if(exists("y")){write.csv(y, paste(dir.out, "/ww_est_track_", as.character(x$date[n]), sep=""))}

# no effort for date.list[1]
