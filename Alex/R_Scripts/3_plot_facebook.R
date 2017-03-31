#This file is used for computating the different plots on posts and comments to differnt products
library(ggplot2)
library(plyr)
library(dplyr)
library(zoo)
library(reshape2)


plotFacebookPostsByMonth <- function (posts, keyword){
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

plotFacebookPostActivites <- function(labels,...){
  # Plot a the number of activites on facebook posts. The number of dataframes and the amount of labels have to be the same!
  #
  # Args:
  #   labels: Vector of labels of the different datasets provided
  #   ...: Arbitrary amount of different post dataframes
  #
  # Returns:
  #   A ggplot2 bar chart
  
  
  entities <- c(labels)
  dataframes.post <- list(...)
  commentCountC <- c()
  likeCountC <- c()
  shareCountC <- c()
  
  if(length(entities) != length(dataframes.post)){
    message("please provide the same number of labels and dataframes")
    return(NA)
  }
  
  for(postDataframe in dataframes.post){
    commentCountC <- c(commentCountC, sum(postDataframe$comments_count.x))
    likeCountC <- c(likeCountC, sum(postDataframe$likes_count.x ))
    shareCountC <- c(shareCountC, sum(postDataframe$shares_count))
  }
  
  acitivities.plot.df <- data.frame(
    product=entities,
    commentCount=commentCountC,
    likeCount=likeCountC,
    shareCount=shareCountC
  )
  
  acitivities.plot.df.melted <- melt(acitivities.plot.df, id.var="product")
  acitivities.plot <- ggplot(acitivities.plot.df.melted, aes(x = product, y = value))
  acitivities.plot <-  acitivities.plot + facet_wrap(~ variable) +
    geom_bar(stat = "identity") + labs(x = "Product", y = "Count", title = "Activities on different keywords")+
    geom_text(aes(label=value), vjust=-0.5, color="red", size=3.5, position = position_stack(vjust = 0.5))
  
  return(acitivities.plot)
}


facebookMaster.df <- read.csv("Final_FB_3103.csv", sep = ",", as.is = TRUE)

#Format dates 
facebookMaster.df$created_time.x <- as.Date(facebookMaster.df$created_time.x)
facebookMaster.df$created_time.y <- as.Date(facebookMaster.df$created_time.y)

#Extracting product posts
posts <- unique(select(facebookMaster.df, 2, 4, 7, 8, 12, 13)) #key, likes_count.x, message.x, created_time.x, comments_count, shares_count

#Companies 
posts.companies <- subset(posts, key == "AbbVie" | key == "Amgen" | key == "Bristol-Myers Squibb" )
posts.companies.abbvie = subset(posts.companies, key == "AbbVie")
posts.companies.amgen = subset(posts.companies, key == "Amgen")
posts.companies.bristol = subset(posts.companies, key == "Bristol-Myers Squibb")


#Products
posts.products <- subset(posts, key == "Imbruvica" | key == "Adalimumab" | key == "Trilipix" | key == "Enbrel" | key == "Humira" )
posts.products.humira <- subset(posts.products, key == "Humira")
posts.products.enbrel <- subset(posts.products, key == "Enbrel")
posts.products.trilipix <- subset(posts.products, key == "Trilipix")
posts.products.adalimumab <- subset(posts.products, key == "Adalimumab")
posts.products.imbruvica <- subset(posts.products, key == "Imbruvica")


#Diseases
posts.diseases <- subset(posts, key == "HepatitisC" | key == "JuvenileIdiopathicArthritis" | key == "JuvenileRheumatoidArthritis" | key == "Ankylosing Spondylitis" | key == "Rheumatoid Arthritis" | key == "Psoriasis")
posts.diseases.hepatitisC <- subset(posts.diseases, key == "HepatitisC")
posts.diseases.juvenileIdiopathicArthritis <- subset(posts.diseases, key == "JuvenileIdiopathicArthritis")
posts.diseases.juvenileRheumatoidArthritis <- subset(posts.diseases, key == "JuvenileRheumatoidArthritis")
posts.diseases.ankylosing <- subset(posts.diseases, key == "Ankylosing Spondylitis")
posts.diseases.rheumatoid <- subset(posts.diseases, key == "Rheumatoid Arthritis")
posts.diseases.psoriasis <- subset(posts.diseases, key == "Psoriasis")

#- Timelines -#

#Companies
posts.companies.abbvie.plot <- plotFacebookPostsByMonth(posts.companies.abbvie, "Abbvie")
posts.companies.abbvie.plot
ggsave("./img/abbvie_timeline_plot.png",posts.companies.abbvie.plot)

posts.companies.amgen.plot <- plotFacebookPostsByMonth(posts.companies.amgen, "Amgen")
posts.companies.amgen.plot
ggsave("./img/amgen_timeline_plot.png",posts.companies.amgen.plot)

posts.companies.bristol.plot <- plotFacebookPostsByMonth(posts.companies.bristol, "Bristol-Myers Squibb")
posts.companies.bristol.plot
ggsave("./img/bristol-meyers_timeline_plot.png",posts.companies.bristol.plot)


#Products
posts.products.humira.plot <- plotFacebookPostsByMonth(posts.products.humira, "Humira")
posts.products.humira.plot
ggsave("./img/humira_timeline_plot.png",posts.products.humira.plot)

posts.products.adalimumab.plot <- plotFacebookPostsByMonth(posts.products.adalimumab, "Adalimumab")
posts.products.adalimumab.plot
ggsave("./img/adalimumab_timeline_plot.png",posts.products.adalimumab.plot)

posts.products.enbrel.plot <- plotFacebookPostsByMonth(posts.products.enbrel, "Enbrel")
posts.products.enbrel.plot
ggsave("./img/enbrel_timeline_plot.png",posts.products.enbrel.plot)

posts.products.imbruvica.plot <- plotFacebookPostsByMonth(posts.products.imbruvica, "Imbruvica")
posts.products.imbruvica.plot
ggsave("./img/imbruvica_timeline_plot.png",posts.products.imbruvica.plot)


#Diseases
posts.diseases.ankylosing.plot <- plotFacebookPostsByMonth(posts.diseases.ankylosing, "Ankylosing Spondylitis")
posts.diseases.ankylosing.plot 
ggsave("./img/ankylosing-spondylitis_timeline_plot.png", posts.diseases.ankylosing.plot )

posts.diseases.hepatitisC.plot <- plotFacebookPostsByMonth(posts.diseases.hepatitisC, "HepatitisC")
posts.diseases.hepatitisC.plot
ggsave("./img/HepatitisC_timeline_plot.png", posts.diseases.hepatitisC.plot)

posts.diseases.juvenileIdiopathicArthritis.plot <- plotFacebookPostsByMonth(posts.diseases.juvenileIdiopathicArthritis, "JuvenileIdiopathicArthritis")
posts.diseases.juvenileIdiopathicArthritis.plot
ggsave("./img/juvenileIdiopathicArthritis_timeline_plot.png", posts.diseases.juvenileIdiopathicArthritis.plot)

posts.diseases.juvenileRheumatoidArthritis.plot <- plotFacebookPostsByMonth(posts.diseases.juvenileRheumatoidArthritis, "JuvenileRheumatoidArthritis")
posts.diseases.juvenileRheumatoidArthritis.plot
ggsave("./img/juvenileRheumatoidArthritis_timeline_plot.png", posts.diseases.juvenileRheumatoidArthritis.plot )

posts.diseases.rheumatoid.plot <- plotFacebookPostsByMonth(posts.diseases.rheumatoid, "Rheumatoid Arthritis")
posts.diseases.rheumatoid.plot
ggsave("./img/rheumatoid-Arthritis_timeline_plot.png", posts.diseases.rheumatoid.plot )

posts.diseases.psoriasis.plot <- plotFacebookPostsByMonth(posts.diseases.psoriasis, "Psoriasis")
posts.diseases.psoriasis.plot
ggsave("./img/psoriasis_timeline_plot.png", posts.diseases.psoriasis.plot )


#- Activities -#

posts.products.activities.plot <- plotFacebookPostActivites(c("Humira", "Enbrel","Adlimumab","Imbruvica","Trilipix"), posts.products.humira, posts.products.enbrel, posts.products.adalimumab, posts.products.imbruvica,posts.products.trilipix)
posts.products.activities.plot
ggsave("./img/products_activities_plot.png",posts.products.activities.plot)

posts.companies.activities.plot <- plotFacebookPostActivites(c("Abbvie", "Amgen", "Bristol-Myers Squibb"), posts.companies.abbvie, posts.companies.amgen, posts.companies.bristol)
posts.companies.activities.plot
ggsave("./img/companies_activities_plot.png",posts.companies.activities.plot)

posts.diseases.activities.plot <- plotFacebookPostActivites(c("HepatitisC", "JuvenileIdiopathicArthritis", "JuvenileRheumatoidArthritis", "Ankylosing Spondylitis","Rheumatoid Arthritis", "Psioriasis"),
                                                           posts.diseases.hepatitisC, posts.diseases.juvenileIdiopathicArthritis, posts.diseases.juvenileRheumatoidArthritis, posts.diseases.ankylosing, posts.diseases.rheumatoid, posts.diseases.psoriasis)
posts.diseases.activities.plot
ggsave("./img/diseases_activities_plot.png",posts.diseases.activities.plot)




## Plotting product post counts 
posts.plot.df <- data.frame(product=c("Humira", "Enbrel", "Trilipix", "Adalimumab", "Imbruvica"),
                            postCount=c(nrow(posts.products.humira), nrow(posts.products.enbrel), nrow(posts.products.trilipix), nrow(posts.products.adalimumab), nrow(posts.products.imbruvica)))

posts.plot<-ggplot(data=posts.plot.df, aes(x=product, y=postCount)) +
  geom_bar(stat="identity")+
  geom_text(aes(label=postCount), vjust=-0.5, color="black", size=3.5)+
  labs(x = "Product", y = "Post count", 
       title = "Post count on our different keywords")

posts.plot
ggsave("./img/product_posts_counts.png",posts.plot)
