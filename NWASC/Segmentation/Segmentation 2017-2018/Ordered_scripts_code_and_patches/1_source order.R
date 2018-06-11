#Requirement for this file
library(dplyr)
library(sp)
library(rgeos)
#Fix for spiece names
source('rework_Mass_CEC/code_patches/spp_c replacements.R')
#fix for known unkown removal or...
source('rework_Mass_CEC/code_patches/Known none bird removal.R')
#roll_up Phase 2 double observer transects
source('rework_Mass_CEC/code_patches/ConsudatePilotObservertracks.R')

#### Phase 2 ####
source('rework_Mass_CEC/Phase II Data and Code/1_data_pull_and_wrangle.R')

#### Phase 2 Processed ####
source('rework_Mass_CEC/Phase II Data and Code/2_phase2_segmentation.R')
seg.dat.phase2 = segmentCTS(obs.pre, shp.pre , cts.dat, seg.min = 0.0)

datetime = Sys.Date()
dft = 'Corrected_MassCEC_segmentation'
filenm = paste(paste("segmented_seabird_catalog",datetime,dft,sep = "-"),".csv")
write.csv(seg.dat.phase2,file = filenm, row.names = FALSE)
rm(datetime,dft,filenm)
rm(Dataset160_leg_tran_id,MidAtlanticDetection2012_rear_observers,missingtransects)
rm(rearobs_trans_id,rearobsdrop)
