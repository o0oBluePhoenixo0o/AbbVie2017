#How to delete retweets from file#
#Loading the libraries
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
data_new[1,]
