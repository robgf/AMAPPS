# Function to segment "segmentable" data from Atlantic Coast Surveys database
# Returns dataframe of segmented data

# seg.tol sets break point for end segment
# Calculates species counts by default; set occurences = TRUE for number of sightings

# Distances are in nautical miles

# Kyle Dettloff
# 04-18-2015

segmentAC = function(data, seg.length = 2.5, seg.tol = 0.5, occurences = FALSE) {
  seg = data %>% mutate(nseg = ifelse(trans_dist_eff <= seg.length, 1,
                                         ifelse(trans_dist_eff / seg.length - floor(trans_dist_eff / seg.length) >= seg.tol,
                                                floor(trans_dist_eff / seg.length) + 1, floor(trans_dist_eff / seg.length)))) %>%
  # assign segment numbers to observations  
  mutate(seg_num = as.numeric(ifelse(dist_cum <= seg.length | nseg == 1, 1,
                                     ifelse(dist_cum <= seg.length * nseg, ceiling(dist_cum / seg.length),
                                            nseg)))) %>%
  select(-dist_cum) %>% filter(!is.na(seg_num)) %>%
  # calculate segment distances and number of empty segments
  mutate(tot_empty = nseg - n_distinct(seg_num))
  # create dataframe of empty segments
  seg_empty = seg %>% select(Crew, Year, Month, lat_start, lon_start, trans_dist_eff, trans_bearing, nseg, tot_empty) %>%
    distinct() %>% ungroup() %>% filter(tot_empty > 0) %>% slice(rep(row_number(), tot_empty)) %>% select(-tot_empty)
  # merge empty segments with observations and assign segment numbers
  seg_final_long = bind_rows(seg, seg_empty) %>% select(-tot_empty) %>% group_by(SurveyNbr, Transect, Replicate) %>%
    mutate(seg_num = replace(seg_num, is.na(seg_num), setdiff(1:first(nseg), seg_num)),
           FlockSize = replace(FlockSize, is.na(FlockSize), 0), Species = replace(Species, is.na(Species), "NONE")) %>%
  # calculate segment distances
  mutate(seg_dist = ifelse(nseg == 1, trans_dist_eff,
                           ifelse(seg_num < nseg, seg.length,
                                  ifelse(seg_num == nseg, trans_dist_eff - seg.length * (nseg - 1),
                                         seg.length + trans_dist_eff - nseg * seg.length)))) %>%
  select(-trans_dist_eff) %>% arrange(seg_num) %>%
  # fill in missing condition indicies
  mutate(Condition = na.locf(na.locf(Condition, na.rm = FALSE), na.rm = FALSE, fromLast = TRUE)) %>%
  # calculate distances to segment midpoints
  group_by(SurveyNbr, Transect, Replicate, seg_num) %>% mutate(tmpvar = ifelse(row_number() == 1, 1, 0)) %>%
  group_by(SurveyNbr, Transect, Replicate, tmpvar) %>% mutate(seg_dist_cum = as.numeric(ifelse(tmpvar == 1, cumsum(seg_dist), NA))) %>%
  ungroup() %>% select(-tmpvar) %>% mutate(seg_dist_cum = na.locf(seg_dist_cum)) %>%
  group_by(SurveyNbr, Transect, Replicate, seg_num) %>% mutate(seg_dist_mid = seg_dist_cum - seg_dist / 2) %>%
  select(-seg_dist_cum) %>% mutate(seg_dist = round(seg_dist, 3)) %>%
  # calculate coordinates of segment midpoints  
  mutate(coords_mid = list(destPoint(c(first(lon_start), first(lat_start)), first(trans_bearing), first(seg_dist_mid) * 1852))) %>%
  select(-c(seg_dist_mid, trans_bearing, lat_start, lon_start)) %>%
  mutate(seg_mid_lat = unlist(lapply(coords_mid, `[[`, 2)), seg_mid_lon = unlist(lapply(coords_mid, `[[`, 1))) %>%
  select(-coords_mid) %>%
  # calculate segment-averaged values
  mutate(Condition = replace(Condition, n_distinct(Condition) > 1, mean(unique(Condition), na.rm = TRUE)),
         Dist2Coast_nm = replace(Dist2Coast_nm, n_distinct(Dist2Coast_nm) > 1, mean(unique(Dist2Coast_nm), na.rm = TRUE)),
         Depth = replace(Depth, n_distinct(Depth) > 1, mean(unique(Depth), na.rm = TRUE)),
         Slope = replace(Slope, n_distinct(Slope) > 1, mean(unique(Slope), na.rm = TRUE)))
  # summarize species data by segment and convert to wide form
  seg_final = seg_final_long %>%
    group_by(SurveyNbr, Transect, Replicate, Crew, Year, Month, Species, Condition,
             Dist2Coast_nm, Depth, Slope, seg_num, seg_dist, seg_mid_lat, seg_mid_lon)
  if (occurences == FALSE) {
    # total species count
    seg_final = seg_final %>% summarise(FlockSize = sum(FlockSize)) %>%
      spread(Species, FlockSize, fill = 0) %>% select(-NONE) %>% ungroup()
  } else if (occurences == TRUE) {
    seg_final = seg_final %>% select(-FlockSize) %>% summarise(NGroups = n()) %>%
      spread(Species, NGroups, fill = 0) %>% select(-NONE) %>% ungroup()
  }
  seg_final
}

### run function
source("Q:/Kyle_Working_Folder/Segmentation/Atlantic_Coast_Surveys/pre_segment_acs.R")
segmentedAC = segmentAC(segmentableAC)
