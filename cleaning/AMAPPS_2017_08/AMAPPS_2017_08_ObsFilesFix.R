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

# Wortham Crew
#Transect	Status	Comments
#324600	Full	Surveyed over two days			
#324100	Partial	Adverse Weather			

# Earsom Crew
#Transect	Comments			
#405600		22 Aug stopped count for land, no lost distance			
#405600		22 Aug stopped count for land, no lost distance			
#405600		22 Aug stopped count for land, no lost distance			
#410101		22 Aug stopped count for land, no lost distance			
#405601	Partial	22 Aug lost end of line due to airspace restriction; ended at 405600N/720858W			
#404100		22 Aug stopped count for land, no lost distance			
#402600		22 Aug forgot to call a stop/resume count for a narrow strip of land			
#400600		22 Aug trawler was just offshore and entering port; was not fishing			
#400100		22 Aug stopped count for land, no lost distance			
#395600		22 Aug stopped count for land, no lost distance			
#395100		22 Aug stopped count for land, no lost distance			
#394100		22 Aug stopped count for land, no lost distance			
#371601		24 Aug circled to look at debris, no lost distance			
#385600		26 Aug pilot did not record end of the line; use observer's location			
#384600		26 Aug stopped count for land, no lost distance			
#381600		26 Aug stopped count for land, no lost distance			
#380600		26 Aug stopped count for land, no lost distance			
#375600		26 Aug stopped count for land, no lost distance			
#375600		26 Aug stopped count for land, no lost distance			
#372100		26 Aug stopped count for land, no lost distance			
#370600		26 Aug stopped count for land, no lost distance			
#365601/00		26 Aug did not record break between these two transects			
#355100		27 Aug stopped count for land, no lost distance			
#354600		27 Aug stopped count for land, no lost distance		

# data notes
# manually removed 303600 duplicated data from mtj's 8-20-2017 file
# created removed text document for record in folder
##--------------------------##


##--------------------------##
# species errors
##--------------------------##
obs$type = as.vector(obs$type) # not sure why this is coming in as a matrix - need to check
obs$original.spp.codes = obs$type

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

tmp <- !obs$type %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))


obs$type[obs$type %in% "TRAWL" & obs$comment %in% c("lobster boat","400, lobster boat",
                                                    "300,lobster boat",
                                                    "600, lobster boat no birds following",
                                                    "lobster boat no birds following",
                                                    "lobster boat with 3 HEGU fowing")] = "BOLO"

obs$type[obs$type %in% "BIRD"] = "UNBI"
obs$type[obs$type %in% "BODU"] = "BODO"   
obs$type[obs$type %in% "DDCO"] = "DCCO"  
obs$type[obs$type %in% "DOLP"] = "UNDO"    
obs$type[obs$type %in% "DUCK"] = "UNDU"    
obs$type[obs$type %in% "HEGU"] = "HERG"      
obs$type[obs$type %in% "LEST"] = "LETU"      
obs$type[obs$type %in% "LHSP"] = "LESP"      
obs$type[obs$type %in% "SEAL"] = "UNSE"      
obs$type[obs$type %in% c("UNSB","UISB","SHORE")] = "SHOR"   
obs$type[obs$type %in% c("UIST","UNTU")] = "TURT"   
obs$type[obs$type %in% "WHAL"] = "UNWH"      
obs$type[obs$type %in% "WSIP"] = "WISP"  
obs$type[obs$type %in% "TRAWL"] = "BOTD"
obs$type[obs$type %in% "MOMO"] = "MOLA"
obs$type[obs$type %in% "WIDO"] = "WSDO"
obs$type[obs$type %in% "SALPEN"]	= "SPEN"
obs$type[obs$type %in% "GULL"]	= "UNGU"    
obs$type[obs$type %in% "HTOWR"]	= "TOWR"   
obs$type[obs$type %in% "LOST"]	= "LOTU"    
obs$age[obs$type %in% c("NOGAA")] = "adult"
obs$age[obs$type %in% c("NOGAI")] = "immature"
obs$type[obs$type %in% c("NOGAA", "NOGAI")] = "NOGA"
obs$type[obs$type %in% "BSTP"] = "BRSP" #band rumped storm petrel 
obs$type[obs$type %in% "GRST"] = "GRTU"# green sea turtle
obs$type[obs$type %in% "UISP"] = "UNSP"# unid. ??
obs$type[obs$type %in% "GREA"] = "GREG"
obs$type[obs$type %in% "AGWT"] = "GWTE"
obs$type[obs$type %in% "HBST"] = "HATU"

tmp = obs$type != obs$original.spp.codes
obs$dataChange[tmp] = paste(obs$dataChange[tmp], "; changed TYPE from ", obs$original.spp.codes[tmp], sep = "")
rm(tmp)

# pull out type for useful comments
obs$type[obs$type %in% "COMMENT" & obs$comment %in% c("lobster gear hundreds of pots",
                                                      "lobster gear everywhere")] = "FGLO"
# mixed
obs$type[obs$type %in% "MIXD" & obs$comment %in% c("UNLG,0,S","UNLG,3,S","UNLG,3,F")]= "UNLG"

to.add = obs[obs$type %in% "MIXD" & obs$comment %in% "40%GBBG;60%HEGU",]
obs$count[obs$type %in% "MIXD" & obs$comment %in% "40%GBBG;60%HEGU"] = 36
obs$type[obs$type %in% "MIXD" & obs$comment %in% "40%GBBG;60%HEGU"] = "GBBG"
to.add = mutate(to.add,
                count = 54,
                type = "HERG",
                index = index+0.1)
obs = rbind(obs, to.add)
rm(to.add)

to.add = obs[obs$type %in% "MIXD" & obs$comment %in% "30%GBBG;70%HEGU,0",]
obs$count[obs$type %in% "MIXD" & obs$comment %in% "30%GBBG;70%HEGU,0"] = 15
obs$type[obs$type %in% "MIXD" & obs$comment %in% "30%GBBG;70%HEGU,0"] = "GBBG"
to.add = mutate(to.add,
                count = 35,
                type = "HERG",
                index = index+0.1)
obs = rbind(obs, to.add)
rm(to.add)

obs$comment[obs$type %in% "MIXD" & obs$count %in% "9050%HEGU25%BOGU25%LAGU"] = "50%HEGU;25%BOGU;25%LAGU"
to.add = obs[obs$type %in% "MIXD" & obs$count %in% "9050%HEGU25%BOGU25%LAGU",]
to.add1 = mutate(to.add,
                 count = 23, #rounded up since can't have 1/2 a bird
                 type = "BOGU",
                 index = index+0.1)
to.add2 = mutate(to.add,
                 count = 23, #rounded up since can't have 1/2 a bird
                 type = "LAGU",
                 index = index+0.2)
obs = rbind(obs, to.add1, to.add2)
rm(to.add,to.add1,to.add2)
obs$count[obs$type %in% "MIXD" & obs$comment %in% "50%HEGU;25%BOGU;25%LAGU"] = 45
obs$type[obs$type %in% "MIXD" & obs$comment %in% "50%HEGU;25%BOGU;25%LAGU"] = "HERG"

obs$type[obs$type %in% "MIXD"] = "UNKN" # listing as unknown for now, waiting for observer to get back to me


# final check
ammendended.list = c(as.character(spplist$spp_cd),"BEGCNT","ENDCNT","BEGSEG","ENDSEG","COCH","COMMENT")
tmp <- !obs$type %in% ammendended.list
message("Found ", sum(tmp), " entries with non-matching AOU codes after edits")
sort(unique(obs$type[tmp]))

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
#390600
obs$dataChange[obs$transect %in% 393600 & obs$day %in% 26] = "Changed TRANSECT from 393600"
obs$transect[obs$transect %in% 393600 & obs$day %in% 26] = 390600
  
# MDK had no BEGSEG for 444100
obs$type[obs$transect %in% 444100 & obs$obs %in% "tpw" & obs$type %in% "BEGCNT" & obs$sec %in% 31483.70]="BEGSEG"
to.add = obs[obs$transect %in% 444100 & obs$obs %in% "tpw" & obs$type %in% "BEGSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
to.add$seat = "lf"
obs = rbind(obs, to.add)

# TPW missed start point for 423100, use MDK's	
obs$type[obs$transect %in% 423100 & obs$obs %in% "mdk" & obs$type %in% "BEGCNT"] = "BEGSEG"
to.add = obs[obs$transect %in% 423100 & obs$obs %in% "mdk" & obs$type %in% "BEGSEG",]
to.add$obs = "tpw"
to.add$comment = "added from mdk's record"
to.add$index = NA
to.add$seat = "rf"
obs = rbind(obs, to.add)

# Note: Did not record the ENDSEG for 415100.	
obs$type[obs$transect %in% 415100 & obs$obs %in% "tpw" & obs$type %in% "BEGCNT"] = "BEGSEG"
obs$type[obs$transect %in% 415100 & obs$obs %in% "tpw" & obs$type %in% "ENDCNT"] = "ENDSEG"
to.add = obs[obs$transect %in% 415100 & obs$obs %in% "tpw" & obs$type %in% "ENDSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
to.add$seat = "lf"
obs = rbind(obs, to.add)
rm(to.add)

# 441100 
#missing 2 ends or typo for beg
obs$type[obs$transect %in% 441100 & obs$obs %in% "tpw" & obs$sec %in% c(61518.03, 62576.77)] = "COMMENT"
#change ENDCNT to END SEG
obs$type[obs$transect %in% 444100 & obs$obs %in% "mdk" & obs$type %in% "ENDCNT" & obs$sec %in% 32331.37]="ENDSEG" 

# 442602 typo for beg
obs$type[obs$transect %in% 442602 & obs$obs %in% "mdk" & obs$sec %in% 37227.20] = "BEGSEG"

# 443100 double end
obs$type[obs$transect %in% 443100 & obs$obs %in% "tpw" & obs$sec %in% 35851.50] = "COMMENT"

# 444600 double end
obs$type[obs$transect %in% 444600 & obs$obs %in% "tpw" & 
           obs$sec %in% 31284.55 & obs$type %in% "ENDCNT"] = "COMMENT"

#change ENDCNT to END SEG
obs$type[obs$transect %in% 411601 & obs$obs %in% "mdk" & obs$type %in% "ENDCNT"]="ENDSEG" 

# change offline obs transects to NA
tmp <- tolower(obs$offline) %in% c("na", "no", "n", "", " ")
obs$obsaChange[tmp] <- paste(obs$obsaChange[tmp], "; changed OFFLINE from ", 
                             obs$offline[tmp], sep = "")
obs$offline[tmp] <- "0"
tmp <- tolower(obs$offline) %in% c("yes", "y")
obs$obsaChange[tmp] <- paste(obs$obsaChange[tmp], "; changed OFFLINE from ", 
                             obs$offline[tmp], sep = "")
obs$offline[tmp] <- "1"

obs = mutate(obs, 
             transect = replace(transect, transect %in% c("0","000000"),NA),
             transect = ifelse(offline %in% 1, NA, transect))

# jsw missing transects
obs$offline[obs$obs %in% "jsw"] = 0 # no offline indicated
obs$offline[obs$obs %in% "jsw" & 
              obs$sec %in% c(49480.29,50794.27,50833.73,32384.48,35213.19,39706.75) & 
              obs$type  %in% "TOWR"] = 1
obs$transect[obs$obs %in% "jsw"] = NA # currently "null"
obs$transect[obs$obs %in% "jsw" & obs$type %in% c("BEGCNT","ENDCNT")] = obs$count[obs$obs %in% "jsw" & obs$type %in% c("BEGCNT","ENDCNT")]
obs$transect[obs$obs %in% "jsw" & obs$offline %in% 0] = na.locf(obs$transect[obs$obs %in% "jsw" & obs$offline %in% 0]) #all offline are na so dont need to change transects to NA for offline yet

# jsw 324600, switch BEG and END
obs$type[obs$obs %in% "jsw" & obs$transect %in% "324600" & obs$sec %in% 55539.87] = "ENDCNT"
obs$type[obs$obs %in% "jsw" & obs$transect %in% "324600" & obs$sec %in% 55239.01] = "BEGCNT"

if(any(is.na(obs$transect[obs$offline %in% 0]))){
  message("missing transect number for on transect record")}

if(any(!is.na(obs$transect[obs$offline %in% 1]))){
  message("remove transect number for offline record")}

# SDE & JFV have "null" in transect, need to change to NA and fill in 
obs$transect[obs$transect %in% "null"] = NA
obs$transect[is.na(obs$transect) & obs$type %in% c("BEGCNT","ENDCNT")] = obs$count[is.na(obs$transect) & obs$type %in% c("BEGCNT","ENDCNT")]

# fill in transects where NA
obs = arrange(obs,month,day,obs,sec, index)
obs$transect[obs$obs %in% c('sde','jfv','mtj')] = na.locf(obs$transect[obs$obs %in% c('sde','jfv','mtj')])
obs$transect[obs$obs %in% c('sde','jfv','mtj') & obs$offline %in% 1] = NA

#385600		26 Aug pilot did not record end of the line; use observer's location	
to.add = obs[obs$transect %in% 385600 & obs$type %in% "ENDCNT" & obs$obs %in% 'jfv',]
to.add = mutate(to.add, 
                seat = "lf",
                obs = "sde",
                comment = "pilot did not record end of the line; used observer's location",
                index = NA,
                day = 26)
obs = rbind(obs, to.add)
rm(to.add)

# 353100 
obs$type[obs$transect %in% 353100 & obs$sec %in% 55155.21 & obs$type %in% "ENDCNT"] = "BEGCNT"

# 355100  
obs$type[obs$transect %in% 355100 & obs$sec %in% 50874.36 & obs$type %in% "ENDCNT"] = "COMMENT" # not sure whats up with this

# 355101 missing an END
to.add = obs[obs$transect %in% 355101 & obs$type %in% "ENDCNT" & obs$obs %in% 'sde',]
to.add = mutate(to.add, 
                seat = "rf",
                obs = "jfv",
                comment = "pilot did not record end of the line; used observer's location",
                index = NA)
obs = rbind(obs, to.add)
rm(to.add)

# 374100 -> wrong transect
obs$transect[obs$transect %in% 374100  & obs$sec %in% 40083.59 & obs$type %in% "ENDCNT"] = 374600 # not sure whats up with this

# 375600 neither SDE or JFV has an END
obs$transect[obs$transect %in% 375601 & obs$sec %in% c(38548.45, 38538.71)] = 375600

# 381101  sde missing BEG
to.add = obs[obs$transect %in% 381101 & obs$type %in% "BEGCNT" & obs$obs %in% 'jfv',]
to.add = mutate(to.add, 
                seat = "lf",
                obs = "sde",
                comment = "pilot did not record beginning of the line; used observer's location",
                index = NA)
obs = rbind(obs, to.add)
rm(to.add)

# 410100       
obs$type[obs$transect %in% 410100 & obs$sec %in% 31459.01] = "COMMENT" #not sure whats up here

# 444600
obs$type[obs$transect %in% 444600 & obs$sec %in% 31075.00] = "COMMENT" #not sure whats up here

message("Fixed transect errors")

## descriptive plots
#ggplot(filter(obs,obs %in% "mdk"), aes(long,lat,col=transect))+geom_point()

#ggplot(filter(obs,obs %in% "mdk", type %in% c("BEGCNT","ENDCNT","BEGSEG","ENDSEG")), 
#       aes(long,lat,col=transect))+geom_point()+geom_text(aes(label=transect),hjust=0, vjust=0)

#ggplot(filter(obs,obs %in% "mdk", type %in% c("BEGCNT","ENDCNT","BEGSEG","ENDSEG")), 
#       aes(long,lat,col=type))+geom_point()+geom_text(aes(label=transect),hjust=0, vjust=0)
##--------------------------##


##--------------------------##
# fix errors
##--------------------------##

# ---------- #  
# counts
# ---------- # 
obs$count[obs$count %in% c("1.1.f","1.2.f.adult")] = 1
obs$distance.to.obs[obs$count %in% c("1/4")] = 0.25
obs$distance.to.obs[obs$count %in% c("1.5")] = 1.5
obs$count[obs$count %in% c("1/4","1.5")] = 1
obs$count[obs$count %in% "0"] = NA
obs = filter(obs, !count %in% "")

## investigate high counts
#x = obs[as.numeric(obs$count) > 100 & !obs$type %in% c("BEGSEG","ENDSEG","BEGCNT","ENDCNT","COCH"),]
obs$distance.to.obs[obs$type %in% "BOTD" & obs$obs %in% "tpw" & obs$count %in% "200"] = 200
obs$count[obs$type %in% "BOTD" & obs$obs %in% "tpw" & obs$count %in% "200"] = 1
#rm(x)
# ---------- # 

# ---------- # 
# dates
# ---------- # 
# mdk uses 5 instead of 8
obs$month[obs$obs %in% "mdk"] = 8
obs = mutate(obs, date = as.Date(paste(month, day, year, sep="/"),format="%m/%d/%Y"),
             month = as.numeric(month), day = as.numeric(day), year = as.numeric(year))

# jfv says it's the 30th when it was flown on the 26th
obs$comment[obs$obs %in% "jfv" & obs$day %in% 30] = paste(obs$comment[obs$obs %in% "jfv" & obs$day %in% 30],
                                                          "DAY changed from 30", sep = "; ")
obs$day[obs$obs %in% "jfv" & obs$day %in% 30] = 26
# ---------- # 


# ---------- # 
# distance
# ---------- # 
# change meters to nm
obs$distance.to.obs[obs$obs %in% c("tpw","mdk")] = obs$distance.to.obs[obs$obs %in% c("tpw","mdk")] * 0.000539957
# ---------- # 


# ---------- # 
# condition
# ---------- # 
# 350100 
to.add = obs[obs$transect %in% 350100 & obs$sec %in% 39841.16,]
obs$count[obs$transect %in% 350100 & obs$sec %in% 39841.16]=4
to.add = mutate(to.add,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 332100
to.add = obs[obs$transect %in% 332100 & obs$sec %in% 39418.99,]
obs$count[obs$transect %in% 332100 & obs$sec %in% 39418.99]=4
to.add = mutate(to.add,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 330600
to.add = obs[obs$transect %in% 330600 & obs$sec %in% 62500.39,]
obs$count[obs$transect %in% 330600 & obs$sec %in% 62500.39]=3
to.add = mutate(to.add,
                condition = 4,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#325100
to.add = obs[obs$transect %in% 325100 & obs$sec %in% 57246.51,]
obs$count[obs$transect %in% 325100 & obs$sec %in% 57246.51]=5
to.add = mutate(to.add,
                condition = 4,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#324100 
to.add = obs[obs$transect %in% 324100 & obs$sec %in% 50757.27,]
obs$count[obs$transect %in% 324100 & obs$sec %in% 50757.27]=4
to.add = mutate(to.add,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#320100 
to.add = obs[obs$transect %in% 320100 & obs$sec %in% 39460.09,]
obs$count[obs$transect %in% 320100 & obs$sec %in% 39460.09]=4
to.add = mutate(to.add,
                condition = 5,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)


#293600
to.add = obs[obs$transect %in% 293600 & obs$sec %in% 45053.45,]
obs$count[obs$transect %in% 293600 & obs$sec %in% 45053.45]=4
to.add = mutate(to.add,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#302600 
to.add = obs[obs$transect %in% 302600 & obs$sec %in% 35983.72,]
obs$count[obs$transect %in% 302600 & obs$sec %in% 35983.72]=4
to.add = mutate(to.add,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 312600 
to.add = obs[obs$transect %in% 312600 & obs$sec %in% 39785.95,]
obs$count[obs$transect %in% 312600 & obs$sec %in% 39785.95]=4
to.add = mutate(to.add,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# "343600"
to.add = obs[obs$transect %in% 343600 & obs$sec %in% 59640.68,]
obs$count[obs$transect %in% 343600 & obs$sec %in% 59640.68]=2
to.add = mutate(to.add,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)


# "404601"
to.add = obs[obs$transect %in% 404601 & obs$sec %in% 29965.11,]
obs$count[obs$transect %in% 404601 & obs$sec %in% 29965.11]=5
obs$condition[obs$transect %in% 404601 & obs$sec %in% 29965.11]=5
to.add = mutate(to.add,
                count = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

to.add = obs[obs$transect %in% 404601 & obs$sec %in% 30759.10,]
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

to.add = obs[obs$transect %in% 404601 & obs$sec %in% 30680.55,]
obs$count[obs$transect %in% 404601 & obs$sec %in% 30680.55]=5
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"405602"
to.add = obs[obs$transect %in% 405602 & obs$sec %in% 33769.26,]
obs$count[obs$transect %in% 405602 & obs$sec %in% 33769.26]=3
to.add = mutate(to.add,
                count = 5,
                condition = 5,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"410601"
to.add = obs[obs$transect %in% 410601 & obs$sec %in% 38026.63,]
obs$count[obs$transect %in% 410601 & obs$sec %in% 38026.63]=4
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# "412601" 
to.add = obs[obs$transect %in% 412601 & obs$sec %in% 48016.08,]
obs$count[obs$transect %in% 412601 & obs$sec %in% 48016.08]=4
to.add = mutate(to.add,
                count = 5,
                condition = 5,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"413102" 
to.add = obs[obs$transect %in% 413102 & obs$sec %in% 45292.94 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 413102 & obs$sec %in% 45292.94 & obs$type %in% "COCH"]=5
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"413601" 
to.add = obs[obs$transect %in% 413601 & obs$sec %in% 37927.10 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 413601 & obs$sec %in% 37927.10 & obs$type %in% "COCH"]=5
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"413602" 
to.add = obs[obs$transect %in% 413602 & obs$sec %in% 38578.08 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 413602 & obs$sec %in% 38578.08 & obs$type %in% "COCH"]=3
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

to.add = obs[obs$transect %in% 413602 & obs$sec %in% 38871.09 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 413602 & obs$sec %in% 38871.09 & obs$type %in% "COCH"] = 4
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"415100" 
to.add = obs[obs$transect %in% 415100 & obs$sec %in% 33634.87 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 415100 & obs$sec %in% 33634.87 & obs$type %in% "COCH"]=4
to.add = mutate(to.add,
                count = 5,
                condition = 5,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"415601"
to.add = obs[obs$transect %in% 415601 & obs$sec %in% 32316.91 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 415601 & obs$sec %in% 32316.91 & obs$type %in% "COCH"]=5
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"420100" 
to.add = obs[obs$transect %in% 420100 & obs$sec %in% 31304.51 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 420100 & obs$sec %in% 31304.51 & obs$type %in% "COCH"]=4
to.add = mutate(to.add,
                count = 5,
                condition = 5,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"420101" 
obs$type[obs$transect %in% 420101 & obs$sec %in% 31721.47 & obs$type %in% "COCH"] = "COMMENT" 

#"424100" 
to.add = obs[obs$transect %in% 424100 & obs$sec %in% 46147.42 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 424100 & obs$sec %in% 46147.42 & obs$type %in% "COCH"]=3
to.add = mutate(to.add,
                count = 5,
                condition = 5,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

to.add = obs[obs$transect %in% 424100 & obs$sec %in% 46585.13 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 424100 & obs$sec %in% 46585.13 & obs$type %in% "COCH"] = 4
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

obs$count[obs$transect %in% 424100 & obs$sec %in% 47069.07 & obs$type %in% "COCH"] = 5
obs$offline[obs$transect %in% 424100 & obs$sec %in% 47069.07 & obs$type %in% "COCH"] = 1
obs$transect[obs$transect %in% 424100 & obs$sec %in% 47069.07 & obs$type %in% "COCH"] = NA

#"424600"
to.add = obs[obs$transect %in% 424600 & obs$sec %in% 45211.66 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 424600 & obs$sec %in% 45211.66 & obs$type %in% "COCH"] = 4
to.add = mutate(to.add,
                count = 5,
                condition = 5,
                index=index+0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"425100" 
obs$count[obs$transect %in% 425100 & obs$sec %in% 43549.45] = 3
obs$count[obs$transect %in% 425100 & obs$sec %in% 43632.28] = 4

#"430100" 
obs$count[obs$transect %in% 430100 & obs$sec %in% 42096.20] = 4
obs$count[obs$transect %in% 430100 & obs$sec %in% 42120.77] = 3

#"431100" 
to.add = obs[obs$transect %in% 431100 & obs$sec %in% 41274.03 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 431100 & obs$sec %in% 41274.03 & obs$type %in% "COCH"] = 5
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"433600" 
to.add = obs[obs$transect %in% 433600 & obs$sec %in% 46112.60 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 433600 & obs$sec %in% 46112.60 & obs$type %in% "COCH"] = 5
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#"434100"
to.add = obs[obs$transect %in% 434100 & obs$sec %in% 43170.57 & obs$type %in% "COCH",]
obs$count[obs$transect %in% 434100 & obs$sec %in% 43170.57 & obs$type %in% "COCH"] = 4
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 303600 
to.add = obs[obs$transect %in% 303600 & obs$sec %in% 38752.68 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 311600 
to.add = obs[obs$transect %in% 311600 & obs$sec %in% 36107.16 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 5,
                condition = 5,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)
to.add = obs[obs$transect %in% 311600 & obs$sec %in% 36425.16 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)
to.add = obs[obs$transect %in% 311600 & obs$sec %in% 36778.79 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)
to.add = obs[obs$transect %in% 311600 & obs$sec %in% 36971.03 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 325600
to.add = obs[obs$transect %in% 325600 & obs$sec %in% 58809.05 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)
to.add = obs[obs$transect %in% 325600 & obs$sec %in% 57726.00 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 331100 
to.add = obs[obs$transect %in% 331100 & obs$sec %in% 34472.23 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)
to.add = obs[obs$transect %in% 331100 & obs$sec %in% 35142.17 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 341100
to.add = obs[obs$transect %in% 341100 & obs$sec %in% 43746.21 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)
to.add = obs[obs$transect %in% 341100  & obs$sec %in% 43219.85 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

# 351101
to.add = obs[obs$transect %in% 351101 & obs$sec %in% 43492.25 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 4,
                condition = 4,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)
to.add = obs[obs$transect %in% 351101  & obs$sec %in% 43400.56 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)

#425100
to.add = obs[obs$transect %in% 425100 & obs$sec %in% 43549.45 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 5,
                condition = 5,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)
to.add = obs[obs$transect %in% 425100  & obs$sec %in% 43632.28 & obs$type %in% "COCH",]
to.add = mutate(to.add,
                count = 3,
                condition = 3,
                index=index-0.1,
                dataChange = "Added COCH based on other COCH")
obs = rbind(obs,to.add)
rm(to.add)


# change mtj condition codes since they are wrong after all COCHs
# fix remaining errors before filling in the NAs
obs$dataChange[obs$obs %in% 'mtj' & obs$type %in% 'BEGCNT' & obs$transect %in% 305600] = "Change CONDITION from 3"
obs$condition[obs$obs %in% 'mtj' & obs$type %in% 'BEGCNT' & obs$transect %in% 305600] = 4

obs$condition[obs$obs %in% 'mtj' & !obs$type %in% c('BEGCNT')] = NA
obs$condition[obs$obs %in% 'mtj' & obs$type %in% c('COCH')] = obs$count[obs$obs %in% 'mtj' & obs$type %in% c('COCH')]
obs = arrange(obs,obs,transect,sec,index)
obs$condition[obs$obs %in% 'mtj'] = na.locf(obs$condition[obs$obs %in% 'mtj'] )
# ---------- # 


# ---------- # 
# offline
# ---------- # 
obs$offline[is.na(obs$transect) & 
              obs$comment %in% c("counting on transit leg","counting on transit transect","transit transect") & 
              obs$offline %in% 0] = 1

# fix offline for tpw
obs$type[obs$obs %in% 'tpw' & obs$transect %in% 0 & obs$type %in% c('BEGCNT','ENDCNT')] = 'COMMENT'
obs$transect[obs$obs %in% 'tpw' & obs$transect %in% 0] = NA
obs$offline[obs$obs %in% 'tpw' & is.na(obs$transect)] = 1

# there are others who listed offline BEG and END records which screw up some things later on
obs$type[obs$offline %in% 1 & obs$type %in% c('BEGCNT','ENDCNT')] = 'COMMENT'
# ---------- #

message("Fixed other errors")
##--------------------------##

# STILL NEED TO ADDRESS
#(missing COUNT for 6 non-offline observations)
#(there are 9 observations with count >= 10,000)

#x = obs[is.na(obs$count),] #checked is OK

# errors
#x = obs[obs$transect %in% 381100,]
#x = obs[obs$transect %in% 365100,]
#x = obs[obs$transect %in% 365101,]
# 26 Aug did not record break between these two transects			
# 365100  no BEG for either
# NEED TO ADDRESS
# 365101  no END for either
#371601		24 Aug circled to look at debris, no lost distance	
# Note: Called the end of 415101 about 1/2 mile late.
# missing transects (NAs)
# tpw 434100
# tpw 433600
# tpw 430600
# tpw 424100 add Beg?
# tpw 8/24 40522.50: 40610.21 -> all off transect counts by mdk times. 414101 ends at 40522.35
# twp 412101


