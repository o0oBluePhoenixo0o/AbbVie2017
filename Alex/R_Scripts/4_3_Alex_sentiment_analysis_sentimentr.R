# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets with sentimentr


# install.packages("sentimentr")
# install.packages("stringr")

library(sentimentr)
library(stringr)


# Remove twitter handles
notwhandles <- str_replace_all(as.character(twitterMaster.df$Text), "@\\w+", "")
mySentiment.sentimentr <- sentimentr::sentiment_by(as.character(notwhandles))

tweets.sentr <- cbind(Id=twitterMaster.df$Id,notwhandles, mySentiment.sentimentr , time = twitterMaster.df$Created.At)
tweets.sentr$Id <- format(tweets.sent$Id, scientific=F)


# Model Evaluation
results.sentimentR <- sentimentr::sentiment_by(as.character(tweets_test$V6))
results.sentimentR$sent <- ifelse(results.sentimentR$ave_sentiment > 0, 4, 0) # translate sentiments back to the original training data
print(table(results.sentimentR$sent, tweets_test$V1))


