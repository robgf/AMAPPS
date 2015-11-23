# ---------------------------------------------------------------------------- #
# runArcGISpy.R
# Date Created: 2014-06-20
# Author: JBL
#
# Description: This function runs the specific python code file in ArcGIS 
# from within R.
# ---------------------------------------------------------------------------- #

runArcGISpy <- function(pyfile) {
  cmd <- paste('"C:/Python27/ArcGIS10.1/python.exe"', '"PythonFilePath"')
  system(gsub("PythonFilePath", pyfile, cmd))
}
