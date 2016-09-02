# ------------------------# 
# change names
#names(obs)[names(obs) == "__in_Flock"] <- "count"
names(obs)[names(obs) == "flock_cor"] <- "count"
obs$type = toupper(obs$type)
# ------------------------# 

# ------------------------# 
# convert units to latlong
#utm_zone = "19T"
obs$Northing = as.numeric(obs$Northing)
obs$Northing[obs$Northing==0]=NA
obs$Easting = as.numeric(obs$Easting)
obs$Easting[obs$Easting==0]=NA

# prepare UTM coordinates matrix (rgdal)
utms = cbind(obs$Easting,obs$Northing)
utms = utms[!is.na(utms[,1]),] # will not work with NA's
utmcoor<-SpatialPoints(utms, proj4string=CRS("+proj=utm +zone=19T"))
#utmdata$X and utmdata$Y are corresponding to UTM Easting and Northing, respectively. zone= UTM zone
# converting
longlatcoor<-spTransform(utmcoor,CRS("+proj=longlat +datum=WGS84"))
longlatcoor = as.data.frame(longlatcoor)
colnames(longlatcoor) = c("lon","lat")

tmp = obs[!is.na(obs$Northing),]
tmp2 = obs[is.na(obs$Northing),]
tmp2$lat=""
tmp2$lon=""
obs = rbind(cbind(tmp,longlatcoor),tmp2)
rm(tmp,tmp2,longlatcoor,utms,utmcoor)
colnames(obs) = tolower(colnames(obs))
obs$behavior=gsub("\\s", "", obs$behavior)
# ------------------------# 

# SPECIES
obs$type[obs$type=="ATLANTICWHITE-SIDEDDOLPHIN"] = "WSDO"
obs$type[obs$type %in% c("UNMG","UNIDENTIFIEDMERG")] = "UNME"
obs$type[obs$type=="DEADCOEI"] = "COEI"
obs$type[obs$type=="DEADGULL"] = "UNGU"
obs$type[obs$type=="DEADFLOATINGALCID"] = "UNAL"
obs$type[obs$type=="FINWHALE"] = "FIWH"
obs$type[obs$type=="HARBORPORPOISE"] = "HAPO"
obs$type[obs$type=="HARBORSEAL"] = "HASE"
obs$type[obs$type=="HUMPBACKWHALE"] = "HUWH"
obs$type[obs$type=="MINKEWHALE"] = "MIWH"
obs$type[obs$type=="MONARCHBUTTERFLY"] = "MONA"
obs$type[obs$type %in% c("UN-IDSHARK","UN-IDSHARK")] = "SHAR"
obs$type[obs$type=="UNIDDOLPHIN"] = "UNDO"
obs$type[obs$type=="LARGEWHALE"] = "UNLW"
obs$type[obs$type %in% c("UNIDWHALE","WHALE")]="UNWH"

#guesses since contact listed with data no longer available
obs$type[obs$type=="BLDU"] = "ABDU"
obs$type[obs$type=="CAGO"] = "CANG"
obs$type[obs$type %in% c("DEADULGU","ULGU")] = "UNLG"
obs$type[obs$type=="LSTP"] = "LEAS"
obs$type[obs$type=="UNGE"] = "UNGR"
obs$type[obs$type=="UNID"] = "UNKN"
	
#dates
obs$gps_date = as.Date(obs$gps_date)
	
	
