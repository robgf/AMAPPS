# ---------------------------------------------------------------------------- #
# fixSeconds.R
# Date Created: 2012-07-12
# Author: JBL
#
# Description: This program checks the observation files for points with 
# missing seconds and interpolates new SEC values based on the observer's 
# track file.
# ---------------------------------------------------------------------------- #

fixSeconds <- function(obsds, trackds) {
  
  #LoadPackage("geosphere")
  
  # IF MISSING SECONDS VALUE, INTERPOLATE USING TRACK FILE
  tmp <- (is.na(obsds$sec) | obsds$sec == 0)
  if (sum(tmp) > 0) {
    sec.fix <- obsds[tmp, ]
    for (i in 1:sum(tmp)) {      
      if (nrow(trackds) == 0) {
        message("Missing track file and manual seconds fix required: ", basename(sec.fix$file[i]))
      }
      trackds$dist <- distVincentyEllipsoid(p1 = cbind(trackds$long, trackds$lat), 
                                            p2 = c(sec.fix$long[i], sec.fix$lat[i]))
      trackds <- trackds[order(trackds$dist), ]
      trackds$flag <- numeric(nrow(trackds))
      trackds$flag[1:5] <- c(2, rep(1, 4))
      trackds$use <- numeric(nrow(trackds))
      trackds$use[1:2] <- 1
      min.index <- min(trackds$index[trackds$flag %in% 1:2])
      max.index <- max(trackds$index[trackds$flag %in% 1:2])
      fix.i <- subset(trackds, index >= min.index & index <= max.index)
      fix.i <- fix.i[order(fix.i$index), ]
      
      if (nrow(fix.i) > 5 | max(fix.i$dist[fix.i$use == 1]) > 1000) {
        message("Manual seconds fix required: ", basename(sec.fix$file[i]))
      }
      
      dist <- distVincentyEllipsoid(p1 = c(fix.i$long[fix.i$use == 1][1], 
                                           fix.i$lat[fix.i$use == 1][1]), 
                                    p2 = c(fix.i$long[fix.i$use == 1][2], 
                                           fix.i$lat[fix.i$use == 1][2]))
      s <- dist / (abs(fix.i$sec[fix.i$use == 1][1] - fix.i$sec[fix.i$use == 1][2]))
      
      if (fix.i$index[fix.i$flag == 2] == min.index) {
        newsec <- fix.i$sec[fix.i$flag == 2] - (fix.i$dist[fix.i$flag == 2] / s) 
      } else if (fix.i$index[fix.i$flag == 2] == max.index) {
        newsec <- fix.i$sec[fix.i$flag == 2] + (fix.i$dist[fix.i$flag == 2] / s)
      } else if (!(fix.i$index[fix.i$flag == 2] %in% c(min.index, max.index))) {
        newsec <- fix.i$sec[fix.i$use == 1][1] + (fix.i$dist[fix.i$use == 1][1] / s)
      }
      
      obsds$dataChange[tmp][i] <- paste(obsds$dataChange[tmp][i], "; changed SEC from ", 
                                        sec.fix$sec[i], sep = "")
      obsds$sec[tmp][i] <- newsec
    }
    
  }
  
  return(obsds)
  
}
