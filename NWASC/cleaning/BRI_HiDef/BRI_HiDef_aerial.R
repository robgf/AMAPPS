require(rgdal)

path = "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received/BRI_DOE_HiDef"

# The input file geodatabase
fgdb = file.path(path, "BRI_DOE_Hidef_aerialSurveys_final.gdb")

# List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list = ogrListLayers(fgdb)
print(fc_list)

# Read the feature class
obs = readOGR(dsn = fgdb,layer = "BRI_DOE_hidef_obs_final")
stripey = readOGR(dsn = fgdb,layer = "BRI_DOE_hidef_stripey_final")   
trans = readOGR(dsn = fgdb,layer = "BRI_DOE_hidef_transects_final")

# Determine the Featured Class extent, projection, and attribute information
summary(obs)
summary(stripey)
summary(trans)

# View the feature class
plot(obs)
plot(stripey)
plot(trans)
