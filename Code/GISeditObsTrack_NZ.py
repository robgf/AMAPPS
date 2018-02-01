# Import arcpy module"                                                                                                   
import arcpy, os, string                                                                                                
                                                                                                                     
# Allow ArcGIS to overwrite existing files                                                                              
arcpy.env.overwriteOutput = True                                                                                        
                                                                                                                    
def EditObsTracks(TrackInput, OutputLocation):                                                                          
TemplatePath = \"//IFW9mbm-fs1/MB SeaDuck/AMAPPS/amapps_gis/\"                           
                                                                                                                  
# Get map document template                                                                                         
mxd = arcpy.mapping.MapDocument(TemplatePath + \"GISeditObsTrack_template.mxd\")                                    
                                                                                                                   
# Loop through 'key' variable                                                                                       
allkeys = set()                                                                                                     
keys = arcpy.SearchCursor(TrackInput)                                                                               
for i in keys:                                                                                                      
allkeys.add(i.getValue(\"key\"))                                                                                  
                                                                                                                     
# Output shapefile for each 'key' value                                                                             
for i in allkeys:                                                                                                   
print str(i)                                                                                                      
sqlSelect = \"\\\"key\\\" = '\" + str(i) + \"'\"                                                                  
arcpy.Select_analysis(TrackInput, TemplatePath + \"TempShapefiles/temp_obsTrack_\" + str(i) + \".shp\", sqlSelect)
templayer = arcpy.mapping.Layer(TemplatePath + \"TempShapefiles/temp_obsTrack_\" + str(i) + \".shp\")             
                                                                                                                 
sourcelayer = arcpy.mapping.Layer(TemplatePath + \"GISeditObsTrack_symbology.lyr\")                               
arcpy.mapping.UpdateLayer(arcpy.mapping.ListDataFrames(mxd)[0], templayer, sourcelayer, True)                     
arcpy.mapping.AddLayer(arcpy.mapping.ListDataFrames(mxd)[0], templayer)                                           

# Save map document                                                                                                 
mxd.saveACopy(OutputLocation + \"GISeditObsTrack.mxd\")                                                             
return None   
