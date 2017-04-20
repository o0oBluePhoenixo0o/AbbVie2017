#install the necessary packages
install.packages("NLP")
install.packages("tm")
install.packages("SnowballC")

library("NLP")
library("tm")
library("SnowballC")

df <-read.csv(file.choose(),header = TRUE,sep = ",")
mode(df)
lengths(df)

#build a corpus, and specify the source to be character vectors
myCorpus <- Corpus(VectorSource(df$text))

#convert to lower case
myCorpus <- tm_map(myCorpus,content_transformer(tolower))

#remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeURL))

#remove anything other than English letters or space
removeNumPunct <-function(x) gsub("[^[:alpha:][:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeNumPunct))

#add two extra stop words:"rt" and "via"
myStopwords <- c(stopwords("english"),"rt","via")
#remove "r" and "big" from stopwords
#myStopwords <- setdiff(myStopwords,c("r","big"))
#remove stopwords from corpus
myCorpus <- tm_map(myCorpus,removeWords,myStopwords)
#remove extra whitespace
myCorpus <- tm_map(myCorpus,stripWhitespace)

#keep a copy of corpus to use later as a dictionary for stem completion
myCorpusCopy <- myCorpus

#inspect documents (tweets) numbered 11 to 15 (myCorpus[11:15])
#the code below is used for to make text fit for paper width
for(i in 11:15)
{
  cat(paste("[[",i,"]]",sep=""))
  writeLines(strwrap(myCorpus[[i]],width = 73))
}

#inspect documents (tweets) numbered 11 to 15 (myCorpus[11:15])
#the code below is used for to make text fit for paper width
for(i in 11:15)
{
  cat(paste("[",i,"]"))
  writeLines(strwrap(as.character(myCorpus[[i]]),100))
}

#stem words
myCorpus <- tm_map(myCorpus,stemDocument)

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


