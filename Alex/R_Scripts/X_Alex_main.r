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
facebookMaster.df <- read_csv("Final_FB_0405_prep.csv")
twitterMaster.df <- read_csv("Final_TW_0807_prep.csv")

twitterMaster.df$Source <- gsub("<.*?>", "", twitterMaster.df$Source)
twitterMaster.df$To.User.Id <- ifelse(is.na(twitterMaster.df$To.User.Id), NULL,twitterMaster.df$To.User.Id )

twitterMaster.df[is.na(twitterMaster.df)] <- "\N"

twitterMaster.df$messagePrep <- twitterMaster.df$message
twitterMaster.df$messagePrep <- removeTwitterHandles(twitterMaster.df$messagePrep)
twitterMaster.df$messagePrep <- tryTolower(twitterMaster.df$messagePrep)
twitterMaster.df$messagePrep <- removeTags(twitterMaster.df$messagePrep)
twitterMaster.df$messagePrep <- removeURL(twitterMaster.df$messagePrep)

for (i in 1:nrow(twitterMaster.df)) {
  print(i)
  message <- twitterMaster.df[i,18]
  twitterMaster.df[i,18] <- paste(qdap::rm_stopwords(message, tm::stopwords("english"))[[1]], sep=" ", collapse = " ")
}
twitterMaster.df$messagePrep <- convertLatin_ASCII(twitterMaster.df$messagePrep)
twitterMaster.df$week <- lubridate::week(twitterMaster.df$created_time)

fromUsers <- cbind(twitterMaster.df$From.User, twitterMaster.df$From.User.Id)
toUsers <- cbind(twitterMaster.df$To.User, twitterMaster.df$To.User.Id)

toUsers <- toUsers[complete.cases(toUsers), ]
write.csv(fromUsers, file = paste("fromUsers0807",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")
write.csv(toUsers, file = paste("toUsers0807",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")
write.csv(twitterMaster.df, file = paste("dbImport0807",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")


# Training tweets

tweets.test <- read_csv('./trainingandtestdata/Final_Manual_1905.csv')

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
#tweets.test <- tweets.classified[-trainIndex, ]


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
