# ------------------------------------------------------------------- #
# Created to trim the data to only those within the survey transect as online
# the rest of the points will be assigned offline=1
# additionally add BEG and END counts to where survey transect starts and ends
#
# By: Kaycee Coleman
# June 2016
# ------------------------------------------------------------------- #

MassCEC_surveyFix <- function(data) {
  # Beginning of transect roughly -71.037, 41.1
  # End of transect roughtly -70.4286,41.4283
  
  # check if there are BEG/END points near these
  # if not assign them
  data$lat=as.numeric(as.character(data$lat))
  data$lon=as.numeric(as.character(data$lon))
  data$sec=as.numeric(as.character(data$sec))
  
  # BEG
  dists = abs(data$lat-41.1)
  if(any(dists<0.01 & data$type=="BEGCNT" & data$lon<(-71.0))){
    begin.sec = data$sec[dists<0.01 & data$type=="BEGCNT" & data$lon<(-71.0)]
    data$dataChange[dists<0.01 & data$type=="BEGCNT" & data$lon<(-71.0)] = "Changed TYPE from BEGCNT"
    data$type[dists<0.01 & data$type=="BEGCNT" & data$lon<(-71.0)] = "BEGTRAN"
#    if(data$type[which(dists<0.005 & data$type=="BEGCNT" & data$lon<(-71.0))-1]!="ENDCNT"){
#      add = data[dists<0.005 & data$type=="BEGCNT" & data$lon<(-71.0),]
#      add$type ="ENDCNT"
#      add$offline="1"
#      add$index = add$index -0.1
#      data = rbind(data,add)
#    }
  } else {
    dat=data[data$lon<(-71.0)]
    begin.sec = dat$sec[which.min(dists[data$lon<(-71.0)])]
    add1 = dat[which.min(dists[data$lon<(-71.0)]),]
    add1$type ="BEGTRAN"
    add1$index = add1$index -0.1
    add1$offline="0"
    add1$dataChange="Added BEGTRAN"
    data = rbind(data,add1)
#    add2 = dat[which.min(dists[data$lon<(-71.0)]),]
#    add2$type ="ENDCNT"
#    add2$index = add2$index -0.2
#    add2$offline="1"
#    add2$comment="ENDSEG"
#    data = rbind(data,add1,add2)
  }
  data <- data[order(data$index), ]
  
  # END
    dists = abs(data$lat-41.4283)
    if(any(dists<0.01 & data$type=="ENDCNT" & data$lon>(-70.45))){
      end.sec = data$sec[dists<0.01 & data$type=="ENDCNT" & data$lon>(-70.45)]
      data$dataChange[dists<0.01 & data$type=="ENDCNT" & data$lon>(-70.45)]="Changed from ENDCNT"
      data$type[dists<0.01 & data$type=="ENDCNT" & data$lon>(-70.45)]="ENDTRAN"
 #     if(data$type[which(dists<0.005 & data$type=="ENDCNT" & data$lon>(-70.45))+1]!="BEGCNT" & 
 #          nrow(data)>which(dists<0.005 & data$type=="ENDCNT" & data$lon>(-70.45))){
 #       add = data[dists<0.005 & data$type=="ENDCNT" & data$lon>(-70.45),]
 #       add$type ="BEGCNT"
 #       add$index = add$index -0.1
 #       add$offline="1"
 #       data = rbind(data,add)
 #     }
    } else {
      dat=data[data$lon>(-70.45)]
      end.sec = dat$sec[which.min(dists[data$lon>(-70.45)])]
      add3 = dat[which.min(dists[data$lon>(-70.45)]),]
      add3$type ="ENDTRAN"
      add3$offline="0"
      add3$dataChange="Added ENDTRAN"
      add3$index = add3$index +0.1   
#      if(nrow(data)>which.min(dists[data$lon>(-70.45)])){
#        add4 = dat[which.min(dists[data$lon>(-70.45)]),]
#        add4$type ="BEGCNT"
#        add4$index = add4$index +0.2
#        add4$offline="1"
#        data = rbind(data,add4)       
#     }
      data = rbind(data,add3)
    }   
  data <- data[order(data$index), ]
  
  # assign everything before the begin point to offline
  # assign everything after the begin point to offline
  # assign all waypoint between the two as online
  data$offline[data$sec<begin.sec]="1"
  data$offline[data$sec>end.sec]="1"
  data$offline[data$sec<=end.sec & data$sec>=begin.sec & data$type=="WAYPNT"]="0"
  
  return(data)
}
