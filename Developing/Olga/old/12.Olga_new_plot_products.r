####Fixed date fromat plot for products keywords#####


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

tweets <- subset(tweets, label == "humira" | label == "enbrel" | label == "trilipix" | label == "adalimumab"| label == "imbruvica"| label == "ibrutinib" )

tweets.humira <- subset(tweets, label == "humira")
tweets.enbrel <- subset(tweets, label == "enbrel")
tweets.trilipix <- subset(tweets, label == "trilipix")
tweets.adalimumab <- subset(tweets, label == "adalimumab")
tweets.imbruvica <- subset(tweets, label == "imbruvica")
tweets.ibrutinib <- subset(tweets, label == "ibrutinib")



nrow(tweets.humira)

nrow(tweets.enbrel)

nrow(tweets.trilipix)

nrow(tweets.adalimumab)

nrow(tweets.imbruvica)

nrow(tweets.ibrutinib)

tweets.humira2 <- subset(tweets, label == "humira")
tweets.humira2<-tweets.humira[grep("[0-9]{1}/[0-9]{2}/2017",tweets.humira$Created.At),]
tweets.humira2$created <- as.Date(tweets.humira2$Created.At, format="%m/%d/%Y")
tweets.humira3 <- subset(tweets, label == "humira")
tweets.humira3<-tweets.humira[grep("[0-9]{1}/[0-9]{2}/2003",tweets.humira$Created.At),]
tweets.humira3$Created.At<-gsub("/17/2003", "-03-2017", tweets.humira3$Created.At)
tweets.humira3$created <- as.Date(tweets.humira3$Created.At, format="%d-%m-%Y")
tweets.humira1 <- subset(tweets, label == "humira")
tweets.humira1$created <- as.Date(tweets.humira1$Created.At, format="%Y-%m-%d")
tweets.humira <- rbind(tweets.humira2,tweets.humira3)
tweets.humira <- rbind(tweets.humira,tweets.humira1)
tweets.humira<- tweets.humira[!(is.na(tweets.humira$created)),]

tweets.enbrel2 <- subset(tweets, label == "enbrel")
tweets.enbrel2<-tweets.enbrel[grep("[0-9]{1}/[0-9]{2}/2017",tweets.enbrel$Created.At),]
tweets.enbrel2$created <- as.Date(tweets.enbrel2$Created.At, format="%m/%d/%Y")
tweets.enbrel3 <- subset(tweets, label == "enbrel")
tweets.enbrel3<-tweets.enbrel[grep("[0-9]{1}/[0-9]{2}/2003",tweets.enbrel$Created.At),]
tweets.enbrel3$Created.At<-gsub("/17/2003", "-03-2017", tweets.enbrel3$Created.At)
tweets.enbrel3$created <- as.Date(tweets.enbrel3$Created.At, format="%d-%m-%Y")
tweets.enbrel1 <- subset(tweets, label == "enbrel")
tweets.enbrel1$created <- as.Date(tweets.enbrel1$Created.At, format="%Y-%m-%d")
tweets.enbrel <- rbind(tweets.enbrel2,tweets.enbrel3)
tweets.enbrel <- rbind(tweets.enbrel,tweets.enbrel1)
tweets.enbrel<- tweets.enbrel[!(is.na(tweets.enbrel$created)),]

tweets.trilipix2 <- subset(tweets, label == "trilipix")
tweets.trilipix2<-tweets.trilipix[grep("[0-9]{1}/[0-9]{2}/2017",tweets.trilipix$Created.At),]
tweets.trilipix2$created <- as.Date(tweets.trilipix2$Created.At, format="%m/%d/%Y")
tweets.trilipix3 <- subset(tweets, label == "trilipix")
tweets.trilipix3<-tweets.trilipix[grep("[0-9]{1}/[0-9]{2}/2003",tweets.trilipix$Created.At),]
tweets.trilipix3$Created.At<-gsub("/17/2003", "-03-2017", tweets.trilipix3$Created.At)
tweets.trilipix3$created <- as.Date(tweets.trilipix3$Created.At, format="%d-%m-%Y")
tweets.trilipix1 <- subset(tweets, label == "trilipix")
tweets.trilipix1$created <- as.Date(tweets.trilipix1$Created.At, format="%Y-%m-%d")
tweets.trilipix <- rbind(tweets.trilipix2,tweets.trilipix3)
tweets.trilipix <- rbind(tweets.trilipix,tweets.trilipix1)
tweets.trilipix<- tweets.trilipix[!(is.na(tweets.trilipix$created)),]

tweets.imbruvica2 <- subset(tweets, label == "imbruvica")
tweets.imbruvica2<-tweets.imbruvica[grep("[0-9]{1}/[0-9]{2}/2017",tweets.imbruvica$Created.At),]
tweets.imbruvica2$created <- as.Date(tweets.imbruvica2$Created.At, format="%m/%d/%Y")
tweets.imbruvica3 <- subset(tweets, label == "imbruvica")
tweets.imbruvica3<-tweets.imbruvica[grep("[0-9]{1}/[0-9]{2}/2003",tweets.imbruvica$Created.At),]
tweets.imbruvica3$Created.At<-gsub("/17/2003", "-03-2017", tweets.imbruvica3$Created.At)
tweets.imbruvica3$created <- as.Date(tweets.imbruvica3$Created.At, format="%d-%m-%Y")
tweets.imbruvica1 <- subset(tweets, label == "imbruvica")
tweets.imbruvica1$created <- as.Date(tweets.imbruvica1$Created.At, format="%Y-%m-%d")
tweets.imbruvica <- rbind(tweets.imbruvica2,tweets.imbruvica3)
tweets.imbruvica <- rbind(tweets.imbruvica,tweets.imbruvica1)
tweets.imbruvica<- tweets.imbruvica[!(is.na(tweets.imbruvica$created)),]

tweets.adalimumab2 <- subset(tweets, label == "adalimumab")
tweets.adalimumab2<-tweets.adalimumab[grep("[0-9]{1}/[0-9]{2}/2017",tweets.adalimumab$Created.At),]
tweets.adalimumab2$created <- as.Date(tweets.adalimumab2$Created.At, format="%m/%d/%Y")
tweets.adalimumab3 <- subset(tweets, label == "adalimumab")
tweets.adalimumab3<-tweets.adalimumab[grep("[0-9]{1}/[0-9]{2}/2003",tweets.adalimumab$Created.At),]
tweets.adalimumab3$Created.At<-gsub("/17/2003", "-03-2017", tweets.adalimumab3$Created.At)
tweets.adalimumab3$created <- as.Date(tweets.adalimumab3$Created.At, format="%d-%m-%Y")
tweets.adalimumab1 <- subset(tweets, label == "adalimumab")
tweets.adalimumab1$created <- as.Date(tweets.adalimumab1$Created.At, format="%Y-%m-%d")
tweets.adalimumab <- rbind(tweets.adalimumab2,tweets.adalimumab3)
tweets.adalimumab <- rbind(tweets.adalimumab,tweets.adalimumab1)
tweets.adalimumab<- tweets.adalimumab[!(is.na(tweets.adalimumab$created)),]

#tweets.bristol$created

tweets.ibrutinib2 <- subset(tweets, label == "ibrutinib")
tweets.ibrutinib2<-tweets.ibrutinib[grep("[0-9]{1}/[0-9]{2}/2017",tweets.ibrutinib$Created.At),]
tweets.ibrutinib2$created <- as.Date(tweets.ibrutinib2$Created.At, format="%m/%d/%Y")
tweets.ibrutinib3 <- subset(tweets, label == "ibrutinib")
tweets.ibrutinib3<-tweets.ibrutinib[grep("[0-9]{1}/[0-9]{2}/2003",tweets.ibrutinib$Created.At),]
tweets.ibrutinib3$Created.At<-gsub("/17/2003", "-03-2017", tweets.ibrutinib3$Created.At)
tweets.ibrutinib3$created <- as.Date(tweets.ibrutinib3$Created.At, format="%d-%m-%Y")
tweets.ibrutinib1 <- subset(tweets, label == "ibrutinib")
tweets.ibrutinib1$created <- as.Date(tweets.ibrutinib1$Created.At, format="%Y-%m-%d")
tweets.ibrutinib <- rbind(tweets.ibrutinib2,tweets.ibrutinib3)
tweets.ibrutinib <- rbind(tweets.ibrutinib,tweets.ibrutinib1)
tweets.ibrutinib<- tweets.ibrutinib[!(is.na(tweets.ibrutinib$created)),]

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

tweets.humira.plot <- plotTweetsByMonth(tweets.humira, "Humira")
tweets.humira.plot

tweets.enbrel.plot <- plotTweetsByMonth(tweets.enbrel, "Enbrel")
tweets.enbrel.plot

tweets.trilipix.plot <- plotTweetsByMonth(tweets.trilipix, "Trilipix")
tweets.trilipix.plot

tweets.adalimumab.plot <- plotTweetsByMonth(tweets.adalimumab, "Adalimumab")
tweets.adalimumab.plot

tweets.imbruvica.plot <- plotTweetsByMonth(tweets.imbruvica, "Imbruvica")
tweets.imbruvica.plot

tweets.ibrutinib.plot <- plotTweetsByMonth(tweets.ibrutinib, "Ibrutinib")
tweets.ibrutinib.plot

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
tweets.plot.df <- data.frame(product=c("humira" ,"enbrel", "trilipix" ,"adalimumab","imbruvica","ibrutinib"),
                            tweetsCount=c(nrow(tweets.humira), nrow(tweets.enbrel), nrow(tweets.trilipix),nrow(tweets.adalimumab),nrow(tweets.imbruvica),nrow(tweets.ibrutinib)))

posts.plot<-ggplot(data=tweets.plot.df, aes(x=product, y=tweetsCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=tweetsCount), vjust=-0.5, color="black", size=3.5)+
  labs(x = "Product", y = "Tweets count", 
       title = "Tweets count on our different keywords")

tweets.plot.df


