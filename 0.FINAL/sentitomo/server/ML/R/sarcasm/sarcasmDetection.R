# loading required packages
source("./ML/R/needs.R");
needs(e1071)
needs(tm)
needs(data.table)
needs(dplyr)

#load list of models
load("./ML/R/sarcasm/Sarcasm_Obj.RData");

# Get the command line arguments
args = commandArgs(trailingOnly=TRUE)

## Assume CORE dataset is TW_df
# Extract out only ID & Message

TW_df <- args[1]

###################################################
# Preprocessing the TW_df and cleaning the corpus #
###################################################

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

corp <- vec2clean.corp(TW_df)

# Creating Document Term Matrix from the corp with TF weighting
dtm <- DocumentTermMatrix(corp, control = 
                            list(weighting = weightTf))

#remove sparsity and prepare data frame
sparse <- removeSparseTerms(dtm, 0.9992)
prep <- data.table(as.matrix(sparse))

# removing del.words features from master
prep[, (del.words) := NULL]

# creating master data set
prep <- as.data.frame(prep)

#create new dtm that matches original dtm for training
xx <- tryCatch({left_join(prep,df[1,])}, error = function(e){message(e)})

#put everything to 0s except the message
xx[,ncol(prep)+1:ncol(xx)] <- 0

#Binning 
xx <- data.frame(lapply(xx[,1:ncol(xx)], function(x){ifelse(x==0,0,1)}))

# Converting numericals to factors 
xx <- data.frame(lapply(xx, as.factor))

#########################################################################
# for robust Naive Bayes model with laplace estimator
n.pred.lap <- predict(n.model.lap, xx, type = 'raw')
output <- round(n.pred.lap[1,2]*100,2)

cat(unname(output))