# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets


# install.packages("sentimentr")
# install.packages("stringr")

library(sentimentr)
library(stringr)


# Remove twitter handles
notwhandles <- str_replace_all(as.character(twitterMaster.df$Text), "@\\w+", "")
mySentiment.sentimentr <- sentiment_by(as.character(notwhandles))

plot(mySentiment.sentimentr)


tweets.sentr <- cbind(Id=twitterMaster.df$Id,notwhandles, mySentiment.sentimentr , time = twitterMaster.df$Created.At)
tweets.sentr$Id <- format(tweets.sent$Id, scientific=F)

