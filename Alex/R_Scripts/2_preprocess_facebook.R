# This files contains methods on preprocess FB data

#install.packages("plyr")
#install.packages("dplyr")
#install.packages("SnowballC")
#install.packages("qdap")
#install.packages("tm")

library(plyr)
library(dplyr)
library(tm)
library(qdap)
library(SnowballC)

Sys.setenv(JAVA_HOME = '/Library/Java//Home')
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
source("./translateR.R")

#- Read master -#
facebookMaster.df <- read.csv("Final_FB_2403.csv", sep = ",", as.is = TRUE)

#- Extract posts and comments -#
posts <- select(facebookMaster.df, 1, 6, 7) # key, message.x, created_time.x
comments <- facebookMaster.df[complete.cases(facebookMaster.df[]),c("key", "message.y", "created_time.y")]  #key, message.y, created_time.y

# First separate by key then do unique 

# Product posts
posts.products <- subset(posts, key == "Imbruvica" | key == "Adalimumab" | key == "Trilipix" | key == "Enbrel" | key == "Humira" )
posts.products <- unique(posts.products)

#- Pre process message of posts -#

# lower case
posts.products$message.x <- tolower(posts.products$message.x) 

# detect the language of all posts
posts.products$lang.x <- lapply(posts.products$message.x, detectLanguage)

# Tanslate every message.x from the posts
posts.products <- posts.products %>% 
  rowwise() %>% 
  dplyr::mutate(translated.x = translateMyMemory(message.x, toISO639_1(lang.x) ,"en", "weiss_alex@gmx.net"))



# Replace original message with translated one if the lang.x is not "eng" not necessarily needed
posts.products <- posts.products %>% 
  rowwise() %>% 
  dplyr::mutate(message.x = ifelse(lang.x=="eng", message.x, translated.x))

# delete translated.x
# posts.products <- within(posts.products, rm(translated.x)) 

# remove punctuation
posts.products$message.x <- gsub('[[:punct:]]', '', posts.products$message.x) 

# Remove stopwords
posts.products <- posts.products %>% 
  rowwise() %>% 
  dplyr::mutate(message.x = paste(rm_stopwords(message.x, tm::stopwords("english"))[[1]], sep=" ", collapse = " "))

# Stem words
posts.products <- posts.products %>% 
  rowwise() %>% 
  dplyr::mutate(message.x =  wordStem(message.x))
                      

#- Comments -# 

comments <- unique(comments)


#- BACKLOG -#



