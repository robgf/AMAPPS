# ------------------------------------------------------------------------- #
# ObsFilesFix_2014.R
# Date Created: 2014-02-10
# Author: Jeff B. Leriness
# edited by Kaycee Coleman, May 2015
#
# Reasons to fix obs:
# 1) Fix incorrect type codings
# 2) Flag usless observations for removal or indexing
# 3) Fix condition change errors
# 4) Break mixed flock observations
# ------------------------------------------------------------------------- #

# --------------------------------------------- #
# FIX INCORRECT CODINGS             
# --------------------------------------------- #

# ------------------------------- #
# correct types
# ------------------------------- #
old = NA
old = obs$type
obs$type = ifelse(obs$type == "RAYS", "UNRA", obs$type)
obs$type = ifelse(obs$type == "SHRK", "SHAR", obs$type) # error idenitified in WAV file FAL14114 need audio fine to verify
obs$type = ifelse(obs$type == "14", "2014", obs$type)
obs$type = ifelse(obs$type == "HHSH", "HASH", obs$type)
obs$type = ifelse(obs$type == "RIST", "KRST", obs$type)
obs$type = ifelse(obs$type == "BAEG", "BAEA", obs$type) #  FAL14057 sde Crew4126lf_101714_birds.asc
obs$type = ifelse(obs$type == "SALMONPENS", "SPEN", obs$type)
obs$type = ifelse(obs$type == "PORP", "UNPO", obs$type) # SEB14002,3, 6, 20; sfy Crew4446 unid. porpoise
obs$type = ifelse(obs$type == "DWSC", "UNSC", obs$type) # SEB14001 sfy  Crew4446 scoters
obs$type = ifelse(obs$type == "SCOT", "UNSC", obs$type) # SEB14008, 11, 15, 13; mdk, sfy;  Crew4446
obs$type = ifelse(obs$type == "EIDE", "BIRD", obs$type) # SEB14005 sfy Crew4446 unidentified birds
obs$type = ifelse(obs$type == "MERG", "COME", obs$type) # SEB14006,7,8; mdk,sfy; Crew4446
obs$type = ifelse(obs$type == "ALCD", "UNAL", obs$type)
obs$type = ifelse(obs$type == "BALOON", "BALN", obs$type) 
obs$type = ifelse(obs$type == "BBGU", "UBBG", obs$type)
obs$type = ifelse(obs$type == "BIRD", "UNBI", obs$type) 
obs$type = ifelse(obs$type == "DOLP", "UNDO", obs$type) 
obs$type = ifelse(obs$type == "GRST", "GRTU", obs$type) 
obs$type = ifelse(obs$type == "GULL", "UNGU", obs$type) 
obs$type = ifelse(obs$type == "LEST", "LETU", obs$type) 
obs$type = ifelse(obs$type == "LOON", "UNLO", obs$type)
obs$type = ifelse(obs$type == "LOST", "LOTU", obs$type) 
obs$type = ifelse(obs$type == "SEAL", "UNSE", obs$type)
obs$type = ifelse(obs$type == "SMTE", "UNST", obs$type) #CHECK
obs$type = ifelse(obs$type == "UIST", "TURT", obs$type) #CHECK
obs$type = ifelse(obs$type == "UNTU", "TURT", obs$type) #CHECK
obs$type = ifelse(obs$type == "WHAL", "UNWH", obs$type) 
obs$type = ifelse(obs$type == "HEGU", "HERG", obs$type) 
obs$type = ifelse(obs$type == "BALLOON", "BALN", obs$type) 
obs$type = ifelse(obs$type == "UNMG", "UNGU", obs$type) 


tmp = obs$type != old
obs$dataChange[tmp] = paste(obs$dataChange[tmp], "; changed TYPE from ", old[tmp], sep = "")
rm(tmp, old)

# This was a test from Jim W, there are no mermaids!! 
obs = obs[-(which(obs$type == "MERMAD")),]
message("deleted fictitious mermaids")

# incorrect coding, correct coding verified by Wav File SEB14003
obs$dataChange[obs$type == "COCH" & obs$transect == "442602" & obs$sec == "41987.36" & obs$obs == "sfy"] = 
  paste(obs$dataChange[obs$type == "COCH" & obs$transect == "442602" & obs$sec == "41987.36" & obs$obs == "sfy"],
        "; changed TYPE from COCH")
obs$type[obs$type == "COCH" & obs$transect == "442602" & obs$sec == "41987.36" & obs$obs == "sfy"]= "TRAW" 
# ------------------------------- #



# ------------------------------- #
# correct seats
# ------------------------------- #
# seat variable copied from ObsFilesErrorChecks.R, this is the seat in the text file name
seat <- substr(matrix(unlist(strsplit(basename(obs$file), "_")), nrow = nrow(obs), byrow = TRUE)[, 1], 
               nchar(matrix(unlist(strsplit(basename(obs$file), "_")), nrow = nrow(obs), byrow = TRUE)[, 1]) - 1, 
               nchar(matrix(unlist(strsplit(basename(obs$file), "_")), nrow = nrow(obs), byrow = TRUE)[, 1]))

# incorrect seat coding as ff
tmp = obs$seat == "ff" & obs$obs == "sfy" # Sarah Yates, transcription error
old = obs$seat[tmp]
obs$seat[tmp] = seat[tmp]
obs$dataChange[tmp] = paste(obs$dataChange[tmp], "; changed TYPE from ", old, sep = "")

# incorrect seat coding as lf when text file says rf
tmp = obs$seat == "lf" & seat == "rf" # Sarah Yates, transcription error
old = obs$seat[tmp]
obs$seat[tmp] = seat[tmp]
obs$dataChange[tmp] = paste(obs$dataChange[tmp], "; changed TYPE from ", old, sep = "")

rm(seat)
# ------------------------------- #


# ------------------------------- #
# correct transects
# ------------------------------- #
# missing transects for all of Crew4126
# they are in the count column
obs$dataChange[obs$crew == "Crew4126" & is.na(obs$transect)] = 
  paste(obs$dataChange[obs$crew == "Crew4126" & is.na(obs$transect)], "; changed TRANSECT from NA")
obs$transect[obs$crew == "Crew4126" & obs$type == "BEGCNT"] = obs$count[obs$crew == "Crew4126" & obs$type == "BEGCNT"]
obs$transect[obs$crew == "Crew4126" & obs$type == "ENDCNT"] = obs$count[obs$crew == "Crew4126" & obs$type == "ENDCNT"]
obs$transect[obs$crew == "Crew4126" & obs$offline == "0"] = na.locf(obs$transect[obs$crew == "Crew4126" & obs$offline == "0"])
# need to verify that these are correct transects for those gps points, visually looks good though
# ------------------------------- #


# -------------------------------------- #
# Check for unecessary BEG/END or     
# add row based on crew member's data 
# -------------------------------------- #
obs$index=as.numeric(obs$index)
# TRANSECT "412602" added missing ENDCNT #
if (length(which(obs$obs == "sfy" & obs$transect == "412602" & obs$type == "ENDCNT")) == 0) {
  add = obs[obs$obs == "sfy" & obs$transect == "412602" & obs$type == "BEGCNT",]
  tmp = obs[obs$obs == "mdk" & obs$transect == "412602" & obs$type == "ENDCNT",] # the other observers endcount for that transect for end lat,lon
  add$type = "ENDCNT"
  add$lat = tmp$lat
  add$long = tmp$long
  add$sec = tmp$sec
  add$index = add$index + 9.01
  add$dataChange = paste("; added row due to missing BEG/END point", sep = "")
  obs = rbind(obs, add)
  rm(add, tmp)
  print("added row due to missing BEG/END point")
}

# TRANSECT "414101" deleted duplicate ENDCNT #
if (nrow(obs[obs$obs == "sfy" & obs$transect == "414101" & obs$type == "ENDCNT",]) == 2) {
  obs = obs[-(which(obs$obs == "sfy" & obs$transect == "414101" & obs$type == "ENDCNT")[2]),]
  print("deleted duplicate ENDCNT")
}

# TRANSECT "442101" & TRANSECT "442102" -> changed typo
obs$dataChange[obs$obs == "sfy" & obs$transect == "442102" & obs$count == "442101"] = 
    paste(obs$dataChange[obs$obs == "sfy" & obs$transect == "442102" & obs$count == "442101"], 
    "; changed COUNT from 442101 to 4421202", sep = "")
obs$count[obs$obs == "sfy" & obs$transect == "442102" & obs$count == "442101"] = "442102"
print("changed TRANSECT typo")

# TRANSECT "444100" added missing ENDCNT #
if (length(which(obs$obs == "sfy" & obs$transect == "444100" & obs$type == "ENDCNT")) < 4) {
  add = obs[obs$obs == "sfy" & obs$transect == "444100" & obs$type == "BEGCNT",][4,]
  tmp = obs[obs$obs == "mdk" & obs$transect == "444100" & obs$type == "ENDCNT",][2,] # the other observers endcount for that transect for end lat,lon
  add$type = "ENDCNT"
  add$lat = tmp$lat
  add$long = tmp$long
  add$sec = tmp$sec
  add$index = add$index + 9.01
  add$dataChange = paste("; added row due to missing BEG/END point", sep = "")
  obs = rbind(obs, add)
  rm(add, tmp)
  print("added row due to missing BEG/END point")
}

# TRANSECT "444600"
if (nrow(obs[obs$obs == "sfy" & obs$transect == "444600" & obs$type == "ENDCNT",]) == 3) {
  obs = obs[-(which(obs$obs == "sfy" & obs$transect == "444600" & obs$type == "ENDCNT")[2]),]
  print("deleted duplicate ENDCNT")
}

# TRANSECT "441600" change BEGCNT to ENDCNT
if (nrow(obs[obs$obs == "mdk" & obs$transect == "441600" & obs$type == "BEGCNT",]) == 8) {
  obs$type[obs$obs == "mdk" & obs$transect == "441600" & obs$type == "BEGCNT" & obs$sec == 53554.80] = "ENDCNT"
  obs$dataChange[obs$obs == "mdk" & obs$transect == "441600" & obs$type == "ENDCNT" & obs$sec == 53554.80] = 
      paste(obs$dataChange[obs$obs == "mdk" & obs$transect == "441600" & obs$type == "ENDCNT" & obs$sec == 53554.80],
      "; changed TYPE from BEGCNT to ENDCNT", sep = "")
  print("changed BEGCNT to ENDCNT")
}

# TRANSECT "371101" & "371102" changed begcount transect typo
obs$dataChange[obs$obs=="mtj" & obs$transect=="371102"] = paste(obs$dataChange[obs$obs=="mtj" & obs$transect=="371102"],
                                                                "; Changed COUNT from 371101; Changed TRANSECT from 371101",
                                                                sep="")
obs$count[obs$obs=="mtj" & obs$transect=="371102"] = "371101"
obs$transect[obs$obs=="mtj" & obs$transect=="371102"] = "371101"
print("changed BEGCNT 371102 TRANSECT")

# TRANSECT "385600" change begcount transect typo
obs$dataChange[obs$obs=="mtj" & obs$transect=="385600" & obs$sec == 35846.76 & obs$type == "BEGCNT"] = 
  paste(obs$dataChange[obs$obs=="mtj" & obs$transect=="385600" & obs$sec == 35846.76 & obs$type == "BEGCNT"],
  "; Changed TRANSECT from 385600",
  sep="")
obs$transect[obs$obs=="mtj" & obs$transect=="385600" & obs$sec == 35846.76 & obs$type == "BEGCNT"] = "384600"
print("changed BEGCNT 385600 TRANSECT")

# TRANSECT "392600" removed endcount
obs = obs[-which(obs$obs=="mtj" & obs$transect=="392600" & obs$sec == 39519.04 & obs$type == "ENDCNT"),] 
print("deleted ENDCNT")

# check BEG and ENDs
obs$type=as.vector(obs$type)
obs %>% filter(type %in% c("BEGCNT","ENDCNT")) %>% select(index, transect, seat) %>% 
  group_by(seat, transect) %>% summarise(num = n()) %>% filter((num %% 2) != 0)

# change transect 0 
obs$transect[obs$transect==0]=NA
