## Unstructured to Structured

# In this code, we create a corpus, clean the corpus and 
# Implement tokenization by creating DTM

# clear the environment
rm(list= ls())

# check and set working directory
setwd("~/GitHub/AbbVie2017/Philipp/")

# loading required libraries

require(tm)           # for text mining
require(dtplyr)   # for faster data operations

# reading the data set from current working directory
TW_df <- read.csv("TweetsDataSet.csv",as.is = TRUE, sep = ",")
TW_df <- unique(TW_df)
# checking structure and summary
dim(TW_df)
str(TW_df)
summary(TW_df)


## Preprocessing the TW_df and cleaning the corpus

# user defined variables and functions

# Function for taking in the vector from TW_df data set and do all preprocessing steps below:
# preprocessing steps- Case folding; Remove numbers, words and punctuation and perform stemming and stripping extra whitespaces


# vec2clean.corp function takes two arguments: x = vector to be cleaned, y = document number to show the process by printing
vec2clean.corp <- function(x,y=NULL){
  
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
  print(x$content[[y]])
  x = tm_map(x, tolower)
  print(x$content[[y]])
  x = tm_map(x, removeNumbers)
  print(x$content[[y]])
  x = tm_map(x, removeWords, a)
  print(x$content[[y]])
  x = tm_map(x, AposToSpace)
  print(x$content[[y]])
  x = tm_map(x, removePunctuation)
  print(x$content[[y]])
  x = tm_map(x, stemDocument)
  print(x$content[[y]])
  x = tm_map(x, stripWhitespace)
  print(x$content[[y]])
  
  return(x)
  
}

# Calling the vec2clean.corp with TW_dfs(x) and we desire to check the progress with document 3(y)

corp <- vec2clean.corp(TW_df$message,37)
corp

# Creating Document Term Matrix from the corp with TF weighting
dtm <- DocumentTermMatrix(corp, control = 
                            list(weighting = weightTf))
dtm
# dtm has (documents: 91298, terms: 30554) with 100% sparsity


# Removing Sparse term and take out those words which are more relevant
sparse.dtm <- removeSparseTerms(dtm, 0.999 )
sparse.dtm
# sparse.dtm has (documents: 91298, terms: 783)

# converting Document term matrix to a Data frame
TW_dfs.df <- data.frame(as.matrix(sparse.dtm)) # TW_dfs.df has 442 features(0.9982 sparsity)

############################################################################3
## Wordcloud 
require(data.table)
require(wordcloud)
require(ggplot2)

## creating wordcloud for entire data set

# creating word frequency data frame
word.freq <- sort(colSums(data.table(as.matrix(sparse.dtm))), decreasing = T)
word.freq <- data.table(Terms = names(word.freq), frequency = word.freq)

# creating word cloud for top 200 words in frequency
wordcloud(word.freq$Terms, word.freq$frequency,max.words = 150, scale = c(4,0.75),
          random.order = F, colors=brewer.pal(8, "Dark2"))
a <- word.freq[frequency>2000]

# Bar graph for words that are more frequent appearing more than 2000 times
ggplot(a, aes(Terms, frequency))+
  geom_bar(stat = 'identity', colour = '#041838', fill = '#0b439e')+
  labs(title= 'Alphabetical ordered High frequent Terms')
#clearing graphical memory
dev.off()

## Seperate Word clouds for sarcastic and non-sarcastic TW_dfs
# subsetting sarcasm and non sarcasm TW_dfs 
sarcasm     <- TW_df[TW_df$sarcastic == 1,]
sarcasm <- unique(sarcasm)
sarcasm.not <- TW_df[TW_df$sarcastic == 0,]
sarcasm.not <- unique(sarcasm.not)
# corpus for both sarcastic and non-sarcastic

corp.sarcasm = vec2clean.corp(sarcasm$message, 5)
# Wordcloud for Sarcasm subset
wordcloud(corp.sarcasm, min.freq = 300, max.words = 300,
          random.order = F, scale = c(5 ,0.75),  colors=brewer.pal(8, "Dark2"))

corp.sarcasm.not = vec2clean.corp(sarcasm.not$message, 5)
# Wordcloud for Non Sarcasm subset
wordcloud(corp.sarcasm.not, min.freq = 200, max.words = 300,
          random.order = F, scale = c(5 ,0.75),  colors=brewer.pal(8, "Dark2"))

# DTM for sarcasm and non sarcasm corpora
dtm.sar <- DocumentTermMatrix(corp.sarcasm)
dtm.non <- DocumentTermMatrix(corp.sarcasm.not)

# Most frequent 30 words in Sarcasm and non-sarcasm DTMs
findFreqTerms(dtm.sar)[seq(30)]
findFreqTerms(dtm.non)[seq(30)]

# Finding out the most common words and frequent words 
# These words should be eliminated from the master DTM
common <- NULL
for(i in findFreqTerms(dtm.non)[seq(100)]){
  for(j in findFreqTerms(dtm.sar)[seq(100)]){
    if(identical(i,j)){
      common = c(common,i)
      print(i)
    }
  }
}
common # common words are passed to feature engineering code

####################################################################################
## This code is about Feature engineering and Feature selection
# We check correlations and associations between variables.

#remove sparsity and prepare data frame
sparse <- removeSparseTerms(dtm, 0.9992)
sparse

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
      print(paste(colnames(corr)[i],',',colnames(corr)[j])) # print rows and column numbers which are correlated
    }
  }
}
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
master <- data.table(label = TW_df$sarcastic, df)
master.factor <- as.data.frame(master)

#Binning 
master.factor <- data.frame(lapply(master[,2:ncol(master)], function(x){ifelse(x==0,0,1)}))

# Converting numericals to factors 
master.factor <- data.frame(lapply(master.factor, as.factor))
# master.factor has all categorical variables 0 and 1 factors

master.factor <- cbind(label = master$label, master.factor)

# This code is about Preparing samples of the master data set and 
# splitting training and testing sets

# loading necessary libraries
require(caTools)

# function to create sample and push the train and test data sets out
# we are considering sample count as 5022(91298*0.055)
# and 0.8 ratio as training and testing ratio

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

# For producing Training and Testing sets of master.numeric
Train.Test.list <- sample2train.test(master,123)

train.num <- Train.Test.list[[1]]
test.num  <- Train.Test.list[[2]]

# saving numeric train and test sets
save(train.num, test.num, file = 'TrainTest_num.dat')

# For producing Training and Testing sets of master.factor
Train.Test.list <- sample2train.test(master.factor,123)

train <- Train.Test.list[[1]]
test  <- Train.Test.list[[2]]
