# --------------------- #
# Quality control BOEM terns 2013 data
# from FWS MB
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(tidyverse) # read and bind csvs
require(rgdal) # read shapefiles
require(foreign) # read dbf
require(dplyr)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "BOEM_terns2013"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
data.list = c( "TernSurvey1_CorrectedObservations.csv","TernSurvey2_CorrectedObservations.csv",
               "TernSurvey3_CorrectedObservations.csv","TernSurvey4_CorrectedObservations.csv")
data.list = paste(dir.in, data.list, sep="/")
data = data.list %>% map_df(~read_csv(.x, col_types = cols(.default = "c")))

#time
data = data %>% mutate(ss.s = ifelse(nchar(ss.s)==1,paste("0",ss.s,sep=""),ss.s),
                       mm = ifelse(nchar(mm)==1,paste("0",mm,sep=""),mm),
                       date_time = paste(paste(MM,DD,YYYY,sep="/"),paste(hh,mm,ss.s,sep=":"),sep=" "))

# fix beaufort
data$Beaufort[is.na(data$Beaufort)] = data$ort[is.na(data$Beaufort)]
data$Beaufort[is.na(data$Beaufort)] = data$Beauf[is.na(data$Beaufort)]
data = select(data, -Beauf, -ort)

#split data and track
track = data[data$Type %in% "GPS",]
data = data[!data$Type %in% "GPS",]
#---------------------#


#---------------------#
# fix errors
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
Spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

tmp = which(is.na(data$Spp)) 
data$Spp[tmp]= data$species[tmp]
data$species[tmp]=NA
unique(data$species)
data = dplyr::select(data,-species)
data$original_species_tx = data$Spp

tmp <- !data$Spp %in% Spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(data$Spp[tmp]))

data$Spp[data$Spp %in% c("'CXFC","MIACO","RBTU","SILTF","FLCR")] = "UNKN" 
data$Spp[data$Spp %in% c("FRONT","FT")] = "OCFR"
data$Spp[data$Spp %in% c("CIRCL")] = "COMMENT"
data$Spp[data$Spp %in% "BLUFI"] = "TUNA"  
data$Spp[data$Spp %in% c("STTE")] = "UNTE"   
data$Spp[data$Spp %in% "UNTU"] = "TURT" 
data$Spp[data$Spp %in% "START"] = "BEGCNT"
data$Spp[data$Spp %in% c("END","ENDSU")] = "ENDCNT"
data$Spp[data$Spp %in% c("BOAT","BOATS")] = "BOAT" 
data$Spp[data$Spp %in% "SHARK"] = "SHAR"  
data$Spp[data$Spp %in% "SCOT"] = "UNSC"   

data$Spp[is.na(data$Spp) & data$Comment.1 %in% c("STOP","DONE")] = "ENDCNT"
data$Spp[is.na(data$Spp) & data$Comment.2 %in% "STOP"] = "ENDCNT"
#data$Spp[is.na(data$Spp) & data$Behavior %in% c("stop","STOP")] = "ENDCNT"
data$Spp[is.na(data$Spp) & data$Comment.1 %in% c("START","START 300")] = "BEGCNT"
data$Spp[is.na(data$Spp) & data$Comment.1 %in% c("200 TERNS")] = "UNTE"
data$Count[data$Spp %in% "UNTE" & data$Comment.1 %in% c("200 TERNS")] = 200
data$Spp[is.na(data$Spp) & data$Comment.1 %in% c("TRAWLER")]="BOTD"
data$Spp[is.na(data$Spp) & data$Comment.1 %in% c("FRONT","WIND E 0-5","RAIN SHOWE","PART CLDY",
                                              "CLOUDY","RAIN GAME","CLEAR","LT WIND W",
                                              "WIND W 8","WIND LT","WIND SW 5",
                                              "EAR     WIND W","W 12","NE",
                                              "WIND E 10","WIND SE 12","SIND SW 12")] = "COMMENT"
# add trawl records
to.add = data[!data$Spp %in% "BOTD" & data$Comment.1 %in% c("TRAWLER","DRAGGER","TRAWLER ST"),]
to.add$Count = 1
to.add$Spp = "BOTD"
to.add$behavior = ""
to.add$original_species_tx = to.add$Comment.1
to.add$Comment.1 = "Added record due to comment"
data = rbind(data, to.add)
rm(to.add)
data = arrange(data,date_time)

# fix lat lon
data$Longitude = as.numeric(data$Longitude)*-1
data$Latitude = as.numeric(data$Latitude)

#track
track$Type[track$Type %in% "GPS"] = "WAYPNT"
track$Longitude = as.numeric(track$Longitude)*-1
track$Latitude = as.numeric(track$Latitude)
#---------------------#


#---------------------#
## split tracks by survey
# end Beg and End counts
#---------------------#
data$offline = 0
track$offline = 0

#--------#
# survey 1
# SAP
#--------#
track1SAP = track[track$SurveyID=="TernSurvey1"& track$Obs=="SAP",]
data1SAP = data[data$SurveyID=="TernSurvey1"& data$Obs=="SAP",]
track1SAP = arrange(track1SAP,date_time)
data1SAP = arrange(data1SAP,date_time)  
track1SAP$id = 1:dim(track1SAP)[1]
data1SAP$id = 1:dim(data1SAP)[1]

  #add end
to.add = data1SAP[data1SAP$id == 27,]
to.add$Spp = "ENDCNT"
to.add$id = 27.1
to.add$original_species_tx = NA
to.add$Comment.1 = "added ENDCNT based on track"
data1SAP = bind_rows(data1SAP,to.add) %>% arrange(id)
data1SAP$Spp[data1SAP$id == 28] = "Comment"
data1SAP$Comment.1[data1SAP$id == 28] = paste(data1SAP$Comment.1[data1SAP$id == 28],
                                              "changed ENDCNT to Comment based on track",sep="; ")
  #add end
to.add = track1SAP[track1SAP$id == 600,]
to.add$Spp = "ENDCNT"
to.add$id = 15.1
to.add$original_species_tx = NA
to.add$Comment.1 = "added ENDCNT based on track"
data1SAP = bind_rows(data1SAP,to.add) %>% arrange(date_time)

  #add beg
to.add = track1SAP[track1SAP$id == 1306,]
to.add$Spp = "BEGCNT"
to.add$id = 31.1
to.add$original_species_tx = NA
to.add$Comment.1 = "added BEGCNT based on track"
data1SAP = bind_rows(data1SAP,to.add) %>% arrange(date_time)

  #add end
to.add = track1SAP[track1SAP$id == 1238,]
to.add$Spp = "ENDCNT"
to.add$id = 30.1
to.add$original_species_tx = NA
to.add$Comment.1 = "added ENDCNT based on track"
data1SAP = bind_rows(data1SAP,to.add) %>% arrange(date_time)

  # change from NA
data1SAP$Spp[data1SAP$id %in% 31]="UNKN"

data1SAP$Spp[data1SAP$id == 18]= "BEGCNT"
data1SAP$Comment.1[data1SAP$id == 18] = "Changed Spp from NA; added BEGCNT based on track and empty space in record"

  # note offline obs
data1SAP$offline[data1SAP$id %in% c(1:5,16,17,28,29,31)] = 1
track1SAP$offline[track1SAP$id %in% c(1:418, 601:735, 1074:1184, 1239:1306, 1409:1691)] = 1
#--------#

#--------#
# survey 1
# RRV
#--------#
track1RRV = track[track$SurveyID=="TernSurvey1"& track$Obs=="RRV",]
data1RRV = data[data$SurveyID=="TernSurvey1"& data$Obs=="RRV",]
track1RRV = arrange(track1RRV,date_time)
data1RRV = arrange(data1RRV,date_time)  
track1RRV$id = 1:dim(track1RRV)[1]
data1RRV$id = 1:dim(data1RRV)[1]

  #add beg
to.add = data1RRV[data1RRV$id == 18,]
to.add$Spp = "BEGCNT"
to.add$id = 17.1
to.add$original_species_tx = NA
to.add$Comment.1 = "added BEGCNT based on track"
data1RRV = bind_rows(data1RRV,to.add) %>% arrange(date_time)

to.add = data1SAP[data1SAP$id %in% c(15.1, 27.1, 30, 30.1, 31.1),]
to.add$Obs = "RRV"
to.add$id = c(15.1,27.1,31.1,32.1,34.1)
data1RRV = bind_rows(data1RRV,to.add) %>% arrange(id)
  
data1RRV$offline[data1RRV$id %in% c(1:5,16,17,28:31,33,34,38)] = 1
track1RRV$offline[track1RRV$id %in% c(1:341, 526:616, 1000:1110, 1164:1231, 1335:1413)] = 1
#--------#

#--------#
# survey 2
# SAP
#--------#
track2SAP = track[track$SurveyID=="TernSuvey2"& track$Obs=="SAP",]
data2SAP = data[data$SurveyID=="TernSuvey2"& data$Obs=="SAP",]
track2SAP = arrange(track2SAP,date_time)
data2SAP = arrange(data2SAP,date_time)  
track2SAP$id = 1:dim(track2SAP)[1]
data2SAP$id = 1:dim(data2SAP)[1]

data2SAP$offline[data2SAP$id %in% c(1:2,60:69)] = 1
track2SAP$offline[track2SAP$id %in% c(1:438, 1265:1687)] = 1
#--------#

#--------#
# survey 2
# SAP
#--------#
track2RRV = track[track$SurveyID=="TernSuvey2"& track$Obs=="RRV",]
data2RRV = data[data$SurveyID=="TernSuvey2"& data$Obs=="RRV",]
track2RRV = arrange(track2RRV,date_time)
data2RRV = arrange(data2RRV,date_time)  
track2RRV$id = 1:dim(track2RRV)[1]
data2RRV$id = 1:dim(data2RRV)[1]

# add beg, change end
to.add = data2RRV[data2RRV$id==4,]
to.add$Spp="BEGCNT"
to.add$Comment.1="added BEGCNT due to track design"
to.add$id=3.1
data2RRV = bind_rows(data2RRV,to.add) %>% arrange(date_time)

to.add = data2SAP[data2SAP$Spp %in% "ENDCNT",]
to.add$Obs = "RRV"
to.add$Comment.1 = "added from SAP"
to.add$id=49.1
data2RRV = bind_rows(data2RRV,to.add) %>% arrange(date_time)

#offline
data2RRV$offline[data2RRV$id %in% c(1:3,50:75)] = 1
track2RRV$offline[track2RRV$id %in% c(1:361, 1189:1609)] = 1
#--------#

## survey3 missing long for both data and track

#--------#
# survey 4
# SAP
#--------#
track4SAP = track[track$SurveyID=="survey4"& track$Obs=="SAP",]
data4SAP = data[data$SurveyID=="survey4"& data$Obs=="SAP",]
track4SAP = arrange(track4SAP,date_time)
data4SAP = arrange(data4SAP,date_time)  
track4SAP$id = 1:dim(track4SAP)[1]
data4SAP$id = 1:dim(data4SAP)[1]

  #add end
to.add = track4SAP[track4SAP$id==954,]
to.add$Spp = "ENDCNT"
to.add$id=13.1
to.add$Comment.1="added ENCNT based on track design"
data4SAP = bind_rows(data4SAP,to.add) %>% arrange(date_time)

  #offline
data4SAP$offline[data4SAP$id %in% c(1:5,14:16)] = 1
track4SAP$offline[track4SAP$id %in% c(1:201, 955:1060)] = 1
track4SAP = track4SAP[!is.na(track4SAP$Type),]
#--------#


#--------#
# survey 4
# RRV
#--------#
track4RRV = track[track$SurveyID=="survey4"& track$Obs=="RRV",]
data4RRV = data[data$SurveyID=="survey4"& data$Obs=="RRV",]
track4RRV = arrange(track4RRV,date_time)
data4RRV = arrange(data4RRV,date_time)  
track4RRV$id = 1:dim(track4RRV)[1]
data4RRV$id = 1:dim(data4RRV)[1]

# add BEG and END
to.add = data4SAP[data4SAP$Spp %in% c("BEGCNT","ENDCNT"),]
to.add$Obs = "RRV"
data4RRV = bind_rows(data4RRV,to.add) %>% arrange(date_time)

data4RRV$offline[data4RRV$id %in% c(1:3,14:29)] = 1
track4RRV$offline[track4RRV$id %in% c(1:122, 875:1153)] = 1
track4RRV = track4RRV[!is.na(track4RRV$Type),]
#--------#

#--------#
#x = track4RRV
#y = data4RRV
#plot(x$Longitude,x$Latitude,col="yellow")
#points(x$Longitude[x$offline==0],x$Latitude[x$offline==0],col="grey")
#points(y$Longitude[y$Spp=="ENDCNT"],y$Latitude[y$Spp=="ENDCNT"],col="red",pch=15,cex=1.5)
#points(y$Longitude[y$Spp=="BEGCNT"],y$Latitude[y$Spp=="BEGCNT"],col="darkgreen",pch=15,cex=1.5)
#points(y$Longitude,y$Latitude,col="orange",pch=16)
#points(y$Longitude[y$offline %in% 1],y$Latitude[y$offline %in% 1],col="purple",pch=16)
