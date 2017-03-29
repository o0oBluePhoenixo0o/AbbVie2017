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



posts.products <- subset(posts, key == "Imbruvica" | key == "Adalimumab" | key == "Trilipix" | key == "Enbrel" | key == "Humira" )

posts.products.humira <- subset(posts.products, key == "Humira")
posts.products.enbrel <- subset(posts.products, key == "Enbrel")
posts.products.trilipix <- subset(posts.products, key == "Trilipix")
posts.products.adalimumab <- subset(posts.products, key == "Adalimumab")
posts.products.imbruvica <- subset(posts.products, key == "Imbruvica")



plotPostsByMonth <- function (posts, keyword){
  # Plot a facebook post dataframe grouping by monthly posts counts. Dataframe needs at least $created_time.x attribute. 
  #
  # Args:
  #   posts: Dataframe of Facebook posts with column created_time.x
  #   keyword: String indicating the plotted keyword, used for title generation
  #
  # Returns:
  #   A ggplot2 line plot
  
  posts.month <- posts
  posts.month$created_time.x <- format(as.Date(posts.month$created_time.x), format ="%m-%y") # format to only show month and year
  posts.month<- ddply(posts.month, 'created_time.x', function(x) c(count=nrow(x)))
  
  posts.month <-  posts.month[order(as.yearmon(as.character(posts.month$created_time.x),"%m-%Y")),] #use zoo's as.yearmon so that we can group by month/year
  posts.month$created_time.x <- factor(posts.month$created_time.x, levels=unique(as.character(posts.month$created_time.x)) ) #so that ggplot2 respects the order of my dates
  
  
  posts.month.plot<-ggplot(data=posts.month, aes(x=posts.month$created_time.x, y=count, group = 1)) +
    geom_point() +
    geom_line(aes(colour = count), stat = "identity") + scale_colour_gradient(low="red",high = "green") +
    geom_text(aes(label=count), vjust=-0.5, color="black", size=3.5) +
    labs(x = "Month-Year", y = "Post count", 
         title = paste("Post count on keyword", keyword, sep = " "))
  return(posts.month.plot)
}




posts.products.humira.plot <- plotPostsByMonth(posts.products.humira, "Humira")
posts.products.humira.plot

posts.products.adalimumab.plot <- plotPostsByMonth(posts.products.adalimumab, "Adalimumab")
posts.products.adalimumab.plot

posts.products.enbrel.plot <- plotPostsByMonth(posts.products.enbrel, "Enbrel")
posts.products.enbrel.plot

posts.products.imbruvica.plot <- plotPostsByMonth(posts.products.imbruvica, "Imbruvica")
posts.products.imbruvica.plot




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

