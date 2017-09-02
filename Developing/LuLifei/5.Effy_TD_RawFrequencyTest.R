#install the necessary packages
#install.packages("NLP")
#install.packages("tm")
#install.packages("SnowballC")
#install.packages("ggplot2")

library("NLP")
library("tm")
library("SnowballC")
library("ggplot2")

df <- read.csv(file.choose(),header = TRUE,sep = ",")
dfDictionary <- subset(df,label=="abbvie")
mode(dfDictionary[[6]])
dfDictionary$created <- as.character(dfDictionary$created)
mode(dfDictionary[[6]])
dfDictionary$created <- substr(dfDictionary$created,1,10)
dfTest <- subset(dfDictionary,created=="2017-03-28")

#build corpus, and specify the source to be character vectors
myCorpus <- Corpus(VectorSource(dfDictionary$text))
myTest <- Corpus(VectorSource(dfTest$text))

#convert to lower case
myCorpus <- tm_map(myCorpus,content_transformer(tolower))
myTest <- tm_map(myTest,content_transformer(tolower))


#remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeURL))
myTest <- tm_map(myTest,content_transformer(removeURL))

#remove anything other than English letters or space
removeNumPunct <-function(x) gsub("[^[:alpha:][:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeNumPunct))
myTest <- tm_map(myTest,content_transformer(removeNumPunct))

#add two extra stop words:"rt" and "abbv"
myStopwords <- c(stopwords("english"),"rt","abbv")
#remove "r" and "big" from stopwords
#myStopwords <- setdiff(myStopwords,c("r","big"))
#remove stopwords from corpus
myCorpus <- tm_map(myCorpus,removeWords,myStopwords)
myTest <- tm_map(myTest,removeWords,myStopwords)
#remove extra whitespace
myCorpus <- tm_map(myCorpus,stripWhitespace)
myTest <- tm_map(myTest,stripWhitespace)

#inspect documents (tweets) numbered 11 to 15 (myCorpus[11:15])
#the code below is used for to make text fit for paper width
for(i in 11:15)
{
  cat(paste("[",i,"]"))
  writeLines(strwrap(as.character(myCorpus[[i]]),100))
}

#stem words
myCorpus <- tm_map(myCorpus,stemDocument)
myTest <- tm_map(myTest,stemDocument)

#complete stem
#stemCompletion2 <- function(x,dictionary)
#{
#  x <- unlist(strsplit(as.character(x)," "))
#  x <- x[x != ""]
#  x <- stemCompletion(x,dictionary = dictionary)
#  x <- paste(x,sep="",collapse = " ")
#  PlainTextDocument(stripWhitespace(x))
#}

#myCorpus <- lapply(myCorpus,stemCompletion2, dictionary=myCorpusCopy)
#myCorpus <- Corpus(VectorSource(myCorpus))

#have a look at the documents numvered 11 to 15 in the built corpus
#inspect(myCorpus[11:15])


#count frequency of "join"
#joinCases <- lapply(myCorpusCopy, function(x){grep(as.character(x),pattern = "\\<join")})
#sum(unlist(joinCases))

#count frequency of "joins"
#joinsCases <- lapply(myCorpusCopy, function(x){grep(as.character(x),pattern = "\\<joins")})
#sum(unlist((joinsCases)))

#replace "joins" with "join"
#myCorpus <- tm_map(myCorpus,content_transformer(gsub),pattern="join",replacement="joins")

#term document matrix building
tdmDictionary <- TermDocumentMatrix(myCorpus,control=list(wordLengths=c(1,Inf)))
tdmDictionary
tdmTest <- TermDocumentMatrix(myTest,control=list(wordLengths=c(1,Inf)))
tdmTest

#have a look at the first six starting with "llc" and tweets numbered 101 to 110
idx <- which(dimnames(tdmDictionary)$Terms=="llc")
inspect(tdmDictionary[idx+(0:5),120:129])
idx <- which(dimnames(tdmTest)$Terms=="llc")
inspect(tdmTest[idx+(0:5),101:110])

#inspect frequent words
findFreqTerms(tdmTest, lowfreq = 30)

#raw term frequency
rawTermFrequencyD <- rowSums(as.matrix(tdmDictionary))
rawTermFrequencyT <- rowSums(as.matrix(tdmTest))

#term frequency
termTotalD <- sum(rawTermFrequencyD)
termTotalT <- sum(rawTermFrequencyT)
termFrequencyD <- rawTermFrequencyD/termTotalD
termFrequencyT <- rawTermFrequencyT/termTotalT
dftfD <- data.frame(term=names(rawTermFrequencyD),rawFreq=rawTermFrequencyD,freq=termFrequencyD)
dftfT <- data.frame(term=names(rawTermFrequencyT),rawFreq=rawTermFrequencyT,freq=termFrequencyT)

#create a new dataframe to store the more frequent term
d <- data.frame(term=c(NA),rawFreq=c(NA),freq=(NA))

#change term from "numeric" into "character"
dftfD$term <- as.character(dftfD$term)
dftfT$term <- as.character(dftfT$term)

#find more frequent term
for(i in 1:278)
{
  for(j in 1:1425)
  {
    if(dftfT$term[i]==dftfD$term[j])
    {
      if(dftfT$freq[i]>dftfD$freq[j])
      {
        d <- rbind.data.frame(d,dftfT[i,])
      }
    }
  }
}

#draw the barchart
pd <- subset(d,d$freq>0.008)
pd <- pd[1:2]
ggplot(pd,aes(x=term,y=rawFreq))+geom_bar(stat = "identity")+xlab("Term")+ylab("Frequency")+coord_flip()
