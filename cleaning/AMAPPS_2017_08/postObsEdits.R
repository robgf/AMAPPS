# key transect     n
# <chr>    <chr> <int>
#   1  Crew3521_rf_2017_8_20   301600     1
# 2  Crew3521_rf_2017_8_20   302100     3
# 3  Crew4126_lf_2017_8_26   365100     1
# 4  Crew4126_lf_2017_8_26   365101     1
#  5  Crew4126_lf_2017_8_27   363100     1
# 6  Crew4126_lf_2017_8_27   363600     3
# 7  Crew4126_rf_2017_8_26   365100     1
# 8  Crew4126_rf_2017_8_26   365101     1
# 9  Crew4446_rf_2017_8_20   434600    21
#  10 Crew4446_rf_2017_8_21   424100     3
#  11 Crew4446_rf_2017_8_21   430600     1


# k = 'Crew4126_lf_2017_8_26'
# t1 = 365100
# t2 = 365101
# x = filter(obstrack, key %in% k, transect %in% t1)
# y = filter(obstrack, key %in% k, transect %in% t2)
# xy = rbind(x,y) %>% arrange(sec,index)
# ggplot(xy, aes(long,lat,col=transect))+geom_point()

# Crew3521_rf_2017_8_20
# 301600 needs and ENDCNT
obstrack$type[obstrack$key %in% 'Crew3521_rf_2017_8_20' & obstrack$transect %in% 301600 & obstrack$type %in% 'ENDCNT']="COMMENT"
obstrack$type[obstrack$key %in% 'Crew3521_rf_2017_8_20' & is.na(obstrack$obs) & obstrack$sec %in% 33677.05] = "ENDCNT"
obstrack$transect[obstrack$key %in% 'Crew3521_rf_2017_8_20' & is.na(obstrack$obs) & obstrack$sec %in% 33677.05] = 301600
obstrack$comment[obstrack$key %in% 'Crew3521_rf_2017_8_20' & is.na(obstrack$obs) & obstrack$sec %in% 33677.05] = "Added ENDCNT"
obstrack$offline[obstrack$key %in% 'Crew3521_rf_2017_8_20' & is.na(obstrack$obs) & obstrack$sec %in% 33677.05] = 0


#obstrack$offline[obstrack$key %in% 'Crew3521_rf_2017_8_20' & obstrack$transect %in% 301600 & obstrack$sec > 33677.05] = 1
#obstrack$transect[obstrack$key %in% 'Crew3521_rf_2017_8_20' & obstrack$transect %in% 301600 & obstrack$sec > 33677.05] = NA
         
# Crew4126_lf_2017_8_26
# Crew4126_rf_2017_8_26
# Add end at 365101 and add beg to 365100?

# missing track
# #365100
# -75.97500, 36.85 # west
# -75.77895, 36.85 # east -> need to add
# #365101
# -75.77895, 36.85 # west
# -75.09000, 36.85 #east -> need to add
to.add = as.data.frame(matrix(nrow=1,data = c(-75.77895, 36.85, NA, NA, 8, 26, 2017, NA, NA, "Added split between 365100/365101", NA)))
names(to.add) = c("long","lat","obs","seat","month","day","year","transect","type","comment", "key")
to.add1 = to.add %>% mutate(obs = 'jfv', seat = 'rf', transect = 365101, type = 'ENDCNT', index = 258.1, key = 'Crew4126_rf_2017_8_26',
                            long = as.numeric(long),lat = as.numeric(lat), month=as.numeric(month), day=as.numeric(day), year = as.numeric(year))
to.add2 = to.add %>% mutate(obs = 'jfv', seat = 'rf', transect = 365100, type = 'BEGCNT', index = 258.9, key = 'Crew4126_rf_2017_8_26',
                            long = as.numeric(long),lat = as.numeric(lat), month=as.numeric(month), day=as.numeric(day), year = as.numeric(year))
to.add3 = to.add %>% mutate(obs = 'sde', seat = 'lf', transect = 365101, type = 'ENDCNT', index = 276.1, key = 'Crew4126_lf_2017_8_26',
                            long = as.numeric(long),lat = as.numeric(lat), month=as.numeric(month), day=as.numeric(day), year = as.numeric(year))
to.add4 = to.add %>% mutate(obs = 'sde', seat = 'lf', transect = 365100, type = 'BEGCNT', index = 276.9, key = 'Crew4126_lf_2017_8_26',
                            long = as.numeric(long),lat = as.numeric(lat), month=as.numeric(month), day=as.numeric(day), year = as.numeric(year))
obstrack = bind_rows(obstrack, to.add1, to.add2, to.add3, to.add4) %>% arrange(key,sec,index)
rm(to.add,to.add1,to.add2,to.add3,to.add4)

# Crew4126_lf_2017_8_27
# 363100 needs and BEGCNT; 302100 need to remove BEGCOUNT that changed from 363100 to 363600
obstrack$type[obstrack$key %in% 'Crew4126_lf_2017_8_27' & is.na(obstrack$obs) & obstrack$sec %in% 33440.51]="BEGCNT"
obstrack$transect[obstrack$key %in% 'Crew4126_lf_2017_8_27' & is.na(obstrack$obs) & obstrack$sec %in% 33440.51]= 363100
obstrack$comment[obstrack$key %in% 'Crew4126_lf_2017_8_27' & is.na(obstrack$obs) & obstrack$sec %in% 33440.51]= "Added BEGCNT"
obstrack$offline[obstrack$key %in% 'Crew4126_lf_2017_8_27' & is.na(obstrack$obs) & obstrack$sec %in% 33440.51]= 0

# obstrack$type[obstrack$key %in% 'Crew4126_lf_2017_8_27' & obstrack$transect %in% 363100 & obstrack$sec %in% 33445.42]="BEGCNT"
# obstrack$type[obstrack$key %in% 'Crew4126_lf_2017_8_27' & obstrack$transect %in% 363100 & obstrack$sec %in% 33445.42]="BEGCNT"
# obstrack$offline[obstrack$key %in% 'Crew4126_lf_2017_8_27' & obstrack$transect %in% 363100 & obstrack$sec < 33445.42] = 1
# obstrack$transect[obstrack$key %in% 'Crew4126_lf_2017_8_27' & obstrack$transect %in% 363100 & obstrack$sec < 33445.42] = NA

# Crew4446_rf_2017_8_20
# missing BEG for 434600
# -70.18585, 43.76669
# -68.68500, 43.76700
# first obs close enough to start since there isn't a track for that bit
to.add = obstrack[obstrack$key %in% 'Crew4446_rf_2017_8_20' & obstrack$transect %in% 434600,][1,]
to.add = to.add %>% mutate(type = 'BEGCNT',comment = 'Added BEGCNT',index=index-0.1,count=NA)
obstrack = bind_rows(obstrack, to.add) %>% arrange(key,sec,index)
rm(to.add)
# cant find error in 435100

# Crew4446_rf_2017_8_21
# offline obs
obstrack$offline[obstrack$key %in% 'Crew4446_rf_2017_8_21' & 
                   obstrack$sec %in% c(41274.03,41287.88,41393.98,41406.21,41411.22,41459.11)] = 1
obstrack$transect[obstrack$key %in% 'Crew4446_rf_2017_8_21' & 
                   obstrack$sec %in% c(41274.03,41287.88,41393.98,41406.21,41411.22,41459.11)] = NA
# 424100 add end?
# obstrack$type[obstrack$key %in% 'Crew4446_rf_2017_8_21'] 
# obstrack$type[obstrack$key %in% 'Crew4446_rf_2017_8_21' & obstrack$transect %in% 424100 & obstrack$sec %in%  46038.06]='ENDCNT'
# obstrack$comment[obstrack$key %in% 'Crew4446_rf_2017_8_21' & obstrack$transect %in% 424100 & obstrack$sec %in%  46038.06]='Added ENDCNT'
         
#Crew4446_rf_2017_8_24'
obstrack$offline[obstrack$key %in% 'Crew4446_rf_2017_8_24' & 
                   obstrack$sec %in% 45292.94 & 
                   obstrack$type %in% 'ENDCNT'] = 1
obstrack$transect[obstrack$key %in% 'Crew4446_rf_2017_8_24' & 
                   obstrack$sec %in% 45292.94 & 
                   obstrack$type %in% 'ENDCNT'] = NA

#Crew4446_rf_2017_8_21  430600
# add BEG
to.add = obstrack[obstrack$key %in% 'Crew4446_rf_2017_8_21' & obstrack$transect %in% 430600,][1,]
to.add = to.add %>% mutate(type = 'BEGCNT',comment = 'Added BEGCNT',index=index-0.1,count=NA)
obstrack = bind_rows(obstrack, to.add) %>% arrange(key,sec,index)
rm(to.add)
