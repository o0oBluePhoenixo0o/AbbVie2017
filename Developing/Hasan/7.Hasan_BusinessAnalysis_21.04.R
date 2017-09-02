#Set working directory always otherwise goes to mydocument by default
#setwd("C:/Users/Md.RaziulHasan/Desktop/BI/Source/Rdata")
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

# Text Preprocessing
# convert to lower case
myCorpus <- tm_map(myCorpus, content_transformer(tolower))

# remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))

# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))

# remove stopwords
myStopwords <- c(setdiff(stopwords('english'), c("rt")), "use", "see", "used", "via", "amp") 
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

# remove extra whitespace
myCorpus <- tm_map(myCorpus, stripWhitespace)

#For Backup of corpus or further analysis in Rapidminer
setwd("C:/Users/Md.RaziulHasan/Desktop/BI/Source/TwitterCorpus")
writeCorpus(myCorpus)
inspect(myCorpus[11:15])

# keep a copy for stem completion later
myCorpusCopy <- myCorpus

# Plotting FTerms: Install required package
install.packages("SnowballC", dependencies = TRUE)

#load package
library(SnowballC)

# Stemming
myCorpus <- tm_map(myCorpus, stemDocument) # stem words

# inspect documents (tweets) numbered 11 to 15
inspect(myCorpus[11:15])

writeLines(strwrap(myCorpus[[190]]$content, 60))

# count word frequence
wordFreq <- function(corpus, word) {
  results <- lapply(corpus,
                    function(x) { grep(as.character(x), pattern=paste0("nn<",word)) }
  )
  sum(unlist(results))
}

#Issues in Stem Completion
#n.miner <- wordFreq(myCorpusCopy, "miner")
#n.mining <- wordFreq(myCorpusCopy, "mining")
#cat(n.miner, n.mining)

# replace oldword with newword
#replaceWord <- function(corpus, oldword, newword) {
#  tm_map(corpus, content_transformer(gsub),
#         pattern=oldword, replacement=newword)
#}

#Build Term Document Matrix
tdm <- TermDocumentMatrix(myCorpus,
                          control = list(wordLengths = c(3, 25)))

#view the matrix
tdm

#reducing weight for most frequent terms
idx <- which(dimnames(tdm)$Terms %in% c("johnson & johnson","psoriasis","rheumatoid arthritis","hepatitis c","bristol myers","abbvie,amgen","humira","ankylosing spondylitis","ibrutinib","enbrel","adalimumab","imbruvica","trilipix","jia","hcv", "rt"))
as.matrix(tdm[idx, 21:30]) #subscript out of bound error

# inspect frequent words
(freq.terms <- findFreqTerms(tdm, lowfreq = 120))
setwd("D:/Workspace/R/TP/data")

term.freq <- rowSums(as.matrix(tdm)) #Error: cannot allocate vector of size 16.1 Gb
term.freq <- subset(term.freq, term.freq >= 100) #Error in subset(term.freq, term.freq >= 20) : object 'term.freq' not found

#make a data frame of most frequent terms with their frequencies
df <- data.frame(term = names(term.freq), freq = term.freq)

#Install & load required packages for ploting
install.packages("ggplot2", dependencies = TRUE)
library(ggplot2)

#plot the most frequent words
ggplot(df, aes(x=term, y=freq)) + geom_bar(stat="identity") +
  xlab("Terms") + ylab("Count") + coord_flip() +
  theme(axis.text=element_text(size=5))

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

# Term Association analysis
# which words are associated with 'abbvi', 'humira', 'hcv', 'stock', 'arthriti', psoriasi, biosimilar, bristolmy?
findAssocs(tdm, "abbv", 0.2)
findAssocs(tdm, "humira", 0.2)
findAssocs(tdm, "hcv", 0.2)
findAssocs(tdm, "stock", 0.2)
findAssocs(tdm, "arthriti", 0.2)
findAssocs(tdm, "psoriasi", 0.2)
findAssocs(tdm, "bristolmy", 0.2)
findAssocs(tdm, "therapi", 0.2)


#Network of terms
library(graph)
library(Rgraphviz)
plot(tdm, term = freq.terms, corThreshold = 0.05, weighting = T)

#Topic Modelling

dtm <- as.DocumentTermMatrix(tdm, sparse=TRUE)
dtm.new   <- dtm[rowTotals> 0, ] 
library(topicmodels)

lda <- LDA(dtm.new, k = 10) # find 8 topics
term <- terms(lda, 10) # first 7 terms of every topic
(term <- apply(term, MARGIN = 2, paste, collapse = ", "))

topics <- topics(lda) # 1st topic identified for every document (tweet)

require(data.table)
library(xts)


topics <- data.frame(date=as.Date(tweets.df$Created.At, format = "%Y.%m.%d"), topic=topics)
ggplot(topics, aes(date, fill = term[topic])) +
  geom_density(position = "stack") #Error: ggplot2 doesn't know how to deal with data of class integer

#Top Retweeted Tweets
# select top retweeted tweets
table(tweets.df$Retweet.Count)
selected <- which(tweets.df$Retweet.Count >= 9)
# plot them
dates <- strptime(tweets.df$Created.At, format="%Y-%m-%d")
plot(x=dates, y=tweets.df$Retweet.Count, type="l", col="grey",
     xlab="Date", ylab="Times retweeted")
colors <- rainbow(10)[1:length(selected)]
points(dates[selected], tweets.df$Retweet.Count[selected],
       pch=19, col=colors)
text(dates[selected], tweets.df$Retweet.Count[selected],
     tweets.df$Text[selected], col=colors, cex=.9)

#Sentiment Analysis

#Download RSentiment package from CRAN windows binary zip

# sentiment analysis
library(RSentiment)
calculate_score(tweets.df$Text) #Error in data.frame(r1, words) : arguments imply differing number of rows: 30, 31

sentiments <- calculate_sentiment(tweets.df$Text) #arguments imply differing number of rows: 30, 31
table(sentiments$polarity)
calculate_total_presence_sentiment(tweets.df$Text)

# sentiment plot
#sentiments$score <- 0
#sentiments$score[sentiments$polarity == "positive"] <- 1
#sentiments$score[sentiments$polarity == "negative"] <- -1
#sentiments$date <- as.IDate(tweets.df$created)
#result <- aggregate(score ~ date, data = sentiments, sum)
#plot(result, type = "l") 


#Retrieve User Info and Followers: Timeline analysis
user <- getUser("abbvie")
user$toDataFrame()
friends <- user$getFriends() # who this user follows
followers <- user$getFollowers() # this user's followers
followers2 <- followers[[1]]$getFollowers() # a follower's followers

# need the following library: twitteR, maps, geosphere, and RColorBrewer
library(maps)
library(geosphere)
library(RColorBrewer)

# Plotting followers
# Source the function
source("http://biostat.jhsph.edu/~jleek/code/twitterMap.R")

# Make your twittermap
twitterMap("abbvie")
#If you want both your followers and people you follow in a plot you can do:
twitterMap("abbvie",plotType="both")
twitterMap("simplystats",userLocation="Global")

#Customer Satisfaction

#Stock Prediction

