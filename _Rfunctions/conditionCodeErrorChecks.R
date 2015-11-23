# ------------------------------------------------------------------------- #
# This program checks the observation files for condition change coding 
# errors.
#
# Program Name: ConditionCodeErrorChecks.R
# Date Created: 11/04/2011
# Author: JBL
# modified: Nov. 2015, Kaycee Coleman
# ------------------------------------------------------------------------- #

conditionCodeErrorChecks = function(data, survlab = "") {
  
  outdata = deparse(substitute(data))
  
  data$flag = 1
  data$flag[data$type == "COCH"] = 0
  data$flag[data$type == "COCH" & data$condition == "0"] = 3
  data = data[order(data$crew, data$seat, data$obs, data$year, data$month, data$day, data$sec, 
                    data$index, data$flag), ]
  data$flag = NULL
  
  # IF CONDITION CODE CHANGES, TYPE SHOULD EQUAL COCH #
  # IF TYPE EQUALS COCH, CONDITION CODE SHOULD CHANGE #
  data$key = paste(data$crew, data$transect, data$year, data$month, data$day, data$seat, sep = "-")
  
  allkeys = sort(unique(data$key))
  data$data_error = ""
  for (i in seq(along = allkeys)) {
    tmp = data$key == allkeys[i] & data$keep == 1
    if (sum(tmp) > 1) {
      bsec = data$sec[tmp][data$type[tmp] %in% c("BEGSEG", "BEGCNT")]
      esec = data$sec[tmp][data$type[tmp] %in% c("ENDSEG", "ENDCNT")]
      for (j in seq(along = esec)) {
        tmp.j = tmp & data$sec >= bsec[j] & data$sec <= esec[j]
        for (k in 2:sum(tmp.j)) {
          if (data$condition[tmp.j][k] != data$condition[tmp.j][k - 1] & 
                data$type[tmp.j][k] != "COCH")
            data$data_error[tmp.j][k] = paste(data$data_error[tmp.j][k], 
                                              "; CONDITION change, but TYPE != COCH", sep = "")
          if (data$type[tmp.j][k] == "COCH" & 
                data$condition[tmp.j][k] == data$condition[tmp.j][k - 1])
            data$data_error[tmp.j][k] = paste(data$data_error[tmp.j][k], 
                                              "; TYPE == COCH, but no change in CONDITION", 
                                              sep = "")
          if (data$type[tmp.j][k] == "COCH" & 
                data$count[tmp.j][k] != data$condition[tmp.j][k])
            data$data_error[tmp.j][k] = paste(data$data_error[tmp.j][k], 
                                              "; CONDITION != COUNT", sep = "")
        }
      }
    }
  }
  tmp = grepl("COCH", data$data_error)
  cat("Found", sum(tmp), "inconsistencies between CONDITION and TYPE = 'COCH'.\n\n")
  
  data$dataChange = ifelse(substr(data$dataChange, 1, 1) == " ", 
                            substr(data$dataChange, 2, nchar(data$dataChange)), 
                            data$dataChange)
  data$dataChange = ifelse(substr(data$dataChange, 1, 2) == "; ", 
                            substr(data$dataChange, 3, nchar(data$dataChange)), 
                            data$dataChange)
  data$dataError = ifelse(substr(data$dataError, 1, 2) == "; ", 
                           substr(data$dataError, 3, nchar(data$dataError)), data$dataError)
  data$dataError = gsub(" ; ", "; ", data$dataError)
  
  tmp = data$dataError != "" & data$keep == 1
  if (sum(tmp) > 0) {
    error = data[tmp, ]
    write.csv(error, file.path(dir.out, paste(survlab, "ConditionCodeErrors.csv", sep = "_")), 
              row.names = FALSE)
  } else if (file.exists(file.path(dir.out, paste(survlab, "ConditionCodeErrors.csv", sep = "_")))) 
    unlink(file.path(path, paste(survlab, "ConditionCodeErrors.csv", sep = "_")))
  
  assign(outdata, data, envir = .GlobalEnv)
  
}
