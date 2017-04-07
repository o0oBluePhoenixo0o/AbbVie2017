
library(ggplot2)
library(plyr)
library(dplyr)
library(zoo)
library(reshape2)

setwd("~/Desktop/Products3")
data_tw <- read.csv("Twitter_31.03.17.csv", sep = ",", as.is = TRUE)

data_tw$Label

tweets<-data_tw

colnames(tweets)[13]

colnames(tweets)[13]<-"label"

tweets<-tweets[-grep("RT @",tweets$Text),]

tweets$Text

tweets <- subset(tweets, label == "rheumatoid arthritis" | label == "psoriasis" | label == "hcv" | label == "ankylosing spondylitis")



tweets.arthritis <- subset(tweets, label == "rheumatoid arthritis")
tweets.psoriasis <- subset(tweets, label == "psoriasis")
tweets.hcv <- subset(tweets, label == "hcv")
tweets.ankylosing <- subset(tweets, label == "ankylosing spondylitis")

#tweets_products
#tweets_products$created <- as.Date(tweets_products$Created.At)

#id<- grep('PM',tweets.amgen$Created.At)
#tweets.amgen[id,]
tweets.arthritis$created <- as.Date(tweets.arthritis$Created.At, format="%m/%d/%y")
tweets.arthritis<- tweets.arthritis[!(is.na(tweets.arthritis$created)),]
#tweets.amgen<-tweets.amgen[-grep("RT @",tweets.amgen$Text),]
#tweets.amgen$Text

#tweets.arthritis$Created.At

#as.Date(tweets.arthritis$Created.At, format="%m/%d/%y")

tweets.psoriasis$created <- as.Date(tweets.psoriasis$Created.At, format="%m/%d/%y")
tweets.psoriasis<- tweets.psoriasis[!(is.na(tweets.psoriasis$created)),]
#tweets.bristol<-tweets.bristol[-grep("RT @",tweets.bristol$Text),]
#tweets.bristol$created

tweets.hcv$created <- as.Date(tweets.hcv$Created.At, format="%m/%d/%y")
tweets.hcv<- tweets.hcv[!(is.na(tweets.hcv$created)),]
#tweets.abbvie<-tweets.abbvie[-grep("RT @",tweets.abbvie$Text),]
#tweets.abbvie$created

tweets.ankylosing$created <- as.Date(tweets.ankylosing$Created.At, format="%m/%d/%y")
tweets.ankylosing<- tweets.ankylosing[!(is.na(tweets.ankylosing$created)),]

plotTweetsByMonth <- function (tweets, keywords){
# 
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

tweets.arthritis.plot <- plotTweetsByMonth(tweets.arthritis, "Rheumatoid arthritis")
tweets.arthritis.plot

tweets.psoriasis.plot <- plotTweetsByMonth(tweets.psoriasis, "Psoriasis")
tweets.psoriasis.plot

tweets.hcv.plot <- plotTweetsByMonth(tweets.hcv, "HCV")
tweets.hcv.plot

tweets.ankylosing.plot <- plotTweetsByMonth(tweets.ankylosing, "Ankylosing spondylitis")
tweets.ankylosing.plot

## Plotting product post counts 
tweets.plot.df <- data.frame(product=c("Abbvie", "Bristol-Myers", "Amgen"),
                            tweetsCount=c(nrow(tweets.abbvie), nrow(tweets.bristol), nrow(tweets.amgen)))

posts.plot<-ggplot(data=tweets.plot.df, aes(x=product, y=tweetsCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=tweetsCount), vjust=-0.5, color="black", size=3.5)+
  labs(x = "Product", y = "Tweets count", 
       title = "Tweets count on our different keywords")

tweets.plot.df


