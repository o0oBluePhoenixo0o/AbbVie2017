# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets with SentR

# install.packages('devtools')
# install_github('mananshah99/sentR')
library(devtools)
library(sentR)
source('./2_Alex_preprocess.R')

# PreProcess Twitter

twitterMaster.df$Text <- removeURL(twitterMaster.df$Text)
twitterMaster.df$Text <- convert(twitterMaster.df$Text)
twitterMaster.df$Text <- removeTags(twitterMaster.df$Text)
twitterMaster.df$Text <- removeTwitterHandles(twitterMaster.df$Text)
twitterMaster.df$Text <- convertAbbreviations(twitterMaster.df$Text)
twitterMaster.df$Text <- tryTolower(twitterMaster.df$Text)

# Sentiment analysis Twitter

mySentiment <- classify.naivebayes(twitterMaster.df$Text)
tweets.sentr <- cbind(Id=twitterMaster.df$Id,twitterMaster.df$Text, mySentiment , time = twitterMaster.df$Created.At)
tweets.sentr$Id <- format(tweets.sentr$Id, scientific=F)

# Model Evaluation

outBayes <- classify.naivebayes(testdata[1:160,1])
print(table(testdata[1:160,2], outBayes[,4]))

results.sentR <- sentR::classify.naivebayes(tweets_test$V6)
results.sentR[,4] <- ifelse(results.sentR[,4] == 'positive'|results.sentR[,4] == 'neutral' , 4, 0) # translate sentiments back to the original training data
print(table(results.sentR[,4], tweets_test$V1))
