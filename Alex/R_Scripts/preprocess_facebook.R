# This files contains methods on preprocess FB data

#install.packages("plyr")
#install.packages("dplyr")

library(plyr)
library(dplyr)

source("./translateR.R")

#Read master

facebookMaster.df <- read.csv("Final_FB_2403.csv", sep = ",", as.is = TRUE)

# Extract posts and comments

posts <- unique(select(facebookMaster.df, 1, 6, 7)) # key, message.x, created_time.x
comments <- unique(facebookMaster.df[complete.cases(facebookMaster.df[]), c("key", "message.y", "created_time.y")])  #key, message.y, created_time.y

posts.humira <- subset(posts, key == "Humira")
posts.humira$message.x <- tolower(posts.humira$message.x) # lower case
posts.humira$message.x <- gsub('[[:punct:]]', '', posts.humira$message.) # remove punctuation

# Detect and translate text, language detection uses 'franc' package 
posts.humira$lang.x <- lapply(posts.humira$message.x, detectLanguage)# detect the language of all posts
posts.humira <- posts.humira %>% 
  rowwise() %>% 
  dplyr::mutate(translated.x = ifelse (!is.na(message.x),translateMyMemory(message.x, toISO639_1(lang.x) ,"en", "weiss_alex@gmx.net"),""))







