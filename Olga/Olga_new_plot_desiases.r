
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

tweets <- subset(tweets, label == "ankylosing spondylitis" | label == "hepatitis c" | label == "psoriasis" | label == "rheumatoid arthritis" )

tweets.ankylosing <- subset(tweets, label == "ankylosing spondylitis")
tweets.hepatitis <- subset(tweets, label == "hepatitis c")
tweets.psoriasis <- subset(tweets, label == "psoriasis")
tweets.rheumatoid <- subset(tweets, label == "rheumatoid arthritis")



nrow(tweets.ankylosing)

nrow(tweets.hepatitis)

nrow(tweets.psoriasis)

nrow(tweets.rheumatoid)

tweets.ankylosing2 <- subset(tweets, label == "ankylosing spondylitis")
tweets.ankylosing2<-tweets.ankylosing[grep("[0-9]{1}/[0-9]{2}/2017",tweets.ankylosing$Created.At),]
tweets.ankylosing2$created <- as.Date(tweets.ankylosing2$Created.At, format="%m/%d/%Y")
tweets.ankylosing3 <- subset(tweets, label == "ankylosing spondylitis")
tweets.ankylosing3<-tweets.ankylosing[grep("[0-9]{1}/[0-9]{2}/2003",tweets.ankylosing$Created.At),]
tweets.ankylosing3$Created.At<-gsub("/17/2003", "-03-2017", tweets.ankylosing3$Created.At)
tweets.ankylosing3$created <- as.Date(tweets.ankylosing3$Created.At, format="%d-%m-%Y")
tweets.ankylosing1 <- subset(tweets, label == "ankylosing spondylitis")
tweets.ankylosing1$created <- as.Date(tweets.ankylosing1$Created.At, format="%Y-%m-%d")
tweets.ankylosing <- rbind(tweets.ankylosing2,tweets.ankylosing3)
tweets.ankylosing <- rbind(tweets.ankylosing,tweets.ankylosing1)
tweets.ankylosing<- tweets.ankylosing[!(is.na(tweets.ankylosing$created)),]
#tweets.ankylosing$created

tweets.hepatitis2 <- subset(tweets, label == "hepatitis c")
tweets.hepatitis2<-tweets.hepatitis[grep("[0-9]{1}/[0-9]{2}/2017",tweets.hepatitis$Created.At),]
tweets.hepatitis2$created <- as.Date(tweets.hepatitis2$Created.At, format="%m/%d/%Y")
tweets.hepatitis3 <- subset(tweets, label == "hepatitis c")
tweets.hepatitis3<-tweets.hepatitis[grep("[0-9]{1}/[0-9]{2}/2003",tweets.hepatitis$Created.At),]
tweets.hepatitis3$Created.At<-gsub("/17/2003", "-03-2017", tweets.hepatitis3$Created.At)
tweets.hepatitis3$created <- as.Date(tweets.hepatitis3$Created.At, format="%d-%m-%Y")
tweets.hepatitis1 <- subset(tweets, label == "hepatitis c")
tweets.hepatitis1$created <- as.Date(tweets.hepatitis1$Created.At, format="%Y-%m-%d")
tweets.hepatitis <- rbind(tweets.hepatitis2,tweets.hepatitis3)
tweets.hepatitis <- rbind(tweets.hepatitis,tweets.hepatitis1)
tweets.hepatitis<- tweets.hepatitis[!(is.na(tweets.hepatitis$created)),]

tweets.psoriasis2 <- subset(tweets, label == "psoriasis")
tweets.psoriasis2<-tweets.psoriasis[grep("[0-9]{1}/[0-9]{2}/2017",tweets.psoriasis$Created.At),]
tweets.psoriasis2$created <- as.Date(tweets.psoriasis2$Created.At, format="%m/%d/%Y")
tweets.psoriasis3 <- subset(tweets, label == "psoriasis")
tweets.psoriasis3<-tweets.psoriasis[grep("[0-9]{1}/[0-9]{2}/2003",tweets.psoriasis$Created.At),]
tweets.psoriasis3$Created.At<-gsub("/17/2003", "-03-2017", tweets.psoriasis3$Created.At)
tweets.psoriasis3$created <- as.Date(tweets.psoriasis3$Created.At, format="%d-%m-%Y")
tweets.psoriasis1 <- subset(tweets, label == "psoriasis")
tweets.psoriasis1$created <- as.Date(tweets.psoriasis1$Created.At, format="%Y-%m-%d")
tweets.psoriasis<- rbind(tweets.psoriasis2,tweets.psoriasis3)
tweets.psoriasis <- rbind(tweets.psoriasis,tweets.psoriasis1)
tweets.psoriasis<- tweets.psoriasis[!(is.na(tweets.psoriasis$created)),]

tweets.rheumatoid2 <- subset(tweets, label == "rheumatoid arthritis")
tweets.rheumatoid2<-tweets.rheumatoid[grep("[0-9]{1}/[0-9]{2}/2017",tweets.rheumatoid$Created.At),]
tweets.rheumatoid2$created <- as.Date(tweets.rheumatoid2$Created.At, format="%m/%d/%Y")
tweets.rheumatoid3 <- subset(tweets, label == "rheumatoid arthritis")
tweets.rheumatoid3<-tweets.rheumatoid[grep("[0-9]{1}/[0-9]{2}/2003",tweets.rheumatoid$Created.At),]
tweets.rheumatoid3$Created.At<-gsub("/17/2003", "-03-2017", tweets.rheumatoid3$Created.At)
tweets.rheumatoid3$created <- as.Date(tweets.rheumatoid3$Created.At, format="%d-%m-%Y")
tweets.rheumatoid1 <- subset(tweets, label == "rheumatoid arthritis")
tweets.rheumatoid1$created <- as.Date(tweets.rheumatoid1$Created.At, format="%Y-%m-%d")
tweets.rheumatoid <- rbind(tweets.rheumatoid2,tweets.rheumatoid3)
tweets.rheumatoid <- rbind(tweets.rheumatoid,tweets.rheumatoid1)
tweets.rheumatoid<- tweets.rheumatoid[!(is.na(tweets.rheumatoid$created)),]

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

tweets.ankylosing.plot <- plotTweetsByMonth(tweets.ankylosing, "Ankylosing spondylitis")
tweets.ankylosing.plot

tweets.hepatitis.plot <- plotTweetsByMonth(tweets.hepatitis, "Hepatitis C")
tweets.hepatitis.plot

tweets.psoriasis.plot <- plotTweetsByMonth(tweets.psoriasis, "Psoriasis")
tweets.psoriasis.plot

tweets.rheumatoid.plot <- plotTweetsByMonth(tweets.rheumatoid, "Rheumatoid arthritis")
tweets.rheumatoid.plot

## Plotting product post counts 
tweets.plot.df <- data.frame(product=c("Ankylosing spondylitis" ,"Hepatitis C", "Psoriasis" ,"Rheumatoid arthritis"),
                            tweetsCount=c(nrow(tweets.ankylosing), nrow(tweets.hepatitis), nrow(tweets.psoriasis),nrow(tweets.rheumatoid)))

posts.plot<-ggplot(data=tweets.plot.df, aes(x=product, y=tweetsCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=tweetsCount), vjust=-0.5, color="black", size=3.5)+
  labs(x = "Product", y = "Tweets count", 
       title = "Tweets count on our different keywords")

tweets.plot.df


