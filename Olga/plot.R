#This file is used for computating the different plots on posts and comments to differnt products
library(ggplot2)
library(plyr)
library(dplyr)
library(zoo)
library(reshape2)


setwd("~/Desktop/Products3/word/file/new")
data_tw <- read.csv("products.csv", sep = ",", as.is = TRUE)

#- Tweets -#

#Format dates 
data_tw$created <- as.Date(data_tw$created)

#Extracting product tweets
tweets <- unique(select(data_tw, 1, 3, 5, 7, 14, 19)) #key, text, favorites_count, date, retweet_count, label
tweets_products <- subset(tweets, label == "imbruvica" | label == "adalimumab" | label == "trilipix" | label == "enbrel" | label == "humira" )



tweets.humira <- subset(tweets, label == "humira")
tweets.enbrel <- subset(tweets, label == "enbrel")
tweets.trilipix <- subset(tweets, label == "trilipix")
tweets.adalimumab <- subset(tweets, label == "adalimumab")
tweets.imbruvica <- subset(tweets, label == "imbruvica")

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
ggsave("./img/humira_timeline_plot.png",tweets.humira.plot)

tweets.adalimumab.plot <- plotTweetsByMonth(tweets.adalimumab, "Adalimumab")
tweets.adalimumab.plot
ggsave("./img/adalimumab_timeline_plot.png",tweets.adalimumab.plot)

tweets.enbrel.plot <- plotTweetsByMonth(tweets.enbrel, "enbrel")
tweets.enbrel.plot
ggsave("./img/enbrel_timeline_plot.png",tweets.enbrel.plot)

tweets.imbruvica.plot <- plotTweetsByMonth(tweets.imbruvica, "Imbruvica")
tweets.imbruvica.plot
ggsave("./img/imbruvica_timeline_plot.png",tweets.imbruvica.plot)

tweets.trilipix.plot <- plotTweetsByMonth(tweets.trilipix, "trilipix")
tweets.trilipix.plot

## Plotting product post counts 
posts.plot.df <- data.frame(product=c("Humira", "Enbrel", "Trilipix", "Adalimumab", "Imbruvica"),
                            postCount=c(nrow(posts.humira), nrow(posts.enbrel), nrow(posts.trilipix), nrow(posts.adalimumab), nrow(posts.imbruvica)))

posts.plot<-ggplot(data=posts.plot.df, aes(x=product, y=postCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=tweetsCount), vjust=-0.5, color="black", size=3.5)+
  labs(x = "Product", y = "tweets count", 
       title = "Post count on our different keywords")

posts.plot
ggsave("./img/product_posts_counts.png",posts.plot)

#- COMMENTS,LIKES,SHARES -#

comments <- facebookMaster.df[complete.cases(facebookMaster.df[]), c("key", "message.y", "created_time.y")]  # key, message.y, created_time.y
comments.unique <- unique(comments)


comments.humira <- subset(comments.unique, key == "Humira")
comments.enbrel <- subset(comments.unique, key == "Enbrel")
comments.trilipix <- subset(comments.unique, key == "Trilipix")
comments.adalimumab <- subset(comments.unique, key == "Adalimumab")
comments.imbruvica <- subset(comments.unique, key == "Imbruvica")

