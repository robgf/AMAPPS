# ----------------------------------------------------------------------------------------- #

# Created by: Kaycee Coleman, Oct. 2015
# This file if for obvious track errors that should not be included in GIS file
# This will help cut down on manually deleting the points, however you need to visually
# inspect the data to find obvious errors
# Additionally, this is a good spot to add transects that were not recorded by one observer
# since the observations and tracks have already been joined
#
# ----------------------------------------------------------------------------------------- #
# delete track points that were added due to ENDCNT error, needed that ENDCNT to get the track
toCut = which(obstrack$transect=="440600" & obstrack$long < 
                obstrack$long[obstrack$transect=="440600" & obstrack$sec == 49536])
toAdd = obstrack[toCut[obstrack$type[toCut]=="ENDCNT"],]
toAdd$lat = obstrack$lat[obstrack$transect=="440600" & obstrack$sec == 49536]
toAdd$long = obstrack$long[obstrack$transect=="440600" & obstrack$sec == 49536]
toAdd$sec = "49536"
obstrack = obstrack[-toCut,]
obstrack = rbind(obstrack, toAdd)
  
## MISSING TRANSECT 364101 for LF, COPY RF 
toAdd = obstrack[obstrack$transect=="364101",]
toAdd = toAdd[!is.na(toAdd[,1]),]
toAdd$obs = "jsw"
toAdd$seat = "lf"
toAdd$dataChange = paste(toAdd$dataChange, " TRANSECT copied from RT because it was missing in LF file", sep=";")
obstrack = rbind(obstrack, toAdd)
rm(toAdd)

## MISSING TRANSECT 321100 for LF (ONCE CORRECTED), COPY RF 
toAdd = obstrack[obstrack$transect=="321100" & obstrack$obs=="mtj",]
toAdd = toAdd[!is.na(toAdd[,1]),]
toAdd = toAdd[toAdd$type %in% c("BEGCNT","WAYPNT","ENDCNT"),]
toAdd$obs = "fhr"
toAdd$seat = "lf"
toAdd$dataChange = paste(toAdd$dataChange, " TRANSECT copied from RT because it was missing in LF file", sep=";")
obstrack = rbind(obstrack, toAdd)
rm(toAdd)
