



# Raw Term Frequency




# Install the necessary packages ###########################################
install.packages("NLP")
install.packages("tm")
install.packages("SnowballC")
install.packages("ggplot2")


library("NLP")
library("tm")
library("SnowballC")
library("ggplot2")



# Load in data that already preprocessed well ###############################
# The dataset that has been pre-processed well is needed here.
# Please choose the csv file "CTM_preprocess_final.csv" in our dataset which has already finished pre-processing.
df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")


# For testing the code, it is better to choose less data condsidering time efficiency
subdf <- df[sample(1:nrow(df),1000),]



# Raw Term Frequency ################################################################
# Build corpus, and specify the source to be character vectors
myCorpus <- Corpus(VectorSource(subdf$pre_message))


# Build the term document matrix
tdm <- TermDocumentMatrix(myCorpus,control=list(wordLengths=c(1,Inf)))


# Have a look at the first six starting with "llc" and tweets numbered 101 to 110
idx <- which(dimnames(tdm)$Terms=="abbvie")
inspect(tdm[idx+(0:5),120:129])


# Inspect frequent words
findFreqTerms(tdm, lowfreq = 30)


# Raw term frequency
rawTermFrequency <- rowSums(as.matrix(tdm))


# Term frequency
termTotal <- sum(rawTermFrequency)
termFrequency <- rawTermFrequency/termTotal
dftf <- data.frame(term=names(rawTermFrequency),rawFreq=rawTermFrequency,freq=termFrequency)


# Draw the barchart for the frequent terms
pd <- subset(dftf,dftf$freq>0.008)
pd <- pd[1:2]
ggplot(pd,aes(x=term,y=rawFreq))+geom_bar(stat = "identity")+xlab("Term")+ylab("Frequency")+coord_flip()




