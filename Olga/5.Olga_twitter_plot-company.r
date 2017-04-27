
library(ggplot2)
library(plyr)
library(dplyr)
library(zoo)
library(reshape2)

setwd("~/Desktop/Products3/merges")
data_tw <- read.csv("Twitter_03.31.csv", sep = ",", as.is = TRUE)

data_tw$Label

#data_tw$created <- as.Date(data_tw$Created.At, format="%m/%d/%y %I:%M %p")

#data_tw$created

# data_tw<- data_tw[!(is.na(data_tw$created)),]

#data_tw<-data_tw[-grep("RT @",data_tw$Text),]

#nrow(data_tw)



tweets<-data_tw

colnames(tweets)[13]

colnames(tweets)[13]<-"label"

tweets<-tweets[-grep("RT @",tweets$Text),]

tweets$Text

tweets <- subset(tweets, label == "Abbvie" | label == "Bristol-Myers" | label == "Amgen" )



tweets.abbvie <- subset(tweets, label == "Abbvie")
tweets.bristol <- subset(tweets, label == "Bristol-Myers")
tweets.amgen <- subset(tweets, label == "Amgen")


#tweets_products
#tweets_products$created <- as.Date(tweets_products$Created.At)

#id<- grep('PM',tweets.amgen$Created.At)
#tweets.amgen[id,]
tweets.amgen$created <- as.Date(tweets.amgen$Created.At, format="%m/%d/%y %I:%M %p")
tweets.amgen<- tweets.amgen[!(is.na(tweets.amgen$created)),]
#tweets.amgen<-tweets.amgen[-grep("RT @",tweets.amgen$Text),]
#tweets.amgen$Text

tweets.bristol$created <- as.Date(tweets.bristol$Created.At, format="%m/%d/%y %I:%M %p")
tweets.bristol<- tweets.bristol[!(is.na(tweets.bristol$created)),]
#tweets.bristol<-tweets.bristol[-grep("RT @",tweets.bristol$Text),]
#tweets.bristol$created

tweets.abbvie$created <- as.Date(tweets.abbvie$Created.At, format="%m/%d/%y %I:%M %p")
tweets.abbvie<- tweets.abbvie[!(is.na(tweets.abbvie$created)),]
#tweets.abbvie<-tweets.abbvie[-grep("RT @",tweets.abbvie$Text),]
#tweets.abbvie$created



tweets.abbvie

#tweets.amgen$Created.At[id,]

#tweets.amgen[id2,]$Created.At<-as.Date(tweets.amgen[id2,]$Created.At, format="%m/%d/%y %I:%M %p")

#id3<- grep('/|PM|AM',tweets.amgen[id2,]$Created.At,invert=TRUE)
#id3<- grep('PM',tweets.amgen[id2,]$Created.At,invert=TRUE)

#id2<- grep('PM|AM',tweets.amgen$Created.At,invert=TRUE)
#tweets.amgen$created2 <- as.Date(tweets.amgen[id3,]$Created.At, format="%y/%m/%d")

#tweets.amgen[id3,]$Created.At

#id2<- grep('[^PM]+',tweets.amgen$Created.At)
#tweets.amgen[id2,]

#tweets.amgen


#tweets.amgen$created <- as.Date(tweets.amgen$Created.At, format="%m/%d/%y %I:%M %p")
#tweets.amgen$created
#tweets.amgen$created2 <- as.Date(tweets.amgen$Created.At)
#tweets.amgen$created
#tweets.amgen$created2
#tweets.amgen$Created.At

tweets.abbvie

tweets.bristol

#Format dates 
#data_tw$created <- as.Date(data_tw$created)
#data_tw$created <- as.Date(data_tw$Created.At, format="%m/%d/%y %I:%M %p")
#Extracting product tweets
#tweets <- unique(select(data_tw, 1, 3, 5, 7, 14, 19)) #key, text, favorites_count, date, retweet_count, label
#tweets_products <- subset(tweets, label == "imbruvica" | label == "adalimumab" | label == "trilipix" | label == "enbrel" | label == "humira" )
#
#
#
#tweets.humira <- subset(tweets, label == "humira")
#tweets.enbrel <- subset(tweets, label == "enbrel")
#tweets.trilipix <- subset(tweets, label == "trilipix")
#tweets.adalimumab <- subset(tweets, label == "adalimumab")
#tweets.imbruvica <- subset(tweets, label == "imbruvica")


#tweets <- unique(select(data_tw, 1, 3, 5, 7, 14, 19)) #key, text, favorites_count, date, retweet_count, label
#tweets_products <- subset(tweets, label == "imbruvica" | label == "adalimumab" | label == "trilipix" | label == "enbrel" | label == "humira" )




#plotTweetsByMonth <- function (tweets, keywords){

#tweets.month <- data.frame()
#tweets.month <- tweets
#tweets.month$created <- as.Date(tweets.month$created) # format to only show month and year
#tweets.month<- ddply(tweets.month, 'created', function(x) c(count=nrow(x)))

#tweets.month <-  tweets.month[order(as.yearmon(as.character(tweets.month$created),"%m-%Y")),] #use zoo's as.yearmon so that we can group by month/year
#tweets.month$created <- factor(tweets.month$created, levels=unique(as.character(tweets.month$created)) ) #so that ggplot2 respects the order of my dates


#tweets.month.plot<-ggplot(data=tweets.month, aes(x=tweets.month$created, y=count, group = 1)) +
#   geom_point() +
#geom_line(aes(colour = count), stat = "identity") + scale_colour_gradient(low="red",high = "green") +
# geom_text(aes(label=count), vjust=-0.5, color="black", size=3.5) +
#  labs(x = "Month-Year", y = "Post count", 
#        title = paste("Tweet count on keyword", keywords, sep = " "))
#  return(tweets.month.plot)
#}


plotTweetsByMonth <- function (tweets, keywords){
  
  tweets.month <- data.frame()
  tweets.month <- tweets
  #tweets.month$created <- as.Date(tweets.month$created) # format to only show month and year
  tweets.month<- ddply(tweets.month, 'created', function(x) c(count=nrow(x)))
  
  #tweets.month <-  tweets.month[order(as.yearmon(as.character(tweets.month$created),"%m-%Y")),] #use zoo's as.yearmon so that we can group by month/year
  #tweets.month$created <- factor(tweets.month$created, levels=unique(as.character(tweets.month$created)) ) #so that ggplot2 respects the order of my dates
  
  
  tweets.month.plot<-ggplot(data=tweets.month, aes(x=tweets.month$created, y=count, group = 1)) +
    geom_point() +
    geom_line(aes(colour = count), stat = "identity") + scale_colour_gradient(low="red",high = "green") +
    geom_text(aes(label=count), vjust=-0.5, color="black", size=3.5) +
    labs(x = "Date", y = "Tweets count", 
         title = paste("Tweet count on keyword", keywords, sep = " "))
  return(tweets.month.plot)
}

tweets.abbvie.plot <- plotTweetsByMonth(tweets.abbvie, "Abbvie")
tweets.abbvie.plot

tweets.amgen.plot <- plotTweetsByMonth(tweets.amgen, "Amgen")
tweets.amgen.plot

tweets.bristol.plot <- plotTweetsByMonth(tweets.bristol, "Bristol-Myers")
tweets.bristol.plot

