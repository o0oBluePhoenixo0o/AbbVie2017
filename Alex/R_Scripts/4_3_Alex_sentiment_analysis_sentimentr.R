# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets with sentimentr (lexicon based)


# install.packages("sentimentr")
# install.packages("stringr")

library(sentimentr)
library(lubridate)
library(ggplot2)
library(scales)
library(reshape2)
library(dplyr )
library(stringr)
library(qdap)
library(memisc)
source('./2_Alex_preprocess.R')
source('./7_Alex_evaluation.R')

# Model Evaluation
tweets.test <- read.csv("./Final_Manual_3007.csv")

tweets.test$message <- removeURL(tweets.test$message)
tweets.test$message <- convert(tweets.test$message)
tweets.test$message <- removeTags(tweets.test$message)
tweets.test$message <- removeTwitterHandles(tweets.test$message)
tweets.test$message <- convertAbbreviations(tweets.test$message)
tweets.test$message <- tryTolower(tweets.test$message)
tweets.test$message_stemmed <- stemWords(tweets.test$message)

tweets.test$sentiment <- sapply(df$sentiment, function(x)
  x = cases (x %in% c(1,2) -> 'negative',
             x %in% c(3,4) -> 'positive',
             x %in% c('N','n',NA,'',' ') -> 'neutral'))



test.sentimentR <- sentimentr::sentiment_by(as.character(tweets.test$message_stemmed))
test.sentimentR$sent <- ifelse(test.sentimentR$ave_sentiment == 0, "neutral", ifelse(test.sentimentR$ave_sentiment > 0 , "positive", "negative")) # translate sentiments back to the original training data


message("sentimentR")
confusionMatrix(tweets.test$sentiment, test.sentimentR$sent )


test.sentimentR$sent <- ifelse(test.sentimentR$ave_sentiment == 0, "pred_neutral", ifelse(test.sentimentR$ave_sentiment > 0 , "pred_positive", "pred_negative")) # translate sentiments back to the original training data

# Evlauation
cm = as.matrix(table(tweets.test$sentiment,test.sentimentR$sent))
print(cm)
analyzeConfusinMatrix(cm)
