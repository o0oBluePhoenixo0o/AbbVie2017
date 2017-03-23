#This file is used for computating the different plots on posts and comments to differnt products
library(ggplot2)
library(dplyr)

myMaster.df <- read.csv("Alex_FB_Products_utf8.csv", fileEncoding = "UTF-8", sep = ",", as.is = TRUE)


#- POSTS -#

posts <- select(myMaster.df, 1, 6, 7) #key, message.x, created_time.x
posts.unique <- unique(posts)

posts.humira <- subset(posts.unique, key == "Humira")
posts.enbrel <- subset(posts.unique, key == "Enbrel")
posts.trilipix <- subset(posts.unique, key == "Trilipix")
posts.adalimumab <- subset(posts.unique, key == "Adalimumab")
posts.imbruvica <- subset(posts.unique, key == "Imbruvica")

posts.plot.df <- data.frame(product=c("Humira", "Enbrel", "Trilipix", "Adalimumab", "Imbruvica"),
                 postCount=c(nrow(posts.humira), nrow(posts.enbrel), nrow(posts.trilipix), nrow(posts.adalimumab), nrow(posts.imbruvica)))


posts.plot<-ggplot(data=posts.plot.df, aes(x=product, y=postCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=postCount), vjust=-0.5, color="black", size=3.5)

posts.plot

#- COMMENTS -#

comments <- myMaster.df[complete.cases(myMaster.df[collist]), c("key", "message.y", "created_time.y")]
comments.unique <- unique(comments)


comments.humira <- subset(comments.unique, key == "Humira")
comments.enbrel <- subset(comments.unique, key == "Enbrel")
comments.trilipix <- subset(comments.unique, key == "Trilipix")
comments.adalimumab <- subset(comments.unique, key == "Adalimumab")
comments.imbruvica <- subset(comments.unique, key == "Imbruvica")


comments.plot.df <- data.frame(product=c("Humira", "Enbrel", "Trilipix", "Adalimumab", "Imbruvica"),
                 commentCount=c(nrow(comments.humira), nrow(comments.enbrel), nrow(comments.trilipix), nrow(comments.adalimumab), nrow(comments.imbruvica)))


comments.plot<-ggplot(data=comments.plot.df, aes(x=product, y=commentCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=commentCount), vjust=-0.5, color="black", size=3.5)

comments.plot






