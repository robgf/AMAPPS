# Function to segment "segmentable" data prepared from NWASC database
# Returns dataframe of segmented data

# Calculates species counts by default; set occurences = TRUE for number of sightings
# Distances are in nautical miles

# Kyle Dettloff
# 12-18-2015

set.seed(145)
source("Q:/Kyle_Working_Folder/Segmentation/pre_segment_db.R")

segment = function(data, seg.length = 2.5, seg.tol = 0.5, dist.max = 1, occurences = FALSE) {
  # calculate number of segments for each transect
  seg = data %>% mutate(nseg = ifelse(trans_dist_eff <= seg.length, 1,
                                      ifelse(trans_dist_eff / seg.length - floor(trans_dist_eff / seg.length) >= seg.tol,
                                             floor(trans_dist_eff / seg.length) + 1, floor(trans_dist_eff / seg.length)))) %>%
    # randomly assign extra distance
    mutate(seg_extra = ifelse(nseg > 1 & trans_dist_eff > nseg * seg.length, ceiling(runif(1, 0, nseg)), 0)) %>%
    # assign segment numbers to observations  
    mutate(seg_num = as.numeric(ifelse(dist_cum <= seg.length | nseg == 1, 1,
                                       ifelse(dist_cum <= seg.length * nseg, ceiling(dist_cum / seg.length),
                                              seg_extra)))) %>%
    select(-dist_cum) %>% filter(!is.na(seg_num)) %>%
    # calculate segment distances and number of empty segments
    mutate(tot_empty = nseg - n_distinct(seg_num))
  # create dataframe of empty segments
  seg_empty = seg %>% select(strip_width, lat_start, lon_start, trans_bearing, trans_dist_eff, nseg, seg_extra, tot_empty) %>%
    distinct() %>% ungroup() %>% filter(tot_empty > 0) %>% slice(rep(row_number(), tot_empty)) %>% select(-tot_empty)
  # merge empty segments with observations and assign segment numbers
  seg_final_long = bind_rows(seg, seg_empty) %>% select(-tot_empty) %>% group_by(dataset_id, transect_id) %>%
    mutate(seg_num = replace(seg_num, is.na(seg_num), setdiff(1:first(nseg), seg_num)),
           count = replace(count, is.na(count), 0)) %>%
    # calculate segment distances
    mutate(seg_dist = ifelse(nseg == 1, trans_dist_eff,
                             ifelse(seg_num != seg_extra & seg_num < nseg, seg.length,
                                    ifelse(seg_num != seg_extra & seg_num == nseg, trans_dist_eff - seg.length * (nseg - 1),
                                           seg.length + trans_dist_eff - nseg * seg.length)))) %>%
    select(-trans_dist_eff) %>% arrange(seg_num) %>%
    # fill in missing dates and sea states
    mutate(obs_dt = na.locf(na.locf(obs_dt, na.rm = FALSE), na.rm = FALSE, fromLast = TRUE),
           beaufort = na.locf(na.locf(beaufort, na.rm = FALSE), na.rm = FALSE, fromLast = TRUE)) %>%
    # calculate distances to segment midpoints
    group_by(dataset_id, transect_id, seg_num) %>% mutate(tmpvar = ifelse(row_number() == 1, 1, 0)) %>%
    group_by(dataset_id, transect_id, tmpvar) %>% mutate(seg_dist_cum = as.numeric(ifelse(tmpvar == 1, cumsum(seg_dist), NA))) %>%
    ungroup() %>% select(-tmpvar) %>% mutate(seg_dist_cum = na.locf(seg_dist_cum)) %>%
    group_by(dataset_id, transect_id, seg_num) %>% mutate(seg_dist_mid = seg_dist_cum - seg_dist / 2) %>%
    select(-seg_dist_cum) %>%
    # calculate coordinates of segment midpoints  
    mutate(coords_mid = list(destPoint(c(first(lon_start), first(lat_start)), first(trans_bearing), first(seg_dist_mid) * 1852))) %>%
    select(-seg_dist_mid, -trans_bearing, -lat_start, -lon_start) %>%
    mutate(seg_mid_lat = unlist(lapply(coords_mid, `[[`, 2)), seg_mid_lon = unlist(lapply(coords_mid, `[[`, 1))) %>%
    select(-coords_mid) %>%
    # final quality control to check if observations are within specified distance of segment midpoints  
    rowwise() %>% mutate(obs_dist = distVincentySphere(c(lon, lat), c(seg_mid_lon, seg_mid_lat)) / 1852) %>%
    select(-lat, -lon) %>% filter(obs_dist <= sqrt((seg_dist / 2) ^ 2 + dist.max ^ 2) | is.na(obs_dist) | (seg_extra > 0 & seg_extra != nseg)) %>%
    select(-obs_dist, -nseg, -seg_extra) %>%
    # calculate segment-averaged Beaufort values
    ungroup() %>% group_by(dataset_id, transect_id, seg_num) %>%
    mutate(beaufort = replace(beaufort, n_distinct(beaufort) > 1, mean(unique(beaufort))),
           obs_dt = first(obs_dt))
  
  # summarize species data by segment and convert to wide form
  seg_final = seg_final_long %>%
    mutate(spp_cd = replace(spp_cd, is.na(spp_cd), "NONE")) %>%
    group_by(dataset_id, transect_id, seg_num, spp_cd, obs_dt, seg_mid_lat, seg_mid_lon, seg_dist, strip_width, beaufort)
  if (occurences == FALSE) {
    # total species count
    seg_final = seg_final %>% summarise(count = sum(count)) %>%
      spread(spp_cd, count, fill = 0) %>% select(-NONE)
    } else if (occurences == TRUE) {
      # number of species occurences
      seg_final = seg_final %>% select(-count) %>% summarise(noccur = n()) %>%
        spread(spp_cd, noccur, fill = 0) %>% select(-NONE)
    }
  seg_final
}

### run function
segmented = segment(segmentable)

# unload packages (optional)
pkgs = names(sessionInfo()$otherPkgs)
pkgs = paste('package:', pkgs, sep = "")
invisible(lapply(pkgs, detach, character.only = TRUE, unload = TRUE, force = TRUE))