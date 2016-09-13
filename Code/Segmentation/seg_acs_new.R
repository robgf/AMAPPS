# Function to segment continuous survey data in AMAPPS database
# Returns wide-form dataframe with segmented data

# Requires observation table with lat/long for each sighting and spatial lines shapefile containing survey effort

# seg.length sets target segment length (seg.length > 0)

# seg.tol sets threshold for creation of a new segment from extra transect distance (0 <= extra < seg.length)
# as a proportion of target segment length (0 <= seg.tol < 1)

# Calculates species counts by default; set occurences = TRUE for number of flock sightings
# maxDist sets maximum allowable distance (approx. meters) between an observation and its nearest segment line
# Segment midpoints fall on track line by default; set centroids = TRUE to use geographic centroid
# seg.min sets minimum allowable segment length (>= 0)

# Distances are in nautical miles

# Kyle Dettloff
# Modified 08-12-16 after dplyr 0.5.0 update

suppressMessages(library(maptools))
suppressMessages(library(rgeos))
suppressMessages(library(geosphere))
suppressMessages(library(dplyr))
suppressMessages(library(tibble))
suppressMessages(library(tidyr))
suppressMessages(library(zoo))

options(dplyr.show_progress = FALSE)

# read in observation and track tables
load("Q:/Kyle_Working_Folder/Segmentation/Atlantic_Coast_Surveys/Data/AMAPPS.RData")

segmentAMAPPS = function(observations, tracks, seg.length = 2.5/0.926, seg.tol = 0.5, seg.min = seg.length * seg.tol,
                         centroids = FALSE, maxDist = NA, occurences = FALSE) {
  
  if(seg.length <= 0) stop("seg.length > 0 is FALSE")
  if(seg.tol < 0 | seg.tol >= 1) stop("0 <= seg.tol < 1 is FALSE")
  if(seg.min < 0) stop("seg.min >= 0 is FALSE")

  # -------- segment track data ---------------------------------------------------------------------------------------------------
  seg = tracks %>% arrange(SurveyNbr, Transect, Replicate, Obs, Year, Month, Day, Sec) %>%
    mutate(Piece = ifelse(Type %in% c("BEGTRAN", "BEGCNT"), 1, 0)) %>% select(-Type) %>%
    group_by(SurveyNbr, Transect, Replicate, Obs) %>% mutate(Piece = cumsum(Piece)) %>%
    distinct(Long, Lat, Piece, Replicate, Obs, Transect, SurveyNbr, .keep_all = TRUE) %>%
    group_by(SurveyNbr, Transect, Replicate, Obs, Piece) %>%
    mutate(long_i = lag(Long, default = first(Long), order_by = Sec),
           lat_i = lag(Lat, default = first(Lat), order_by = Sec)) %>%
    rowwise %>% mutate(dist = distVincentySphere(c(long_i, lat_i), c(Long, Lat)) / 1852) %>%
    select(-c(long_i, lat_i, Sec)) %>% ungroup %>% group_by(SurveyNbr, Transect, Replicate, Obs, Piece) %>%
    # calculate cumulative distance traveled between waypoints
    mutate(dist_cuml = cumsum(dist), dist_total = max(dist_cuml)) %>% select(-dist) %>%
    # calculate number of segments for each transect
    mutate(nseg = ifelse(dist_total <= seg.length, 1,
                         ifelse(dist_total / seg.length - floor(dist_total / seg.length) >= seg.tol,
                                floor(dist_total / seg.length) + 1, floor(dist_total / seg.length))),
           # number segments with waypoints
           seg_num = ifelse(dist_cuml <= seg.length | nseg == 1, 1,
                            ifelse(dist_cuml <= seg.length * nseg, ceiling(dist_cuml / seg.length), nseg)),
           # number of segments without waypoints
           tot_empty = as.integer(nseg - n_distinct(seg_num)))
  
  # create rows for segments without waypoints  
  seg.empty = seg %>% ungroup %>% select(SurveyNbr, Transect, Replicate, Obs, Piece, dist_total, nseg, tot_empty) %>%
    distinct %>% filter(tot_empty > 0) %>% slice(rep(row_number(), tot_empty)) %>% select(-tot_empty) %>%
    mutate(empty_seg = 1)
  
  # combine segments with and without waypoints
  seg.all = seg %>% select(-tot_empty) %>% bind_rows(., seg.empty) %>% group_by(SurveyNbr, Transect, Replicate, Obs, Piece) %>%
    # number segments without waypoints
    mutate(seg_num = replace(seg_num, is.na(seg_num), setdiff(1:first(nseg), seg_num)),
           # calculate segment lengths
           seg_dist = ifelse(nseg == 1, dist_total,
                             ifelse(seg_num < nseg, seg.length,
                                    ifelse(seg_num == nseg, dist_total - seg.length * (nseg - 1),
                                           seg.length + dist_total - nseg * seg.length))),
           # calculate cumulative segment distance
           seg_dist_cuml = ifelse(seg_num == nseg, dist_total, seg.length * seg_num)) %>%
    select(-dist_total) %>%
    ungroup %>% arrange(SurveyNbr, Transect, Replicate, Obs, Piece, seg_num, dist_cuml) %>%
    group_by(SurveyNbr, Transect, Replicate, Obs, Piece) %>% mutate(dist_cuml = na.locf(dist_cuml)) %>%
    group_by(SurveyNbr, Transect, Replicate, Obs, Piece, seg_num) %>%
    mutate(seg_brk = as.integer(ifelse(row_number() == n() & seg_num != nseg, 1, 0))) %>%
    select(-nseg) %>% group_by(SurveyNbr, Transect, Replicate, Obs, Piece) %>%
    mutate(Long = na.locf(Long), Lat = na.locf(Lat),
           long_lead = na.locf(lead(Long), na.rm = FALSE, fromLast = TRUE),
           lat_lead = na.locf(lead(Lat), na.rm = FALSE, fromLast = TRUE)) %>%
    rowwise %>%
    # calculate heading between last waypoint and segment endpoint
    mutate(heading = as.numeric(ifelse(seg_brk == 0, NA, bearing(c(Long, Lat), c(long_lead, lat_lead), f = 0)))) %>%
    select(-c(seg_brk, long_lead, lat_lead)) %>% ungroup %>%
    group_by(SurveyNbr, Transect, Replicate, Obs, Piece, dist_cuml) %>% mutate(heading = last(heading)) %>%
    group_by(SurveyNbr, Transect, Replicate, Obs, Piece, seg_num) %>%
    # calculate distance between last waypoint and segment endpoint
    mutate(dist_shy = as.numeric(ifelse(is.na(heading), NA, seg_dist_cuml - dist_cuml))) %>%
    rowwise %>%
    # calculate coordinates of segment endpoints
    mutate(coords_end = ifelse(is.na(heading), list(NA), list(destPoint(c(Long, Lat), heading, dist_shy * 1852, f = 0)))) %>%
    select(-c(heading, dist_shy)) %>% ungroup
  
  # create rows for segment endpoints
  end.pts = seg.all %>% select(-empty_seg) %>% filter(!is.na(coords_end)) %>%
    mutate(Long = unlist(lapply(coords_end, `[[`, 1)), Lat = unlist(lapply(coords_end, `[[`, 2)), dist_cuml = seg_dist_cuml) %>%
    select(-c(coords_end, seg_dist_cuml))
  # create rows for segment start points and combine with segment endpoints
  seg.ends = end.pts %>% select(-seg_dist) %>% mutate(seg_num = seg_num + 1) %>% bind_rows(end.pts, .)
  
  # combine segment start points and endpoints with other waypoints
  seg.all.new = seg.all %>% filter(is.na(empty_seg)) %>% select(-c(empty_seg, seg_dist_cuml, coords_end)) %>%
    bind_rows(., seg.ends) %>% arrange(SurveyNbr, Transect, Replicate, Obs, Piece, seg_num, dist_cuml) %>%
    group_by(SurveyNbr, Transect, Replicate, Obs, Piece, seg_num) %>%
    mutate(seg_dist = round(max(seg_dist, na.rm = TRUE), 3),
           id = paste(sprintf("%02d", SurveyNbr), sprintf("%02d", Transect), sprintf("%02d", Replicate),
                      Obs, sprintf("%02d", Piece), sprintf("%02d", seg_num), sep = "-"),
           transect_id = paste(SurveyNbr, Transect, Replicate, Obs, sep = "-")) %>%
    group_by(SurveyNbr, Transect, Replicate) %>% select(-Piece) %>%
    mutate(Year = min(Year, na.rm = TRUE), Month = min(Month, na.rm = TRUE), Day = min(Day, na.rm = TRUE)) %>%
    group_by(transect_id) %>% mutate(Condition = na.locf(Condition), Seat = na.locf(Seat)) %>%
    group_by(id) %>% mutate(dist = dist_cuml - lag(dist_cuml, default = first(dist_cuml)),
                            Condition = round(sum(Condition * dist) / sum(dist), 2)) %>% select(-c(dist, dist_cuml)) %>%
    filter(seg_dist >= seg.min, seg_dist > 0) %>% ungroup
  
  # -------- calculate segment midpoints ------------------------------------------------------------------------------------------
  # create dataframe suitable to become spatial lines object
  listLines = function(df) {
    df %>% select(Long, Lat) %>% as.data.frame %>% Line %>% list
  }
  
  linelist = seg.all.new %>% group_by(transect_id, id) %>% do(coords = listLines(.))
  
  # define Hotine Oblique Mercator projection
  projHOM = "+proj=omerc +lonc=-75 +lat_0=35 +alpha=40 +k_0=0.9996 +ellps=GRS80 +datum=NAD83"
  
  # create spatial lines dataframe from segment waypoints and assign ID to each segment
  lineframe = mapply(x = linelist$coords, ids = linelist$id, function(x, ids) Lines(x, ids)) %>%
    SpatialLines(proj4string = CRS("+proj=longlat")) %>%
    SpatialLinesDataFrame(., as.data.frame(select(linelist, transect_id)), match.ID = FALSE) %>%
    # apply projection
    spTransform(CRS(projHOM))
  
  if (centroids) {
    # calculate geographic centroids of projected segments and convert back to lat/long
    midpoints = gCentroid(lineframe, byid = TRUE) %>% spTransform(CRS("+proj=longlat")) %>%
      as.data.frame %>% rename(mid_long = x, mid_lat = y) %>% rownames_to_column("id")
  }
  if (!centroids) {
    # calculate midpoints of projected segments and convert back to lat/long
    midpoints = SpatialLinesMidPoints(lineframe) %>% spTransform(CRS("+proj=longlat")) %>%
      as.data.frame %>% select(coords.x1, coords.x2) %>% rename(mid_long = coords.x1, mid_lat = coords.x2) %>%
      mutate(id = sapply(slot(lineframe, "lines"), function(x) slot(x, "ID")))
  }
  
  # merge segment midpoints with transect information
  seg.mids = seg.all.new %>% select(-c(Lat, Long)) %>% distinct %>%
    group_by(SurveyNbr, Transect, Replicate, Obs) %>% mutate(seg_num = seq.int(n())) %>% ungroup %>%
    left_join(., midpoints, by = "id") %>% select(-c(id, transect_id, Day))
  
  # -------- assign segments to points --------------------------------------------------------------------------------------------
  # function modified from maptools::snapPointsToLines
  assignPointsToLines = function(points, lines, maxDist = NA) {
    
    # remove observations farther than maxDist from segment
    if (!is.na(maxDist)) {
      w = gWithinDistance(points, lines, dist = maxDist, byid = TRUE)
      validPoints = apply(w, 2, any)
      points = points[validPoints, ]
    }
    
    d = gDistance(points, lines, byid = TRUE) # distance matrix of each point to each segment
    seg_num = apply(d, 2, which.min) # position of each nearest segment in lines object
    
    # create data frame
    cbind(points@data, seg_num)
  }
  
  # wrapper function to restrict point to line pairing by transect ID
  obs2Lines = function(df, lineframe) {
    
    points = df %>% as.data.frame
    # apply HOM projection
    coordinates(points) = c("Long", "Lat")
    proj4string(points) = CRS("+proj=longlat")
    points = spTransform(points, CRS(projHOM))
    
    lines = lineframe[lineframe@data$transect_id == df$transect_id[1], ]
    
    assignPointsToLines(points, lines, maxDist)
  }
  
  # prepare observation table
  obs.transect.id = lineframe@data$transect_id
  obs = observations %>%
    select(SurveyNbr, Transect, Replicate, Obs, Year, Month, Species, FlockSize, Long, Lat) %>%
    # narrow observations to birds
    filter(!(Species %in% c("GRST", "KRST", "LEST", "LOST", "CNRA", "GWSH", "HASH", "MARA",
                            "BODO", "DOLP", "FIWH", "GRSE", "HUWH", "MIWH", "PIWH", "PORP",
                            "RIDO", "RIWH", "WIMA", "SEAL", "WHAL", "UNMM", "UNSD", "SHAR",
                            "UNRA", "UIST", "BALN"))) %>%
    mutate(transect_id = paste(SurveyNbr, Transect, Replicate, Obs, sep = "-")) %>%
    filter(transect_id %in% obs.transect.id)
  # for each transect, find nearest segment to each point
  seg.obs = obs %>% group_by(transect_id) %>% do(obs2Lines(., lineframe)) %>% ungroup %>%
    select(-transect_id)
  
  # join segment midpoints and observations
  segmented = full_join(seg.mids, seg.obs, by = c("SurveyNbr", "Transect", "Replicate", "Obs", "Year", "Month", "seg_num")) %>%
    mutate(FlockSize = replace(FlockSize, is.na(FlockSize), 0),
           Species = replace(Species, is.na(Species), "NONE"),
           SurveyNbr = factor(SurveyNbr), Transect = factor(Transect), Replicate = factor(Replicate)) %>%
    group_by(SurveyNbr, Transect, Replicate, Obs, Seat, Year, Month, Condition, seg_num, seg_dist, mid_long, mid_lat, Species)
  
  # -------- summarize species data by segment and convert to wide form -----------------------------------------------------------
    if (!occurences) {
      # total species count
      segmented = segmented %>% summarise(FlockSize = sum(FlockSize)) %>%
        spread(Species, FlockSize, fill = 0) %>% select(everything(), -matches("NONE")) %>% ungroup
    }
    else if (occurences) {
      # number of species occurences
      segmented = segmented %>% select(-FlockSize) %>% summarise(noccur = n()) %>%
        spread(Species, noccur, fill = 0) %>% select(everything(), -matches("NONE")) %>% ungroup
    }

}

### example run ###
seg.amapps = segmentAMAPPS(observations, tracks)
