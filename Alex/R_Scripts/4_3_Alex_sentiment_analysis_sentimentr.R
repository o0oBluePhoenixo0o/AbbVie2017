# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets with sentimentr (lexicon based)


# install.packages("sentimentr")
# install.packages("stringr")

library(sentimentr)
library(stringr)
source('./2_Alex_preprocess.R')

# Sentiment analysis Twitter (as we use lexicon based approach we use the stemmed text here)

mySentiment.sentimentr <- sentimentr::sentiment_by(as.character(twitterMaster.df$Text_stemmed))
tweets.sentimentr <- cbind(Id=twitterMaster.df$Id, twitterMaster.df$Text, mySentiment.sentimentr , time = twitterMaster.df$Created.At)
tweets.sentimentr$Id <- format(tweets.sent$Id, scientific=F)

# Sentiment analysis Facebok (as we use lexicon based approach we use the stemmed text here)

mySentiment.sentimentr.fb <- sentimentr::sentiment_by(as.character(facebook.posts.products.humira$message.x_stemmed))
facebook.sentimentr <- cbind(Id=facebook.posts.products.humira$id.x, facebook.posts.products.humira$message.x, mySentiment.sentimentr.fb, time = facebook.posts.products.humira$created_time.x)
facebook.sentimentr$Id <- format(facebook.sentimentr , scientific=FALSE)


# Model Evaluation
tweets.test$text <- removeURL(tweets.test$text)
tweets.test$text <- convert(tweets.test$text)
tweets.test$text <- removeTags(tweets.test$text)
tweets.test$text <- removeTwitterHandles(tweets.test$text)
tweets.test$text <- convertAbbreviations(tweets.test$text)
tweets.test$text <- tryTolower(tweets.test$text)
tweets.test$text_stemmed <- stemWords(tweets.test$text)


test.sentimentR <- sentimentr::sentiment_by(as.character(tweets.test$text_stemmed))
test.sentimentR$sent <- ifelse(test.sentimentR$ave_sentiment > 0, 4, 0) # translate sentiments back to the original training data
print(table(test.sentimentR$sent, tweets.test$sentiment))


