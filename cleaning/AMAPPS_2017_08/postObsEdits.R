#k = 'Crew4446_rf_2017_8_24'
#t1 = 413102
#t2 = 430600
#t3 = 431100 
#x = filter(obstrack, key %in% k, transect %in% t1)
#y = filter(obstrack, key %in% k, transect %in% t2)
#z = filter(obstrack, key %in% k, transect %in% t3)
#xyz = rbind(x,y,z) %>% arrange(sec,index)
#ggplot(x, aes(long,lat,col=transect))+geom_point()

# Crew3521_rf_2017_8_20
# 301600 needs and ENDCNT; 302100 need to remove ENDCOUNT that changed from 301600 to 302100

# Crew4126_lf_2017_8_26
#t1 = 365100 
#t2 = 365101

# Crew4126_lf_2017_8_27
# 363100 needs and BEGCNT; 302100 need to remove BEGCOUNT that changed from 363100 to 363600

# Crew4126_rf_2017_8_26
# Add end at 365101 and add beg to 365100?

# Crew4446_rf_2017_8_20
# missing BEG for 434600
# cant find error in 435100

# Crew4446_rf_2017_8_21
# offline obs
obstrack$offline[obstrack$key %in% 'Crew4446_rf_2017_8_21' & 
                   obstrack$sec %in% c(41274.03,41287.88,41393.98,41406.21,41411.22,41459.11)] = 1
obstrack$transect[obstrack$key %in% 'Crew4446_rf_2017_8_21' & 
                   obstrack$sec %in% c(41274.03,41287.88,41393.98,41406.21,41411.22,41459.11)] = NA
# 424100 add end?

#Crew4446_rf_2017_8_24'
obstrack$offline[obstrack$key %in% 'Crew4446_rf_2017_8_24' & 
                   obstrack$sec %in% 45292.94 & 
                   obstrack$type %in% 'ENDCNT'] = 1
obstrack$transect[obstrack$key %in% 'Crew4446_rf_2017_8_24' & 
                   obstrack$sec %in% 45292.94 & 
                   obstrack$type %in% 'ENDCNT'] = NA
