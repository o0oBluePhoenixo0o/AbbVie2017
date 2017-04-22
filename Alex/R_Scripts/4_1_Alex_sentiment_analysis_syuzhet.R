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

# PreProcess Twitter

twitterMaster.df$Text <- removeURL(twitterMaster.df$Text)
twitterMaster.df$Text <- convert(twitterMaster.df$Text)
twitterMaster.df$Text <- removeTags(twitterMaster.df$Text)
twitterMaster.df$Text <- removeTwitterHandles(twitterMaster.df$Text)
twitterMaster.df$Text <- convertAbbreviations(twitterMaster.df$Text)
twitterMaster.df$Text <- tryTolower(twitterMaster.df$Text)

# Sentiment analysis

mySentiment <- syuzhet::get_nrc_sentiment(as.character(twitterMaster.df$Text))
tweets.syuzhet <- cbind(Id=twitterMaster.df$Id, twitterMaster.df$Text, mySentiment, time = twitterMaster.df$Created.At)
tweets.syuzhet$Id <- format(tweets.syuzhet$Id, scientific=FALSE)



# Total count of emotions

plot <- plotSyuzhetEmotions(tweets.syuzhet)
plot


# Model Evaluation

testNotwhandles <- str_replace_all(as.character(tweets_test$V6), "@\\w+", "")
results.syuzhet <- syuzhet::get_nrc_sentiment(as.character(testNotwhandles))

results.syuzhet <- as.data.frame(results.syuzhet[,9:10])
results.syuzhet$sent <- ifelse((results.syuzhet$positive- results.syuzhet$negative) > 0, 4, 0)# translate sentiments back to the original training data

print(table(results.syuzhet$sent, tweets_test$V1))





