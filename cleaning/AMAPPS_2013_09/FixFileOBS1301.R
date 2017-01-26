# pull apart one large file into seperate days 
# 
folderName = "Crew3316_Roetker"
fileName = "OBS1301.asc"
data <- read.csv(paste(dir.in, folderName, fileName, sep = "/"), header = FALSE, 
                   colClasses = "character")

# fix date to split properly 
data$V2 = "9"

# fix transect
data$V6[as.numeric(data$V15)>10000] = data$V15[as.numeric(data$V15)>10000]
# fill in transects where offline != y | Y
require(zoo)
data$V8 = toupper(data$V8)
data$V6[data$V6 == "null"] = NA
data$V6[data$V8 != "Y"] = na.locf(data$V6[data$V8 != "Y"])

# break into seperate tables by day
days = unique(data$V3)
for (a in 1:length(days)) {
  df = data[data$V3 == days[a],]
  date = paste("09",days[a],"2013", sep = "")
  # export out into dir.in
  write.table(df, paste(paste(dir.in, folderName, paste("Crew3316rf", date, "birds", sep = "_"), sep = "/"), "csv", sep = "."), 
            row.names = F, col.names = F, sep = ",")
}
rm(a, df, date, days, folderName, fileName, data)

