#install the necessary packages
#install.packages("NLP")
#install.packages("tm")
#install.packages("SnowballC")
#install.packages("ggplot2")
install.packages("fpc")

library("NLP")
library("tm")
library("SnowballC")
library("ggplot2")

df <- read.csv(file.choose(),header = TRUE,sep = ",")

#build corpus, and specify the source to be character vectors
myCorpus <- Corpus(VectorSource(df$text))

#convert to lower case
myCorpus <- tm_map(myCorpus,content_transformer(tolower))

#remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeURL))

#remove anything other than English letters or space
removeNumPunct <-function(x) gsub("[^[:alpha:][:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeNumPunct))

#add two extra stop words:"rt" and ...
myStopwords <- c(stopwords("english"),"rt","dont","abbv")

#remove "r" and "big" from stopwords
#myStopwords <- setdiff(myStopwords,c("r","big"))

#remove stopwords from corpus
myCorpus <- tm_map(myCorpus,removeWords,myStopwords)

#remove extra whitespace
myCorpus <- tm_map(myCorpus,stripWhitespace)

#inspect documents (tweets) numbered 11 to 15 (myCorpus[11:15])
#the code below is used for to make text fit for paper width
for(i in 11:15)
{
  cat(paste("[",i,"]"))
  writeLines(strwrap(as.character(myCorpus[[i]]),100))
}

#stem words
myCorpus <- tm_map(myCorpus,stemDocument)

#inspect documents (tweets) numbered 11 to 15 (myCorpus[11:15])
#the code below is used for to make text fit for paper width
for(i in 11:15)
{
  cat(paste("[",i,"]"))
  writeLines(strwrap(as.character(myCorpus[[i]]),100))
}

#count frequency of "join"
#joinCases <- lapply(myCorpusCopy, function(x){grep(as.character(x),pattern = "\\<join")})
#sum(unlist(joinCases))

#count frequency of "joins"
#joinsCases <- lapply(myCorpusCopy, function(x){grep(as.character(x),pattern = "\\<joins")})
#sum(unlist((joinsCases)))

#replace "joins" with "join"
#myCorpus <- tm_map(myCorpus,content_transformer(gsub),pattern="join",replacement="joins")

#term document matrix building
tdm <- TermDocumentMatrix(myCorpus,control=list(wordLengths=c(1,Inf)))
tdm

#have a look at the first six starting with "llc" and tweets numbered 101 to 110
idx <- which(dimnames(tdm)$Terms=="llc")
inspect(tdm[idx+(0:5),101:110])
#idx <- which(dimnames(tdmTest)$Terms=="llc")
#inspect(tdmTest[idx+(0:5),101:110])

#term frequency
termFrequency <- rowSums(as.matrix(tdm))
#rawTermFrequencyT <- rowSums(as.matrix(tdmTest))

##clustering words
#remove sparse terms
tdm2 <- removeSparseTerms(tdm,sparse=0.95)
tdm3 <- as.matrix(tdm2)

#cluster terms
disMatrix <- dist(scale(tdm3))
fit <- hclust(disMatrix,method="ward.D")

#make a plot
plot(fit)
#cut tree into 10 clusters
(groups <- cutree(fit,k=16))


##clustering Tweets with the k-means algrithm
#transpose the matrix to cluster documents(tweets)
tdm4 <- t(tdm3)
#set a fixed random seed
set.seed(122)
#k-means clustering of tweets
k <- 8
kmeansResult <- kmeans(tdm4,k)
#cluster centers
round(kmeansResult$centers,digits=3) 

#check the top three words in every cluster
for(i in 1:k)
{
  cat(paste("cluster",i,":",sep=""))
  s <- sort(kmeansResult$centers[i,],decreasing=T)
  cat(names(s)[1:3],"\n")
  #print the tweets of every cluster)
  #print(rdmTweets[which(kmeansResult$cluster==i)])
}


##clustering Tweets with the k-medoids algorithm
library(fpc)
#partitioning around medoids with estimation fo number of clusters
pamResult <- pamk(tdm4,metric="manhattan")
#number of clusters identified
(k <- pamResult$nc)
pamResult <- pamResult$pamobject
#print cluster medoids
for(i in 1:k)
{
  cat(paste("cluster",i,": "))
  cat(colnames(pamResult$medoids)[which(pamResult$medoids[i,]==1)],"\n")
  #print tweets in cluster i
  #print(rdmTweets[pamResult$clustering==i])
}

#plot clustering result
#set to two graphs per page
layout(matrix(c(1,2),2,1))
plot(pamResult,color=F,lavels=4,lines=0,cex=0.8,col.clus=1,
     col.p=pamResult$clustering)
#change back to one graph per page
layout(matrix(1))

pamResult2 <- pamk(m3,krange=2:8,metric="manhattan")

