setwd("~/GitHub/AbbVie2017/Philipp")

library(memisc)

# function for converting some symbols
conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")
# Test set 15.05.17
testdf <- read.csv("Final_Manual_1505.csv", as.is = TRUE, sep = ",") 

    
testdf$sentiment <- sapply(testdf$sentiment, function(x)
                          x = cases (x %in% c(1,2) -> 'Negative',
                                      x %in% c(3,4) -> 'Positive',
                                      x == 'N' -> 'Neutral'))

testdf <- testdf[, which(names(testdf) %in% c("message","Id","sentiment"))]
# converting some symbols
testdf$message <- sapply(testdf$message, function(x) conv_fun(x))

#####################################################################
# loading packages
library(tidyverse)
library(text2vec)
library(caret)
library(glmnet)
library(ggrepel)

### loading and preprocessing a training set of tweets
# function for converting some symbols
conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")

##### loading classified tweets ######
# source: http://help.sentiment140.com/for-students/
# 0 - the polarity of the tweet (0 = negative, 4 = positive)
# 1 - the id of the tweet
# 2 - the date of the tweet
# 3 - the query. If there is no query, then this value is NO_QUERY.
# 4 - the user that tweeted
# 5 - the text of the tweet

tweets_classified <- read_csv('trainingandtestdata/training.1600000.processed.noemoticon.csv',
                              col_names = c('sentiment', 'id', 'date', 'query', 'user', 'text')) %>%
  # converting some symbols
  dmap_at('text', conv_fun) %>%
  # replacing class values
  mutate(sentiment = ifelse(sentiment == 0, 0, 1))

# there are some tweets with NA ids that we replace with dummies
tweets_classified_na <- tweets_classified %>%
  filter(is.na(id) == TRUE) %>%
  mutate(id = c(1:n()))
tweets_classified <- tweets_classified %>%
  filter(!is.na(id)) %>%
  rbind(., tweets_classified_na)

# data splitting on train and test
set.seed(2340)
trainIndex <- createDataPartition(tweets_classified$sentiment, p = 0.8, 
                                  list = FALSE, 
                                  times = 1)
tweets_train <- tweets_classified[trainIndex, ]
tweets_test <- tweets_classified[-trainIndex, ]

##### doc2vec #####
# define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer

it_train <- itoken(tweets_train$text, 
                   preprocessor = prep_fun, 
                   tokenizer = tok_fun,
                   ids = tweets_train$id,
                   progressbar = TRUE)
it_test <- itoken(tweets_test$text, 
                  preprocessor = prep_fun, 
                  tokenizer = tok_fun,
                  ids = tweets_test$id,
                  progressbar = TRUE)

#####################################################################################

# creating vocabulary and document-term matrix
vocab <- create_vocabulary(it_train)
vectorizer <- vocab_vectorizer(vocab)
dtm_train <- create_dtm(it_train, vectorizer)
dtm_test <- create_dtm(it_test, vectorizer)

# define tf-idf model
tfidf <- TfIdf$new()

# fit the model to the train data and transform it with the fitted model
dtm_train_tfidf <- fit_transform(dtm_train, tfidf)
dtm_test_tfidf <- fit_transform(dtm_test, tfidf)

#############################################################
### Apply model on test dataset

# loading classification model (87.5%)
glmnet_classifier <- readRDS('Models/0204_glmnet_classifier.RDS')

# tokenization
it_txt <- itoken(testdf$message,
                 preprocessor = prep_fun,
                 tokenizer = tok_fun,
                 ids = testdf$id,
                 progressbar = TRUE)

# creating vocabulary and document-term matrix
dtm_txt <- create_dtm(it_txt, vectorizer)

# transforming data with tf-idf
dtm_txt_tfidf <- fit_transform(dtm_txt, tfidf)

# predict probabilities of positiveness
preds_txt <- predict(glmnet_classifier, dtm_txt_tfidf, type = 'response')[ ,1]

# adding rates to initial dataset
testdf$preds_txt <- preds_txt
testdf$sentiment_result <- cases(preds_txt >=0.65 -> 'Positive',
                                 preds_txt >=0.35 -> 'Neutral',
                                 preds_txt < 0.35 -> 'Negative',
                                 check.xor = FALSE)

################################################################
#Calculating confusion matrix
a <- testdf$sentiment
b <- testdf$sentiment_result

cm <- caret::confusionMatrix(a,b)$table
cm
n = sum(cm) # number of instances
nc = nrow(cm) # number of classes
diag = diag(cm) # number of correctly classified instances per class 
rowsums = apply(cm, 1, sum) # number of instances per class
colsums = apply(cm, 2, sum) # number of predictions per class
p = rowsums / n # distribution of instances over the actual classes
q = colsums / n # distribution of instances over the predicted classes

#Accuracy
accuracy = sum(diag) / n
accuracy
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
data.frame(macroPrecision, macroRecall, macroF1)

#Micro Averageing
micro_prf = (diag(s) / apply(s,1, sum))[1]
micro_prf

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
mcc
