# This files uses the NRC-Word-EMotion-Association-Lexcicon and the syuzhet package for sentiment analysis

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



# Remove twitter handles
notwhandles <- str_replace_all(as.character(twitterMaster.df$Text), "@\\w+", "")
mySentiment <- get_nrc_sentiment(as.character(notwhandles))

tweets.sent <- cbind(Id=twitterMaster.df$Id,notwhandles, mySentiment, time = twitterMaster.df$Created.At)
tweets.sent$Id <- format(tweets.sent$Id, scientific=FALSE)

# Total count of emotions
sentimentTotals <- data.frame(colSums(tweets.sent[,c(3:10)]))
names(sentimentTotals) <- "count"
sentimentTotals <- cbind("sentiment" = rownames(sentimentTotals), sentimentTotals)
rownames(sentimentTotals) <- NULL
ggplot(data = sentimentTotals, aes(x = sentiment, y = count)) +
  geom_bar(aes(fill = sentiment), stat = "identity") +
  theme(legend.position = "none") +
  xlab("Sentiment") + ylab("Total Count") + ggtitle("Total Sentiment Score for All Tweets")




