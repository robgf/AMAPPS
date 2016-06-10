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

# position
obs$position=tolower(obs$position)
names(obs)[names(obs)=="position"] <- "seat"
obs$seat[obs$seat=="bl"]="lr"
obs$seat[obs$seat=="lb"]="lr"
obs$seat[obs$seat=="rb"]="rr"
obs$seat[obs$seat=="br"]="rr"
obs$seat[obs$seat=="gps"]=""
obs$dataChange[obs$seat=="hull"]=paste(obs$dataChange[obs$seat=="hull"],"; Changed SEAT from HULL",sep="")
obs$dataChange[obs$seat=="comp"]=paste(obs$dataChange[obs$seat=="comp"],"; Changed SEAT from COMP",sep="")
obs$seat[obs$observer %in% c("GPS","COMP")]=""
obs$seat[obs$seat %in% "comp"]=""


# offline
obs$offline=tolower(obs$offline)

# species
# DataChange comments for spp_cd errors
changes = c("TRAWL","DRAGGER","DOLPHIN","DOLPHINS","GPS","TANKER","CARGOSHIP","ROCKWEED",
            "SEAL","SHARK","TURTLE","MARINEMAMMAL","LOON","BALLOON","WHALE", "ALCD",
            "SUNFISH","DUCK","BASK","GULL","PASS","SCOT","UNTU","FIBO","SHIP","COMP")
for (a in 1:length(changes)) {
  obs$dataChange[which(obs$type == changes[a])] = 
    paste(obs$dataChange[which(obs$type == changes[a])],
          "; Changed TYPE from ", changes[a], sep ="") 
}
rm(changes, a)

obs$type[obs$type %in% c("TRAWL","DRAGGER")]="BOTD" # change dragger to boat trawler or dragger code
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
obs$type[obs$type == "OLDS"]="LTDU"

# changed from SHIP
obs$type[grep("cargo",obs$behavior)] = "BOCA" #changed from SHIP
obs$type[grep("tanker",obs$behavior)] = "BOTA"
obs$type[grep("fishing800m",obs$behavior)] = "BOFI"
obs$type[obs$type=="SHIP"] = "BOCF" 

# time
names(obs)[names(obs)=="time"] <- "sec"

# condition
names(obs)[names(obs)=="conditions"] <- "condition"

# survey
obs$survey_num = gsub(" ","",obs$survey_num)

# count (round about way since some counts had decimal points that read as non-digit when a character)
names(obs)[names(obs)=="number"] <- "count"
#obs$count[obs$count=="I"]="1"
obs$count[grep("2SWIMMINGUNKMARINEMAMMAL",obs$behavior)]="2"
tmp <- gsub("[[:digit:]]","",obs$count) #letters
words <- unlist(tmp)
obs$behavior[nchar(words)>1]=words[nchar(words)>1]
tmp2 <- gsub("[^[:digit:]]","",obs$count) #numbers
new.count <- as.numeric(unlist(tmp2))
obs$count=as.numeric(obs$count)
obs$count[is.na(obs$count)]=new.count[is.na(obs$count)] #replace with the counts broken from behavior
obs$count[is.na(obs$count)] = 0
rm(tmp, tmp2, words, new.count)
obs$count[obs$type %in% c("GPS","WAYPNT","BEGCNT","ENDCNT")] = 0


# behvaior
obs$behavior=tolower(obs$behavior)
obs$behavior[obs$behavior=="flyin"] = "flying"

