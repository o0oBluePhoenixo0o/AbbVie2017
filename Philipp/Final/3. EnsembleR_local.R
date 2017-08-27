
# check and set working directory
setwd("~/GitHub/AbbVie2017/Philipp/")

# loading required packages
require(e1071)
require(SnowballC)
require(caTools)
require(rpart)
require(rpart.plot)
require(randomForest)
require(h2o)
require(tm)
require(memisc)
require(dplyr)
require(data.table)
require(stringr)
require(RODBC)

Sentitomo <-odbcConnect("sentitomo",uid="abbvieunima",pwd="OY00wPcwOK695i0d")
TW_df <-sqlQuery(Sentitomo,"select * from TW_Tweet")

TW_df <- TW_df[,c("id","message")]
TW_df <- unique(TW_df)

finaldf <- TW_df
finaldf$R_Ensemble <- NA

#load list of models
load("./Final/EnsembleR_objs_1308.RData");

h2o.init()
h2o.loadModel("./Final/DRF_model_R_1502640066600_2")
h2o.loadModel("./Final/GBM_model_R_1502640066600_1")

as.character(finaldf[1,c("message")])

R_Ensemble <- function (text) {
  
  TW_df <- text
  
  #Abbreviation translation
  TW_df <- convertAbbreviations(TW_df)
  # clean
  corp <- vec2clean.corp(TW_df)
  #dtm
  prep <- DocumentTermMatrix(corp)
  str(prep)
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
    require(plyr)
    g <- score.sentiment(TW_df, pos.words, neg.words, .progress='text')
    g <- mutate(g, sentiment = ifelse(g$score > 0, 'Positive', 
                                      ifelse(g$score < 0, 'Negative', 'Neutral')))
    BL <- g$sentiment
    result <- BL
  }
  return(result)
}


test <- finaldf
a<-Sys.time()
test$R_Ensemble <- sapply(test$message, function(x) R_Ensemble(x))
b<-Sys.time()
b-a