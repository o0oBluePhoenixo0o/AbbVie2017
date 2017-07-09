needs(dplyr)
needs(plyr)
needs(dplyr)
needs(tm)
needs(qdap)
needs(SnowballC)
needs(stringr)
needs(lubridate)


Sys.setenv(JAVA_HOME = '/Library/Java//Home')
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
#source("./translateR.R")
attach(input[[1]])


loadAbbrev <- function(filename) {
  # Concates custom abbreviation dataset with the default one from qdap
  #
  # Args:
  #   filename: Filename of the abbreviation lexicon
  #
  # Returns:
  #   A 2-column(abv,rep) data.frame
  
  myAbbrevs <- read.csv(filename, sep = ",", as.is = TRUE)
  return(rbind(abbreviations,myAbbrevs))
}

myAbbrevs <- loadAbbrev('./ML/R/abbrev.csv')

convertAbbreviations <- function(text){
  # Replaces abbreviation with the corresporending long form
  #
  # Args:
  #   text: Text to remove the abbreviations from
  #
  # Returns:
  #   String
  if(is.na(text) || text == ""){
    return(text)
  } else {
    return(qdap::replace_abbreviation(text, abbreviation = myAbbrevs, ignore.case = TRUE))
  }
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

removeURL <- function(text) {
  # Removes all urls from a given text
  #
  # Args:
  #   text: Text to remove the URL from
  #
  # Returns:
  #   String
  
  return(gsub('http\\S+\\s*', '', text))
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

# output of final expression is returned to node
out <- message
out <- removeTwitterHandles(out)
out <- tryTolower(out)
out <- removeTags(out)
out <- removeURL(out)
#out <- convertAbbreviations(out)
out <- removeStopWords(out)
 # the last expression has to NOT be assigned to a variable so that our JS can read it
convertLatin_ASCII(out)
