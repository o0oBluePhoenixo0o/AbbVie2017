# This is the main file to test

library(caret)
library(readr)
source("./1_Alex_crawl_facebook.r")
source("./2_Alex_preprocess.r")
source("./4_1_Alex_sentiment_analysis_syuzhet.r")
source("./4_2_Alex_sentiment_analysis_naiveBayes.r")
source("./4_3_Alex_sentiment_analysis_sentimentr.r")
source("./4_4_Alex_sentiment_analysis_sentr.r")
source("./translateR.r")

# Set working directory to the directoy where the file is located 
setwd("~/GitHub/AbbVie2017/Alex")


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
twitterMaster.df <- read.csv("Final_TW_0405_prep.csv", sep = ",", as.is = TRUE)
tweets.classified <- read_csv('./trainingandtestdata/training.1600000.processed.noemoticon.csv',
                              col_names = c('sentiment', 'id', 'date', 'query', 'user', 'text'))

# Training tweets

set.seed(2340)
trainIndex <- caret::createDataPartition(tweets.classified$sentiment, p = 0.00080, 
                                  list = FALSE, 
                                  times = 1)

tweets.train <- tweets.classified[trainIndex, ]
tweets.test <- tweets.classified[-trainIndex, ]

## Take only a small portion to test
testIndex <- caret::createDataPartition(tweets.classified$sentiment, p = 0.00010, 
                                 list = FALSE, 
                                 times = 1)
tweets.test <- tweets.test[testIndex, ] 
write.csv(tweets.test, file = paste("./tweets_test.csv"), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")

# Preprocess twitter

twitterMaster.df$Text <- removeURL(twitterMaster.df$Text)
twitterMaster.df$Text <- convert(twitterMaster.df$Text)
twitterMaster.df$Text <- removeTags(twitterMaster.df$Text)
twitterMaster.df$Text <- removeTwitterHandles(twitterMaster.df$Text)
twitterMaster.df$Text <- convertAbbreviations(twitterMaster.df$Text)
twitterMaster.df$Text <- tryTolower(twitterMaster.df$Text)
twitterMaster.df$Text_stemmed <- stemWords(twitterMaster.df$Text)



# Preprocess facebook

facebookMaster.df$created_time.x <- as.Date(facebookMaster.df$created_time.x)
facebookMaster.df$created_time.y <- as.Date(facebookMaster.df$created_time.y)

## Posts
facebookMaster.df$message.x <- removeURL(facebookMaster.df$message.x)
facebookMaster.df$message.x <- convert(facebookMaster.df$message.x)
facebookMaster.df$message.x <- removeTags(facebookMaster.df$message.x)
facebookMaster.df$message.x <- convertAbbreviations(facebookMaster.df$message.x)
facebookMaster.df$message.x <- tryTolower(facebookMaster.df$message.x)
facebookMaster.df$message.x_stemmed <- stemWords(facebookMaster.df$message.x)

## Comments
facebookMaster.df$message.y <- removeURL(facebookMaster.df$message.y)
facebookMaster.df$message.y <- convert(facebookMaster.df$message.y)
facebookMaster.df$message.y <- removeTags(facebookMaster.df$message.y)
facebookMaster.df$message.y <- convertAbbreviations(facebookMaster.df$message.y)
facebookMaster.df$message.y <- tryTolower(facebookMaster.df$message.y)
facebookMaster.df$message.y_stemmed <- stemWords(facebookMaster.df$message.y)



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

## Extract comment subsets
