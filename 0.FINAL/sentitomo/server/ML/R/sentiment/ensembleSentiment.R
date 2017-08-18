# loading required packages
# setwd("~/CloudStation/Team Project/Topic Monitoring in the Pharmaceutical Industry/AbbVie2017/0.FINAL/sentitomo/server")

source("./ML/R/needs.R")

needs(e1071)
needs(SnowballC)
needs(caTools)
needs(rpart)
needs(rpart.plot)
needs(randomForest)
needs(h2o)
needs(tm)
needs(memisc)
needs(plyr)
needs(dplyr)
needs(data.table)
needs(stringr)

#load list of models
load("./ML/R/sentiment/EnsembleR_objs_1308.RData");

#disable logging, to make server life easier with reading the output, because h2o will output a lot of information messages
sink("/dev/null")
h2o.init()
h2o.loadModel("./ML/R/sentiment/DRF_model_R_1502640066600_2")
h2o.loadModel("./ML/R/sentiment/GBM_model_R_1502640066600_1")

# Get the command line arguments
args = commandArgs(trailingOnly=TRUE)

## Assume CORE dataset is TW_df
# Extract out only ID & Message

TW_df <- args[1]

#Abbreviation translation

myAbbrevs <- read.csv('./ML/R/sentiment/abbrev.csv')
TW_df <- convertAbbreviations(TW_df)
# clean
corp <- vec2clean.corp(TW_df)
#dtm
prep <- DocumentTermMatrix(corp)
prep <- as.data.frame(as.matrix(prep))
#get list of words from the test
words <- names(prep)

#create new dtm that matches original dtm for training
xx <- tryCatch({left_join(prep,tweetsSparseX[1,],by = words)}, error = function(e){message(e)})

result <- NA

#if the new message does not fit in the dtm of train dataset then execute only BingLiu's lexicon
BL <- 0
if("try-error" %in% class(xx)|class(xx) == "NULL") {BL <- 1}

if (BL == 0){
  #put everything to 0s except the message
  xx[,ncol(prep)+1:ncol(xx)] <- 0
  
  h2o.init()
  #put to h2o frame
  xxh2o <- as.h2o(xx)
  
  ########################################
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
  
  final <- try(cbind(CART,RF,SVM,NB,DRF,GBM))
  
  for (i in 1:nrow(final)){
    final$Major[i] <- find_major(final,i)
  }
  #Result of Majority Voting
  result <- final$Major
  
} else {
  g <- score.sentiment(TW_df, pos.words, neg.words, .progress='text')
  g <- mutate(g, sentiment = ifelse(g$score > 0, 'Positive', 
                                    ifelse(g$score < 0, 'Negative', 'Neutral')))
  BL <- g$sentiment
  result <- BL
}

#Turn logging on again
sink()

#Result of EnsembleR
result

