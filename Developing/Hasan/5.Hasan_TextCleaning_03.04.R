#Set working directory always otherwise goes to mydocument by default
setwd("D:/Workspace/R/TP/data")

#Install tm package with dependencies, for ex. NLP is requied
install.packages("tm", dependencies = TRUE)

#Load the package using library(), require() works but not right
library(tm)

#load the csv file
tweets.df = read.csv(file.choose(), header=T, sep=",", stringsAsFactors=FALSE)

#view the file
View(tweets.df)

#Build Corpus of a char vectors, I am considering the Text column only for my future analysis
myCorpus <- Corpus(VectorSource(tweets.df$Text))

# convert to lower case
myCorpus <- tm_map(myCorpus, content_transformer(tolower))

# remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))

#?? Issue with German Text, need to use Alex's translate.R
#?? Ask Philipp, if I need to make two subset of Corpus, 1 Eng another De.

# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))

# remove stopwords
myStopwords <- c(setdiff(stopwords('english'), c("abbvie", "humira"))) #("hcv", "psoriasis", "adalimumab", "enbrel", "bristol-myers")
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

# remove extra whitespace
myCorpus <- tm_map(myCorpus, stripWhitespace)

# keep a copy for stem completion later
myCorpusCopy <- myCorpus
                 
