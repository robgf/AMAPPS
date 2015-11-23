# ------------------------------------------------------------------------- #
# addBegEnd_GISeditObsTrack.R
# Date Created: 2011-11-04
# Author: JBL
#
# Description: This program adds necessary 'BEGSEG', 'ENDSEG', 'BEGCNT', 
# 'ENDCNT' rows to the combined observation/track files after they are 
# edited in GIS. The output is an R data frame.
# ------------------------------------------------------------------------- #

addBegEnd_GISeditObsTrack = function(data) {
  
  data$type = gsub(" ", "", data$type)
  
  data$key = paste(data$crew, data$seat, data$year, data$month, data$day, substr(data$transLat,1,4), 
                   data$transLong, sep = "-")
  allkeys = unique(data$key)
  data = data[order(data$ID), ]
  for (i in seq(along = allkeys)) {
    tmp = data$key == allkeys[i]
    data.i = data[tmp, ]
    
    # ADD BEGCNT AT START
    if (data.i$type[1] != "BEGCNT") {
      if (nrow(data.i) == 1 & data.i$type[1] == "ENDCNT") {
        add = data.i
        add$lat = NA
        add$long = NA
        add$sec = NA
        add$type = "BEGCNT"
        add$ID = add$ID - .01
        add$dataChange = paste(add$dataChange, "; added row based on GIS track file edits", 
                                sep = "")
        data = rbind(data, add)
        data = data[order(data$ID), ]
        tmp = data$key == allkeys[i]
        data.i = data[tmp, ]
      } else {
        add = data.i[1, ]
        add$type = "BEGCNT"
        add$ID = add$ID - .01
        add$dataChange = paste(add$dataChange, "; added row based on GIS track file edits", 
                                sep = "")
        data = rbind(data, add)
        data = data[order(data$ID), ]
        tmp = data$key == allkeys[i]
        data.i = data[tmp, ]
      }
    }
    data[tmp, ] = data.i
    
    # ADD ENDCNT AT END
    if (data.i$type[nrow(data.i)] != "ENDCNT") {
      if (nrow(data.i) == 1 & data.i$type[1] == "BEGCNT") {
        add = data.i
        add$lat = NA
        add$long = NA
        add$sec = NA
        add$type = "ENDCNT"
        add$ID = add$ID + .01
        add$dataChange = paste(add$dataChange, "; added row based on GIS track file edits", 
                                sep = "")
        data = rbind(data, add)
        data = data[order(data$ID), ]
        tmp = data$key == allkeys[i]
        data.i = data[tmp, ]
      } else {
        add = data.i[nrow(data.i), ]
        add$type = "ENDCNT"
        add$ID = add$ID + .01
        add$dataChange = paste(add$dataChange, "; added row based on GIS track file edits", 
                                sep = "")
        data = rbind(data, add)
        data = data[order(data$ID), ]
        tmp = data$key == allkeys[i]
        data.i = data[tmp, ]
      }
    }
    data[tmp, ] = data.i
    
    for (j in 2:nrow(data.i)) {
      if (data.i$ID[j] - data.i$ID[j-1] > 1) {
        # ADD ENDCNT
        if (data.i$type[j-1] != "ENDCNT") {
          add = data.i[j-1, ]
          add$type = "ENDCNT"
          add$ID = add$ID + .01
          add$dataChange = paste(add$dataChange, 
                                  "; added row based on GIS track file edits", sep = "")
          data = rbind(data, add)
        }
        # ADD BEGCNT
        if (data.i$type[j] != "BEGCNT") {
          add = data.i[j, ]
          add$type = "BEGCNT"
          add$ID = add$ID - .01
          add$dataChange = paste(add$dataChange, 
                                  "; added row based on GIS track file edits", sep = "")
          data = rbind(data, add)
        }
      }
    }
    data = data[order(data$ID), ]
    tmp = data$key == allkeys[i]
    data.i = data[tmp, ]
    
    if (nrow(data.i) > 2) {
      for (j in 2:(nrow(data.i)-1)) {
        if (data.i$type[j] == "BEGCNT" & data.i$type[j-1] != "ENDCNT") {
          add = data.i[j-1, ]
          add$type = "ENDCNT"
          add$ID = add$ID + .01
          add$dataChange = paste(add$dataChange, 
                                  "; added row based on GIS track file edits", sep = "")
          data = rbind(data, add)
        }
        if (data.i$type[j] == "ENDCNT" & data.i$type[j+1] != "BEGCNT") {
          add = data.i[j+1, ]
          add$type = "BEGCNT"
          add$ID = add$ID - .01
          add$dataChange = paste(add$dataChange, 
                                  "; added row based on GIS track file edits", sep = "")
          data = rbind(data, add)
        }
      }
    }
  }
  data = data[order(data$ID), ]
  
  # DELETE UNNESSARY BEG/END POINTS
  allkeys = unique(data$key)
  for (i in seq(along = allkeys)) {
    tmp = data$key == allkeys[i]
    data.i = data[tmp, ]
    
    b = subset(data.i, type == "BEGCNT", select = c("lat", "long", "sec"))
    e = subset(data.i, type == "ENDCNT", select = c("lat", "long", "sec"))
    b = merge(b, e)
    b = b[!duplicated(b), ]
    b = b[order(b$sec), ]
    
    if (nrow(b) > 0) {
      for (j in seq(along = b$sec)) {
        b.j = b[j, ]
        b.j$delete = 1
        data.i = merge(data.i, b.j, all = TRUE)
        data.i = data.i[order(data.i$ID), ]
        tmp.del = !is.na(data.i$delete) & data.i$type %in% c("BEGCNT", "ENDCNT")
        if (sum(is.na(data.i$delete)) == 0) {
          data.i = NULL
          next
        }
        if (data.i$type[tmp.del][1] == "BEGCNT" & data.i$type[tmp.del][sum(tmp.del)] == "ENDCNT") {
          data.i = subset(data.i, is.na(delete))
        } else if (data.i$type[tmp.del][1] == "BEGCNT" & data.i$type[tmp.del][sum(tmp.del)] == "BEGCNT") {
          data.i = data.i[-which(tmp.del)[-1], ]
        } else if (data.i$type[tmp.del][1] == "ENDCNT" & data.i$type[tmp.del][sum(tmp.del)] == "BEGCNT") {
          data.i = data.i[-which(tmp.del), ]
        } else if (data.i$type[tmp.del][1] == "ENDCNT" & data.i$type[tmp.del][sum(tmp.del)] == "ENDCNT") {
          data.i = data.i[-which(tmp.del)[-sum(tmp.del)], ]
        }
        data.i$delete = NULL
      }
    }
    if (nrow(b) > 0) data = rbind(data.i, data[!tmp, ])
  }
  data = data[order(data$ID), ]
  
  # CHANGE BEGSEG/ENDSEG TO BEGCNT/ENDCNT WHEN NECESSARY (AND VICE VERSA)
  allkeys = unique(data$key)
  for (i in seq(along = allkeys)) {
    tmp.i = data$key == allkeys[i]
    data.i = data[tmp.i, ]
    
    # CHANGE ENDPOINT "CNT"s TO "SEG"s
    if (data.i$type[1] == "BEGCNT") {
      old = data.i$type[1]
      data.i$type[1] = "BEGSEG"
      data.i$dataChange[1] = paste(data.i$dataChange[1], "; changed TYPE from ", old, 
                                    sep = "")
    }
    if (data.i$type[nrow(data.i)] == "ENDCNT") {
      old = data.i$type[nrow(data.i)]
      data.i$type[nrow(data.i)] = "ENDSEG"
      data.i$dataChange[nrow(data.i)] = paste(data.i$dataChange[nrow(data.i)], 
                                               "; changed TYPE from ", old, sep = "")
    }
    
    # CHANGE INTERMEDIATE BEG/END "SEG"s TO "CNT"s
    tmp.data = grepl("SEG", data.i$type)
    tmp.data[c(1, length(tmp.data))] = FALSE
    if (sum(tmp.data) > 0) {
      old = data.i$type[tmp.data]
      data.i$type[tmp.data] = gsub("SEG", "CNT", data.i$type[tmp.data])
      data.i$dataChange[tmp.data] = paste(data.i$dataChange[tmp.data], 
                                           "; changed TYPE from ", old, sep = "")
    }
    data[tmp.i, ] = data.i
    
    if (sum(data$type[tmp.i] == "BEGSEG") < 1 | sum(data$type[tmp.i] == "ENDSEG") < 1 | 
          sum(data$type[tmp.i] == "BEGSEG") != sum(data$type[tmp.i] == "ENDSEG")) 
      cat("Error in BEGSEG/ENDSEG: ", allkeys[i], "\n")
    if (sum(data$type[tmp.i] == "BEGCNT") != sum(data$type[tmp.i] == "ENDCNT")) 
      cat("Error in BEGSEG/ENDSEG: ", allkeys[i], "\n")
  }
  
  # ADD GPS & SEC VALUES FOR ADDED ROWS WHERE MISSING #
  tmp = is.na(data$lat) & grepl("; added row based on GIS track file edits", data$dataChange)
  if (sum(tmp) > 0) {
    for (i in 1:sum(tmp)) {
      temp = data[data$transect == data$transect[tmp][i] & 
                    data$replicate == data$replicate[tmp][i] & 
                    data$day == data$day[tmp][i] & 
                    data$month == data$month[tmp][i] & 
                    data$type == data$type[tmp][i] & 
                    data$seat != data$seat[tmp][i], ]
      data$lat[tmp][i] = temp$lat
      data$long[tmp][i] = temp$long
      data$sec[tmp][i] = temp$sec
    }
  }
  data[order(data$ID), ]
  
}

