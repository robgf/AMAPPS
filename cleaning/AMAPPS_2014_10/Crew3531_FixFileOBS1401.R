# pull apart one large file into seperate days 
# 
folderName = "Crew3521_Wortham"
fileName = "OBS1401.asc"
data <- read.csv(paste(dir.in, folderName, fileName, sep = "/"), header = FALSE, 
                 colClasses = "character")

# fix initials
data$V4[data$V4 == "fr"] = "fhr"

# fix transect
data$V6[as.numeric(data$V15)>10000] = data$V15[as.numeric(data$V15)>10000]
# fill in transects where offline != y | Y
require(zoo)
data$V8 = toupper(data$V8)
data$V6[data$V6 == "null"] = NA
data$V6[data$V8 != "Y"] = na.locf(data$V6[data$V8 != "Y"])

# fix days based on pilot's files
## CHECK IN AUDIO
data$V3[data$V3 == "1"] = "8"

# fix where Tim took over on 10-22, and split 10-22 file into 10-21 and 10-21
data$V5[data$V3 == "22"] = "mtj"
# 21 -> "322100" "321600" "321100" "320600" "320100" "315600" "315100" "314600" "314100"
# 22 -> "313600" "313100" "312600" "312100" "311600" "311100" "310600" "310100"
data$V3[data$V5 == "mtj" & data$V6 >= "314100"] = "21"

# break into seperate tables by day
days = unique(data$V3)
for (a in 1:length(days)) {
  df = data[data$V3 == days[a],]
  day = days[a]; 
  if (nchar(day) == 1) {day = paste("0", day, sep = "")}
  date = paste("10",day,"2014", sep = "")
  # export out into dir.in
  write.table(df, paste(paste(dir.in, folderName, paste("Crew3521rf", date, "birds", sep = "_"), sep = "/"), "csv", sep = "."), 
              row.names = F, col.names = F, sep = ",")
}
rm(a, df, date, days, day, folderName, fileName, data)


## Fix Order of other files 
obsfiles <- list.files(dir.in, pattern = "f_10", recursive = TRUE, full.names = TRUE) #changed from "_birds.txt"
#not in sequential order 10-09-2014
if (!"Crw3521lf_10092014_brdsRaw.asc" %in% basename(obsfiles)) {
  data = read.table(paste(dir.in, "Crew3521_Wortham/Crew3521lf_10092014_birds.asc", sep = "/"), sep = ",")
  write.table(data, paste(dir.in, "Crew3521_Wortham/Crw3521lf_10092014_brdsRaw.asc", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
  data = data[order(data[,12]),]
  write.table(data, paste(dir.in, "Crew3521_Wortham/Crew3521lf_10092014_birds.asc", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
} 

# not in sequential order 10-21-2014
if (!"Crw3521rf_10212014_brdsRaw.csv" %in% basename(obsfiles)) {
  data = read.table(paste(dir.in, "Crew3521_Wortham/Crew3521rf_10212014_birds.csv", sep = "/"), sep = ",")
  write.table(data, paste(dir.in, "Crew3521_Wortham/Crw3521rf_10212014_brdsRaw.csv", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
  data = data[order(data[,12]),]
  write.table(data, paste(dir.in, "Crew3521_Wortham/Crew3521rf_10212014_birds.csv", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
}

# cut 10-13 data out of 10-12 its duplicated in the 10-13 file
if (!"Crw4126lf_101214_brdsRaw.asc" %in% basename(obsfiles)) {
  data = read.table(paste(dir.in, "Crew4126_Earsom/Crew4126lf_101214_birds.asc", sep = "/"), sep = ",")
  write.table(data, paste(dir.in, "Crew4126_Earsom/Crw4126lf_101214_brdsRaw.asc", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
  data = data[-which(data$V3 == "13"),]
  write.table(data, paste(dir.in, "Crew4126_Earsom/Crew4126lf_101214_birds.asc", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
}

# cut 10-18 data out of 10-17, add to 10-18 file
if (!"Crw4126lf_101714_brdsRaw.asc" %in% basename(obsfiles)) {
  data = read.table(paste(dir.in, "Crew4126_Earsom/Crew4126lf_101714_birds.asc", sep = "/"), sep = ",")
  data2 = read.table(paste(dir.in, "Crew4126_Earsom/Crew4126lf_101814_birds.asc", sep = "/"), sep = ",")
  write.table(data, paste(dir.in, "Crew4126_Earsom/Crw4126lf_101714_brdsRaw.asc", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
  write.table(data2, paste(dir.in, "Crew4126_Earsom/Crw4126lf_101814_brdsRaw.asc", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
  insert = data[which(data$V3 == "18"),]
  data = data[-which(data$V3 == "18"),]
  data2 = rbind(insert, data2)
  write.table(data, paste(dir.in, "Crew4126_Earsom/Crew4126lf_101714_birds.asc", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
  write.table(data2, paste(dir.in, "Crew4126_Earsom/Crew4126lf_101814_birds.asc", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
}

# change 10-0 to 10-6
if (!"Crw4446rf_10062014_brdsRaw.txt" %in% basename(obsfiles)) {
  data = read.csv(paste(dir.in, "Crew4446_Koneff/Crew4446rf_10062014_birds.txt", sep = "/"), header = FALSE, 
                colClasses = "character")
  write.table(data, paste(dir.in, "Crew4446_Koneff/Crw4446rf_10062014_brdsRaw.txt", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
  data$V3 = "6"
  write.table(data, paste(dir.in, "Crew4446_Koneff/Crew4446rf_10062014_birds.txt", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
}

# not in sequential order, due to duplicate rows
if (!"Crw4446rf_10102014_brdsRaw.txt" %in% basename(obsfiles)) {
  data = read.csv(paste(dir.in, "Crew4446_Koneff/Crew4446rf_10102014_birds.txt", sep = "/"), header = FALSE, 
                colClasses = "character")
  write.table(data, paste(dir.in, "Crew4446_Koneff/Crw4446rf_10102014_brdsRaw.txt", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
  data$V14[data$V14 == "BEGSEG"] = "BEGCNT" #fix to remove duplicate
  data = data[!duplicated(data),]
  write.table(data, paste(dir.in, "Crew4446_Koneff/Crew4446rf_10102014_birds.txt", sep = "/"), 
            row.names = F, col.names = F, sep = ",")
}

# Fix Track files
# split 10-14 into 10-14 and 10-16 track file
tfiles <- list.files(paste(dir.in, "Crew4126_Earsom/TrackFiles", sep="/"), recursive = TRUE, full.names = TRUE) #changed from "_birds.txt"
if (!"Crw4126lf_10142014_trckRaw.txt" %in% basename(tfiles)) {
  data = read.csv(paste(dir.in, "Crew4126_Earsom/TrackFiles/Crew4126lf_101414_track.txt", sep = "/"), header = FALSE, 
                  colClasses = "character")
  write.table(data, paste(dir.in, "Crew4126_Earsom/TrackFiles/Crw4126lf_10142014_trckRaw.txt", sep = "/"), 
              row.names = F, col.names = F, sep = ",")
  data2 = data[(which(diff(as.numeric(data$V3)) < 0) + 1):length(data$V3),]
  data = data[1:which(diff(as.numeric(data$V3)) < 0),]
  write.table(data, paste(dir.in, "Crew4126_Earsom/TrackFiles/Crew4126lf_101414_track.txt", sep = "/"), 
              row.names = F, col.names = F, sep = ",")
  write.table(data2, paste(dir.in, "Crew4126_Earsom/TrackFiles/Crew4126lf_10162014_track.txt", sep = "/"), 
              row.names = F, col.names = F, sep = ",")
  
}


rm(data, data2, insert)
