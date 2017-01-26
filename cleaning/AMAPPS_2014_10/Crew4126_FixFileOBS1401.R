# pull apart one large file into seperate days 
# 
folderName = "Crew4126_Earsom" 
fileName = "OBS1401.asc"
data <- read.csv(paste(dir.in, folderName, fileName, sep = "/"), header = FALSE, 
                 colClasses = "character")


# break into seperate tables by day
days = unique(data$V3)
for (a in 1:length(days)) {
  df = data[data$V3 == days[a],]
  day = days[a]; 
  if (nchar(day) == 1) {day = paste("0", day, sep = "")}
  date = paste("10",day,"2014", sep = "")
  # export out into dir.in
  write.table(df, paste(paste(dir.in, folderName, paste("Crew4126rf", date, "birds", sep = "_"), sep = "/"), "csv", sep = "."), 
              row.names = F, col.names = F, sep = ",")
}
rm(a, df, date, days, day, fileName, data)


fileName = "OBS1402.asc"
data <- read.csv(paste(dir.in, folderName, fileName, sep = "/"), header = FALSE, 
                 colClasses = "character")


# break into seperate tables by day
days = unique(data$V3)
for (a in 1:length(days)) {
  df = data[data$V3 == days[a],]
  day = days[a]; 
  if (nchar(day) == 1) {day = paste("0", day, sep = "")}
  date = paste("10",day,"2014", sep = "")
  # export out into dir.in
  write.table(df, paste(paste(dir.in, folderName, paste("Crew4126rf", date, "birds", sep = "_"), sep = "/"), "csv", sep = "."), 
              row.names = F, col.names = F, sep = ",")
}
rm(a, df, date, days, day, folderName, fileName, data)

