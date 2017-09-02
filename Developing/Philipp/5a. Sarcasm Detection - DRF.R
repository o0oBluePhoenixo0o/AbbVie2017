
# clear the environment
rm(list= ls())

# check and set working directory
setwd("~/GitHub/AbbVie2017/Philipp/")

# loading  libraries
require(tm)      # for text mining
require(dplyr)   # for faster data operations
require(data.table)
require(caTools)
require(qdap)

# loading required package
require(h2o) # to implement random forest quick

loadAbbrev <- function(filename) {
  # Concates custom abbreviation dataset with the default one from qdap
  #
  # Args:
  #   filename: Filename of the abbreviation lexicon
  #
  # Returns:
  #   A 2-column(abv,rep) data.frame
  
  myAbbrevs <- read.csv(filename, sep = ",", as.is = TRUE)
  return(rbind(abbreviations,myAbbrevs))
}

myAbbrevs <- loadAbbrev('abbrev.csv')

convertAbbreviations <- function(message){
  # Replaces abbreviation with the corresporending long form
  #
  # Args:
  #   text: Text to remove the abbreviations from
  #
  # Returns:
  #   String
  if(is.na(message) || message == ""){
    return(message)
  } else {
    newText <- message
    for (i in 1:nrow(myAbbrevs)){
      newText <- gsub(paste0('\\<', myAbbrevs[[i,1]], '\\>'), paste(myAbbrevs[[i,2]]), newText)
    }
    return (newText)
  }
}

# Get data from manual label dataset
manual_test <- read.csv("Final_Manual_3007.csv", as.is = TRUE, sep = ",", stringsAsFactors = F)

manual_test <- manual_test[,c(5,4,7)]
colnames(manual_test) <- c("ID","tweet","label")
manual_test$ID <- as.factor(manual_test$ID)
manual_test$label[manual_test$label %in% c(0,NA)] <- 'non-sarcastic'
manual_test$label[manual_test$label == 1] <- 'sarcastic'

# Get data from 91k dataset
TW_df <- read.csv("TweetsDataSet.csv",stringsAsFactors = F)
TW_df <- unique(TW_df)

# Merge manual label dataset with 91k
TW_df <- rbind(TW_df,manual_test)
TW_df$tweet <- convertAbbreviations(TW_df$tweet)
## Preprocessing the TW_df and cleaning the corpus
# user defined variables and functions
# Function for taking in the vector from TW_df data set and do all preprocessing steps below:
# preprocessing steps- Case folding; Remove numbers, words and punctuation and perform stemming and stripping extra whitespaces

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

# Calling the vec2clean.corp with TW_dfs(x) and we desire to check the progress with document 3(y)

corp <- vec2clean.corp(TW_df$tweet)

# Creating Document Term Matrix from the corp with TF weighting
dtm <- DocumentTermMatrix(corp, control = 
                            list(weighting = weightTf))

# subsetting sarcasm and non sarcasm TW_dfs 
sarcasm     <- TW_df[TW_df$label == 'sarcastic',]
sarcasm <- unique(sarcasm)
sarcasm.not <- TW_df[TW_df$label == 'non-sarcastic',]
sarcasm.not <- unique(sarcasm.not)

# corpus for both sarcastic and non-sarcastic
corp.sarcasm = vec2clean.corp(sarcasm$tweet)
corp.sarcasm.not = vec2clean.corp(sarcasm.not$tweet)

# DTM for sarcasm and non sarcasm corpora
dtm.sar <- DocumentTermMatrix(corp.sarcasm)
dtm.non <- DocumentTermMatrix(corp.sarcasm.not)

common <- NULL
for(i in findFreqTerms(dtm.non)[seq(100)]){
  for(j in findFreqTerms(dtm.sar)[seq(100)]){
    if(identical(i,j)){
      common = c(common,i)
    }
  }
} # common words are passed to feature engineering code

####################################################################################
## Feature engineering and Feature selection
# We check correlations and associations between variables.

#remove sparsity and prepare data frame
sparse <- removeSparseTerms(dtm, 0.9992)
df <- data.table(as.matrix(sparse))

# Find associations 
unlist(findAssocs(sparse, findFreqTerms(sparse,100),corlimit = 0.5))
# this may not provide all correlated pairs
rm(dtm,sparse) # as it is not necessary

# we go for pearson correlation matrix to get more detailed info
corr <- data.table(cor(df, use = "complete.obs", method= "pearson"))
corr.terms <- NULL

for(i in 1:(nrow(corr)-1)){
  for(j in (i+1):ncol(corr)){
    if((abs(corr[[i,j]])>0.49) ==T){
      corr.terms = c(corr.terms, names(corr)[i])
    }}}

# corr.terms consist of correlated terms which are more than 50% with any other variable
# only one term out correlated pair is added while 'for' loop
rm(corr,i,j)
corr.terms

# combining both common and del.words
del.words <- c(corr.terms, common)
del.words <- unique(del.words)

# removing del.words features from master
df[, (del.words) := NULL]
dim(df)

# creating master data set
master <- data.table(label = TW_df$label, df)
master.factor <- as.data.frame(master)

#Binning 
master.factor <- data.frame(lapply(master[,2:ncol(master)], function(x){ifelse(x==0,0,1)}))

# Converting numericals to factors 
master.factor <- data.frame(lapply(master.factor, as.factor))
# master.factor has all categorical variables 0 and 1 factors
master.factor <- cbind(label = master$label, master.factor)

##############################################################################################
# This code is about Preparing samples of the master data set and 
# splitting training and testing sets

# function to create sample and push the train and test data sets out

sample2train.test <- function(master.x, seed.x, samp.ratio= 0.055, train.ratio= 0.8){
  set.seed(seed = seed.x)
  samp.split = sample.split(master.x$label, samp.ratio)
  sample = subset(master.x, samp.split == T)
  
  # training and testing 
  spl = sample.split(sample$label, train.ratio)
  train.x = subset(sample, spl == T )
  test.x  = subset(sample, spl == F )
  return(list(train.x, test.x))
}

# pass the desired master data set, seed(to produce random sample), sample ratio and train ratio
# sample ratio and train ratio are defaulted with 0.055(5022 observations) and 0.8 respectively

# For producing Training and Testing sets of master.factor
Train.Test.list <- sample2train.test(master.factor,123)

train <- Train.Test.list[[1]]
test  <- Train.Test.list[[2]]

# Initializing h2o cluster
h2o.init()

set.seed(123)

# loading data to h2o clusters 
h.train     <- as.h2o(train)
h.test      <- as.h2o(test)

#--------------------------------------------------------------------

# creating predictor and target indices
x <- 2:ncol(train)
y <- 1

# Building random forest model on factor data
rf.model     <- h2o.randomForest(x=x, y=y, training_frame = h.train, ntrees = 1000)

# Random forest evaluation for Factor data
pred <- as.data.frame(h2o.predict(rf.model, h.test))
caret::confusionMatrix(table('Actual class' = test$label, 'Predicted class' = pred$predict))
metrics(table('Actual class' = test$label, 'Predicted class' = pred$predict))

# GBM Model
gbm.model <- h2o.gbm(x=x, y=y, training_frame = h.train,
                     max_depth = 5,
                     ntrees =1000,
                     learn_rate = 0.05)

pred_gbm <- as.data.frame(h2o.predict(h2o.gbm, h.test))

# Deep Learning Model
deep_learning <- h2o.deeplearning( x = x,
                                   y=y, training_frame = h.train,
                                   activation="Rectifier",
                                   hidden=80,
                                   epochs=50,
                                   adaptive_rate =F
)

# saving model 
h2o.saveModel(rf.model, path = "N:/")

# saving data objects
save.image(file="Sarcasm_Obj_DRF.RData")
