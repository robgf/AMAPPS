#---------------#
# fix track info once a transect was assigned
#---------------#

# lf 324600
obstrack$transect[obstrack$transect %in% 324600 & obstrack$seat %in%'lf'& obstrack$lat>37.5] = NA

# lf 363100

# remove loop in 290600 for both lf and rf
# lf
#add BEG ID 2694
#add END ID 2660
obstrack$type[obstrack$seat %in% 'lf' & obstrack$transect %in% 290600 & obstrack$sec %in% 36779.69] = "ENDCNT"
obstrack$type[obstrack$seat %in% 'lf' & obstrack$transect %in% 290600 & obstrack$sec %in% 36949.66] = "BEGCNT"
obstrack$offline[obstrack$seat %in% 'lf' & obstrack$transect %in% 290600 & 
                    obstrack$sec > 36779.69 & obstrack$sec < 36949.66] = 1
obstrack$transect[obstrack$seat %in% 'lf' & obstrack$transect %in% 290600 & 
                    obstrack$sec > 36779.69 & obstrack$sec < 36949.66] = NA
# rf
obstrack$offline[obstrack$seat %in% 'rf' & obstrack$transect %in% 290600 & 
                    obstrack$sec > 36767.55 & obstrack$sec < 36963.25] = 1
obstrack$transect[obstrack$seat %in% 'rf' & obstrack$transect %in% 290600 & 
                    obstrack$sec > 36767.55 & obstrack$sec < 36963.25] = NA

# add closest seconds
x = obstrack[obstrack$transect %in% 365101 & obstrack$obs %in% 'sde',]
# END ID 173 sec 57793.85
obstrack$sec[obstrack$transect %in% 365101 & obstrack$obs %in% 'sde' & obstrack$type %in% "ENDCNT"] = 
obstrack$sec[obstrack$transect %in% 365100 & obstrack$obs %in% 'sde' & obstrack$type %in% "BEGCNT"] = 
  
obstrack$sec[obstrack$transect %in% 365101 & obstrack$obs %in% 'jfv' & obstrack$type %in% "ENDCNT"] = 
obstrack$sec[obstrack$transect %in% 365100 & obstrack$obs %in% 'jfv' & obstrack$type %in% "BEGCNT"] = 

# plot
# x = obstrack[obstrack$transect %in% 363100 & obstrack$seat %in%'lf',]
# y = x[!is.na(x$obs),]
# ggplot(x, aes(long,lat,col=as.character(transect)))+geom_point()+theme_bw()

x = obstrack[obstrack$lat>35 & obstrack$lat<40 & obstrack$seat %in%'rf',]
ggplot(x, aes(long,lat,col=as.character(transect)))+geom_point()+theme_bw()
