# ------------------------------------------ #
# Fix errors in observation files
# ------------------------------------------ #

# comments
obs$type=toupper(obs$type)
obs$type[obs$type %in% c("FRONT","COMMET","COMMNET")]="COMMENT"
comments = obs[obs$type=="COMMENT",] #remove comments into separate file
obs = obs[obs$type!="COMMENT",]
comments=rbind(comments,obs[obs$type=="",])
obs = obs[obs$type!="",]
# fix comments that can be added to data, then cut comments out
comments$type[grep("balloon",comments$comment)]="BALN"
comments$type[grep("sagrassum",comments$comment)]="SARG"
comments$type[grep("oil",comments$comment)]="FUEL"
comments$type[grep("rockweed",comments$comment)]="RCKW"
comments$type[grep("fishing vessel",comments$comment)]="BOFI"
comments$type[grep("forage fish",comments$comment)]="BAIT"
tmp=!comments$type %in% "COMMENT"
to.add=comments[tmp,]
to.add$dataChange=paste(to.add$dataChange, "; Changed TYPE from comment", sep="")
to.add$behavior=""
obs=rbind(obs,to.add, fill=TRUE)

write.csv(comments, file=paste(dir.out,"comments.csv",sep="/"), row.names=FALSE)
rm(to.add,comments)

# observer
obs$observer=toupper(obs$observer)

# position/ seat
obs$position=tolower(obs$position)
names(obs)[names(obs)=="position"] <- "seat"
obs$seat[obs$seat %in% c("bl","lb")]="lr"
obs$seat[obs$seat %in% c("rb","right","br")]="rr"
obs$seat[obs$observer=="BCH" & obs$survey_num=="sur31"]="rr"
obs$seat[obs$seat == "co pilot"] = "rf"

# offline
obs$offline=tolower(obs$offline)

# species/ type
# DataChange comments for spp_cd errors
changes = c("TRAWL","TRAWLER","DRAGGER","DOLPHIN","DOLPHINS","GPS","TANKER","CARGOSHIP","ROCKWEED",
            "SEAL","SHARK","TURTLE","MARINEMAMMAL","LOON","BALLOON","WHALE", "ALCD",
            "SUNFISH","DUCK","BASK","GULL","PASS","SCOT","UNTU","FIBO","SHIP","COMP",
            "BRANT","DDCO","JASP","LBTU","OLD","STTE","ULGU","ULSH","TRANSBEGCNT","TRANSENDCNT",
            "CALANUS","GRAYSEAL","NOFA","SARGASSUM","STARTRANSIT","TRSW","ULWH")
for (a in 1:length(changes)) {
  obs$dataChange[which(obs$type == changes[a])] = 
    paste(obs$dataChange[which(obs$type == changes[a])],
          "; Changed TYPE from ", changes[a], sep ="") 
}
rm(changes, a)

obs$type[obs$type == "STARTRANSIT"]="BEGSEG" ####
obs$type[obs$type == "TRANSBEGCNT"]="BEGCNT"
obs$type[obs$type == "TRANSENDCNT"]="ENDCNT"
obs$type[obs$type == "SARGASSUM"] ="SARG"
obs$type[obs$type == "GRAYSEAL"] ="GRSE"
obs$type[obs$type == "CALANUS"] ="ZOOP"
obs$type[obs$type %in% c("TRAWL","TRAWLER","DRAGGER")]="BOTD" # change dragger to boat trawler or dragger code
obs$type[obs$type %in% c("DOLPHIN","DOLPHINS")]="UNDO"
obs$type[obs$type %in% c("GPS","COMP")]="WAYPNT"
obs$type[obs$type == "TANKER"]="BOTA"
obs$type[obs$type == "CARGOSHIP"]="BOCA"
obs$type[obs$type == "ROCKWEED"]="RCKW"
obs$type[obs$type == "BALLOON"]="BALN"
obs$type[obs$type == "MARINEMAMMAL"]="UNMM"
obs$type[obs$type == "SEAL"]="UNSE"
obs$type[obs$type == "SHARK"]="SHAR"
obs$type[obs$type == "TURTLE"]="TURT"
obs$type[obs$type == "WHALE"]="UNWH"
obs$type[obs$type == "SUNFISH"]="MOLA"
obs$type[obs$type == "LOON"]="UNLO"
obs$type[obs$type == "DUCK"]="UNDU"
obs$type[obs$type == "ALCD"]="UNAL"
obs$type[obs$type == "BASK"]="BASH"
obs$type[obs$type == "GULL"]="UNGU"
obs$type[obs$type == "PASS"]="UNPA"
obs$type[obs$type == "SCOT"]="UNSC"
obs$type[obs$type == "UNTU"]="TURT"
obs$type[obs$type == "FIBO"]="BOFI"
obs$type[obs$type == "BKLI"]="BLKI"
obs$type[obs$type == "DWSC"]="DASC"
obs$type[obs$type == "RLTO"]="RTLO"
obs$type[obs$type %in% c("OLDS","OLD")]="LTDU"
obs$type[obs$type == "BRANT"]="BRAN"
obs$type[obs$type == "STTE"]="UNTE"
obs$type[obs$type == "LBTU"]="LETU"
obs$type[obs$type == "DDCO"]="DCCO"
obs$type[obs$type == "JASP"]="UNJA"
obs$type[obs$type == "ULGU"]="UNLG"
obs$type[obs$type == "ULSH"]="UNLS"

# time
names(obs)[names(obs)=="time"] <- "sec"

# condition
names(obs)[names(obs)=="conditions"] <- "condition"

# survey
obs$survey_num = gsub(" ","",obs$survey_num)

# behvaior
obs$behavior=tolower(obs$behavior)
obs$behavior[obs$behavior=="flyin"] = "flying"

# year, month, day
obs$month[obs$month=="july"] = 7
obs$year[obs$year=="2104"]="2014"
obs$month = as.numeric(as.character(obs$month))
obs$year = as.numeric(as.character(obs$year))
obs$day = as.numeric(as.character(obs$day))

# comments
names(obs)[names(obs)=="comments"] <- "comment"

# comments
names(obs)[names(obs)=="number"] <- "count"



