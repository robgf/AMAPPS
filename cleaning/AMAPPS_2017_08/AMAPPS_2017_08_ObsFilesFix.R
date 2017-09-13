##--------------------------##
# fixing errors in AMAPPS 2017 08 data
##--------------------------##


##--------------------------##
## Pilot notes

## Crew 4446
## Non-standard species or codes:		
# Code	Description	
# MOMO	Mola Mola Ocean Sunfish	
#	NOGA adult	Note that Koneff did not record age class on Aug 18, and only Koneff used these codes.  TPW put age class in comments.
# NOGAi	NOGA immature 	Note that Koneff did not record age class on Aug 18, and only Koneff used these codes.  TPW put age class in comments.
# UNSK	Unknown Skua	
# WIDO	White-sided Dolphin	
# FIWH	Fin Whale	
## Other relevant information and comments:															
# Note:  started slightly offshore on numerous transects due to coastal development.															
# Note:  distances to Trawlers (fishing vessels) is shown in meters from transect centerline.															
# Note:  MDK had no BEGSEG for 444100															
# Note: TPW recorded data on TRAWL in a different format on 8/18 than on other days															
# Note: MDK did not record ENDCNT/BEGCNT when going over land on 442601 due to high density traffic/workload.  Use breaks from TPW.															
# Note: called the start of 423600 a little late (~1mile).  Entire transect was surveyed.															
# Note:  TPW missed start point for 423100 and the geographic location of the start point for MDK should be verified on line.  Note that this line was started east of the published start point to due harbor boat traffic.															
# Note: Did not record the ENDSEG for 415100.															
# Note: Called the end of 415101 about 1/2 mile late.															
# Note: Cut off the West end of 412101 (ended early) which overlies Martha's Vineyard.															
##--------------------------##


##--------------------------##
# species errors
##--------------------------##
obs$type = as.vector(obs$type)
obs$original.spp.codes = obs$type

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

tmp <- !obs$type %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))
rm(spplist)

obs$type[obs$type %in% "TRAWL" & obs$comment %in% c("lobster boat","400, lobster boat",
                                                    "300,lobster boat",
                                                    "600, lobster boat no birds following",
                                                    "lobster boat no birds following",
                                                    "lobster boat with 3 HEGU fowing")] = "BOLO"
obs$type[obs$type %in% "TRAWL" & obs$comment %in% c("fishing birds following",
                                                    "fishing with gannets and gulls following")] = "BOFI"

obs$type[obs$type %in% "BIRD"] = "UNBI"
obs$type[obs$type %in% "BODU"] = ""    #*******
obs$type[obs$type %in% "DDCO"] = "DCCO"  #?  
obs$type[obs$type %in% "DOLP"] = "UNDO"    
obs$type[obs$type %in% "DUCK"] = "UNDU"    
obs$type[obs$type %in% "HEGU"] = "HERG"      
obs$type[obs$type %in% "LEST"] = "LETU"      
obs$type[obs$type %in% "LHSP"] = "LESP"      
obs$type[obs$type %in% "SEAL"] = "UNSE"      
obs$type[obs$type %in% "UNSB"] = "SHOR"   
obs$type[obs$type %in% "UNTU"] = "TURT"   
obs$type[obs$type %in% "WHAL"] = "UNWH"      
obs$type[obs$type %in% "WSIP"] = "WISP"  
obs$type[obs$type %in% "TRAWL"] = "BOTD"
obs$type[obs$type %in% "MOMO"] = "MOLA"
obs$type[obs$type %in% "WIDO"] = "WSDO"
obs$type[obs$type %in% "SALPEN"]	= "SPEN"

obs$age[obs$type %in% c("NOGAA")] = "adult"
obs$age[obs$type %in% c("NOGAI")] = "immature"
obs$type[obs$type %in% c("NOGAA", "NOGAI")] = "NOGA"

tmp = obs$type != obs$original.spp.codes
obs$dataChange[tmp] = paste(obs$dataChange[tmp], "; changed TYPE from ", obs$original.spp.codes[tmp], sep = "")
rm(tmp, old)

obs$type[obs$type %in% "COMMENT" & obs$comment %in% c("lobster gear hundreds of pots",
                                                      "lobster gear everywhere")] = "FGLO"
  
message("Fixed AOU codes")

## remove duplicate fields

##--------------------------##


##--------------------------##
## fill in other fields from comments
##--------------------------##
#behavior
obs$behavior[obs$comment %in% c("f","s","F","S") & obs$behavior %in% ""] = obs$comment[obs$comment %in% c("f","s","F","S") & obs$behavior %in% ""]
obs$behavior[obs$comment %in% c("300,F, following lobster boat",
                                   "300,F, following trawler",
                                   "300,F,following fishing boat",
                                   "300,F,following trawler")]="f"
obs$behavior[obs$comment %in% c("600,S,adult, following trawler")]="s"
obs$behavior = tolower(obs$behavior)

#age
obs$age[obs$comment %in% c("adult","600,S,adult, following trawler","adult in rockweed",
                           "adult, following trawler","adult,counting on transit transect",
                           "adult,following trawler","adult,transit transect",
                           "adults,following fishing boat")] = "adult"
obs$age[obs$comment %in% c("aubadult","subadult",
                           "sub adult","subadult, fish in bill",
                           "subadult,counting on transit transect",
                           "subadult,transit transect")] = "subadult"
obs$age[obs$comment %in% c("juvenile","juvenile, following fishing boat")] = "juvenile"

#association
obs$association[obs$comment %in% c("following fishing boat",
                                   "300,F,following fishing boat",
                                   "adults,following fishing boat",
                                   "juvenile, following fishing boat")] = "BOFI"
obs$association[obs$comment %in% c("with lobster boat","following lobster boat",
                                   "300,F, following lobster boat",
                                   "300,lobster boat","400, lobster boat")] = "BOLO"
obs$association[obs$comment %in% c("feeding over humpback whale")] = "HUWH"
obs$association[obs$comment %in% c("adult in rockweed")] = "RCKW"
obs$association[obs$comment %in% c("300,F, following trawler",
                                   "300,F,following trawler",
                                   "600,S,adult, following trawler",
                                   "adult, following trawler",
                                   "adult,following trawler")] = "BOTD"
obs$association[obs$comment %in% c("associated with salmon pens")] = "SPEN"

# distance
obs$distance.to.obs[obs$comment %in% c("100")] = 100                                          
obs$distance.to.obs[obs$comment %in% c("1000,no birds following")]=1000                                           
obs$distance.to.obs[obs$comment %in% c("200")] = 200
obs$distance.to.obs[obs$comment %in% c("300","300, birds following","300,birds following",
                                          "300,F, following lobster boat","300,F, following trawler",
                                          "300,F,following fishing boat","300,F,following trawler",
                                          "300,lobster boat" )] = 300                                          
obs$distance.to.obs[obs$comment %in% c("400","400, lobster boat")] = 400                                          
obs$distance.to.obs[obs$comment %in% c("50")] = 50                                           
obs$distance.to.obs[obs$comment %in% c("500")] = 500
obs$distance.to.obs[obs$comment %in% c("600",
                                          "600, lobster boat no birds following",
                                          "600,S,adult, following trawler")] = 600                                          
obs$distance.to.obs[obs$comment %in% c("700")] = 700
##--------------------------##


##--------------------------##
# fix transects errors
##--------------------------##
# MDK had no BEGSEG for 444100
to.add = obs[obs$transect %in% 444100 & obs$obs %in% "tpw" & obs$type %in% "BEGSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
obs = rbind(obs, to.add)

# MDK did not record ENDCNT/BEGCNT when going over land on 442601 
to.add = obs[obs$transect %in% 442601 & obs$obs %in% "tpw" & obs$type %in% "BEGSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
obs = rbind(obs, to.add)

# TPW missed start point for 423100, use MDK's	
to.add = obs[obs$transect %in% 423100 & obs$obs %in% "mdk" & obs$type %in% "BEGSEG",]
to.add$obs = "tpw"
to.add$comment = "added from mdk's record"
to.add$index = NA
obs = rbind(obs, to.add)

# Note: Did not record the ENDSEG for 415100.	
to.add = obs[obs$transect %in% 415100 & obs$obs %in% "tpw" & obs$type %in% "ENDSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
obs = rbind(obs, to.add)
rm(to.add)

# Note: Called the end of 415101 about 1/2 mile late.

# 441100 missing 2 ends or typo for beg
obs$type[obs$transect %in% 441100 & obs$obs %in% "tpw" & obs$sec %in% c(61518.03, 62576.77)] = "REMOVE"

# 442602 typo for beg
obs$type[obs$transect %in% 442602 & obs$obs %in% "mdk" & obs$sec %in% 37227.20] = "BEGSEG"

# 443100 double end
obs$type[obs$transect %in% 443100 & obs$obs %in% "tpw" & obs$sec %in% 35851.50] = "REMOVE"

# 444600 double end
obs$type[obs$transect %in% 444600 & obs$obs %in% "tpw" & 
           obs$sec %in% 31284.55 & obs$type %in% "ENDCNT"] = "REMOVE"

# remove dublicates coded as remove
obs = filter(obs, !type %in% "REMOVE")
##--------------------------##


##--------------------------##
# fix errors
##--------------------------##

## counts
obs$count[obs$count %in% c("1.1.f","1.2.f.adult")] = 1
obs = filter(obs, !count %in% "")

## investigate high counts
#x = obs[as.numeric(obs$count) > 100 & !obs$type %in% c("BEGSEG","ENDSEG","BEGCNT","ENDCNT","COCH"),]
obs$distance.to.obs[obs$type %in% "BOTD" & obs$obs %in% "tpw" & obs$count %in% "200"] = 200
obs$count[obs$type %in% "BOTD" & obs$obs %in% "tpw" & obs$count %in% "200"] = 1
#rm(x)

## dates
# mdk uses 5 instead of 8
obs$month[obs$obs %in% "mdk"] = 8

## change meters to nm
obs$distance.to.obs[obs$obs %in% c("tpw","mdk")] = obs$distance.to.obs[obs$obs %in% c("tpw","mdk")] * 0.000539957
##--------------------------##
