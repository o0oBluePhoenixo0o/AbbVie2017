
library(ggplot2)
library(plyr)
library(dplyr)
library(zoo)
library(reshape2)
library(rccdates)

setwd("~/Desktop/Products3/")
data_tw <-  read.csv("Final_TW_2104.csv", sep = ",", as.is = TRUE)

tweets<-data_tw

colnames(tweets)[14]

colnames(tweets)[14]<-"label"

unique(tweets$label)

tweets<-tweets[-grep("Label",tweets$label),]

tweets <- subset(tweets, label == "abbvie" | label == "bristol myers" | label == "amgen" )



tweets.abbvie <- subset(tweets, label == "abbvie")
tweets.bristol <- subset(tweets, label == "bristol myers")
tweets.amgen <- subset(tweets, label == "amgen")


nrow(tweets.abbvie)

nrow(tweets.bristol)

nrow(tweets.amgen)

tweets.amgen2 <- subset(tweets, label == "amgen")
tweets.amgen2<-tweets.amgen[grep("[0-9]{1}/[0-9]{2}/2017",tweets.amgen$Created.At),]
tweets.amgen2$created <- as.Date(tweets.amgen2$Created.At, format="%m/%d/%Y")


tweets.amgen3 <- subset(tweets, label == "amgen")
tweets.amgen3<-tweets.amgen[grep("[0-9]{1}/[0-9]{2}/2003",tweets.amgen$Created.At),]
tweets.amgen3$Created.At<-gsub("8/17/2003", "2017-03-08", tweets.amgen3$Created.At)
tweets.amgen3$created <- as.Date(tweets.amgen3$Created.At, format="%Y-%m-%d")


tweets.amgen1 <- subset(tweets, label == "amgen")
tweets.amgen1$created <- as.Date(tweets.amgen1$Created.At, format="%Y-%m-%d")


tweets.amgen <- rbind(tweets.amgen2,tweets.amgen3)

tweets.amgen <- rbind(tweets.amgen,tweets.amgen1)

tweets.amgen<- tweets.amgen[!(is.na(tweets.amgen$created)),]

#tweets.amgen$Created.At

#tweets.amgen$created

#tweets.bristol3 <- subset(tweets, label == "bristol myers")
#tweets.bristol3<-tweets.bristol[grep("[0-9]{1}/[0-9]{2}/2003",tweets.bristol$Created.At),]

#tweets.bristol3$Created.At<-gsub("/17/2003", "-03-2017", tweets.bristol3$Created.At)

#tweets.bristol3$created <- as.Date(tweets.bristol3$Created.At, format="%d-%m-%Y")
#tweets.bristol3$created

#tweets.bristol3$Created.At

tweets.bristol2 <- subset(tweets, label == "bristol myers")
tweets.bristol2<-tweets.bristol[grep("[0-9]{1}/[0-9]{2}/2017",tweets.bristol$Created.At),]
tweets.bristol2$created <- as.Date(tweets.bristol2$Created.At, format="%m/%d/%Y")
tweets.bristol3 <- subset(tweets, label == "bristol myers")
tweets.bristol3<-tweets.bristol[grep("[0-9]{1}/[0-9]{2}/2003",tweets.bristol$Created.At),]
tweets.bristol3$Created.At<-gsub("/17/2003", "-03-2017", tweets.bristol3$Created.At)
tweets.bristol3$created <- as.Date(tweets.bristol3$Created.At, format="%d-%m-%Y")
tweets.bristol1 <- subset(tweets, label == "bristol myers")
tweets.bristol1$created <- as.Date(tweets.bristol1$Created.At, format="%Y-%m-%d")
tweets.bristol <- rbind(tweets.bristol2,tweets.bristol3)
tweets.bristol <- rbind(tweets.bristol,tweets.bristol1)
tweets.bristol<- tweets.bristol[!(is.na(tweets.bristol$created)),]

#tweets.bristol$created



tweets.abbvie2 <- subset(tweets, label == "abbvie")
tweets.abbvie2<-tweets.abbvie[grep("[0-9]{1}/[0-9]{2}/2017",tweets.abbvie$Created.At),]
tweets.abbvie2$created <- as.Date(tweets.abbvie2$Created.At, format="%m/%d/%Y")
tweets.abbvie3 <- subset(tweets, label == "abbvie")
tweets.abbvie3<-tweets.abbvie[grep("[0-9]{1}/[0-9]{2}/2003",tweets.abbvie$Created.At),]
tweets.abbvie3$Created.At<-gsub("/17/2003", "-03-2017", tweets.abbvie3$Created.At)
tweets.abbvie3$created <- as.Date(tweets.abbvie3$Created.At, format="%d-%m-%Y")
tweets.abbvie1 <- subset(tweets, label == "abbvie")
tweets.abbvie1$created <- as.Date(tweets.abbvie1$Created.At, format="%Y-%m-%d")
tweets.abbvie <- rbind(tweets.abbvie2,tweets.abbvie3)
tweets.abbvie <- rbind(tweets.abbvie,tweets.abbvie1)
tweets.abbvie<- tweets.abbvie[!(is.na(tweets.abbvie$created)),]

tweets.abbvie$created

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

tweets.abbvie.plot <- plotTweetsByMonth(tweets.abbvie, "abbvie")
tweets.abbvie.plot

tweets.amgen.plot <- plotTweetsByMonth(tweets.amgen, "amgen")
tweets.amgen.plot

tweets.bristol.plot <- plotTweetsByMonth(tweets.bristol, "bristol myers")
tweets.bristol.plot

## Plotting product post counts 
tweets.plot.df <- data.frame(product=c("Abbvie", "Bristol-Myers", "Amgen"),
                            tweetsCount=c(nrow(tweets.abbvie), nrow(tweets.bristol), nrow(tweets.amgen)))

posts.plot<-ggplot(data=tweets.plot.df, aes(x=product, y=tweetsCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=tweetsCount), vjust=-0.5, color="black", size=3.5)+
  labs(x = "Product", y = "Tweets count", 
       title = "Tweets count on our different keywords")

tweets.plot.df

## Plotting product post counts 
tweets.plot.df <- data.frame(product=c("Abbvie", "Bristol-Myers", "Amgen"),
                            tweetsCount=c(nrow(tweets.abbvie), nrow(tweets.bristol), nrow(tweets.amgen)))

posts.plot<-ggplot(data=tweets.plot.df, aes(x=product, y=tweetsCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=tweetsCount), vjust=-0.5, color="black", size=3.5)+
  labs(x = "Product", y = "Tweets count", 
       title = "Tweets count on our different keywords")

tweets.plot.df


