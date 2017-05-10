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


tweets.test <- read_csv("./Alex_TW_Test160.csv")

tweets.test$text <- removeURL(tweets.test$text)
tweets.test$text <- convert(tweets.test$text)
tweets.test$text <- removeTags(tweets.test$text)
tweets.test$text <- removeTwitterHandles(tweets.test$text)
tweets.test$text <- convertAbbreviations(tweets.test$text)
tweets.test$text <- tryTolower(tweets.test$text)
tweets.test$text_stemmed <- stemWords(tweets.test$text)

test.syuzhet <- syuzhet::get_nrc_sentiment(as.character(tweets.test$text_stemmed))
test.syuzhet <- as.data.frame(test.syuzhet[,9:10])
test.syuzhet$sent <- ifelse((test.syuzhet$positive- test.syuzhet$negative) > 0, 4, 0)# translate sentiments back to the original training data

print(table(test.syuzhet$sent, tweets.test$sentiment))





