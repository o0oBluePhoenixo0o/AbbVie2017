# This files contains a naive bayes method to do sentiment analysis on Facebook posts and Twitter tweets

# install.packages("e1071")
# install.packages("tm")
# install.packages("SparseM")
# install.packages("stringi")
# install.packages("caret")
# install.packages("dplyr")
# install.packages("RTextTools")

library(e1071) 
library(tm)
library(SparseM)
library(stringi)
library(caret)
library(dplyr)
library(RTextTools)


getTrainingTweets <- function(){
  # Loads the training tweets
  #
  # Returns:
  #   The training tweets data.frame
  
  message("Loading training tweets")
  tweets.training <- read.csv('trainingandtestdata/training.1600000.processed.noemoticon.csv', header = F)
  tweets.training <- select(tweets.training, 1,6) # only sentiment and text
  tweets.training <- tweets.training[,c(2,1)] # switch columns, only because of the tutorial
  message("Training tweets loaded")
  return(tweets.training)
}



askUser <- function() { 
  # Ask the user wether to load model from saved file or train a new model
  #
  # Returns:
  #   The model of the naive bayes classifier
  
  if (file.exists("naiveBayesModel.RDS")) {
    answer <- readline(prompt="It exists an naiveBayesModel.RDS in the current directory. Do you want to load it? [y] or train a new one ? [n]:  ")
  } else {
    message("It appears no existing model in the current directory. A new model will be trained.")
    answer <- "n"
  }
  return(answer)
}


conv_fun <- function(x) iconv(x, "latin1", "UTF-8", "")


trainClassifier <- function(tweets.classified, save = TRUE){
  # Trains the classifier with the classified training tweets
  #
  # Returns:
  #   The model of the naive bayes classifier
  
  # data splitting on train and test, I can only use a small amount of the training data because my system will crash with a higher number
  set.seed(2340)
  trainIndex <- createDataPartition(tweets.classified$V1, p = 0.00070, 
                                    list = FALSE, 
                                    times = 1)
  
  tweets_train <- tweets.classified[trainIndex, ]
  tweets_test <- tweets.classified[-trainIndex, ]
  
  # Take only a small portion to test
  testIndex <- createDataPartition(tweets.classified$V1, p = 0.00010, 
                                   list = FALSE, 
                                   times = 1)
  tweets_test <- tweets_test[testIndex, ] 
  
  
  #V6 text (Column 1) V1 sentiment(Column 2)
  traindata <- as.data.frame(tweets_train[1:nrow(tweets_train), c(1,2)])
  testdata <- as.data.frame(tweets_test[1:nrow(tweets_test), c(1,2)])
  
  
  traindata$V6 <- stri_encode(traindata$V6, "", "UTF-8") # re-mark encodings
  testdata$V6 <- stri_encode(testdata$V6, "", "UTF-8") # re-mark encodings
  
  # Separate text vector to create Source(),
  # Corpus() constructor for document term
  # Matrix takes Source()
  trainvector <- as.vector(traindata$V6);
  testvector <- as.vector(testdata$V6);
  
  # Create source for vectors
  trainsource <- VectorSource(trainvector);
  testsource <- VectorSource(testvector);
  
  
  # Create corpus for data
  traincorpus <- Corpus(trainsource);
  testcorpus <- Corpus(testsource);
  
  
  # Create term document matrix
  trainmatrix <- t(TermDocumentMatrix(traincorpus));
  testmatrix <- t(TermDocumentMatrix(testcorpus));
  
  # Train naives bayes model with trainmatrix data and traindata$V1 sentiment values 
  message("Model now gets learned")
  model <- naiveBayes(as.matrix(trainmatrix),as.factor(traindata$V1));
  
  if (save){
    # Save model if value is set
    saveRDS(model, paste0("./models/","naiveBayesModel.RDS"))
  }

  # Model Evaluation
  results <- predict(model,as.matrix(testmatrix[1:160,]));
  print(table(results,testdata[1:160,2]))
  return(model)
  
}



initNaiveBayes <- function(){
  # Initialze the naive bayes model for sentiment analysis
  #
  # Returns:
  #   The model of the naive bayes classifier
  
  
  answer <- askUser()
  if (tolower(answer) == "y") {
    message("Load model from file")
    naiveBayesModel <- readRDS("./models/naiveBayesModel.RDS")
    return(naiveBayesModel)
  } else {
    message("Train model")
    naiveBayesModel <- trainClassifier(getTrainingTweets())
    return(naiveBayesModel)
  }
}

naiveBayesModel <- initNaiveBayes()




