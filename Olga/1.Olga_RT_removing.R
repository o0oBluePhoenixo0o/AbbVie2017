library("readr")
library("tm")
library("NLP")
library("twitteR")
#To get the data
data <- read.csv("Products.csv", header = TRUE)
#Look at RT in first row
data[1,]
#Stripping
data_new<-data[-grep("RT @",data$Text),]
#Check 1 row
data_new[1,]
#Don't read after

#In a loop
#for (j in 1:(length(data$Text)-1)) {
#  if(data$Text[j]==data$Text[j+1])
#      {
#      d2<-data[-grep("RT @",data$Text),]
#  }
#}

#Delete a link
#data<-gsub('http.* *', '', data$Text)
#Cleaning
#corpus <- Corpus(VectorSource(data_new))
#corpus1 <-tm_map(corpus, tolower )
#corpus1 <-tm_map(corpus, removePunctuation )
#corpus1 <-tm_map(corpus1, stripWhitespace )
#corpus1 <-tm_map(corpus1,stemDocument )
#
