# FIXING ERRORS IN THE AMAPPS 2013 09 DATA

# DataChange comments for spp_cd errors
changes = c("CAGO","BBGU","ALCD","GULL","BIRD","DOLP","SEAL","GRST",
            "LOST", "LEST", "UIST", "WHAL","LOON","BALOON",
            "BALLOON","UNMT","UMTE","UNTU")
for (a in 1:length(changes)) {
  obs$dataChange[which(obs$type == changes[a])] = 
    paste(obs$dataChange[which(obs$type == changes[a])],
          "; Changed TYPE from ", changes[a], sep ="") 
}
rm(changes, a)

# CODE ERRORS
obs$type[obs$type == "CAGO"] = "CANG"
obs$type[obs$type == "BBGU"] = "UBBG"
obs$type[obs$type == "ALCD"] = "UNAL"
obs$type[obs$type == "GULL"] = "UNGU" 
obs$type[obs$type == "BIRD"] = "UNBI"
obs$type[obs$type == "DOLP"] = "UNDO"
obs$type[obs$type == "SEAL"] = "UNSE"
obs$type[obs$type == "GRST"] = "GRTU"
obs$type[obs$type == "LOST"] = "LOTU"
obs$type[obs$type == "LEST"] = "LETU"
obs$type[obs$type == "UIST" | obs$type == "UNTU"] = "TURT"
obs$type[obs$type == "WHAL"] = "UNWH"
obs$type[obs$type == "LOON"] = "UNLO"
obs$type[obs$type == "BALOON" | obs$type == "BALLOON"] = "BALN"
obs$type[obs$type == "UMTE"] = "UNMT" 
message("Fixed AOU codes")

# FIX PEOPLE
obs$obs[obs$obs == "tj"] = "mtj" 

# FIX TRAW counts
obs$count[obs$type == "BOTD" & obs$count == 0] = 1
message("Fixed TRAWL boat COUNT")


# ENDCNT/ BGNCNT ERRORS

# TRANSECT "341100" duplicate ENDCNT #
if (nrow(obs[obs$obs == "phl" & obs$transect == "341100" & obs$type == "ENDCNT",]) == 2) {
  obs = obs[-(which(obs$obs == "phl" & obs$transect == "341100" & obs$type == "ENDCNT")[2]),]
  message("deleted duplicate ENDCNT")
}

# TRANSECT "343600" duplicate BEGCNT #
if (nrow(obs[obs$obs == "jsw" & obs$transect == "343600" & obs$type == "BEGCNT",]) == 3) {
  obs = obs[-(which(obs$obs == "jsw" & obs$transect == "343600" & obs$type == "BEGCNT")[1]),]
  message("deleted duplicate BEGCNT")
}

# TRANSECT "375601" missing ENDCNT # 
add = obs[obs$obs == "sde" & obs$transect == "375601" & obs$type == "BEGCNT",]
tmp = obs[obs$obs == "mtl" & obs$transect == "375601" & obs$type == "ENDCNT",] # the other observers endcount for that transect for end lat,lon
add$type = "ENDCNT"
add$lat = tmp$lat
add$long = tmp$long
add$sec = tmp$sec
add$index = add$index + .01
add$dataChange = paste("; added row due to missing BEG/END point", sep = "")
obs = rbind(obs, add)
rm(add, tmp)

# TRANSECT "391601" missing ENDCNT # 
add = obs[obs$obs == "sde" & obs$transect == "391601" & obs$type == "BEGCNT",]
tmp = obs[obs$obs == "mtl" & obs$transect == "391601" & obs$type == "ENDCNT",] # the other observers endcount for that transect for end lat,lon
add$type = "ENDCNT"
add$lat = tmp$lat
add$long = tmp$long
add$sec = tmp$sec
add$index = add$index + .01
add$dataChange = paste("; added row due to missing BEG/END point", sep = "")
obs = rbind(obs, add)
rm(add, tmp)

# TRANSECT "395600" duplicate ENDCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "395600" & obs$type == "ENDCNT",]) == 2) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "395600" & obs$type == "ENDCNT")[2]),]
  message("deleted duplicate ENDCNT")
}

# TRANSECT "410101" duplicate ENDCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "410101" & obs$type == "ENDCNT",]) == 3) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "410101" & obs$type == "ENDCNT")[3]),]
  message("deleted duplicate ENDCNT")
}

# TRANSECT "412101" duplicate ENDCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "412101" & obs$type == "ENDCNT",]) == 3) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "412101" & obs$type == "ENDCNT")[3]),]
  message("deleted duplicate ENDCNT")
}

# TRANSECT "413602" duplicate ENDCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "413602" & obs$type == "ENDCNT",]) == 2) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "413602" & obs$type == "ENDCNT")[2]),]
  message("deleted duplicate ENDCNT")
}

# TRANSECT "434600"  duplicate ENDCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "434600" & obs$type == "ENDCNT",]) == 10) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "434600" & obs$type == "ENDCNT")[10]),]
  message("deleted duplicate ENDCNT")
}

# TRANSECT "435100" duplicate ENDCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "435100" & obs$type == "ENDCNT",]) == 3) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "435100" & obs$type == "ENDCNT")[3]),]
  message("deleted duplicate ENDCNT")
}

# TRANSECT "440600" duplicate BEGCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "440600" & obs$type == "BEGCNT",]) == 11) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "440600" & obs$type == "BEGCNT")[10]),]
  message("deleted duplicate BEGCNT")
}

# TRANSECT "441600" duplicate ENDCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "441600" & obs$type == "ENDCNT",]) == 11) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "441600" & obs$type == "ENDCNT")[9]),]
  message("deleted duplicate ENDCNT")
}

# TRANSECT "442601" duplicate ENDCNT #
if (nrow(obs[obs$obs == "mtl" & obs$transect == "442601" & obs$type == "ENDCNT",]) == 7) {
  obs = obs[-(which(obs$obs == "mtl" & obs$transect == "442601" & obs$type == "ENDCNT")[7]),]
  message("deleted duplicate ENDCNT")
}

