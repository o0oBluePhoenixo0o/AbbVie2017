# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets

# install.packages("sentimentr")
# install.packages("RTextTools")
# install.packages("e1071")
# install.packages("tm")

library(sentimentr)
library(RTextTools)
library(e1071)
library(tm)


initNaiveBayesClassifier <- function(trainingData, save = FALSE, filename){
  # Create a classifier for sentiment anlysis based on Naive Bayes
  #
  # Args:
  #   trainign data: Data to train the classifier
  #   save: Should the classifier be saved to a file
  #
  # Returns:
  #   A naive Bayes classifier
  

    # Create Document-Term Matrix
    matrix <- RTextTools::create_matrix(trainingData[, 1], language = "english", removeStopwords = FALSE, removeNumbers = TRUE, stemWords = FALSE, tm::weightTfIdf)
    mat <- as.matrix(matrix)
    
    # Train Naive Bayes on the manually labeled tweets data
    classifier <- naiveBayes(mat[1:10, ], as.factor(trainingData[1:10, 2]))
    
    predicted = predict(classifier, mat[1:15, ]) # Here we actually classify the tweets according their sentiment
    message("Twitter classifier initalised and trained")
    message("Confusion matrix and recall accuracy")
    
    print(table(trainingData[1:15, 2], predicted)) # Confusion Matrix
    message(sprintf("Recall accuracy: %s", recall_accuracy(trainingData[11:15, 2], predicted) ))
    
    
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

sentiment.classifier.twitter <- initNaiveBayesClassifier(tweets, save = TRUE, "twitterNaivesBayesModel")

