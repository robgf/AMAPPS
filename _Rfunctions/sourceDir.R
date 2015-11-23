# ---------------------------------------------------------------------------- #
# This program (function) sources all the ".R" or ".r" files within a 
# specified directory.
#
# Program Name: sourceDir.R
# Date Created: 10/25/2012
# Author: JBL
# ---------------------------------------------------------------------------- #

sourceDir <- function(path, trace = TRUE) {
  for (nm in list.files(path, pattern = "\\.[Rr]$")) {
    if (trace) cat(nm, ":")
    source(file.path(path, nm))
    if (trace) cat("\n")
  }
}
