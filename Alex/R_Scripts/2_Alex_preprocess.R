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

Sys.setenv(JAVA_HOME = '/Library/Java//Home')
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
source("./translateR.R")

removeURL <- function(x) gsub('"(http.*) |(http.*)$|\n', "", x)
removeTags <- function(x) gsub('<.*?>', "", x)
convert <- function(x) iconv(x, "latin1", "ASCII", "")
removeTwitterHandles <- function(x) str_replace_all(as.character(x), "@\\w+", "")
myAbbrevs <- loadAbbrev()
convertAbbreviations <- function(x) replace_abbreviation(x, abbreviation = myAbbrevs, ignore.case = TRUE)

loadAbbrev <- function() {
  # Concates my abbreviation dataset with the default one from qdap
  #
  # Returns:
  #   A 2-column(abv,rep) data.frame
  
  myAbbrevs <- read.csv("abbrev.csv", sep = ",", as.is = TRUE)
  return(rbind(abbreviations,myAbbrevs))
}
tryTolower = function(x){
  # Tries to lower a string, sometimes emoticons can make this tricky
  #
  # Returns:
  #   Lowered string
  
  y = x # we don't want to have NA where toLower() fails, so I jsut keep the original
  # tryCatch error
  
  try_error = tryCatch(tolower(x), error = function(e) e)
  
  # if not an error
  if (!inherits(try_error, "error"))
    y = tolower(x)
  return(y)
}



textProcessPosts <- function(posts, translate = FALSE, lowerCase = FALSE, removePunct = FALSE, removeStopWords = FALSE, stemWords = FALSE){
  # Preprocess a dataframe of posts containing at least a $message.x column
  #
  # Args:
  #   translate: Should the posts be translated
  #   posts: Dataframe of Facebook posts with column message.x 
  #   lowerCase: should messages be lowered in case
  #   removePunct: should the punctuation be removed 
  #   stem: Should the words be stemmed
  #
  # Returns:
  #   The preprocessed data.frame
  
 
  #Translation
  if (translate) {
    # detect language ISO639_2
    posts$lang.x <- lapply(posts$message.x, detectLanguage)
    
    # Tanslate every message.x from the posts
    posts <- posts %>% 
      rowwise() %>% 
      dplyr::mutate(translated.x = translateMyMemory(message.x, toISO639_1(lang.x) ,"en", "weiss_alex@gmx.net"))
    
    # Replace original message with translated one if the lang.x is not "eng" not necessarily needed
    posts <- posts %>% 
      rowwise() %>% 
      dplyr::mutate(message.x = ifelse(lang.x=="eng", message.x, translated.x))
  }
  
  # Lower case
  if (lowerCase) {
    posts$message.x <- tolower(posts$message.x) 
  }
  
  # remove punctuation
  if (removePunct) {
    posts$message.x <- gsub('[[:punct:]]', '', posts$message.x) 
  }
  
  # Remove stopwords
  if (removeStopWords) {
    message("Removing stopwords")
    posts <- posts %>% 
      rowwise() %>% 
      dplyr::mutate(message.x = paste(qdap::rm_stopwords(message.x, tm::stopwords("english"))[[1]], sep=" ", collapse = " "))
  }
  
  # Stem words
  if (stemWords) {
    posts <- posts %>% 
      rowwise() %>% 
      dplyr::mutate(message.x =  SnowballC::wordStem(message.x))
  }
  
  return(posts)
}
