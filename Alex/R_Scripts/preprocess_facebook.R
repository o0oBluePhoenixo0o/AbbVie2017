# This files contains methods on preprocess FB data

#install.packages("plyr")
#install.packages("dplyr")
#install.packages("tm")

library(plyr)
library(dplyr)
library(tm)

source("./translateR.R")

#- Read master -#
facebookMaster.df <- read.csv("Final_FB_2403.csv", sep = ",", as.is = TRUE)

#- Extract posts and comments -#
posts <- unique(select(facebookMaster.df, 1, 6, 7)) # key, message.x, created_time.x
comments <- unique(facebookMaster.df[complete.cases(facebookMaster.df[]), c("key", "message.y", "created_time.y")])  #key, message.y, created_time.y


#- Prepare message of posts and comments -#

posts$message.x <- tolower(posts$message.x) # lower case
posts$message.x <- gsub('[[:punct:]]', '', posts$message.x) # remove punctian


comments$message.x <- tolower(comments$message.x) # lower case
comments$message.x <- gsub('[[:punct:]]', '', comments$message.x) # remove punctuation



posts.humira <- subset(posts, key == "Humira")

documents <- Corpus(VectorSource(posts.humira$message.x))
documents = tm_map(documents, content_transformer(tolower))
documents = tm_map(documents, removePunctuation)
documents = tm_map(documents, removeWords, stopwords("english"))
documents[[20]]$content

documents



# Detect and translate text, language detection uses 'franc' package 
posts.humira$lang.x <- lapply(posts.humira$message.x, detectLanguage)# detect the language of all posts


# Tanslate every message.x from the posts
posts.humira <- posts.humira %>% 
  rowwise() %>% 
  dplyr::mutate(translated.x = translateMyMemory(message.x, toISO639_1(lang.x) ,"en", "weiss_alex@gmx.net"))

# Replace original message with translated one if the lang.x is not "eng"
posts.humira <- posts.humira %>% 
  rowwise() %>% 
  dplyr::mutate(message.x = ifelse(lang.x=="eng", message.x, translated.x))






