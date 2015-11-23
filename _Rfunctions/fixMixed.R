fixMixed <- function(data) {
  a = which(data$type == "MIXD")
  if (length(a) > 0) {
        
    a = which(data$type == "MIXD")
    a = a[1]
    add = data[a,] # copy the information from the row with the Mixed observation
    b = strsplit(add$comment,";")
    for (c in 1:length(unlist(b))) {
      d = strsplit(paste(b[[1]][c], sep=""),"% ")
      add$type = d[[1]][2]
      add$count = sub("^\\s+", "", d[[1]][1])  # trim space before number
      add$dataChange = paste(add$dataChange, "; multiple species: added row based on OBS.COMMENT")
      data = rbind(data, add)
    }            
    data = data[-a,] # delete the row with 'MIXD' which is why we redine 'a' each time
    message("MIXED row separated and the original row was deleted")
    rm(a, b, c, d, add)
  }
  return(data)
}
