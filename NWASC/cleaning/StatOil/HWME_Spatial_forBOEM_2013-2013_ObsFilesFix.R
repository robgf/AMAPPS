# ------------------------# 
# change names
names(obs)[names(obs) == "__in_Flock"] <- "count"
obs$type = toupper(obs$type)
obs$behavior=gsub("\\s", "", obs$behavior)
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
# ------------------------# 

# SPECIES
obs$type[obs$type=="ATLANTIC WHITE-SIDED DOLPHIN"] = "WSDO"
obs$type[obs$type=="DEAD COEI"] = "COEI"
obs$type[obs$type=="DEAD GULL"] = "UNGU"
obs$type[obs$type=="DEADFLOATING ALCID"] = "UNAL"
obs$type[obs$type=="FIN WHALE"] = "FIWH"
obs$type[obs$type=="HARBOR PORPOISE"] = "HAPO"
obs$type[obs$type=="HARBOR SEAL"] = "HASE"
obs$type[obs$type=="HUMPBACK WHALE"] = "HUWH"
obs$type[obs$type=="MINKE WHALE"] = "MIWH"
obs$type[obs$type=="MONARCH BUTTERFLY"] = "MONA"
obs$type[obs$type %in% c("UN-ID SHARK","UN-ID SHARK")] = "SHAR"
obs$type[obs$type=="UNID DOLPHIN"] = "UNDO"
obs$type[obs$type=="LARGE WHALE"] = "UNLW"
obs$type[obs$type %in% c("UNID WHALE","WHALE")]="UNWH"

#guesses
obs$type[obs$type=="BLDU"] = "ABDU"
obs$type[obs$type=="CAGO"] = "CANG"
obs$type[obs$type %in% c("DEAD ULGU","ULGU")] = "UNLG"
obs$type[obs$type=="LSTP"] = ""
obs$type[obs$type=="UNGE"] = ""
obs$type[obs$type=="UNID"] = ""
obs$type[obs$type=="UNMG"] = ""
	
	
	
	
