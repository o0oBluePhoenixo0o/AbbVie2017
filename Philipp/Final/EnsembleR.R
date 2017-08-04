
# clear the environment
rm(list= ls())

setwd("~/GitHub/AbbVie2017/Philipp")
#needs(tm)
#needs(h2o)
#needs(memisc)

# # install packages if not available
# packages <- c('tm', 'SnowballC', 'caTools', 'rpart', 'rpart.plot', 'randomForest','data.table',
# 'dplyr')
# if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
#   install.packages(setdiff(packages, rownames(installed.packages())))
# }

library(SnowballC)
library(caTools)
library(rpart)
library(rpart.plot)
library(randomForest)
library(h2o)
library(tm)
library(memisc)
library(dplyr)
library(data.table)


#################################################3

df <- tweets_classified[,which(names(tweets_classified) %in% c("text","sentiment"))]
colnames(df) <- c("sentiment", "message")
df <- unique(df)

df$sentiment <- sapply(df$sentiment, function(x)
  x = cases (x %in% c(1,2) -> 'Negative',
             x %in% c(3,4) -> 'Positive',
             x %in% c('N',NA,'',' ') -> 'Neutral'))

agg <- summarize(group_by(df,sentiment),n())


#######################################################
# Preprocessing the dataframe and cleaning the corpus #
#######################################################

# Function for taking in the vector from TW_df data set and do all preprocessing steps below:
# preprocessing steps- Case folding; Remove numbers, URLs, words 
# and punctuation and perform stemming and stripping extra whitespaces

conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")
removeURL <- function(x) gsub('"(http.*) |(http.*)$|\n', "", x)

# vec2clean.corp function takes two arguments: x = vector to be cleaned
vec2clean.corp <- function(x){
  
  # As there are many languages used in the data, we consider stopwords of all the languages
  a = c(stopwords("danish"),stopwords("dutch"),stopwords("english"),
        stopwords("finnish"),stopwords("french"), stopwords('SMART'),
        stopwords("german"),stopwords("hungarian"),stopwords("italian"),
        stopwords("norwegian"),stopwords("portuguese"),stopwords("russian"),
        stopwords("spanish"),stopwords("swedish"))
  
  # Function to replace ' and " to spaces before removing punctuation to avoid different words from binding 
  AposToSpace = function(x){
    x= gsub("'", ' ', x)
    x= gsub('"', ' ', x)
    x =gsub('break','broke',x) # break may interrupt control flow in few functions
    return(x)
  }
  
  x = Corpus(VectorSource(x))
  x = tm_map(x, conv_fun)
  x = tm_map(x, removeURL)
  x = tm_map(x, tolower)
  x = tm_map(x, removeNumbers)
  x = tm_map(x, removeWords, a)
  x = tm_map(x, AposToSpace)
  x = tm_map(x, removePunctuation)
  x = tm_map(x, stemDocument)
  x = tm_map(x, stripWhitespace)
  
  return(x)
}


# Calling the vec2clean.corp with TW_df(x)

corp <- vec2clean.corp(df$message)

# Extract frequent terms
frequencies <- DocumentTermMatrix(corp)
findFreqTerms(frequencies, lowfreq = 20)

# Remove these words that are not used very often. Keep terms that appear in 0.5% or more of tweets.
sparse <- removeSparseTerms(frequencies, 0.995)

tweetsSparse <- as.data.frame(as.matrix(sparse))
colnames(tweetsSparse) <- make.names(colnames(tweetsSparse))
tweetsSparse <- cbind(sentiment = df$sentiment, tweetsSparse)

# Build a training and testing set.
set.seed(1908)
split <- sample.split(tweetsSparse$sentiment, SplitRatio=0.8)
trainSparse <- subset(tweetsSparse, split==TRUE)
testSparse <- subset(tweetsSparse, split==FALSE)

#############################################################
# Function to calculate accuracy/prediction/recall

metrics <- function(cm) {
  n = sum(cm) # number of instances
  nc = nrow(cm) # number of classes
  diag = diag(cm) # number of correctly classified instances per class 
  rowsums = apply(cm, 1, sum) # number of instances per class
  colsums = apply(cm, 2, sum) # number of predictions per class
  p = rowsums / n # distribution of instances over the actual classes
  q = colsums / n # distribution of instances over the predicted classes
  
  #Accuracy
  accuracy = sum(diag) / n
  
  #Per-class Precision, Recall, and F-1
  precision = diag / colsums 
  recall = diag / rowsums 
  f1 = 2 * precision * recall / (precision + recall) 
  
  #One-For-All
  OneVsAll = lapply(1 : nc,
                    function(i){
                      v = c(cm[i,i],
                            rowsums[i] - cm[i,i],
                            colsums[i] - cm[i,i],
                            n-rowsums[i] - colsums[i] + cm[i,i]);
                      return(matrix(v, nrow = 2, byrow = T))})
  
  s = matrix(0, nrow = 2, ncol = 2)
  for(i in 1 : nc){s = s + OneVsAll[[i]]}
  
  #Average Accuracy
  avgAccuracy = sum(diag(s)) / sum(s)
  
  #Macro Averaging
  macroPrecision = mean(precision)
  macroRecall = mean(recall)
  macroF1 = mean(f1)
  
  #Micro Averageing
  micro_prf = (diag(s) / apply(s,1, sum))[1]
  
  #####################################
  #Matthew Correlation Coefficient
  mcc_numerator<- 0
  temp <- array()
  count <- 1
  
  for (k in 1:nrow(cm)){
    for (l in 1:nrow(cm)){
      for (m in 1:nrow(cm)){
        temp[count] <- (cm[k,k]*cm[m,l])-(cm[l,k]*cm[k,m])
        count <- count+1}}}
  sum(temp)
  mcc_numerator <- sum(temp)
  
  mcc_denominator_1 <- 0 
  count <- 1
  mcc_den_1_part1 <- 0
  mcc_den_1_part2 <- 0
  
  for (k in 1:nrow(cm)){
    mcc_den_1_part1 <- 0
    for (l in 1:nrow(cm)){
      mcc_den_1_part1 <- mcc_den_1_part1 + cm[l,k]}
    
    mcc_den_1_part2 <- 0;
    
    for (f in 1:nrow(cm)){
      if (f != k){
        for (g in 1:nrow(cm)){
          mcc_den_1_part2 <- mcc_den_1_part2+cm[g,f]
        }}}
    mcc_denominator_1=(mcc_denominator_1+(mcc_den_1_part1*mcc_den_1_part2));
  }
  
  
  mcc_denominator_2 <- 0 
  count <- 1
  mcc_den_2_part1 <- 0
  mcc_den_2_part2 <- 0
  
  for (k in 1:nrow(cm)){
    mcc_den_2_part1 <- 0
    for (l in 1:nrow(cm)){
      mcc_den_2_part1 <- mcc_den_2_part1 + cm[k,l]}
    
    mcc_den_2_part2 <- 0;
    
    for (f in 1:nrow(cm)){
      if (f != k){
        for (g in 1:nrow(cm)){
          mcc_den_2_part2 <- mcc_den_2_part2+cm[f,g]
        }}}
    mcc_denominator_2=(mcc_denominator_2+(mcc_den_2_part1*mcc_den_2_part2));
  }
  
  mcc = (mcc_numerator)/((mcc_denominator_1^0.5)*(mcc_denominator_2^0.5))
  
  final <- as.data.frame(cbind(accuracy,precision,recall,avgAccuracy,
                               macroPrecision,macroRecall,macroF1,
                               micro_prf,mcc))
  return(final)
}

##############################################################
# Build a CART classification regression tree model on the training set.
tweetCART <- rpart(sentiment ~ ., data=trainSparse, method='class')
prp(tweetCART)

predictCART <- predict(tweetCART, newdata=testSparse, type='class')
cmCART <- table(testSparse$sentiment, predictCART)

metrics(cmCART) # 67%

#####################################################
# Random Forest
set.seed(123)
tweetRF <- randomForest(sentiment ~ ., data=trainSparse)

predictRF <- predict(tweetRF, newdata=testSparse)

cmRF <-   table(testSparse$sentiment, predictRF)

metrics(cmRF) #76%

###############################################
# SVM
library(e1071)

SVM1N <- svm(sentiment ~ ., type='C', data=trainSparse, kernel='radial')

predictSVM <- predict(SVM1N, newdata=testSparse, type="class")
cmSVM1 <- table(testSparse$sentiment, predictSVM)
metrics(cmSVM1) #75%

###############################################
# H2O GBM
h2o.init()

# Build a training and testing set for H2O environment

trainH2O <- as.h2o(trainSparse)
testH2O <- as.h2o(testSparse)

# Train GBM model
gbm.model <- h2o.gbm(  training_frame = trainH2O,
                       validation_frame = testH2O,
                       x=2:ncol(trainSparse),            
                       y=1,         
                       ntrees = 500, 
                       max_depth = 50, 
                       learn_rate = 0.3, 
                       seed = 1234)


predictionsGBM <- as.data.frame(h2o.predict(gbm.model,testH2O))

cmGBM <-   table(testSparse$sentiment, predictionsGBM$predict)

metrics(cmGBM)

##########################################################################################
# H2O DRF

h2o.init()

# Build a training and testing set for H2O environment

trainH2O <- as.h2o(trainSparse)
testH2O <- as.h2o(testSparse)

h2o_drf <- h2o.randomForest(    
  training_frame = trainH2O,
  validation_frame = testH2O,
  x=2:ncol(trainSparse),            
  y=1,                          
  ntrees = 500,                 # Increase max trees to 500 
  max_depth = 30,               # Increase depth, from 20
  nbins_cats = 5000,            #
  seed = 1234)                  #

predictionsDRF <- as.data.frame(h2o.predict(h2o_drf,testH2O))
cmDRF <- table(testSparse$sentiment, predictionsDRF$predict)

metrics(cmDRF)

#############################################################3
# e1071 Naive Bayes

NB <- naiveBayes(sentiment ~., data = tweetsSparse, laplace = 3)

predictionsNB <- predict(NB, as.data.frame(testSparse))

cmNB <- table(testSparse$sentiment, predictionsNB)

metrics(cmNB)

############################################
############################################
# MAJORITY VOTING #

finaldf <- cbind(testSparse$sentiment,as.data.frame(predictRF),as.data.frame(predictCART),
                 as.data.frame(predictSVM),predictionsDRF$predict, predictionsGBM$predict)
colnames(finaldf) <- c("Sentiment","RF","CART","SVM","DRF","GBM")

#The majority vote

find_major <- function(df,x){
  a <- df[x,]
  neg <- 0
  pos <- 0
  neu <- 0
  for (i in 2:ncol(df)){
    if (a[i] == 'Negative'){neg <- neg + 1}
    if (a[i] == 'Positive'){pos <- pos + 1}
    if (a[i] == 'Neutral'){neu <- neu + 1}
  }
  result <- c("Positive", "Negative", "Neutral")[which.max(c(pos,neg,neu))]
}

for (i in 1:nrow(finaldf)){
  finaldf$Major[i] <- find_major(finaldf,i)
}

cmMAJOR <- table(finaldf$Sentiment, finaldf$Major)

metrics(cmMAJOR)

############


test <- "I'm really fucking sad!"

# clean
corptest <- vec2clean.corp(test)
#dtm
prep_test <- DocumentTermMatrix(corptest)

prep_test <- as.data.frame(as.matrix(prep_test))

prep_test <- as.h2o(prep_test)

predict(SVM1N, newdata=prep_test, type="class")

h2o.predict(h2o_drf,prep_test)
h2o.predict(gbm.model, prep_test)
