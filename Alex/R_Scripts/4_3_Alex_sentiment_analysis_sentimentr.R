# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets with sentimentr


# install.packages("sentimentr")
# install.packages("stringr")

library(sentimentr)
library(stringr)
source('./2_Alex_preprocess.R')


# PreProcess Twitter

twitterMaster.df$Text <- removeURL(twitterMaster.df$Text)
twitterMaster.df$Text <- convert(twitterMaster.df$Text)
twitterMaster.df$Text <- removeTags(twitterMaster.df$Text)
twitterMaster.df$Text <- removeTwitterHandles(twitterMaster.df$Text)
twitterMaster.df$Text <- convertAbbreviations(twitterMaster.df$Text)
twitterMaster.df$Text <- tryTolower(twitterMaster.df$Text)

# Sentiment analysis Twitter

mySentiment <- sentimentr::sentiment_by(as.character(twitterMaster.df$Text))
tweets.sentimentr <- cbind(Id=twitterMaster.df$Id, twitterMaster.df$Text, mySentiment , time = twitterMaster.df$Created.At)
tweets.sentimentr$Id <- format(tweets.sent$Id, scientific=F)


# Model Evaluation

results.sentimentR <- sentimentr::sentiment_by(as.character(tweets_test$V6))
results.sentimentR$sent <- ifelse(results.sentimentR$ave_sentiment > 0, 4, 0) # translate sentiments back to the original training data
print(table(results.sentimentR$sent, tweets_test$V1))


