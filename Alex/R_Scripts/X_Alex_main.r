# This is the main file to test

library(caret)
library(readr)
library(purrr)
source("./1_Alex_crawl_facebook.r")
source("./2_Alex_preprocess.r")
source("./4_1_Alex_sentiment_analysis_syuzhet.r")
source("./4_2_Alex_sentiment_analysis_naiveBayes.r")
source("./4_3_Alex_sentiment_analysis_sentimentr.r")
source("./4_4_Alex_sentiment_analysis_sentr.r")
source("./translateR.r")
options(scipen=999)
# Set working directory to the directoy where the file is located 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# Crawl the data from facebook

searchFB("Humira")
searchFB("Adalimumab")
searchFB("Enbrel")
searchFB("Trilipix")
searchFB("Imbruvica")
searchFB("Ibrutinib")

# Merge the data into one big .csv file
mergeCSVsUTF8("./products/Adalimumab.csv","./products/Enbrel.csv","./products/Humira.csv","./products/Imbruvica.csv","./products/Trilipix.csv", "./products/Ibrutinib.csv")


# Read master files
facebookMaster.df <- read.csv("Final_FB_0405_prep.csv", sep = ",", as.is = TRUE)
twitterMaster.df <- read.csv("Final_TW_1005_prep.csv", sep = ",", as.is = TRUE)


# Training tweets

tweets.test_classified <- read_csv('./trainingandtestdata/Final_Manual_0805.csv')

tweets.classified <- read_csv('trainingandtestdata/training.1600000.processed.noemoticon.csv',
                              col_names = c('sentiment', 'id', 'date', 'query', 'user', 'text')) %>%
  # converting some symbols
  dmap_at('text', convertLatin_ASCII) %>%
  # replacing class values
  mutate(sentiment = ifelse(sentiment == 0, 0, 1))


set.seed(2340)
trainIndex <- createDataPartition(tweets.classified$sentiment, p = 0.8, 
                                  list = FALSE, 
                                  times = 1)
tweets.train <- tweets.classified[trainIndex, ]
tweets.test <- tweets.classified[-trainIndex, ]


# Preprocess twitter
twitterMaster.df$message <- sapply(twitterMaster.df$message, removeURL)
twitterMaster.df$message <- sapply(twitterMaster.df$message, removeTwitterHandles)
twitterMaster.df$message <- sapply(twitterMaster.df$message, removeTags)
twitterMaster.df$message <- sapply(twitterMaster.df$message, convertLatin_ASCII)
twitterMaster.df$message <- sapply(twitterMaster.df$message, tryTolower)
twitterMaster.df$message <- sapply(twitterMaster.df$message, convertAbbreviations)
twitterMaster.df$message <- sapply(twitterMaster.df$message, removeStopWords)
twitterMaster.df$message_stemmed <- sapply(twitterMaster.df$message, stemWords)

# Preprocess facebook

facebookMaster.df$created_time.x <- as.Date(facebookMaster.df$created_time.x)
facebookMaster.df$created_time.y <- as.Date(facebookMaster.df$created_time.y)

## Posts
facebookMaster.df$message.x <- sapply(facebookMaster.df$message.x, removeURL)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , removeTags)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , convertLatin_ASCII)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , tryTolower)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , convertAbbreviations)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , removeStopWords)
facebookMaster.df$message.x_stemmed <- sapply(facebookMaster.df$message.x , stemWords)


## Comments
facebookMaster.df$message.x <- sapply(facebookMaster.df$message.x, removeURL)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , removeTags)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , convertLatin_ASCII)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , tryTolower)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , convertAbbreviations)
facebookMaster.df$message.x  <- sapply(facebookMaster.df$message.x , removeStopWords)
facebookMaster.df$message.y_stemmed <- sapply(facebookMaster.df$message.x , stemWords)


## Extract post subsets and detect language
facebook.posts <- unique(select(facebookMaster.df, 2, 3, 4, 5, 6, 7, 8, 12, 13, 27)) #key, id.x likes_count.x, message.x, from.id, from.name, created_time.x, comments_count, shares_count, message.x_stemmed
facebook.posts$lang.x <- lapply(facebook.posts$message.x, detectLanguage)

facebook.posts.products <- subset(facebook.posts, key == "Imbruvica" | key == "Adalimumab" | key == "Trilipix" | key == "Enbrel" | key == "Humira" )
facebook.posts.products.humira <- subset(facebook.posts.products, key == "Humira" & lang.x == "eng")
facebook.posts.products.enbrel <- subset(facebook.posts.products, key == "Enbrel" & lang.x == "eng")
facebook.posts.products.trilipix <- subset(facebook.posts.products, key == "Trilipix" & lang.x == "eng")
facebook.posts.products.adalimumab <- subset(facebook.posts.products, key == "Adalimumab" & lang.x == "eng")
facebook.posts.products.imbruvica <- subset(facebook.posts.products, key == "Imbruvica" & lang.x == "eng")


## Extract comment subsets and detect language
facebook.comments <- unique(select(facebookMaster.df, 2, 20, 21, 22, 23, 26, 28)) #key, from_id.y, from_name.y, message.y, created_time.y, id.y, message.y_stemmed
facebook.comments$lang.y <- lapply(facebook.comments$message.y, detectLanguage)
