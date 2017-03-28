#This file is used for computating the different plots on posts and comments to differnt products
library(ggplot2)
library(plyr)
library(dplyr)
library(zoo)
library(reshape2)
facebookMaster.df <- read.csv("Final_FB_2403.csv", sep = ",", as.is = TRUE)

#- POSTS -#

#Format dates 
facebookMaster.df$created_time.x <- as.Date(facebookMaster.df$created_time.x)
facebookMaster.df$created_time.y <- as.Date(facebookMaster.df$created_time.y)

#Extracting product posts
posts <- unique(select(facebookMaster.df, 1, 3, 6, 7, 11,12)) #key, likes_count.x, message.x, created_time.x, comments_count, shares_count


posts.humira <- subset(posts, key == "Humira")
posts.enbrel <- subset(posts, key == "Enbrel")
posts.trilipix <- subset(posts, key == "Trilipix")
posts.adalimumab <- subset(posts, key == "Adalimumab")
posts.imbruvica <- subset(posts, key == "Imbruvica")

posts.products <- subset(posts, key == "Imbruvica" | key == "Adalimumab" | key == "Trilipix" | key == "Enbrel" | key == "Humira" )



#-Plotting time lines -#

## ADALIMUMAB
posts.adalimumab_month <- posts.adalimumab
posts.adalimumab_month$created_time.x <- format(as.Date(posts.adalimumab_month$created_time.x), format ="%m-%y")


posts.adalimumab_byTimeMonth <- ddply(posts.adalimumab_month, 'created_time.x', function(x) c(count=nrow(x)))

posts.adalimumab_byTimeMonth <- posts.adalimumab_byTimeMonth[order(as.yearmon(as.character(posts.adalimumab_byTimeMonth$created_time.x),"%m-%Y")),] #use zoo's as.yearmon so that we can group by month
posts.adalimumab_byTimeMonth$created_time.x <- factor(posts.adalimumab_byTimeMonth$created_time.x, levels=unique(as.character(posts.adalimumab_byTimeMonth$created_time.x)) ) #so that ggplot2 respects the order of my dates

posts.adalimumab_byTimeMonth.plot<-ggplot(data=posts.adalimumab_byTimeMonth, aes(x=posts.adalimumab_byTimeMonth$created_time.x, y=count, group = 1)) +
  geom_point() +
  geom_line(aes(colour = count), stat = "identity") + scale_colour_gradient(low="red",high = "green") +
  geom_text(aes(label=count), vjust=-0.5, color="black", size=3.5) +
  labs(x = "Month-Year", y = "Post count", 
       title = "Post count on keyword 'Adalimumab' from 01.01.2012-24.03.2016")


posts.adalimumab_byTimeMonth.plot
ggsave("./img/adalimumab_posts_timeline.png",posts.adalimumab_byTimeMonth.plot)



## HUMIRA
posts.humira_month <- posts.humira
posts.humira_month$created_time.x <- format(as.Date(posts.humira_month$created_time.x), format ="%m-%y")
posts.humira_byTimeMonth <- ddply(posts.humira_month, 'created_time.x', function(x) c(count=nrow(x)))

posts.humira_byTimeMonth <- posts.humira_byTimeMonth[order(as.yearmon(as.character(posts.humira_byTimeMonth$created_time.x),"%m-%Y")),] # use zoo's as.yearmon so that we can group by month
posts.humira_byTimeMonth$created_time.x <- factor(posts.humira_byTimeMonth$created_time.x, levels=unique(as.character(posts.humira_byTimeMonth$created_time.x)) ) # so that ggplot2 respects the order of my dates



posts.humira_byTimeMonth.plot<-ggplot(data=posts.humira_byTimeMonth, aes(x=posts.humira_byTimeMonth$created_time.x, y=count, group = 1)) +
  geom_point() +
  geom_line(aes(colour = count)) + scale_colour_gradient(low="red",high = "green") +
  geom_text(aes(label=count), vjust=-0.5, color="black", size=3.5) +
  labs(x = "Month-Year", y = "Post count", 
       title = "Post count on keyword 'Humira' from 01.01.2012-24.03.2016")


posts.humira_byTimeMonth.plot
ggsave("./img/humira_posts_timeline.png",posts.humira_byTimeMonth.plot)


## Plotting product post counts 
posts.plot.df <- data.frame(product=c("Humira", "Enbrel", "Trilipix", "Adalimumab", "Imbruvica"),
                            postCount=c(nrow(posts.humira), nrow(posts.enbrel), nrow(posts.trilipix), nrow(posts.adalimumab), nrow(posts.imbruvica)))

posts.plot<-ggplot(data=posts.plot.df, aes(x=product, y=postCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=postCount), vjust=-0.5, color="black", size=3.5)+
  labs(x = "Product", y = "Post count", 
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


comments.plot.df <- data.frame(
  product=c("Humira", "Enbrel", "Trilipix", "Adalimumab", "Imbruvica"),
  commentCount=c(nrow(comments.humira), nrow(comments.enbrel), nrow(comments.trilipix), nrow(comments.adalimumab), nrow(comments.imbruvica)),
  likesCount=c(sum(posts.humira$likes_count.x),sum(posts.enbrel$likes_count.x),sum(posts.trilipix$likes_count.x),sum(posts.adalimumab$likes_count.x),sum(posts.imbruvica$likes_count.x)),
  sharesCount=c(sum(posts.humira$shares_count),sum(posts.enbrel$shares_count),sum(posts.trilipix$shares_count),sum(posts.adalimumab$shares_count),sum(posts.imbruvica$shares_count))
)


comments.plot.df.melted <- melt(comments.plot.df, id.var="product")
comments.plot <- ggplot(comments.plot.df.melted, aes(x = product, y = value))
comments.plot <- comments.plot + facet_wrap(~ variable) +
                  geom_bar(stat = "identity") + labs(x = "Product", y = "Count", title = "Acitivites on our different keywords")+
                  geom_text(aes(label=value), vjust=-0.5, color="red", size=3.5, position = position_stack(vjust = 0.5))
comments.plot
ggsave("./img/product_additional_counts.png",comments.plot)

