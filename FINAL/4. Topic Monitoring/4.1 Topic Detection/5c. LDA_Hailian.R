url <- "http://cran.us.r-project.org/src/contrib/Archive/cldr/cldr_1.1.0.tar.gz"
pkgFile<-"cldr_1.1.0.tar.gz"
download.file(url = url, destfile = pkgFile)
install.packages(pkgs=pkgFile, type = "source", repos = NULL)
unlink(pkgFile)

install.packages("lda")
install.packages("LDAvis")
install.packages("servr")

library(tm)
library(lda)
library(LDAvis)
library(servr)
library(text2vec)
library(cldr)
library(textstem)


#read file by navigation, the dataset can be Dataset_DeepLearning_TW.csv
Final_TW_Newest<- read.csv(file.choose(),encoding = "UTF-8")


###get key, tweets, time of TW dataset
Final_TW_Tweets<- Final_TW_Newest[c(1,9,2)]
Final_TW_Tweets<- data.frame(na.omit(Final_TW_Tweets))
colnames(Final_TW_Tweets)<- c("key", "Text","time")

#remove non-english posts
Final_TW_Tweets_lag<- detectLanguage(Final_TW_Tweets[[2]])
Final_TW_Tweets<- cbind(Final_TW_Tweets,Final_TW_Tweets_lag)
Final_TW_Tweets<- subset(Final_TW_Tweets,detectedLanguage=="ENGLISH")[c(1,2,3)]


# read in some stopwords:
stop_words <- stopwords("SMART")

＃ remove url
removeURL <- function (sentence){
  #convert to lower-case 
  sentence <- tolower(sentence)
  removeURL <- function(x) gsub('(http.*) |(https.*) |(http.*)$|\n', "", x)
  sentence <- removeURL(sentence)
}

# remove noise terms
clean <- function (sentence){
  remove <- function(x) gsub('\n|wh|can|just|do|now|will|get|one|johnn|priis|dont|also|much|really|even|use|got|still|year|cant|new|going|since|every|want|by|about|as|so|it|may|â|ã|ãƒâ|šã|å|ãƒæ|iãƒæ|rt | ed | fc | bd | bc | wh | ba | ce | ar | wn | ne | it | ae | bb | fef | di | ale | ee | gt | ra | dr | s | d |john|priis', "", x)
  sentence <- remove(sentence)
}

# pre-processing:
Final_TW_Tweets$Text <- sapply(Final_TW_Tweets$Text, function(x) removeURL(x))
Final_TW_Tweets$Text <- removeNumbers(Final_TW_Tweets$Text)
Final_TW_Tweets$Text <- lemmatize_strings(Final_TW_Tweets$Text)
Final_TW_Tweets$Text <- removeWords(Final_TW_Tweets$Text, stop_words)
Final_TW_Tweets$Text <- gsub("'", "", Final_TW_Tweets$Text)  # remove apostrophes
Final_TW_Tweets$Text <- gsub("[[:punct:]]", " ", Final_TW_Tweets$Text)  # replace punctuation with space
Final_TW_Tweets$Text <- sapply(Final_TW_Tweets$Text, function(x) clean(x))
Final_TW_Tweets$Text <- gsub("[[:cntrl:]]", " ", Final_TW_Tweets$Text)  # replace control characters with space
Final_TW_Tweets$Text <- gsub("^[[:space:]]+", "", Final_TW_Tweets$Text) # remove whitespace at beginning of documents
Final_TW_Tweets$Text <- gsub("[[:space:]]+$", "", Final_TW_Tweets$Text) # remove whitespace at end of documents

# tokenize on space and output as a list:
doc.list <- strsplit(Final_TW_Tweets$Text, "[[:space:]]+")

# compute the table of terms:
term.table <- table(unlist(doc.list))
term.table <- sort(term.table, decreasing = TRUE)

#termtable<- as.data.frame(term.table)

# remove terms that are stop words or occur fewer than 800 times:
del <- names(term.table) %in% stop_words | term.table < 800
term.table <- term.table[!del]
vocab <- names(term.table)

# now put the documents into the format required by the lda package:
get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
documents <- lapply(doc.list, get.terms)

# Compute some statistics related to the data set:
D <- length(documents)  # number of documents
W <- length(vocab)  # number of terms in the vocab 
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document 
N <- sum(doc.length)  # total number of tokens in the data
term.frequency <- as.integer(term.table)  # frequencies of terms in the corpus

# MCMC and model tuning parameters:
K <- 20 # topic number
G <- 10000
alpha <- 0.02
eta <- 0.02

# Fit the model:
fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))
datasetReviews <- list(phi = phi,
                     theta = theta,
                     doc.length = doc.length,
                     vocab = vocab,
                     term.frequency = term.frequency)


# create the JSON object to feed the visualization:
json <- createJSON(phi = datasetReviews$phi, 
                   theta = datasetReviews$theta, 
                   doc.length = datasetReviews$doc.length, 
                   vocab = datasetReviews$vocab, 
                   term.frequency = datasetReviews$term.frequency)
# display visualization
serVis(json, out.dir = 'vi', open.browser = TRUE)

#get topic list
topic_list<- top.topic.words(fit$topics, num.words = 10, by.score = FALSE)
topic_list_LDA<- t(topic_list)

topic_list_LDA<- as.data.frame(topic_list_LDA)
topic_list_LDA<-paste(topic_list_LDA$V1,topic_list_LDA$V2,topic_list_LDA$V3,topic_list_LDA$V4,topic_list_LDA$V5,
                     topic_list_LDA$V6,topic_list_LDA$V7,topic_list_LDA$V8, topic_list_LDA$V9, topic_list_LDA$V30, sep = ', ')
topic_list_LDA<- as.data.frame(topic_list_LDA)
colnames(topic_list_LDA)<- 'Terms'

Topic<- as.data.frame(list(1:dim.data.frame(topic_list_LDA)[1]))
colnames(Topic)<- "TopicID"
topic_list_LDA<- cbind(Topic,topic_list_LDA)

# export topic list
write.csv(topic_list_LDA, file = "topic_list_LDA.csv", quote = TRUE, sep= ",",
          row.names=FALSE, qmethod='escape',
          fileEncoding = "UTF-8", na = "NA")


###################################### Assign Topics Back to each Post##################################
               
# get weighted topic-post assignment matrix
pridicDoc<- slda.predict.docsums(documents=documents, 
                                 fit$topics, 
                                 alpha, 
                                 eta, 
                                 num.iterations = 10000, 
                                 average.iterations = 5000, 
                                 trace = 0L)

#get top1 topic for each post
getTopTopic<- function(pridicDoc){
  
  t<- list()
  for(i in 1:dim(pridic)[2]){
    
    for(j in 1:dim(pridic)[1]){
      
      if(pridic[j,i]==max(pridic[,i])){
        
        t<- rbind(t,j)
      }
    }
  }
  
  return(t)
}
               
# apply the function and get topic assignment list
topic<- getTopTopic(pridic)
               
topic<- as.data.frame(topic)
               
# Combine the post dataset with topic
Final_TW_Tweets_Topic<- cbind(Final_TW_Tweets, topic)
colnames(Final_TW_Tweets)[4]<- "TopicID"
# link TopicID with topic Content
Final_TW_Tweets_Topic_Final<- merge(x = Final_TW_Tweets_Topic, y = topic_list_LDA, by = "TopicID", all.x = TRUE)



