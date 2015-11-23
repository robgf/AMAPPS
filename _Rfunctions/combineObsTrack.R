# ---------------------------------------------------------------------------- #
# combineObsTrack.R
# Date Created: 2011-10-28
# Author: JBL
#
# Description: This program combines the observation files and track files, 
# while cutting the track files to segments actually surveyed. The output is 
# an R data frame named track.edit.
#
# This function references the following files and/or programs: 
#   M:/Sea Duck Survey/Jeff_Working_Folder/R functions/combineByName.R
# ---------------------------------------------------------------------------- #

combineObsTrack <- function(obsds, trackds, alt.trackds) {
  
  require(geosphere)
  
  # CUT TRACK FILES TO SEGMENTS ACTUALLY SURVEYED #
  beg <- subset(obsds, type == "BEGCNT", select = c(sec, index))
  end <- subset(obsds, type == "ENDCNT", select = c(sec, index))
  if (nrow(beg) != nrow(end)) stop("Error in BEG/END: ", unique(obsds$file))
  if (is.null(trackds) & is.null(alt.trackds)) message("No track file to use: ", unique(obsds$file))
  for (i in 1:nrow(beg)) {
    obs.i <- subset(obsds, index >= beg$index[i] & index <= end$index[i])
    if (is.null(trackds)) {
      track.i <- obs.i[0, ]
    } else {
      track.i <- subset(trackds, round(sec, 2) > round(beg$sec[i], 2) & 
                          round(sec, 2) < round(end$sec[i], 2))
    }
    trk.add <- ifelse(any(is.null(trackds), nrow(track.i) == 0 & beg$sec[i] != end$sec[i]), TRUE, FALSE)
    
    # -------------------------------------------------------------------- #
    # ADD TEMPORARY TRACKFILE POINTS TO OBSERVERS WITH MISSING TRACK FILES
    # -------------------------------------------------------------------- #
    if (trk.add) {
      sec.diff <- rep(NA, nrow(obs.i))
      track.i <- alt.trackds
      if (is.null(track.i)) {
        track.i <- obs.i[0, ]
      } else {
        for (j in 1:nrow(obs.i)) {
          track.i$dist <- distVincentyEllipsoid(p1 = cbind(track.i$long, track.i$lat), 
                                                p2 = c(obs.i$long[j], obs.i$lat[j]))
          track.i <- track.i[order(track.i$dist), ]
          track.i$flag <- 0
          track.i$flag[1:5] <- c(2, rep(1, 4))
          track.i$use <- 0
          track.i$use[1:2] <- 1
          min.index <- min(track.i$index[track.i$flag %in% 1:2])
          max.index <- max(track.i$index[track.i$flag %in% 1:2])
          fix.i <- subset(track.i, index >= min.index & index <= max.index)
          fix.i <- fix.i[order(fix.i$index), ]
          
          if (nrow(fix.i) > 5 | max(fix.i$dist[fix.i$use == 1]) > 1000) {
            track.i$dist <- NULL
            track.i$flag <- NULL
            track.i$use <- NULL
            next
          }
          
          dist <- distVincentyEllipsoid(p1 = c(fix.i$long[fix.i$use == 1][1], 
                                               fix.i$lat[fix.i$use == 1][1]), 
                                        p2 = c(fix.i$long[fix.i$use == 1][2], 
                                               fix.i$lat[fix.i$use == 1][2]))
          s <- dist / (abs(fix.i$sec[fix.i$use == 1][1] - fix.i$sec[fix.i$use == 1][2]))
          
          if (fix.i$index[fix.i$flag == 2] == min.index) 
            newsec <- fix.i$sec[fix.i$flag == 2] - (fix.i$dist[fix.i$flag == 2] / s)
          if (fix.i$index[fix.i$flag == 2] == max.index) 
            newsec <- fix.i$sec[fix.i$flag == 2] + (fix.i$dist[fix.i$flag == 2] / s)
          if (!(fix.i$index[fix.i$flag == 2] %in% c(min.index, max.index))) 
            newsec <- fix.i$sec[fix.i$use == 1][1] + (fix.i$dist[fix.i$use == 1][1] / s)
          
          sec.diff[j] <- newsec - obs.i$sec[j]
          track.i$dist <- NULL
          track.i$flag <- NULL
          track.i$use <- NULL
        }
        if (is.na(median(sec.diff, na.rm = TRUE))) {
          message("Missing track file and manual seconds fix required: ", unique(obsds$file))
          track.i <- track.i[0, ]
        } else {
          track.i$sec <- track.i$sec - median(sec.diff, na.rm = TRUE)
          track.i <- subset(track.i, round(sec, 2) > round(beg$sec[i], 2) & 
                              round(sec, 2) < round(end$sec[i], 2))
        }
      }
    }
    # -------------------------------------------------------------------- #
    
    out.i <- combineByName(track.i, obs.i)
    out.i$seat <- unique(obs.i$seat)
    out.i$obs <- unique(obs.i$obs)
    out.i$offline[is.na(out.i$offline)] <- 0
    out.i$GPSerror[is.na(out.i$GPSerror)] <- 0
    out.i$type[is.na(out.i$type)] <- "WAYPNT"
    out.i$band[is.na(out.i$band)] <- 0
    out.i$track <- ifelse(trk.add, 0, 1)
    if (trk.add) out.i$track[out.i$type == "WAYPNT"] <- 2
    out.i$begend <- 0
    out.i$begend[out.i$type == "BEGCNT"] <- -1
    out.i$begend[out.i$type == "ENDCNT"] <- 1
    out.i <- out.i[order(out.i$sec, out.i$begend, out.i$index), ]
    out.i$begend <- NULL
    
    # IF LAT, LONG MISSING (EQUAL TO 0), INTERPOLATE POSITION USING TRACK FILE POINTS
    tmp <- which(out.i$lat == 0 | out.i$long == 0)
    if (length(tmp) > 0) {
      for (j in 1:length(tmp)) {
        if (nrow(out.i) < 3) {
          message("Missing GPS value and manual fix required: ", unique(obsds$file))
          next
        }
        if (tmp[j] == 1) {
          fix <- c(2, 3)
        } else if (tmp[j] == nrow(out.i)) {
          fix <- c(tmp[j] - 2, tmp[j] - 1)
        } else {
          fix <- c(tmp[j] - 1, tmp[j] + 1)
        }
        dist <- distVincentyEllipsoid(p1 = c(out.i$long[fix[1]], out.i$lat[fix[1]]), 
                                      p2 = c(out.i$long[fix[2]], out.i$lat[fix[2]]))
        s <- dist / (abs(out.i$sec[fix[1]] - out.i$sec[fix[2]]))
        b <- bearing(p1 = c(out.i$long[fix[1]], out.i$lat[fix[1]]), 
                     p2 = c(out.i$long[fix[2]], out.i$lat[fix[2]]))
        fix.use <- which.min(sapply(fix, function(x) abs(out.i$sec[x] - out.i$sec[tmp])))
        dist <- s * (out.i$sec[tmp] - out.i$sec[fix[fix.use]])
        dest <- destPoint(p = c(out.i$long[fix[fix.use]], out.i$lat[fix[fix.use]]), 
                          b = b, d = dist)
        out.i$lat[tmp] <- dest[, "lat"]
        out.i$long[tmp] <- dest[, "lon"]
        out.i$GPSerror[tmp] <- -1
      }
    }
    
    # DELETE TRACK FILE POINT IF BEARING CHANGES BY MORE 100 DEGREES
    if (nrow(out.i) > 1 & min(out.i$sec) < max(out.i$sec)) {
      b <- rep(NA, nrow(out.i))
      delete <- rep(0, nrow(out.i))
      for (j in 1:(nrow(out.i)-1)) {
        b[j] <- bearing(p1 = c(out.i$long[j], out.i$lat[j]), 
                        p2 = c(out.i$long[j+1], out.i$lat[j+1]))
        if (is.na(b[j])) next
        if (j > 1) {
          if (!(is.na(b[j-1])) & abs(b[j] - b[j-1]) > 100 & out.i$type[j] == "WAYPNT") 
            delete[j] <- 1
        }
      }
      out.i <- out.i[delete == 0, ]
    }
    
    # ASSIGN CONDITION CODES TO TRACK FILE POINTS
    if (length(sort(unique(out.i$condition))) == 1 & sum(out.i$type == "COCH") == 0) {
      out.i$condition <- sort(unique(out.i$condition))
    } else {
      for (j in 2:nrow(out.i)) {
        if (is.na(out.i$condition[j]) & out.i$type[j] == "WAYPNT") 
          out.i$condition[j] <- out.i$condition[j-1]
        if (out.i$condition[j] != out.i$condition[j-1] & out.i$type[j] != "COCH") 
          message("Error in condition codes: ", unique(obsds$file))
      }
    }
    
    dat <- if (i == 1) out.i else rbind(dat, out.i)
  }
  row.names(dat) <- NULL
  dat$index <- as.numeric(row.names(dat))
  
  return(dat)
  
}
