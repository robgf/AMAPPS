# ---------------------------------------------------------------------------
# CalcObsCovariates.py
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
  sdpath = "M:/Sea Duck Survey"
else:
  sdpath = "C:/Users/JLeirness/Documents/FWS/Sea Duck Survey"

# Check out any necessary licenses
arcpy.CheckOutExtension("spatial")


# Bathymetry raster file
DepthFile = sdpath + "/DataBase/Editing_Database.gdb/AtlanticCoast_Bathymetry"

# Slope raster file
SlopeFile = sdpath + "/DataBase/Editing_Database.gdb/AtlanticCoast_Slope"

# Observation file
ObsFile = sdpath + "/Jeff_Working_Folder/DataProcessing/temp/temp_Observations.dbf"

# Observation file layer
ObsFileLayer = "ObsFile_Layer"

# Output file
OutFile = sdpath + "/Jeff_Working_Folder/DataProcessing/temp/temp_ObsCovariates.shp"


# Process: Make XY Event Layer
arcpy.MakeXYEventLayer_management(ObsFile, "Long", "Lat", ObsFileLayer, arcpy.SpatialReference(4326))

# Process: Project
arcpy.Project_management(ObsFileLayer, OutFile, arcpy.SpatialReference(102003))

# Process: Near
arcpy.Near_analysis(OutFile, sdpath + "/DataBase/Editing_Database.gdb/Covariate_Files/AtlanticCoastline")

# Process: Extract Multi Values to Points
arcpy.gp.ExtractMultiValuesToPoints_sa(OutFile, "'" + DepthFile + "' Depth; '" + SlopeFile + "' Slope")

