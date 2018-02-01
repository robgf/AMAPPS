#-----------------------#
#-----------------------#

#-----------------------#
# errors
#-----------------------#
#[1] "Transect  384601  only has one observer and needs to be checked"
#[2] "Transect  385100  only has one observer and needs to be checked"
##JFV 8/23 just didn't do 384601 & 385100


##1 Crew3521_lf_2017_8_20 301600       3
##2 Crew3521_rf_2017_8_20 301600       1
#3 Crew4126_lf_2017_8_27 363600       3 
#4 Crew4446_rf_2017_8_21 424100       3

# check transects changed
#1 Crew4126_rf_2017_8_26 390600   393600      # solid change
#10 Crew4126_lf_2017_8_27 363600   363100     # BEG error
#11 Crew3521_rf_2017_8_20 302100   301600     # END error
#12 Crew4446_rf_2017_8_18 442100   442600     # solid change
#-----------------------#

# tests ------ #
# x = obstrack[obstrack$transect %in% c(424100),] %>% arrange(obs, transect,sec,index)
# y = as.data.frame(matrix(nrow=1,ncol=2,data=c(36.58538,-74.93930)))
# names(y) =c("lat","lon")
#ggplot(x, aes(long, lat, col=transect))+geom_jitter() #+geom_point(data = y, aes(x = lon, y=lat),col="black")
# ------------ #

obstrack = obstrack %>% ungroup()  

#-----------------------#
#10 Crew4126_lf_2017_8_27 363600   363100  
# BEG is wrong
# change to COMMENT
# add BEG
obstrack$type[obstrack$transect %in% 363600 & obstrack$sec %in% 33315.07] = "COMMENT"
obstrack$transect[obstrack$transect %in% 363600 & obstrack$sec %in% 33315.07] = NA

to.add = obstrack[obstrack$transect %in% 363100 & obstrack$type %in% "BEGCNT",]
to.add = to.add %>% mutate(seat = "lf",
                           obs = "sde",
                           index = 21.9,
                           condition = NA,
                           dataChange = "Added based on observer's BEGCNT",
                           WAVfile = NA,
                           file = NA,
                           key = "Crew4126_lf_2017_8_27")
obstrack = rbind(obstrack, to.add)
rm(to.add)
#-----------------------#

#-----------------------#
# 11 Crew3521_rf_2017_8_20 302100   301600  
# add an END
obstrack$transect[obstrack$transect %in% 302100  & obstrack$sec %in% 33827.05] = NA

to.add = obstrack[obstrack$transect %in% 301600 & obstrack$type %in% "ENDCNT",]
to.add = to.add %>% mutate(seat = "rf",
                           obs = "mtj",
                           index = 2.9,
                           condition = NA,
                           dataChange = "Added based on pilot's ENDCNT",
                           WAVfile = NA,
                           file = NA, 
                           key = "Crew3521_rf_2017_8_20")
obstrack = rbind(obstrack, to.add)
rm(to.add)
#-----------------------#

#-----------------------#
#4 Crew4446_rf_2017_8_21 424100       3
# extra BEGCNT, no clue where the END break on the line would've happened so removed
obstrack$type[obstrack$seat %in% "rf" & obstrack$transect %in% 424100 & obstrack$sec %in% 46124.84] = "COMMENT"
#-----------------------#

#-----------------------#
# missing crew
obstrack$crew[obstrack$transect %in% c(365101,365100)] = "Crew4126"
#-----------------------#
