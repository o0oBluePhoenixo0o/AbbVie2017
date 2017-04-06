# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets

# install.packages("sentimentr")
# install.packages("RTextTools")
# install.packages("e1071")
# install.packages("tm")

library(sentimentr)
library(RTextTools)
library(e1071)
library(tm)
library(tidyverse)


initNaiveBayesClassifier <- function(tweets, save = FALSE, filename){
  # Create a classifier for sentiment anlysis based on Naive Bayes
  #
  # Args:
  #   trainign data: Data to train the classifier
  #   save: Should the classifier be saved to a file
  #
  # Returns:
  #   A naive Bayes classifier
  

    # Create Document-Term Matrix
  View(tweets)
    matrix= RTextTools::create_matrix(tweets[,1], language="english", 
                        removeStopwords=FALSE, removeNumbers=TRUE, 
                        stemWords=FALSE)     
    mat = as.matrix(matrix)
    View(mat)
    
    # Train Naive Bayes on the manually labeled tweets data
    # mat is the matrix with preprocessed tweets, as.factor() converts strings into factors
  
    classifier = naiveBayes(mat[1:10,], as.factor(tweets[1:10,2]) )
    
    # test the validity
    print(dim(mat[11:15,]))
    predicted = predict(classifier, mat[11:15,]); predicted
    print(table(tweets[11:15, 2], predicted))
    recall_accuracy(tweets[11:15, 2], predicted)
    
    
    if (save) {
      saveRDS(classifier, paste0(filename,".RDS"))
    }
    
    return(classifier)
}

sentimentTwitter<- function(tweets){
  # Classifies twitter tweets according their sentiment level, using Naives Bayes trained with tweets
  #
  # Args:
  #   tweets: Document term matrix of tweets
  #
  # Returns:
  #   Factor containing the classes of the different tweets ordered by input
  
  if (is.null(tweets)) {
    message("Please provide an argument")
    return(NA)
  } else if (!is.matrix(tweets)) {
    message(sprintf("Argument is not of class matrix it is a %s", class(tweets)))
    return(NA)
  }

  
  if(is.null(sentiment.classifier.twitter) || is.na(sentiment.classifier.twitter)){
    message("Classifier is not initialised!")
    return(NA)
  }
  
  return(predict(sentiment.classifier.twitter, tweets[, ]))
}



# Load manually labeled tweets
pos_tweets = rbind(c("I love this car", "positive"),
                   c("This view is amazing","positive"),
                   c("I feel great this morning", "positive"),
                   c("I am so excited about the concert", "positive"),
                   c("He is my best friend", "positive"))

neg_tweets = rbind(c("I do not like this car", "negative"),
                   c("This view is horrible", "negative"),
                   c("I feel tired this morning", "negative"),
                   c("I am not looking forward to the concert","negative"),
                   c("He is my enemy", "negative"))

# Tweets to test the classifier
test_tweets = rbind(c("feel happy this morning", "positive"),
                    c("larry friend","positive"),
                    c("not like that man", "negative"),
                    c("house not great", "negative"), 
                    c("your song annoying", "negative"))

tweets = rbind(pos_tweets, neg_tweets, test_tweets)
print(class(tweets))

conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")
tweets_classified <- read_csv('trainingandtestdata/training.1600000.processed.noemoticon.csv',
                              col_names = c('sentiment', 'id', 'date', 'query', 'user', 'text')) %>%
  # converting some symbols
  dmap_at('text', conv_fun) %>%
  # replacing class values
  mutate(sentiment = ifelse(sentiment == 0, "negative", "positive"))

tweets.classified.training <- select(tweets_classified , 1, 6)# sentiment, text
tweets.classified.training <- head(tweets.classified.training, 15)
tweets.classified.training <- tweets.classified.training[c("text", "sentiment")] # switch columns
tweets.classified.training <- as.matrix(tweets.classified.training)
print(dim(tweets.classified.training))
sentiment.classifier.twitter <- initNaiveBayesClassifier(tweets.classified.training, save = TRUE, "twitterNaivesBayesModel")

