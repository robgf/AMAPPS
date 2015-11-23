# ---------------------------------------------------------------------------- #
# This program (function) combines data frames (like rbind) but by matching 
# column names. Columns without matches in the other data frame are still 
# combined but with NA in the rows corresponding to the data frame without 
# the variable. A warning is issued if there is a type mismatch between 
# columns of the same name and an attempt is made to combine the columns.
#
# Program Name: combineByName.R
# Date Created: 09/19/2011
# Author: JBL
# ---------------------------------------------------------------------------- #

combineByName <- function(A, B) {

  a.names <- names(A)
  b.names <- names(B)
  all.names <- union(a.names, b.names)

  a.type <- sapply(A, typeof)
  b.type <- sapply(B, typeof)
  a_b.names <- names(A)[!names(A) %in% names(B)]
  b_a.names <- names(B)[!names(B) %in% names(A)]

  out <- list()
  for (i in seq(along = all.names)) {
    l.a <- all.names[i] %in% a.names
    pos.a <- match(all.names[i], a.names)
    typ.a <- a.type[pos.a]
    l.b <- all.names[i] %in% b.names
    pos.b <- match(all.names[i], b.names)
    typ.b <- b.type[pos.b]
    if (l.a & l.b) {
      if (typ.a == typ.b) {
        vec <- c(A[, pos.a], B[, pos.b])
      } else {
        warning(c("Type mismatch in variable named: ", all.names[i], "\n"))
        vec <- try(c(A[, pos.a], B[, pos.b]))
      }
    } else if (l.a) {
      vec <- c(A[, pos.a], rep(NA, nrow(B)))
    } else {
      vec <- c(rep(NA, nrow(A)), B[, pos.b])
    }
    out[[i]] <- vec
  }
  names(out) <- all.names
  out <- data.frame(out, stringsAsFactors = FALSE)
  
  return(out)

}
