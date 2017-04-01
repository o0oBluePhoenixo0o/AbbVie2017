#This files contains method to do sentiment analysis on Facebook posts and Twitter tweets

#install.packages("sentimentr")
library(sentimentr)



#- SENTIMENTR -#
myPosts <- c(posts.products$message.x)

myPosts
sentiment_by(myPosts)
