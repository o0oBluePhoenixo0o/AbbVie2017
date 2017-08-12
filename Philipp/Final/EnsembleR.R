
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
library(e1071)
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
library(stringr)

# #################################################
# 
# convertAbbreviations <- function(message){
#   
#   # Replaces abbreviation with the corresporending long form
#   #
#   # Args:
#   #   text: Text to remove the abbreviations from
#   #
#   # Returns:
#   #   String
#   
#   if(is.na(message) || message == ""){
#     return(message)
#   } else {
#     newText <- message
#     for (i in 1:nrow(myAbbrevs)){
#       newText <- gsub(paste0('\\<', myAbbrevs[[i,1]], '\\>'), paste(myAbbrevs[[i,2]]), newText)
#       cat(paste0(newText,"\n"), file="R.out", append = TRUE)
#       
#     }
#     return (newText)
#   }
# } 
# 
# myAbbrevs <- read.csv('abbrev.csv')
#                          
# testabb <- "lol i don't know rofl"
# 
# result_testabb <- convertAbbreviations(testabb)

########################################################
df <- read.csv("Final_Manual_3007.csv", as.is = TRUE, sep = ",")

df <- unique(df)

df$sentiment <- sapply(df$sentiment, function(x)
  x = cases (x %in% c(1,2) -> 'Negative',
             x %in% c(3,4) -> 'Positive',
             x %in% c('N',NA,'',' ') -> 'Neutral'))

#delete the #4516
df <- df[-c(4516),]

agg <- summarize(group_by(df,sentiment),n())

# df$message <- convertAbbreviations(df$message)
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

##########################################################################################################
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
model_path <- h2o.saveModel(object=gbm.model, path=getwd(), force=TRUE)
print(model_path)
predictionsGBM <- as.data.frame(h2o.predict(gbm.model,testH2O))

cmGBM <-   table(testSparse$sentiment, predictionsGBM$predict)

metrics(cmGBM)

##########################################################################################
# H2O DRF

# h2o.init() only need once

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

model_path <- h2o.saveModel(object=h2o_drf, path=getwd(), force=TRUE)
print(model_path)
predictionsDRF <- as.data.frame(h2o.predict(h2o_drf,testH2O))
cmDRF <- table(testSparse$sentiment, predictionsDRF$predict)

metrics(cmDRF)

#############################################################
# e1071 Naive Bayes

NBayes <- naiveBayes(sentiment ~., data = trainSparse, laplace = 3)

predictionsNB <- predict(NBayes, as.data.frame(testSparse))

cmNB <- table(testSparse$sentiment, predictionsNB)

metrics(cmNB)

############################################
#BingLiu Lexicon

#Pulling in positive and negative wordlists
#BingLiu
pos.words <- scan('../Models/Positive.txt', what='character', comment.char=';') #folder with positive dictionary
neg.words <- scan('../Models/Negative.txt', what='character', comment.char=';') #folder with negative dictionary
#Adding words to positive and negative databases
pos.words=c(pos.words, 'Congrats', 'prizes', 'prize', 'thanks', 'thnx', 'Grt', 
            'gr8', 'plz', 'trending', 'recovering', 'brainstorm', 'leader')
neg.words = c(neg.words, 'Fight', 'fighting', 'wtf', 'arrest', 'no', 'not')

#evaluation function
score.sentiment <- function(sentences, pos.words, neg.words, .progress='none')
{
  scores <- laply(sentences, function(sentence, pos.words, neg.words){
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence <- gsub('[[:punct:]]', "", sentence)
    sentence <- gsub('[[:cntrl:]]', "", sentence)
    sentence <- gsub('\\d+', "", sentence)
    #convert to lower-case and remove punctuations with numbers
    sentence <- removePunctuation(removeNumbers(tolower(sentence)))
    removeURL <- function(x) gsub('"(http.*) |(http.*)$|\n', "", x)
    sentence <- removeURL(sentence)
    # split into words. str_split is in the stringr package
    word.list <- str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words <- unlist(word.list)
    # compare our words to the dictionaries of positive & negative terms
    pos.matches <- match(words, pos.words)
    neg.matches <- match(words, neg.words)
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches <- !is.na(pos.matches)
    neg.matches <- !is.na(neg.matches)
    score <- sum(pos.matches) - sum(neg.matches)
    return(score)
  }, pos.words, neg.words, .progress=.progress)
  scores.df <- data.frame(score=scores, message=sentences)
  return(scores.df)
}
require(plyr)
require(stringr)
scores <- score.sentiment(df$message, pos.words, neg.words, .progress='text')
result <- scores

#Add ID to result set
result$Id <- df$Id
#add new scores as a column
result <- mutate(result, Id, sentiment = ifelse(result$score > 0, 'Positive', 
                                                ifelse(result$score < 0, 'Negative', 'Neutral')))

cmBL <- table(df$sentiment,result$sentiment)
metrics(cmBL)

############################################
# MAJORITY VOTING #

finaldf <- cbind(testSparse$sentiment,as.data.frame(predictRF),as.data.frame(predictCART),
                 as.data.frame(predictSVM),predictionsDRF$predict, predictionsGBM$predict,
                 result$sentiment,as.data.frame(predictionsNB))
colnames(finaldf) <- c("Sentiment","RF","CART","SVM","DRF","GBM","BL","NB")

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
tweetsSparseX <- as.data.frame(as.matrix(sparse))
############
# drop non-save objects
rm(agg,CART,df,final_test,finaldf,g,NB,predictionsDRF,predictionsGBM,prep_test,result,RF,
   scores,SVM,BL,cmBL,cmCART,cmGBM,cmMAJOR,cmNB,cmRF,cmSVM1,corp,corptest,DRF,frequencies,i,
   predictCART,predictionsNB,predictRF,predictSVM,sparse,split,
   test,testH2O,trainH2O,xxh2o,cmDRF,tweetsSparse,testSparse,trainSparse,xx)
save.image(file="EnsembleR_objs.RData")
############

test <- "I hate like this Humira It tastes funny..."
#convertAbbreviations(test)
# clean
corptest <- vec2clean.corp(test)
#dtm
prep_test <- DocumentTermMatrix(corptest)
prep_test <- as.data.frame(as.matrix(prep_test))

colnames(tweetsSparseX) <- make.names(colnames(tweetsSparseX))

tweetsSparseX[,1:ncol(tweetsSparseX)] <- 0

xx <- left_join(prep_test,tweetsSparseX[1,])

xx[,ncol(prep_test)+1:ncol(xx)] <- 0

xxh2o <- as.h2o(xx)

CART <- as.data.frame(predict(tweetCART, newdata=xx, type='class'))
names(CART) <- 'CART'

RF <- as.data.frame(predict(tweetRF, newdata=xx))
names(RF) <- 'RF'

SVM <- as.data.frame(predict(SVM1N, newdata=xx, type="class"))
names(SVM) <- 'SVM'

NB <- as.data.frame(predict(NBayes, as.data.frame(xx)))
names(NB) <- 'NB'

DRF <- as.data.frame(h2o.predict(h2o_drf,xxh2o))
DRF <- DRF$predict

GBM <- as.data.frame(h2o.predict(gbm.model, xxh2o))
GBM <- GBM$predict


g <- score.sentiment(test, pos.words, neg.words, .progress='text')
g <- mutate(g, sentiment = ifelse(g$score > 0, 'Positive', 
                           ifelse(g$score < 0, 'Negative', 'Neutral')))
BL <- g$sentiment

final_test <- try(cbind(CART,RF,SVM,NB,DRF,GBM,BL))
final_test

for (i in 1:nrow(final_test)){
  final_test$Major[i] <- find_major(finaldf,i)
}
final_test$Major

h2o.shutdown(prompt = FALSE)
