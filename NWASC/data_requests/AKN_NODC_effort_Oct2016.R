# --------------- #
# Data requested by Fayvor and Leo from AKN
# needed effort to go with downloaded observations from NODC website
# 
# Load last archived transect export (track)
# remove share level 1 data
#
# created by Kaycee Coleman
# Oct. 28, 2016
# --------------- #


# --------------- #
# LOAD PACKAGES
# --------------- #
require(rgdal)
# --------------- #


# --------------- #
# SET INPUT/OUTPUT DIRECTORY PATHS
# --------------- #
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/seabird_database_export/archive/"
dir.out = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_sent/AKN_Fayvor_and_Leo/"
setwd(dir)
# --------------- #


# --------------- #
# load data
# --------------- #
## The input file geodatabase
fgdb = file.path(dir, "seabird_database_export_boem_15July2014.gdb")

## List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list = ogrListLayers(fgdb)
print(fc_list)

## Read the feature class
#obs = readOGR(dsn = fgdb,layer = "observations")
transect_lines = readOGR(dsn = fgdb,layer = "transect_lines")   
transect_points = readOGR(dsn = fgdb,layer = "transect_points") 


## make data.frame
# points has different datasets in it than lines
transect_points = as.data.frame(transect_points) 
tl = as(transect_lines, "SpatialPointsDataFrame")
transect_lines = as.data.frame(tl)


# to remove from lines (share level = 1)
to.remove = c("DOEBRIBoatApr2014","DOEBRIBoatApril2012","DOEBRIBoatAug2012",
              "DOEBRIBoatAug2013","DOEBRIBoatDec2012","DOEBRIBoatDec2013",
              "DOEBRIBoatJan2013","DOEBRIBoatJan2014","DOEBRIBoatJune2012",
              "DOEBRIBoatJune2013","DOEBRIBoatMar2013","DOEBRIBoatMay2013",
              "DOEBRIBoatNov2012","DOEBRIBoatOct2013","DOEBRIBoatSep2012",
              "DOEBRIBoatSep2013","WHOIJuly2010","WHOISept2010")
transect_lines = transect_lines[!transect_lines$source_dataset_id %in% to.remove,]

## export as csvs
write.csv(transect_points, file=paste(dir.out,"NWASC_archive_transect_points.csv",sep="/"), row.names = FALSE)
write.csv(transect_lines, file=paste(dir.out,"NWASC_archive_transect_lines.csv",sep="/"), row.names = FALSE)
