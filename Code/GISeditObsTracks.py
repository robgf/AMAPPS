# ---------------------------------------------------------------------------
# GISeditObsTracks.py
# Date Created: 2014-10-17
# Author: JBL
#
# updated by K. Coleman, Jan. 2018
#
# Description: This file takes the shapefiles with the observations and the tracks
# and color codes the errors as well as the transects for visual inspection in ArcGIS
# ---------------------------------------------------------------------------

# Import arcpy module
import arcpy, os, string     

# Allow ArcGIS to overwrite existing files
arcpy.env.overwriteOutput = True

# SET PATH TO PROJECT FOLDER
projpath = "//ifw-hqfs1/MB SeaDuck/AMAPPS/clean_data/AMAPPS_2017_08/"

# Input files
obsTrack = projpath + "temp_shapefiles/temp_obsTrack.shp"

# Get map document template
gispath = "//ifw-hqfs1/MB SeaDuck/AMAPPS/amapps_gis/"
mxdpath = os.path.join(gispath,"GISeditObsTrack_template.mxd")
mxd = arcpy.mapping.MapDocument(mxdpath)

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
  
  lyrpath = os.path.join(gispath,"GISeditObsTrack_symbology.lyr")
  sourcelayer = arcpy.mapping.Layer(lyrpath)
  arcpy.mapping.UpdateLayer(arcpy.mapping.ListDataFrames(mxd)[0], templayer, sourcelayer, True)
  arcpy.mapping.AddLayer(arcpy.mapping.ListDataFrames(mxd)[0], templayer)

# Save map document
mxd.saveACopy(projpath + "temp_shapefiles/GISeditObsTrack.mxd")
