# ---------------------------------------------------------------------------
# GISeditObsTracks.py
# Date Created: 2014-10-17
# Author: JBL
#
# Description: 
# ---------------------------------------------------------------------------

# Import arcpy module
import arcpy

# Allow ArcGIS to overwrite existing files
arcpy.env.overwriteOutput = True

# SET PATH TO SEA DUCK SURVEY DIRECTORY
sdpath = "P:/USFWS/"

# SET PATH TO DATA PROCESSING GIS FOLDER
path = sdpath + "Jeff_Working_Folder/DataProcessing/GIS/"

# SET PATH TO MAP TEMPLATE
mtemplate = path + "GISeditObsTrack_template.mxd"

# SET PATH TO PROJECT FOLDER
projpath = path

# Input files
obsTrack = projpath + "temp_shapefiles/temp_obsTrack.shp"


# Get map document template
mxd = arcpy.mapping.MapDocument(mtemplate)

# Loop through 'key' variable
allkeys = set()
keys = arcpy.SearchCursor(obsTrack)
for i in keys:
  allkeys.add(i.getValue("key"))

# Output shapefile for each 'key' value
for i in allkeys:
  sqlSelect = "\"key\" = '" + str(i) + "'"
  arcpy.Select_analysis(obsTrack, projpath + "temp_shapefiles/temp_obsTrack_" + str(i) + ".shp", sqlSelect)
  templayer = arcpy.mapping.Layer(projpath + "temp_shapefiles/temp_obsTrack_" + str(i) + ".shp")
  sourcelayer = arcpy.mapping.Layer(path + "GISeditObsTrack_symbology.lyr")
  arcpy.mapping.UpdateLayer(arcpy.mapping.ListDataFrames(mxd)[0], templayer, sourcelayer, True)
  arcpy.mapping.AddLayer(arcpy.mapping.ListDataFrames(mxd)[0], templayer)

# Save map document
mxd.saveACopy(projpath + "GISeditObsTrack.mxd")
