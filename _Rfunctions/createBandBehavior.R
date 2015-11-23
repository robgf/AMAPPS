# ---------------------------------------------------------------------------- #
# createBandBehavior.R
# Author: Jeffery Leirness
# Date Created: 2014-12-31
#
# Description: 
# ---------------------------------------------------------------------------- #

cleanCommentField <- function(x) {
  x <- gsub(",+", ",", x)  # remove multiple commas
  x <- gsub("^ *|(?<= ) | *$", "", x, perl = TRUE)  # remove multple spaces
  x <- gsub("\\s+,", ",", x)  # remove spaces before commas
  x <- gsub("^,|,$", "", x)  # remove leading and trailing commas
  x <- gsub("^\\s+|\\s+$", "", x)  # remove leading and trailing spaces
  x
}

createBandBehavior <- function(dat) {
  dat$comment <- cleanCommentField(dat$comment)
  
  # CREATE BAND COLUMN
  dat$band <- numeric(nrow(dat))
  tmp <- grep("^[0-3],", dat$comment)
  dat$band[tmp] <- as.numeric(substr(dat$comment[tmp], 1, 1))
  dat$comment[tmp] <- substr(dat$comment[tmp], 2, nchar(dat$comment[tmp]))
  dat$comment <- cleanCommentField(dat$comment)
  
  # CREATE BEHAVIOR COLUMN
  dat$behavior <- ""
  tmp <- grep("^f,|^s,", tolower(dat$comment))
  dat$behavior[tmp] <- tolower(substr(dat$comment[tmp], 1, 1))
  dat$comment[tmp] <- substr(dat$comment[tmp], 2, nchar(dat$comment[tmp]))
  dat$comment <- cleanCommentField(dat$comment)
  
  return(dat)
}
