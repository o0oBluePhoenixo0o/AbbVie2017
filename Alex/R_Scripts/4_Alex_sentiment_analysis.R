# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets

# install.packages("sentimentr")
# install.packages("RTextTools")
# install.packages("e1071")
# install.packages("tm")
# install.packages("caret")

library(sentimentr)
library(RTextTools)
library(e1071)
library(tm)
library(tidyverse)
library(syuzhet)
library(caret)


getTrainingTweets <- function(){
  message("Loading training tweets")
  tweets.training <- read.csv('trainingandtestdata/training.1600000.processed.noemoticon.csv', header = F)
  tweets.training <- select(tweets.training, 1,6) # only sentiment and text
  tweets.training <- tweets.training[,c(2,1)] # switch columns, only because of the tutorial
  message("Training tweets loaded")
  return(tweets.training)
}


# It is working with small matrices on my mashine, but with the whole training set my RSession will crash due to not
# enough memory... maybe someone can check ? 
initNaiveBayesClassifier <- function() {
  tweets.training <- getTrainingTweets()
  tweets.training$V1 <- ifelse(tweets.training$V1 ==0, "negative", "positive") # change sentiment to characters, also because of the tutorial
  
  # From Philipp for splitting the training data
  set.seed(2340)
  trainIndex <- createDataPartition(tweets.training$V1, p = 0.6, 
                                    list = FALSE, 
                                    times = 1)
  
  tweets.training.train <- tweets.training[trainIndex, ]
  tweets.training.test  <- tweets.training[-trainIndex, ]
  message("Training tweets partioned")

  matrix = create_matrix(tweets.training.train[,1], language="english", 
                              removeStopwords=FALSE, removeNumbers=TRUE, 
                              stemWords=FALSE) 
  
  
  message("Create matrix sucessfull")
  mat <- as.matrix(matrix)
  message("as.matrix sucessfull")
  
  
  
  classifier = naiveBayes(mat[1:trainIndex,], as.factor(test[1:trainIndex,2] ))
  
  # test the validity
  predicted = predict(classifier, tweets.training.test[trainIndex:nrow(tweets.training.test),]); predicted
  table(tweets.training.test[trainIndex:nrow(tweets.training.test),], predicted)
  recall_accuracy(tweets.training.test[trainIndex:nrow(tweets.training.test),], predicted)
  
  saveRDS(classifier, "twitterNaiveBayesModel.RDS")
  return(classifier)
}
sentiment.classifier.twitter <- initNaiveBayesClassifier()












