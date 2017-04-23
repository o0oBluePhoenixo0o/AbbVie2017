# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets with SentR

# install.packages('devtools')
# install_github('mananshah99/sentR')
library(devtools)
library(sentR)
source('./2_Alex_preprocess.R')

# Sentiment analysis Twitter

mySentiment.sentr <- classify.naivebayes(twitterMaster.df$Text_stemmed)
tweets.sentr <- cbind(Id=twitterMaster.df$Id,twitterMaster.df$Text, mySentiment.sentr , time = twitterMaster.df$Created.At)
tweets.sentr$Id <- format(tweets.sentr$Id, scientific=F)

# Sentiment analysis Facebook

mySentiment.sentr.fb <- classify.naivebayes(facebook.posts.products.humira$message.x_stemmed)
facebook.sentr <- cbind(Id=facebook.posts.products.humira$id.x, facebook.posts.products.humira$message.x, mySentiment.sentr.fb, time = facebook.posts.products.humira$created_time.x)
facebook.sentr$Id <- format(facebook.sentr$Id, scientific=F)


# Model Evaluation

test.sentR <- sentR::classify.naivebayes(tweets.test$text_stemmed)
test.sentR[,4] <- ifelse(test.sentR[,4] == 'positive'|test.sentR[,4] == 'neutral' , 4, 0) # translate sentiments back to the original training data
print(table(test.sentR[,4], tweets.test$sentiment))
