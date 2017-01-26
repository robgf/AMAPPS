#-------------------#
# fix problems that occur after the join of track and obs
#-------------------#

#-------------------#
# for some reason double BEG and END counts are generated even after an attempt to fix this error
# so if they occur, remove them

obstrack %>% filter(type %in% c("BEGCNT","ENDCNT")) %>% select(transect, key) %>% 
  group_by(key, transect) %>% summarise(num = n()) %>% filter((num %% 2) != 0)

obstrack[obstrack$key %in% "Crew4446_rf_2014_10_10" & obstrack$transect %in% 412602 & 
           obstrack$type %in% "ENDCNT" & obstrack$count %in% 300,] = NA
obstrack[obstrack$key %in% "Crew4446_rf_2014_10_10" & obstrack$transect %in% 412601 &
           obstrack$type %in% "BEGCNT" & obstrack$sec %in% 53939.23,] = NA
obstrack = obstrack[!is.na(obstrack$sec),]
#-------------------#

#-------------------#
# remove transit info in the beginning 
x = obstrack$ID[obstrack$type %in% "BEGCNT"][1]
obstrack = obstrack[obstrack$ID %in% c(x:max(obstrack$ID)),] 
# now na.locf will work
#-------------------#
