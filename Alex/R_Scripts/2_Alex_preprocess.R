# This files contains methods on preprocessing

# install.packages("plyr")
# install.packages("dplyr")
# install.packages("SnowballC")
# install.packages("qdap")
# install.packages("tm")
# loadChromeLangDetect <- function(){
#  url <- "http://cran.us.r-project.org/src/contrib/Archive/cldr/cldr_1.1.0.tar.gz"
#  pkgFile<-"cldr_1.1.0.tar.gz"
#  download.file(url = url, destfile = pkgFile)
#  install.packages(pkgs=pkgFile, type = "source", repos = NULL)
#  unlink(pkgFile)
#}
# loadChromeLangDetect()

library(cldr)
library(plyr)
library(dplyr)
library(tm)
library(qdap)
library(SnowballC)
library(stringr)

Sys.setenv(JAVA_HOME = '/Library/Java//Home')
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
source("./translateR.R")

removeURL <- function(x) {
  # Removes all urls from a given text
  #
  # Returns:
  #   String
  
  return(gsub('"(http.*) |(http.*)$|\n', "", x))
} 

removeTags <- function(x){
  # Removes all types of HTML tags from a given text
  #
  # Returns:
  #   String
  
  return(gsub('<.*?>', "", x))
}

convertLatin_ASCII <- function(x){
  # Converts text into ASCII to avoid some text identification issues
  #
  # Returns:
  #   String
  
  return(iconv(x, "latin1", "ASCII", ""))
} 

loadAbbrev <- function(filename) {
  # Concates custom abbreviation dataset with the default one from qdap
  #
  # Returns:
  #   A 2-column(abv,rep) data.frame
  
  myAbbrevs <- read.csv(filename, sep = ",", as.is = TRUE)
  return(rbind(abbreviations,myAbbrevs))
}

myAbbrevs <- loadAbbrev('abbrev.csv')

convertAbbreviations <- function(x){
  # Replaces abbreviation with the corresporending long form
  #
  # Returns:
  #   String
  
  return(qdap::replace_abbreviation(x, abbreviation = myAbbrevs, ignore.case = TRUE))
} 

removeTwitterHandles <- function(x){
  # Remove all twitter handles from a given text
  #
  # Returns:
  #   String
  
  return(str_replace_all(as.character(x), "@\\w+", ""))
} 

tryTolower = function(x){
  # Tries to lower a string, sometimes emoticons can make this tricky
  #
  # Returns:
  #    String
  
  y = x # we don't want to have NA where toLower() fails, so I jsut keep the original
  # tryCatch error
  
  try_error = tryCatch(tolower(x), error = function(e) e)
  
  # if not an error
  if (!inherits(try_error, "error"))
    y = tolower(x)
  return(y)
}

translate <- function(x, to) {
  # Translate a String into another language
  #
  # Returns:
  #   String
  
  return(translate(x, toISO639_1(detectLanguage(x)) ,to, "weiss_alex@gmx.net"))
}

removeStopWords <- function(x){
  # Remove stopwords from a english text
  #
  # Returns:
  #   String
  
  return(paste(qdap::rm_stopwords(message.x, tm::stopwords("english"))[[1]], sep=" ", collapse = " "))
}

stemWords <- function(x) {
  # Stem words of a english text
  #
  # Returns:
  #   String
  
  return(tm::stemDocument(x))
}