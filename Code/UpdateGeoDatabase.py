# ---------------------------------------------------------------------------
# UpdateGeoDatabase.py
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


# Observation file
ObsFile = sdpath + "Jeff_Working_Folder/DataProcessing/temp/Database_Observations.dbf"
ObsFileLayer = "ObsFile_Layer"

# Track file
TrackFile = sdpath + "Jeff_Working_Folder/DataProcessing/temp/Database_Tracks.dbf"
TrackFileLayer = "TrackFile_Layer"

# Distance flown file
TransInfo = sdpath + "Jeff_Working_Folder/DataProcessing/temp/Database_Transect_Information.dbf"

# Distance flown file
DistFlown = sdpath + "Jeff_Working_Folder/DataProcessing/temp/temp_DistFlown.shp"

# Output files
ObsFileTempOut = sdpath + "DataBase/Atlantic_Coast_Surveys.gdb/temp_Observations"
ObsFileOut = sdpath + "DataBase/Atlantic_Coast_Surveys.gdb/Observations"
TrackFileTempOut = sdpath + "DataBase/Atlantic_Coast_Surveys.gdb/temp_Tracks"
TrackFileOut = sdpath + "DataBase/Atlantic_Coast_Surveys.gdb/Tracks"
TransInfoTempOut = sdpath + "DataBase/Atlantic_Coast_Surveys.gdb/temp_Transect_Information"
TransInfoTempOut2 = sdpath + "DataBase/Atlantic_Coast_Surveys.gdb/temp_Transect_Information2"
TransInfoOut = sdpath + "DataBase/Atlantic_Coast_Surveys.gdb/Transect_Information"


# Process: Make XY Event Layer
arcpy.MakeXYEventLayer_management(ObsFile, "Long", "Lat", ObsFileLayer, arcpy.SpatialReference(4326))
arcpy.MakeXYEventLayer_management(TrackFile, "Long", "Lat", TrackFileLayer, arcpy.SpatialReference(4326))

# Process: Project
arcpy.Project_management(ObsFileLayer, ObsFileTempOut, arcpy.SpatialReference(102003))
arcpy.Project_management(TrackFileLayer, TrackFileTempOut, arcpy.SpatialReference(102003))

# Process: Sort
arcpy.Sort_management(ObsFileTempOut, ObsFileOut, "SurveyNbr ASCENDING;Transect ASCENDING;Replicate ASCENDING;Crew ASCENDING;Seat ASCENDING;Obs ASCENDING;Year ASCENDING;Month ASCENDING;Day ASCENDING;Sec ASCENDING", "UR")
arcpy.Sort_management(TrackFileTempOut, TrackFileOut, "SurveyNbr ASCENDING;Transect ASCENDING;Replicate ASCENDING;Crew ASCENDING;Seat ASCENDING;Obs ASCENDING;Year ASCENDING;Month ASCENDING;Day ASCENDING;Sec ASCENDING", "UR")


# Process: Join Field
arcpy.JoinField_management(DistFlown, "GIS_ID2", TransInfo, "GIS_ID2", "SurveyNbr;Transect;Replicate;Crew;Seat;Obs;StartDt;EndDt;DistFlown;AvgConditi;ACWSD;ACWSDrepor;WindArea;MissingTra;ImputedDis")

# Process: Sort
arcpy.Sort_management(DistFlown, TransInfoTempOut, "SurveyNbr ASCENDING;Transect ASCENDING;Replicate ASCENDING;Crew ASCENDING;Seat ASCENDING;Obs ASCENDING", "UR")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "StartDt2", "DATE")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "StartDt2", "[StartDt]", "VB")

# Process: Delete Field
arcpy.DeleteField_management(TransInfoTempOut, "StartDt")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "StartDt", "DATE")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "StartDt", "[StartDt2]", "VB")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "EndDt2", "DATE")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "EndDt2", "[EndDt]", "VB")

# Process: Delete Field
arcpy.DeleteField_management(TransInfoTempOut, "EndDt")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "EndDt", "DATE")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "EndDt", "[EndDt2]", "VB")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "DistFlown2", "DOUBLE")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "DistFlown2", "[DistFlown]", "VB")

# Process: Delete Field
arcpy.DeleteField_management(TransInfoTempOut, "DistFlown")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "DistFlown", "DOUBLE")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "DistFlown", "[DistFlown2]", "VB")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "AvgCondition", "DOUBLE")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "AvgCondition", "[AvgConditi]", "VB")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "ACWSD2", "LONG")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "ACWSD2", "[ACWSD]", "VB")

# Process: Delete Field
arcpy.DeleteField_management(TransInfoTempOut, "ACWSD")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "ACWSD", "LONG")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "ACWSD", "[ACWSD2]", "VB")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "ACWSDreport", "LONG")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "ACWSDreport", "[ACWSDrepor]", "VB")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "WindArea2", "LONG")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "WindArea2", "[WindArea]", "VB")

# Process: Delete Field
arcpy.DeleteField_management(TransInfoTempOut, "WindArea")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "WindArea", "LONG")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "WindArea", "[WindArea2]", "VB")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "MissingTrackFile", "LONG")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "MissingTrackFile", "[MissingTra]", "VB")

# Process: Add Field
arcpy.AddField_management(TransInfoTempOut, "ImputedDistFlown", "LONG")

# Process: Calculate Field
arcpy.CalculateField_management(TransInfoTempOut, "ImputedDistFlown", "[ImputedDis]", "VB")

# Process: Delete Field
arcpy.DeleteField_management(TransInfoTempOut, "GIS_ID2;SUM_DistFl;StartDt2;EndDt2;DistFlown2;AvgConditi;ACWSD2;ACWSDrepor;WindArea2;MissingTra;ImputedDis")

# Process: Sort
arcpy.Sort_management(TransInfoTempOut, TransInfoTempOut2, "SurveyNbr ASCENDING;Transect ASCENDING;Replicate ASCENDING;Crew ASCENDING;Seat ASCENDING;Obs ASCENDING", "UR")

# Process: Append
arcpy.Append_management(TransInfoTempOut2, TransInfoOut, "TEST", "", "")

# Process: Sort
arcpy.Sort_management(TransInfoOut, TransInfoTempOut, "SurveyNbr ASCENDING;Transect ASCENDING;Replicate ASCENDING;Crew ASCENDING;Seat ASCENDING;Obs ASCENDING", "UR")

# Process: Sort
arcpy.Sort_management(TransInfoTempOut, TransInfoOut, "SurveyNbr ASCENDING;Transect ASCENDING;Replicate ASCENDING;Crew ASCENDING;Seat ASCENDING;Obs ASCENDING", "UR")


# Process: Delete
arcpy.Delete_management(ObsFileTempOut)

# Process: Delete
arcpy.Delete_management(TrackFileTempOut)

# Process: Delete
arcpy.Delete_management(TransInfoTempOut)

# Process: Delete
arcpy.Delete_management(TransInfoTempOut2)

