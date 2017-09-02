#####
#
# The purpose of this file is to learn text preprocessing in R
# Using Yanchang Zhao's tutorial for sentiment analysis and topic modeling
# and to test the methods on twitter data in our project
# 
####

#Install tm package with dependencies, for ex. NLP is requied
install.packages("tm", dependencies = TRUE)

#Load the package using library(), require() works but not right
library(tm)

#load the csv file
tweets.df = read.csv(file.choose(), header=T, sep=",", stringsAsFactors=FALSE)

#view the file
View(tweets.df)

#Build Corpus of a char vectors
myCorpus <- Corpus(VectorSource(tweets.df$Text))

# convert to lower case
myCorpus <- tm_map(myCorpus, content_transformer(tolower))

# remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))

# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))

# remove stopwords including keywords since those will naturally occure frequently
myStopwords <- c(setdiff(stopwords('english'), c("abbvie", "humira", "hcv", "psoriasis", "adalimumab", "enbrel", "bristol-myers"))) 
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

# remove extra whitespace
myCorpus <- tm_map(myCorpus, stripWhitespace)

# keep a copy for stem completion later
myCorpusCopy <- myCorpus

# stemming, building Term Document Matrix and finding Top frequent Words
# Install required package
install.packages("SnowballC", dependencies = TRUE)

#load package
library(SnowballC)

# Stemming
myCorpus <- tm_map(myCorpus, stemDocument) # stem words

# count word frequency
wordFreq <- function(corpus, word) {
  results <- lapply(corpus,
                  function(x) { grep(as.character(x), pattern=paste0("nn<",word)) }
)
sum(unlist(results))
}

#Build Term Document Matrix
tdm <- TermDocumentMatrix(myCorpus,
                          control = list(wordLengths = c(1, Inf)))

#view the matrix
tdm

#reducing weight for most frequent terms
idx <- which(dimnames(tdm)$Terms %in% c("abbvie", "humira", "rt"))
as.matrix(tdm[idx, 21:30]) #subscript out of bound error

# inspect frequent words
(freq.terms <- findFreqTerms(tdm, lowfreq = 20))

term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 20)

#make a data frame of most frequent terms with their frequencies
df <- data.frame(term = names(term.freq), freq = term.freq)

#Install & load required packages for ploting
install.packages("ggplot2", dependencies = TRUE)
library(ggplot2)

#plot the most frequent words
ggplot(df, aes(x=term, y=freq)) + geom_bar(stat="identity") +
  xlab("Terms") + ylab("Count") + coord_flip() +
  theme(axis.text=element_text(size=4))

##Wordcloud
m <- as.matrix(tdm)
# calculate the frequency of words and sort it by frequency
word.freq <- sort(rowSums(m), decreasing = T)

#install RcolorBrewer
install.packages("RColorBrewer", dependencies = TRUE)
library(RColorBrewer)

# colors
pal <- brewer.pal(9, "BuGn")[-(1:4)]

## plot word cloud
# install & load requied packages
install.packages("wordcloud", dependencies = TRUE)
library(wordcloud)

wordcloud(words = names(word.freq), freq = word.freq, min.freq = 3,
          random.order = F, colors = pal)

#Save the session
save.image("D:/Workspace/R/TP/data/tdmTFTwc.RData")
                 
