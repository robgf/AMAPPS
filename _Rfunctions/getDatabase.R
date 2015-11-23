# ---------------------------------------------------------------------------- #
# getDatabase.R
# Date Created: 2013-07-24
# Author: JBL
#
# Description: 
# ---------------------------------------------------------------------------- #

getDatabase <- function(db) {
  
  # CONNECT TO MS ACCESS DATABASE
  database <- odbcConnectAccess2007(file.path(dbpath, paste(db, ".accdb", sep = "")))
  
  # READ TABLES INTO R
  tables <- sqlTables(database)[, c("TABLE_NAME", "TABLE_TYPE")]
  idx <- tables$TABLE_TYPE == "TABLE" & !grepl("^~", tables$TABLE_NAME)
  tables <- as.character(tables[idx, "TABLE_NAME"])
  for (j in seq(along = tables)) {
    assign(paste("Database", tables[j], sep = "_"), 
           sqlFetch(database, tables[j], stringsAsFactors = FALSE), envir = .GlobalEnv)
  }
  
  # CLOSE MS ACCESS DATABASE CONNECTION
  odbcCloseAll()
  
}
