# ------------------------------- #
# Fix errors in VOWTAP data
# --------------------------------#

# --------------------------------#
# change common names to species codes
code <- odbcConnectExcel2007(xls.file = paste(speciesPath, "NWASC_codes.xlsx", sep=""))
spplist <- sqlFetch(code, "codes")$spp_cd
common_nm <- sqlFetch(code, "codes")$common_nm
odbcClose(code)
rm(code)

obs$dataChange=""
obs$dataChange = paste("; Changed TYPE from ", obs$type, sep="")

common_nm = tolower(common_nm)
obs$type = tolower(obs$type)
obs$type = gsub("\\s", "", obs$type)
common_nm = gsub("\\s", "", common_nm)
obs$type = gsub("'", "", obs$type)
common_nm = gsub("'", "", common_nm)
obs$type = gsub("-", "", obs$type)
common_nm = gsub("-", "", common_nm)

ind = unique(obs$type)
ind = cbind((common_nm[common_nm %in% ind]), as.character(spplist[common_nm %in% ind]))
colnames(ind) = c("nm","spp")
ind = as.data.frame(ind) 

out = apply(obs, 1, function(x) if(x[3] %in% ind$nm) {x=as.character(ind$spp[ind$nm==x[3]])})
obs$type[which(out!="NULL")] = out[which(out!="NULL")]
rm(ind, out)

# other species
obs$type[obs$type %in% c("darkwingedscoter","darkwingedscotersp.")] = "DASC"
obs$type[obs$type=="gullspecies"] = "UNGU"
obs$type[obs$type=="littleblackbackedgull"] = "LBBG"
obs$type[obs$type=="peregrinefalcom"] = "PEFA"
obs$type[obs$type=="unidentifiedshorebirdsp."] = "SHOR"
# --------------------------------#
