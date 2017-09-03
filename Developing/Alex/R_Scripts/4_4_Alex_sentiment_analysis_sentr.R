# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets with SentR

# install.packages('devtools')
library(devtools)
# install_github('mananshah99/sentR')
# install.packages("memisc")
# install.packages("caret")

library(caret)
library(memisc)
library(sentR)

source('./2_Alex_preprocess.R')
source('./7_Alex_evaluation.R')


# Model Evaluation


#Choose the 'Final_Manual_3007.csv' from 5. Dataset
tweets.test <- read.csv(file.choose())

# Model Evaluation
tweets.test$message <- removeURL(tweets.test$message)
tweets.test$message <- convertLatin_ASCII(tweets.test$message)
tweets.test$message <- removeTags(tweets.test$message)
tweets.test$message <- removeTwitterHandles(tweets.test$message)
# tweets.test$message <- convertAbbreviations(tweets.test$message) only if needed
tweets.test$message <- tryTolower(tweets.test$message)
tweets.test$message_stemmed <- stemWords(tweets.test$message)

tweets.test$sentiment <- sapply(tweets.test$sentiment, function(x)
  x = cases (x %in% c(1,2) -> 'negative',
             x %in% c(3,4) -> 'positive',
             x %in% c('N','n',NA,'',' ') -> 'neutral'))


test.sentR <- sentR::classify.naivebayes(tweets.test$message_stemmed)

message("sentR")
confusionMatrix(tweets.test$sentiment, test.sentR[,4])


test.sentR[,4] <- ifelse(test.sentR[,4] == 'neutral', "pred_neutral", ifelse(test.sentR[,4] == 'positive', "pred_positive", "pred_negative")) # translate sentiments back to the original training data
print(table(test.sentR[,4], tweets.test$sentiment))

# Evlauation
cm = as.matrix(table(tweets.test$sentiment,test.sentR[,4]))
print(cm)
analyzeConfusinMatrix(cm)

