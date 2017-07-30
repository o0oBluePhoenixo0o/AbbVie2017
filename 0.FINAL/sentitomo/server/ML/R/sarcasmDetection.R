# loading required packages
needs(e1071)
needs(tm)
needs(data.table)


# Load pre-trained model 23.07
load('./ML/R/SD_NB_2307.dat')
# Load list of delete words 23.07
load('./ML/R/del_word.dat')

# Get data from CORE table
attach(input[[1]])

## Assume CORE dataset is TW_df
# Extract out only ID & Message

TW_df <- message

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
df <- data.table(as.matrix(sparse))

# removing del.words features from master
df[, (del.words) := NULL]

# creating master data set
df <- as.data.frame(df)

#Binning 
df <- data.frame(lapply(df[,1:ncol(df)], function(x){ifelse(x==0,0,1)}))

# Converting numericals to factors 
df <- data.frame(lapply(df, as.factor))

#########################################################################
# for robust Naive Bayes model with laplace estimator
n.pred.lap <- predict(n.model.lap, df, type = 'raw')
output <- round(n.pred.lap[1,2]*100,2)
output