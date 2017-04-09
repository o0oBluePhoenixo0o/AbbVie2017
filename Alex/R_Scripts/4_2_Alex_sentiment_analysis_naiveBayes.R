# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets

# install.packages("e1071")
# install.packages("tm")
# install.packages("SparseM")
# install.packages("stringi")
# install.packages("caret")
# install.packages("dplyr")

library(e1071) 
library(tm)
library(SparseM)
library(stringi)
library(caret)
library(dplyr)


conv_fun <- function(x) iconv(x, "latin1", "UTF-8", "")



tweets.classified <- getTrainingTweets();

# data splitting on train and test, I can only use a small amount of the training data because my system will crash with a higher number
set.seed(2340)
trainIndex <- createDataPartition(tweets.classified$V1, p = 0.00070, 
                                  list = FALSE, 
                                  times = 1)
tweets_train <- tweets.classified[trainIndex, ]
tweets_test <- tweets.classified[-trainIndex, ]


#V6 text (Column 1) V1 sentiment(Column 2)
traindata <- as.data.frame(tweets_train[1:nrow(tweets_train), c(1,2)])
testdata <- as.data.frame(tweets_test[1:nrow(tweets_test), c(1,2)])


traindata$V6 <- stri_encode(traindata$V6, "", "UTF-8") # re-mark encodings
testdata$V6 <- stri_encode(testdata$V6, "", "UTF-8") # re-mark encodings

# SEPARATE TEXT VECTOR TO CREATE Source(),
# Corpus() CONSTRUCTOR FOR DOCUMENT TERM
# MATRIX TAKES Source()
trainvector <- as.vector(traindata$V6);
testvector <- as.vector(testdata$V6);

# CREATE SOURCE FOR VECTORS
trainsource <- VectorSource(trainvector);
testsource <- VectorSource(testvector);


# CREATE CORPUS FOR DATA
traincorpus <- Corpus(trainsource);
testcorpus <- Corpus(testsource);


# CREATE TERM DOCUMENT MATRIX
trainmatrix <- t(TermDocumentMatrix(traincorpus));
testmatrix <- t(TermDocumentMatrix(testcorpus));

# TRAIN NAIVE BAYES MODEL USING trainmatrix DATA AND traindate$Journal_group CLASS VECTOR
model <- naiveBayes(as.matrix(trainmatrix),as.factor(traindata$V1));


# SAVE MODEL FOR LATER USE
saveRDS(model, "naiveBayesModel.RDS")

# PREDICTION
results <- predict(model,as.matrix(testmatrix));
results




getTrainingTweets <- function(){
  message("Loading training tweets")
  tweets.training <- read.csv('trainingandtestdata/training.1600000.processed.noemoticon.csv', header = F)
  tweets.training <- select(tweets.training, 1,6) # only sentiment and text
  tweets.training <- tweets.training[,c(2,1)] # switch columns, only because of the tutorial
  message("Training tweets loaded")
  return(tweets.training)
}



