



# Clustering




# Install the necessary packages
install.packages("NLP")
install.packages("tm")
install.packages("SnowballC")
install.packages("ggplot2")
install.packages("fpc")


library("NLP")
library("tm")
library("SnowballC")
library("ggplot2")
library("fpc")



# Load in data that already preprocessed well ###############################
# The dataset that has been pre-processed well is needed here. Please choose the csv file "CTM_preprocess_final.csv" in our dataset
df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")


# For testing the code, it is better to choose less data condsidering time efficiency
subdf <- df[sample(1:nrow(df),1000),]



# Prepare data ################################################################
# Build corpus, and specify the source to be character vectors
myCorpus <- Corpus(VectorSource(subdf$pre_message))


# Term document matrix building
tdm <- TermDocumentMatrix(myCorpus,control=list(wordLengths=c(1,Inf)))


# Have a look at the first six starting with "llc" and tweets numbered 120 to 129
idx <- which(dimnames(tdm)$Terms=="abbvie")
inspect(tdm[idx+(0:5),120:129])


# Remove sparse terms
tdm_removersparse <- removeSparseTerms(tdm,sparse=0.98)
tdm_clustering <- as.matrix(tdm_removersparse)



# Clustering words ##################################################################
disMatrix <- dist(scale(tdm_clustering))
fit <- hclust(disMatrix,method="ward.D")


# Make a plot
plot(fit)


# Cut tree into 10 clusters
(groups <- cutree(fit,k=16))



# Clustering Tweets with the k-means algrithm #######################################
# Transpose the matrix to cluster documents(tweets)
dtm <- t(tdm_clustering)


# Set a fixed random seed
set.seed(88)


# K-means clustering of tweets
k <- 8
kmeansResult <- kmeans(dtm,k)


# Cluster centers
round(kmeansResult$centers,digits=3) 


# Check the top three words in every cluster
for(i in 1:k)
{
  cat(paste("cluster",i,":",sep=""))
  s <- sort(kmeansResult$centers[i,],decreasing=T)
  cat(names(s)[1:5],"\n")
  # Print the tweets of every cluster)
  # Print(rdmTweets[which(kmeansResult$cluster==i)])
}


# Clustering Tweets with the k-medoids algorithm
# Partitioning around medoids with estimation fo number of clusters
pamResult <- pamk(dtm,metric="manhattan")


# Number of clusters identified
(k <- pamResult$nc)
pamResult <- pamResult$pamobject


# Print cluster medoids
#for(i in 1:k)
#{
#  cat(paste("cluster",i,": "))
#  cat(colnames(pamResult$medoids)[which(pamResult$medoids[i,]==1)],"\n")
  # Print tweets in cluster i
  # Print(rdmTweets[pamResult$clustering==i])
#}


pamResult



