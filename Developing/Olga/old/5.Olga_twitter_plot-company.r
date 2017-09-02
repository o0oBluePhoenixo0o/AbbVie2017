####Plot code for company keywords####
library(ggplot2)
library(plyr)
library(dplyr)
library(zoo)
library(reshape2)
#Get the data
setwd("~/Desktop/Products3/merges")
data_tw <- read.csv("Twitter_03.31.csv", sep = ",", as.is = TRUE)

data_tw$Label


tweets<-data_tw

colnames(tweets)[13]

colnames(tweets)[13]<-"label"

tweets<-tweets[-grep("RT @",tweets$Text),]

tweets$Text

tweets <- subset(tweets, label == "Abbvie" | label == "Bristol-Myers" | label == "Amgen" )


#Filter on keywords
tweets.abbvie <- subset(tweets, label == "Abbvie")
tweets.bristol <- subset(tweets, label == "Bristol-Myers")
tweets.amgen <- subset(tweets, label == "Amgen")



tweets.amgen$created <- as.Date(tweets.amgen$Created.At, format="%m/%d/%y %I:%M %p")
tweets.amgen<- tweets.amgen[!(is.na(tweets.amgen$created)),]


tweets.bristol$created <- as.Date(tweets.bristol$Created.At, format="%m/%d/%y %I:%M %p")
tweets.bristol<- tweets.bristol[!(is.na(tweets.bristol$created)),]

tweets.abbvie$created <- as.Date(tweets.abbvie$Created.At, format="%m/%d/%y %I:%M %p")
tweets.abbvie<- tweets.abbvie[!(is.na(tweets.abbvie$created)),]
tweets.abbvie

tweets.abbvie

tweets.bristol

plotTweetsByMonth <- function (tweets, keywords){
  
  tweets.month <- data.frame()
  tweets.month <- tweets
  tweets.month<- ddply(tweets.month, 'created', function(x) c(count=nrow(x)))
  
    
#Code for drawing a plot  
  tweets.month.plot<-ggplot(data=tweets.month, aes(x=tweets.month$created, y=count, group = 1)) +
    geom_point() +
    geom_line(aes(colour = count), stat = "identity") + scale_colour_gradient(low="red",high = "green") +
    geom_text(aes(label=count), vjust=-0.5, color="black", size=3.5) +
    labs(x = "Date", y = "Tweets count", 
         title = paste("Tweet count on keyword", keywords, sep = " "))
  return(tweets.month.plot)
}
#Drawing for keywords
tweets.abbvie.plot <- plotTweetsByMonth(tweets.abbvie, "Abbvie")
tweets.abbvie.plot

tweets.amgen.plot <- plotTweetsByMonth(tweets.amgen, "Amgen")
tweets.amgen.plot

tweets.bristol.plot <- plotTweetsByMonth(tweets.bristol, "Bristol-Myers")
tweets.bristol.plot

