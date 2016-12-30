#Data
plot(boat.obs$Longitude,boat.obs$Latitude, col = "grey")
points(boat.obs$Longitude[boat.obs$TRANSECT == "1"],boat.obs$Latitude[boat.obs$TRANSECT == "1"], col = "magenta")
points(boat.obs$Longitude[boat.obs$TRANSECT == "2"],boat.obs$Latitude[boat.obs$TRANSECT == "2"], col = "orange")
points(boat.obs$Longitude[boat.obs$TRANSECT == "3"],boat.obs$Latitude[boat.obs$TRANSECT == "3"], col = "red")
points(boat.obs$Longitude[boat.obs$TRANSECT == "4"],boat.obs$Latitude[boat.obs$TRANSECT == "4"], col = "brown")
points(boat.obs$Longitude[boat.obs$TRANSECT == "5"],boat.obs$Latitude[boat.obs$TRANSECT == "5"], col = "purple")
points(boat.obs$Longitude[boat.obs$TRANSECT == "6"],boat.obs$Latitude[boat.obs$TRANSECT == "6"], col = "navy")
points(boat.obs$Longitude[boat.obs$TRANSECT == "7"],boat.obs$Latitude[boat.obs$TRANSECT == "7"], col = "blue")
points(boat.obs$Longitude[boat.obs$TRANSECT == "8"],boat.obs$Latitude[boat.obs$TRANSECT == "8"], col = "cyan")
points(boat.obs$Longitude[boat.obs$TRANSECT == "9"],boat.obs$Latitude[boat.obs$TRANSECT == "9"], col = "green")
points(boat.obs$Longitude[boat.obs$TRANSECT == "10"],boat.obs$Latitude[boat.obs$TRANSECT == "10"], col = "forest green")
points(boat.obs$Longitude[boat.obs$TRANSECT == "11"],boat.obs$Latitude[boat.obs$TRANSECT == "11"], col = "violet")
points(boat.obs$Longitude[boat.obs$TRANSECT == "12"],boat.obs$Latitude[boat.obs$TRANSECT == "12"], col = "black")

#Transect Text
text(-73.463,40.5999, labels = "12")
text(-73.45,40.603, labels = "11")
text(-73.437,40.608, labels = "10")
text(-73.423,40.611, labels = "9")
text(-73.41,40.614, labels = "8")

text(-73.374,40.516, labels = "2")
text(-73.359,40.518, labels = "3")
text(-73.346,40.52, labels = "4")
text(-73.333,40.522, labels = "5")
text(-73.318,40.523, labels = "6")
text(-73.305,40.525, labels = "7")

#Transect Points
points(c(-73.3945,-73.3752),c(40.613,40.51893), col = "orange", pch=16) #2
points(c(-73.381,-73.3625),c(40.616,40.522),col = "red", pch=16) #3
points(c(-73.368,-73.348),c(40.62,40.525), col = "brown", pch=16) #4
points(c(-73.353,-73.334),c(40.622,40.526), col = "purple", pch=16) #5 
points(c(-73.3388,-73.32),c(40.6175,40.52828), col = "navy", pch=16) #6 
points(c(-73.324,-73.305),c(40.615,40.52868), col = "blue", pch=16) #7  
points(c(-73.409,-73.39),c(40.610,40.518), col = "cyan", pch=16) #8    
points(c(-73.423,-73.40404),c(40.605,40.517), col = "green", pch=16) #9    
points(c(-73.436,-73.419),c(40.603,40.516), col = "forest green", pch=16) #10    
points(c(-73.44927,-73.43212),c(40.598,40.515), col = "violet", pch=16) #11    
points(c(-73.462,-73.44459),c(40.59452,40.512), col = "black", pch=16) #12    

#Transect Lines
l2 = cbind(c(-73.3945,-73.3752),c(40.613,40.51893))
l3 = cbind(c(-73.381,-73.3625),c(40.616,40.522))  
l4 = cbind(c(-73.368,-73.348),c(40.62,40.525))  
l5 = cbind(c(-73.353,-73.334),c(40.622,40.526))  
l6 = cbind(c(-73.3388,-73.32),c(40.6175,40.52828))  
l7 = cbind(c(-73.324,-73.305),c(40.615,40.52868))  
l8 = cbind(c(-73.409,-73.39),c(40.610,40.518))  
l9 = cbind(c(-73.423,-73.40404),c(40.605,40.517))  
l10 = cbind(c(-73.436,-73.419),c(40.603,40.516))  
l11 = cbind(c(-73.44927,-73.43212),c(40.598,40.515))  
l12 = cbind(c(-73.462,-73.44459),c(40.59452,40.512))  

Sl2 <- Line(l2)
Sl3 <- Line(l3)
Sl4 <- Line(l4)
Sl5 <- Line(l5)
Sl6 <- Line(l6)
Sl7 <- Line(l7)
Sl8 <- Line(l8)
Sl9 <- Line(l9)
Sl10 <- Line(l10)
Sl11 <- Line(l11)
Sl12 <- Line(l12)

S2 <- Lines(list(Sl2), ID = "2")
S3 <- Lines(list(Sl3), ID = "3")
S4 <- Lines(list(Sl4), ID = "4")
S5 <- Lines(list(Sl5), ID = "5")
S6 <- Lines(list(Sl6), ID = "6")
S7 <- Lines(list(Sl7), ID = "7")
S8 <- Lines(list(Sl8), ID = "8")
S9 <- Lines(list(Sl9), ID = "9")
S10 <- Lines(list(Sl10), ID = "10")
S11 <- Lines(list(Sl11), ID = "11")
S12 <- Lines(list(Sl12), ID = "12")

SL <- SpatialLines(list(S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12))
survey_design = SpatialLinesDataFrame(SL, data.frame(Transect = c("2","3","4","5","6","7","8","9","10","11","12"), 
                                                     row.names = c("2","3","4","5","6","7","8","9","10","11","12")))

