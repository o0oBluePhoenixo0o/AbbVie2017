# This files contains methods on preprocessing

#install.packages("plyr")
#install.packages("dplyr")
#install.packages("tm")
#install.packages("qdap")
#install.packages("SnowballC")
#install.packages("stringr")
#install.packages("lubridate")
#install.packages("readr")
#install.packages("lubridate")
#install.packages("stringr")
#install.packages("stringi")
#install.packages("franc")
#install.packages("ISOcodes")
#install.packages("textcat")
Sys.setenv(JAVA_HOME = '/Library/Java//Home')
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
dyn.load('/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/server/libjvm.dylib')

library(plyr)
library(dplyr)
library(tm)
library(qdap)
library(SnowballC)
library(stringr)
library(lubridate)
library(readr)
library(stringr)
library(stringi)
library(ISOcodes)
library(textcat)

source("./translateR.R")

removeURL <- function(text) {
  # Removes all urls from a given text
  #
  # Args:
  #   text: Text to remove the URL from
  #
  # Returns:
  #   String
  
  return(gsub('"(http.*) |(http.*)$|\n', "", text))
} 

removeTags <- function(text){
  # Removes all types of HTML tags from a given text
  #
  # Args:
  #   text: Text to remove the Tags from
  #
  # Returns:
  #   String
  
  return(gsub('<.*?>', "", text))
}

convertLatin_ASCII <- function(text){
  # Converts text into ASCII to avoid some text identification issues
  #
  # Args:
  #   text: Text to convert
  #
  # Returns:
  #   String
  
  return(iconv(text, "latin1", "ASCII", ""))
} 

loadAbbrev <- function(filename) {
  # Concates custom abbreviation dataset with the default one from qdap
  #
  # Args:
  #   filename: Filename of the abbreviation lexicon
  #
  # Returns:
  #   A 2-column(abv,rep) data.frame
  
  myAbbrevs <- read.csv(filename, sep = ",")
  return(myAbbrevs)
}

# Choose 'abbrev.csv' from 5. Dataset
myAbbrevs <- loadAbbrev(file.choose())

convertAbbreviations <- function(message){
  # Replaces abbreviation with the corresporending long form
  #
  # Args:
  #   text: Text to remove the abbreviations from
  #
  # Returns:
  #   String
  if(is.na(message) || message == ""){
    return(message)
  } else {
    newText <- message
    for (i in 1:nrow(myAbbrevs)){
      newText <- gsub(paste0('\\<', myAbbrevs[[i,1]], '\\>'), paste0(myAbbrevs[[i,2]]), newText)
    }
    return (newText)
  }
}

removeTwitterHandles <- function(text){
  # Remove all twitter handles from a given text
  #
  # Args:
  #   text: Text to remove the Twitter handles from
  #
  # Returns:
  #   String
  return(str_replace_all(as.character(text), "@\\w+", ""))
} 

tryTolower = function(text){
  # Tries to lower a string, sometimes emoticons can make this tricky
  #
  # Args:
  #   xtext Text to lower the case
  #
  # Returns:
  #    String
  
  y = text # we don't want to have NA where toLower() fails, so I jsut keep the original
  # tryCatch error
  
  try_error = tryCatch(tolower(text), error = function(e) e)
  
  # if not an error
  if (!inherits(try_error, "error"))
    y = tolower(text)
  return(y)
}

translate <- function(text, to) {
  # Translate a String into another language
  #
  # Args:
  #   text: Text to translate
  #   to: ISO639_1 target language
  #
  # Returns:
  #   String
  
  return(translate(text, toISO639_1(detectLanguage(text)) ,to, "weiss_alex@gmx.net"))
}

removeStopWords <- function(text){
  # Remove stopwords from a english text
  #
  # Args:
  #   text: Text to remove the stopwords from
  #
  # Returns:
  #   String
  
  return(paste(qdap::rm_stopwords(text, tm::stopwords("english"))[[1]], sep=" ", collapse = " "))
}

stemWords <- function(text) {
  # Stem words of a english text
  #
  # Args:
  #   text: Text to stem the words from
  #
  # Returns:
  #   String
  
  return(tm::stemDocument(text))
}

string2Date <- function(text, dateFormats) {
  # Parses a String to Date, by suppliying different formats in which the String can be in
  #
  # Args:
  #   text: Text to parse in date
  #
  # Returns:
  #   A Y-m-d formated date
  
  lubriDate <- lubridate::parse_date_time(text,dateFormats, tz = "UTC")
  
  
  lubriYear <- year(lubriDate)
  lubriMonth <- month(lubriDate)
  lubriDay <- day(lubriDate)
  
  lubriHours <- hour(lubriDate)
  lubriMinute <- minute(lubriDate)
  ymd <- paste(lubriYear,lubriMonth,lubriDay,sep="-")
  hs <- paste(lubriHours,lubriMinute,sep=":")
  
  return (paste(ymd,hs, sep = " "))
}
