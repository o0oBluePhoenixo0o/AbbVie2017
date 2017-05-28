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
tweets.test$message <- removeURL(tweets.test$message)
tweets.test$message <- convert(tweets.test$message)
tweets.test$message <- removeTags(tweets.test$message)
tweets.test$message <- removeTwitterHandles(tweets.test$message)
tweets.test$message <- convertAbbreviations(tweets.test$message)
tweets.test$message <- tryTolower(tweets.test$message)
tweets.test$message_stemmed <- stemWords(tweets.test$message)

tweets.test$sentiment <-  ifelse(tweets.test$sentiment == "N", "neutral", ifelse(tweets.test$sentiment > 2, "positive", "negative"))


test.sentimentR <- sentimentr::sentiment_by(as.character(tweets.test$message_stemmed))
test.sentimentR$sent <- ifelse(test.sentimentR$ave_sentiment == 0, "neutral", ifelse(test.sentimentR$ave_sentiment > 0 , "positive", "negative")) # translate sentiments back to the original training data


message("sentimentR")
confusionMatrix(tweets.test$sentiment, test.sentimentR$sent )


test.sentimentR$sent <- ifelse(test.sentimentR$ave_sentiment == 0, "pred_neutral", ifelse(test.sentimentR$ave_sentiment > 0 , "pred_positive", "pred_negative")) # translate sentiments back to the original training data

print(table(test.sentimentR$sent,tweets.test$sentiment))


analyzeConfusinMatrix(tweets.test$sentiment, test.sentimentR$sent)
