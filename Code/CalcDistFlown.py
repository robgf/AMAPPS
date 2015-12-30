# ---------------------------------------------------------------------------
# CalcDistFlown.py
# Date Created: 2013-07-23
# Author: JBL
#
# Description: 
# ---------------------------------------------------------------------------

# Import arcpy module
import arcpy

# Allow ArcGIS to overwrite existing files
arcpy.env.overwriteOutput = True

# CHECK WHICH COMPUTER: LAPTOP OR FWS DESKTOP
if arcpy.Exists("M:"):
  cpu = "work"
else:
  cpu = "home"

# SET PATH TO SEA DUCK SURVEY DIRECTORY
if cpu == "work":
  sdpath = "M:/Sea Duck Survey/"
else:
  sdpath = "C:/Users/JLeirness/Documents/FWS/Sea Duck Survey/"


# Track file
Tracks = sdpath + "Jeff_Working_Folder/DataProcessing/temp/temp_Tracks4DistFlown.dbf"

# Track file layer
TracksLayer = "Tracks_Layer"

# Output files
OutFile1 = sdpath + "Jeff_Working_Folder/DataProcessing/temp/temp_DistFlown1.shp"
OutFile2 = sdpath + "Jeff_Working_Folder/DataProcessing/temp/temp_DistFlown4AvgCondition.shp"
OutFile3 = sdpath + "Jeff_Working_Folder/DataProcessing/temp/temp_DistFlown.shp"


# Process: Make XY Event Layer
arcpy.MakeXYEventLayer_management(Tracks, "Long", "Lat", TracksLayer, arcpy.SpatialReference(4326))

# Process: Project
arcpy.Project_management(TracksLayer, OutFile1, arcpy.SpatialReference(102003))

# Process: Points To Line
arcpy.PointsToLine_management(OutFile1, OutFile2, "GIS_ID", "index")

# Process: Add Field
arcpy.AddField_management(OutFile2, "GIS_ID2", "TEXT")

# Process: Calculate Field
arcpy.CalculateField_management(OutFile2, "GIS_ID2", "!GIS_ID!.split(\"_\")[0] + \"_\" + !GIS_ID!.split(\"_\")[1] + \"_\" + !GIS_ID!.split(\"_\")[2] + \"_\" + !GIS_ID!.split(\"_\")[3] + \"_\" + !GIS_ID!.split(\"_\")[4]", "PYTHON_9.3")

# Process: Add Field
arcpy.AddField_management(OutFile2, "DistFlown", "FLOAT")

# Process: Calculate Field
arcpy.CalculateField_management(OutFile2, "DistFlown", "!shape.length@nauticalmiles!", "PYTHON_9.3")

# Process: Dissolve
arcpy.Dissolve_management(OutFile2, OutFile3, "GIS_ID2", "DistFlown SUM", "MULTI_PART", "DISSOLVE_LINES")

# Process: Delete
arcpy.Delete_management(OutFile1)

