# This files uses the NRC-Word-Emotion-Association-Lexcicon and the syuzhet package for sentiment analysis
# Author: Alxander Weiß

# install.packages("syuzhet")
# install.packages("memisc")
# install.packages("caret")

library(caret)
library(memisc)
library(syuzhet)

source('./2_Alex_preprocess.R')
source('./7_Alex_evaluation.R')


# Model Evaluation


#Choose the 'Final_Manual_3007.csv' from 5. Dataset
tweets.test <- read.csv(file.choose())

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

test.syuzhet <- syuzhet::get_nrc_sentiment(as.character(tweets.test$message_stemmed))
test.syuzhet <- as.data.frame(test.syuzhet[,9:10])
test.syuzhet$sent <- ifelse((test.syuzhet$positive - test.syuzhet$negative) == 0, "neutral", ifelse(test.syuzhet$positive - test.syuzhet$negative > 0 , "positive", "negative"))# translate sentiments back to the original training data

message("syuzhet")
confusionMatrix(tweets.test$sentiment, test.syuzhet$sent)
test.syuzhet$sent <- ifelse((test.syuzhet$positive - test.syuzhet$negative) == 0, "pred_neutral", ifelse(test.syuzhet$positive - test.syuzhet$negative > 0 , "pred_positive", "pred_negative"))# translate sentiments back to the original training data

# Evlauation
cm = as.matrix(table(tweets.test$sentiment,test.syuzhet$sent))
print(cm)
analyzeConfusinMatrix(cm)


