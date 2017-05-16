# This files uses the NRC-Word-Emotion-Association-Lexcicon and the syuzhet package for sentiment analysis

# install.packages("syuzhet")
# install.packages("lubridate")
# install.packages("ggplot2")
# install.packages("scales")
# install.packages("reshape2")
# install.packages("dplyr")

library(syuzhet)
library(lubridate)
library(ggplot2)
library(scales)
library(reshape2)
library(dplyr )
library(stringr)
library(qdap)
source('./2_Alex_preprocess.R')
source('./7_Alex_evaluation.R')
source('./translateR.R')

plotSyuzhetEmotions <- function(df) {
  sentimentTotals <- data.frame(colSums(df[,c(3:10)]))
  names(sentimentTotals) <- "count"
  sentimentTotals <- cbind("sentiment" = rownames(sentimentTotals), sentimentTotals)
  rownames(sentimentTotals) <- NULL
  ggplot(data = sentimentTotals, aes(x = sentiment, y = count)) +
    geom_bar(aes(fill = sentiment), stat = "identity") +
    theme(legend.position = "none") +
    xlab("Sentiment") + ylab("Total Count") + ggtitle("Total Sentiment Score for All Tweets")
}




# Sentiment analysis twitter (as we use lexicon based approach we use the stemmed text here)

mySentiment.syuzhet.nrc <- syuzhet::get_nrc_sentiment(as.character(twitterMaster.df$message))
mySentiment.syuzhet.stanford <- syuzhet::get_stanford_sentiment(as.character(twitterMaster.df$message))
tweets.syuzhet <- cbind(Id=twitterMaster.df$Id, twitterMaster.df$message, mySentiment.syuzhet, time = twitterMaster.df$created_time)
tweets.syuzhet$Id <- format(tweets.syuzhet$Id, scientific=FALSE)

plot <- plotSyuzhetEmotions(tweets.syuzhet)
plot


# Sentiment analysis facebook posts (as we use lexicon based approach we use the stemmed text here)

mySentiment.syuzhet.fb <- syuzhet::get_nrc_sentiment(as.character(facebook.posts.products.humira$message.x_stemmed))
facebook.syuzhet <- cbind(Id=facebook.posts.products.humira$id.x, facebook.posts.products.humira$message.x, mySentiment.syuzhet.fb, time = facebook.posts.products.humira$created_time.x)
facebook.syuzhet$Id <- format(facebook.syuzhet , scientific=FALSE)

plot <- plotSyuzhetEmotions(facebook.syuzhet)
plot


# Model Evaluation


tweets.test$message <- sapply(tweets.test$message, removeURL)
tweets.test$message <- sapply(tweets.test$message, removeTwitterHandles)
tweets.test$message <- sapply(tweets.test$message, removeTags)
tweets.test$message <- sapply(tweets.test$message, convertLatin_ASCII)
tweets.test$message <- sapply(tweets.test$message, tryTolower)
tweets.test$message <- sapply(tweets.test$message, convertAbbreviations)
tweets.test$message <- sapply(tweets.test$message, removeStopWords)
tweets.test$message_stemmed <- sapply(tweets.test$message, stemWords)

tweets.test$sentiment <-  ifelse(tweets.test$sentiment == "N", "neutral", ifelse(tweets.test$sentiment > 2, "positive", "negative"))

test.syuzhet <- syuzhet::get_nrc_sentiment(as.character(tweets.test$message_stemmed))
test.syuzhet <- as.data.frame(test.syuzhet[,9:10])
test.syuzhet$sent <- ifelse((test.syuzhet$positive - test.syuzhet$negative) == 0, "neutral", ifelse(test.syuzhet$positive - test.syuzhet$negative > 0 , "positive", "negative"))# translate sentiments back to the original training data


message("syuzhet")
confusionMatrix(tweets.test$sentiment, test.syuzhet$sent)
test.syuzhet$sent <- ifelse((test.syuzhet$positive - test.syuzhet$negative) == 0, "pred_neutral", ifelse(test.syuzhet$positive - test.syuzhet$negative > 0 , "pred_positive", "pred_negative"))# translate sentiments back to the original training data




# Evlauation

analyzeConfusinMatrix(tweets.test$sentiment,test.syuzhet$sent)


