
# clear the environment
rm(list= ls())

setwd("~/GitHub/AbbVie2017/Philipp")
#needs(tm)
#needs(h2o)
#needs(memisc)

# # install packages if not available
# packages <- c('tm', 'SnowballC', 'caTools', 'rpart', 'rpart.plot', 'randomForest')
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

#################################################3

df <- read.csv("Final_Manual_3007.csv", as.is = TRUE, sep = ",")

df <- unique(df)

df$sentiment <- sapply(df$sentiment, function(x)
  x = cases (x %in% c(1,2) -> 'Negative',
             x %in% c(3,4) -> 'Positive',
             x %in% c('N',NA,'',' ') -> 'Neutral'))

agg <- summarize(group_by(df,sentiment),n())

#delete the #4516
df <- df[-c(4516),]

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
set.seed(1234)
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

metrics(cmCART)

#####################################################
# Random Forest
set.seed(123)
tweetRF <- randomForest(sentiment ~ ., data=trainSparse)

predictRF <- predict(tweetRF, newdata=testSparse)

cmRF <-   table(testSparse$sentiment, predictRF)

metrics(cmRF)

###############################################
# SVM
library(e1071)

SVM1N <- svm(sentiment ~ ., type='C', data=trainSparse, kernel='radial')

PT1.test2 <- predict(SVM1N, newdata=testSparse, type="class")
cmSVM1 <- table(testSparse$sentiment, PT1.test2)
metrics(cmSVM1)

##########################################################################################
# H2O DRF
library(text2vec)

# vec2clean function takes two arguments: x = vector to be cleaned
vec2clean <- function(x){
  
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
  
  x <- conv_fun(x)
  x <- tolower(x)
  x <- removeNumbers(x)
  x <- removeWords(x,a)
  x <- AposToSpace(x)
  x <- stemDocument(x)
  x <- stripWhitespace(x)
    return(x)
}

# Build a training and testing set for Text2Vec

set.seed(1234)
split <- sample.split(df$sentiment, SplitRatio=0.8)

train2vec <- subset(df[c("message","Id")], split==TRUE)
test2vec <- subset(df[c("message","Id")], split==FALSE)

# Word2Vec
it_train <- itoken(vec2clean(train2vec$message), 
                   ids = train2vec$Id, 
                   progressbar = TRUE)

it_test <- itoken(vec2clean(test2vec$message), 
                  ids = test2vec$Id, 
                  progressbar = TRUE)

it_train <- h2o.word2vec(h2o.tokenize(vec2clean(train2vec$message)))

h2o.init()
h2o.toFrame(trainSparse[,-1])

h2o_drf <- h2o.randomForest(    
  training_frame = trainSparse,       
  validation_frame = testSparse,     
  x=2:ncol(trainSparse),            
  y=1,                          
  ntrees = 500,                 # Increase max trees to 500 
  max_depth = 30,               # Increase depth, from 20
  stopping_rounds = 2,          #
  stopping_tolerance = 1e-2,    #
  score_each_iteration = T,     #
  seed=1234)                    #


# 
# tokenize <- function(sentences, stop.words = STOP_WORDS) {
#   tokenized <- h2o.tokenize(sentences, "\\\\W+")
#   
#   # convert to lower case
#   tokenized.lower <- h2o.tolower(tokenized)
#   # remove short words (less than 2 characters)
#   tokenized.lengths <- h2o.nchar(tokenized.lower)
#   tokenized.filtered <- tokenized.lower[is.na(tokenized.lengths) || tokenized.lengths >= 2,]
#   # remove words that contain numbers
#   tokenized.words <- tokenized.filtered[h2o.grep("[0-9]", tokenized.filtered, invert = TRUE, output.logical = TRUE),]
#   
#   # remove stop words
#   tokenized.words[is.na(tokenized.words) || (! tokenized.words %in% STOP_WORDS),]
# }
# 
# predict <- function(job.title, w2v, gbm) {
#   words <- tokenize(as.character(as.h2o(job.title)))
#   job.title.vec <- h2o.transform(w2v, words, aggregate_method = "AVERAGE")
#   h2o.predict(gbm, job.title.vec)
# }
# 
# print("Break job titles into sequence of words")
# words <- tokenize(job.titles$jobtitle)
# print("Build word2vec model")
# w2v.model <- h2o.word2vec(words, sent_sample_rate = 0, epochs = 10)
# 
# print("Sanity check - find synonyms for the word 'teacher'")
# print(h2o.findSynonyms(w2v.model, "teacher", count = 5))
# 
# print("Calculate a vector for each job title")
# job.title.vecs <- h2o.transform(w2v.model, words, aggregate_method = "AVERAGE")
# 
# print("Prepare training&validation data (keep only job titles made of known words)")
# valid.job.titles <- ! is.na(job.title.vecs$C1)
# data <- h2o.cbind(job.titles[valid.job.titles, "category"], job.title.vecs[valid.job.titles, ])
# data.split <- h2o.splitFrame(data, ratios = 0.8)
# 
# print("Build a basic GBM model")
# gbm.model <- h2o.gbm(x = names(job.title.vecs), y = "category",
#                      training_frame = data.split[[1]], validation_frame = data.split[[2]])
# 
# print("Predict!")
# print(predict("school teacher having holidays every month", w2v.model, gbm.model))
# print(predict("developer with 3+ Java experience, jumping", w2v.model, gbm.model))
# print(predict("Financial accountant CPA preferred", w2v.model, gbm.model))
words <- tokenize(job.titles$jobtitle)