# This files contains methods on preprocess FB data

#i nstall.packages("plyr")
# install.packages("dplyr")
# install.packages("SnowballC")
# install.packages("qdap")
# install.packages("tm")

library(plyr)
library(dplyr)
library(tm)
library(qdap)
library(SnowballC)

Sys.setenv(JAVA_HOME = '/Library/Java//Home')
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
source("./translateR.R")

preProcessPosts <- function(posts, translate = FALSE, lowerCase = FALSE, removePunct = FALSE, removeStopWords = FALSE, stemWords = FALSE){
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
  
  View(posts)
  
  return(posts)
}
