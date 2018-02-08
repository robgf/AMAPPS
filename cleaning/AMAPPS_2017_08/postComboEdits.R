#---------------#
# fix track info once a transect was assigned
#---------------#

# lf 324600
obstrack$offline[obstrack$transect %in% 324600 & obstrack$seat %in%'lf'& obstrack$lat>37.5] = 1
obstrack$transect[obstrack$transect %in% 324600 & obstrack$seat %in%'lf'& obstrack$lat>37.5] = NA

# lf 363100

# remove loop in 290600 for both lf and rf
# lf
#add BEG ID 2694
#add END ID 2660
obstrack$type[obstrack$seat %in% 'lf' & obstrack$transect %in% 290600 & obstrack$sec %in% 36779.69] = "ENDCNT"
obstrack$type[obstrack$seat %in% 'lf' & obstrack$transect %in% 290600 & obstrack$sec %in% 36949.66] = "BEGCNT"
obstrack$offline[obstrack$seat %in% 'lf' & obstrack$transect %in% 290600 & obstrack$sec > 36779.69 & obstrack$sec < 36949.66] = 1
obstrack$transect[obstrack$seat %in% 'lf' & obstrack$transect %in% 290600 & obstrack$sec > 36779.69 & obstrack$sec < 36949.66] = NA
# rf
obstrack$offline[obstrack$seat %in% 'rf' & obstrack$transect %in% 290600 & obstrack$sec > 36767.55 & obstrack$sec < 36963.25] = 1
obstrack$transect[obstrack$seat %in% 'rf' & obstrack$transect %in% 290600 & obstrack$sec > 36767.55 & obstrack$sec < 36963.25] = NA

# add closest seconds

# fix points based on track
obstrack$sec[obstrack$transect %in% 365101 & obstrack$obs %in% 'sde' & obstrack$type %in% "ENDCNT"] = 57793.85
obstrack$lat[obstrack$transect %in% 365101 & obstrack$obs %in% 'sde' & obstrack$type %in% "ENDCNT"] = 36.85000
obstrack$long[obstrack$transect %in% 365101 & obstrack$obs %in% 'sde' & obstrack$type %in% "ENDCNT"] = c(-75.80667)
obstrack$ID[obstrack$transect %in% 365101 & obstrack$obs %in% 'sde' & obstrack$type %in% "ENDCNT"] = 98610.9

obstrack$sec[obstrack$transect %in% 365100 & obstrack$obs %in% 'sde' & obstrack$type %in% "BEGCNT"] = 57793.85
obstrack$lat[obstrack$transect %in% 365100 & obstrack$obs %in% 'sde' & obstrack$type %in% "BEGCNT"] = 36.85000
obstrack$long[obstrack$transect %in% 365100 & obstrack$obs %in% 'sde' & obstrack$type %in% "BEGCNT"] = c(-75.80667)
obstrack$ID[obstrack$transect %in% 365100 & obstrack$obs %in% 'sde' & obstrack$type %in% "BEGCNT"] = 98611.1

# fix transect points
obstrack$transect[obstrack$transect %in% 365101 & obstrack$key %in% "Crew4126_lf_2017_8_26" & obstrack$sec>57793.85] = 365100

# fix points based on track
obstrack$sec[obstrack$transect %in% 365101 & obstrack$obs %in% 'jfv' & obstrack$type %in% "ENDCNT"] = 57785.95
obstrack$lat[obstrack$transect %in% 365101 & obstrack$obs %in% 'jfv' & obstrack$type %in% "ENDCNT"] = 36.85000
obstrack$long[obstrack$transect %in% 365101 & obstrack$obs %in% 'jfv' & obstrack$type %in% "ENDCNT"] = c(-75.80817)
obstrack$ID[obstrack$transect %in% 365101 & obstrack$obs %in% 'jfv' & obstrack$type %in% "ENDCNT"] = 127832.9

obstrack$sec[obstrack$transect %in% 365100 & obstrack$obs %in% 'jfv' & obstrack$type %in% "BEGCNT"] = 57785.95
obstrack$lat[obstrack$transect %in% 365100 & obstrack$obs %in% 'jfv' & obstrack$type %in% "BEGCNT"] = 36.85000
obstrack$long[obstrack$transect %in% 365100 & obstrack$obs %in% 'jfv' & obstrack$type %in% "BEGCNT"] = c(-75.80817)
obstrack$ID[obstrack$transect %in% 365100 & obstrack$obs %in% 'jfv' & obstrack$type %in% "BEGCNT"] = 127833.1

# fix transect points
obstrack$transect[obstrack$transect %in% 365101 & obstrack$key %in% "Crew4126_rf_2017_8_26" & obstrack$sec>57785.95] = 365100

# plot
# x = obstrack[obstrack$transect %in% 363100 & obstrack$seat %in%'lf',]
# y = x[!is.na(x$obs),]
# ggplot(x, aes(long,lat,col=as.character(transect)))+geom_point()+theme_bw()

# x = obstrack[obstrack$lat>35 & obstrack$lat<40 & obstrack$seat %in%'rf',]
# ggplot(x, aes(long,lat,col=as.character(transect)))+geom_point()+theme_bw()

# erroneous transect points
obstrack$dataChange[obstrack$lat < 10] = "Latitude changed from 0.0015"
obstrack$lat[obstrack$lat < 10] = 40.721

# cut track points for 411601 lf bump
obstrack$offline[obstrack$transect %in% 411601 & obstrack$key %in% "Crew4446_lf_2017_8_24" & obstrack$sec>54169.99 & obstrack$sec<54650.20] = 1
obstrack$transect[obstrack$transect %in% 411601 & obstrack$key %in% "Crew4446_lf_2017_8_24" & obstrack$sec>54169.99 & obstrack$sec<54650.20] = NA

# cut track points for 411602 rf bump
# need to redefine BEG
#obstrack$transect[obstrack$transect %in% 411602 & obstrack$key %in% "Crew4446_lf_2017_8_24" & obstrack$sec>& obstrack$sec<] = NA

# cut track points for 412601 lf/rf bump
obstrack$offline[obstrack$transect %in% 412601 & obstrack$key %in% "Crew4446_rf_2017_8_24" & obstrack$sec>48353.10 & obstrack$sec<48657.78] = 1
obstrack$transect[obstrack$transect %in% 412601 & obstrack$key %in% "Crew4446_rf_2017_8_24" & obstrack$sec>48353.10 & obstrack$sec<48657.78] = NA

obstrack$offline[obstrack$transect %in% 412601 & obstrack$key %in% "Crew4446_lf_2017_8_24" & obstrack$sec>48360.30 & obstrack$sec<48658.74] = 1
obstrack$transect[obstrack$transect %in% 412601 & obstrack$key %in% "Crew4446_lf_2017_8_24" & obstrack$sec>48360.30 & obstrack$sec<48658.74] = NA



