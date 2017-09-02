# This file is used for computating the different plots on posts and comments to differnt products

# install.packages("ggplot2")
# install.packages("plyr")
# install.packages("dplyr")
# install.packages("zoo")
# install.packages("reshape2")

library(ggplot2)
library(plyr)
library(dplyr)
library(zoo)
library(reshape2)
library(lubridate)


plotFacebookPostsByMonth <- function (posts, keyword){
  # Plot a facebook post dataframe grouping by monthly posts counts. Dataframe needs at least $created_time.x attribute. It also
  # visualized the standard derivation of posts in a month. Messages the data table for count,mean,sd per month. 
  #
  # Args:
  #   posts: Dataframe of Facebook posts with column created_time.x
  #   keyword: String indicating the plotted keyword, used for title generation
  #
  # Returns:
  #   A ggplot2 line plot
  
  if(nrow(posts)==0){
    message("Your data.frame is empty!")
  }
  
  posts.copy <- posts
  
  
  # prepare df to work with m-y ordering
  posts.copy$created_time.x <- ymd(posts.copy$created_time.x)
  posts.copy$created_time.x <- paste(year(posts.copy$created_time.x),month(posts.copy$created_time.x),day(posts.copy$created_time.x),sep = "-")
  posts.copy <- ddply(posts.copy, 'created_time.x', function(x) c(count=nrow(x)))
  posts.copy$created_time.x <- ymd(posts.copy$created_time.x)
  
  posts.copy$day <- lubridate::day(posts.copy$created_time.x)
  posts.copy$month <- lubridate::month(posts.copy$created_time.x)
  posts.copy$year <- lubridate::year(posts.copy$created_time.x)
  
  posts.copy.monthly <- aggregate( count ~ month + year , posts.copy , sum )
  posts.copy.monthly$mean <- aggregate( count ~ month + year , posts.copy , mean )[3]
  posts.copy.monthly$sd <- aggregate( count ~ month + year , posts.copy , sd )[3]
  posts.copy.monthly$time.x <- paste(posts.copy.monthly$month,posts.copy.monthly$year, sep = "-")
  
  posts.copy.monthly <-  posts.copy.monthly[order(as.yearmon(as.character(posts.copy.monthly$time.x),"%m-%Y")),] # use zoo's as.yearmon so that we can group by month/year
  posts.copy.monthly$time.x <- factor(posts.copy.monthly$time.x, levels=unique(as.character(posts.copy.monthly$time.x)) ) # sso that ggplot2 respects the order of my dates
  
  View(posts.copy.monthly)
  write.csv(posts.copy.monthly, "posts_copy_monthly.csv")
  message(paste("Sum of posts in ",keyword ,sum(posts.copy.monthly$count), sep = " "))
  
  posts.monthly.plot<-ggplot(data=posts.copy.monthly, aes(x=posts.copy.monthly$time.x, y=count, group = 1)) +
    geom_point() +
    geom_errorbar(aes(ymin=count-sd, ymax=count+sd), width=.8) +
    geom_line(aes(colour = count), stat = "identity") + scale_colour_gradient(low="red",high = "green") +
    geom_text(aes(label=count), vjust=-0.5, color="black", size=3.5) +
    labs(x = "Month-Year", y = "Post count", 
         title = paste("Post count on keyword", keyword, sep = " "))
  
  
  # Because of strange print and view error of the aggregated values
  printDf <- data.frame()
  printDf <- cbind(posts.copy.monthly$month,posts.copy.monthly$year,posts.copy.monthly$count,posts.copy.monthly$mean,posts.copy.monthly$sd)
  names(printDf) <- c("month","year","count","mean","sd")
  
  message(paste("Data table for keyword ", keyword, "\n", print_and_capture(printDf), sep = " "))
  return (posts.monthly.plot)
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
    geom_bar(stat = "identity") + labs(x = "Keyword", y = "Count", title = "Activities on different keywords")+
    geom_text(aes(label=value), vjust=-0.5, color="red", size=3.5, position = position_stack(vjust = 0.5))
  
  return(acitivities.plot)
}


print_and_capture <- function(x){
  # Print function, for printing data.frames in message(x)
  #
  # Args:
  #   x: Object to print
  #
  # Returns:
  #   Printable String of the object
  
  paste(capture.output(print(x)), collapse = "\n")
}


facebookMaster.df <- read.csv("Final_FB_2804.csv", sep = ",", as.is = TRUE)
facebookMaster.df <- subset(facebookMaster.df, language == "eng" | language == "sco" | language == "afr") # only english ones

#Format dates 
facebookMaster.df$created_time.x <- as.Date(facebookMaster.df$created_time.x)
facebookMaster.df$created_time.y <- as.Date(facebookMaster.df$created_time.y)

#Extracting  posts and comments
posts <- unique(select(facebookMaster.df, 2, 3, 4, 5, 6, 7, 8, 12, 13, 14, 15, 16, 17, 18)) #key, language, likes_count.x, message.x, from.id, from.name, created_time.x, comments_count, shares_count, loves_count, haha_count, wow_count, sad_count, angry_count
commments <- unique(select(facebookMaster.df, 20, 21, 22, 23, 24, 26)) # from.id_y, from.name_y, message_y, created_time.y, likes_count.y, id.y


#Companies 
posts.companies <- subset(posts, key == "abbvie" | key == "amgen" | key == "bristol myers" | key == "johnson & johnson" )
posts.companies.abbvie = subset(posts.companies, key == "abbvie")
posts.companies.amgen = subset(posts.companies, key == "amgen")
posts.companies.bristol = subset(posts.companies, key == "bristol myers")
posts.companies.johnson = subset(posts.companies, key == "johnson & johnson")


#Products
posts.products <- subset(posts, key == "imbruvica" | key == "adalimumab" | key == "trilipix" | key == "enbrel" | key == "humira" | key == "ibrutinib")
posts.products.humira <- subset(posts.products, key == "humira")
posts.products.enbrel <- subset(posts.products, key == "enbrel")
posts.products.trilipix <- subset(posts.products, key == "trilipix")
posts.products.adalimumab <- subset(posts.products, key == "adalimumab")
posts.products.imbruvica <- subset(posts.products, key == "imbruvica")
posts.products.ibrutinib <- subset(posts.products, key == "ibrutinib")


#Diseases
posts.diseases <- subset(posts, key == "hepatitis c" | key == "rheumatoid arthritis" | key == "rheumatoid arthritis" | key == "ankylosing spondylitis" | key == "psoriasis" | key == "juvenilerheumatoidarthritis" | key == "juvenileidiopathicarthritis")
posts.diseases.hepatitisC <- subset(posts.diseases, key == "hepatitis c")
posts.diseases.juvenileIdiopathicArthritis <- subset(posts.diseases, key == "juvenileidiopathicarthritis")
posts.diseases.juvenileRheumatoidArthritis <- subset(posts.diseases, key == "juvenilerheumatoidarthritis")
posts.diseases.ankylosing <- subset(posts.diseases, key == "ankylosing spondylitis")
posts.diseases.rheumatoid <- subset(posts.diseases, key == "rheumatoid arthritis")
posts.diseases.psoriasis <- subset(posts.diseases, key == "psoriasis")

#- Timelines -#

#Companies
posts.companies.abbvie.plot <- plotFacebookPostsByMonth(posts.companies.abbvie, "Abbvie")
posts.companies.abbvie.plot
ggsave("./img/abbvie_timeline_plot.png",posts.companies.abbvie.plot, width=20, height=4, dpi=100)

posts.companies.amgen.plot <- plotFacebookPostsByMonth(posts.companies.amgen, "Amgen")
posts.companies.amgen.plot
ggsave("./img/amgen_timeline_plot.png",posts.companies.amgen.plot, width=10, height=4, dpi=100)

posts.companies.bristol.plot <- plotFacebookPostsByMonth(posts.companies.bristol, "Bristol-Myers Squibb")
posts.companies.bristol.plot
ggsave("./img/bristol-meyers_timeline_plot.png",posts.companies.bristol.plot, width=10, height=4, dpi=100)

posts.companies.johnson.plot <- plotFacebookPostsByMonth(posts.companies.johnson, "Johnson & Johnson")
posts.companies.johnson.plot 
ggsave("./img/johnson_timeline_plot.png",posts.companies.johnson.plot , width=10, height=4, dpi=100)


#Products
posts.products.humira.plot <- plotFacebookPostsByMonth(posts.products.humira, "Humira")
posts.products.humira.plot
ggsave("./img/humira_timeline_plot.png",posts.products.humira.plot,width=10, height=4, dpi=100)

posts.products.adalimumab.plot <- plotFacebookPostsByMonth(posts.products.adalimumab, "Adalimumab")
posts.products.adalimumab.plot
ggsave("./img/adalimumab_timeline_plot.png",posts.products.adalimumab.plot,width=10, height=4, dpi=100)

posts.products.enbrel.plot <- plotFacebookPostsByMonth(posts.products.enbrel, "Enbrel")
posts.products.enbrel.plot
ggsave("./img/enbrel_timeline_plot.png",posts.products.enbrel.plot,width=10, height=4, dpi=100)

posts.products.imbruvica.plot <- plotFacebookPostsByMonth(posts.products.imbruvica, "Imbruvica")
posts.products.imbruvica.plot
ggsave("./img/imbruvica_timeline_plot.png",posts.products.imbruvica.plot,width=10, height=4, dpi=100)


#Diseases
posts.diseases.ankylosing.plot <- plotFacebookPostsByMonth(posts.diseases.ankylosing, "Ankylosing Spondylitis")
posts.diseases.ankylosing.plot 
ggsave("./img/ankylosing-spondylitis_timeline_plot.png", posts.diseases.ankylosing.plot,width=16, height=4, dpi=100 )

posts.diseases.hepatitisC.plot <- plotFacebookPostsByMonth(posts.diseases.hepatitisC, "HepatitisC")
posts.diseases.hepatitisC.plot
ggsave("./img/hepatitisC_timeline_plot.png", posts.diseases.hepatitisC.plot,width=10, height=4, dpi=100)

posts.diseases.juvenileIdiopathicArthritis.plot <- plotFacebookPostsByMonth(posts.diseases.juvenileIdiopathicArthritis, "JuvenileIdiopathicArthritis")
posts.diseases.juvenileIdiopathicArthritis.plot
ggsave("./img/juvenileIdiopathicArthritis_timeline_plot.png", posts.diseases.juvenileIdiopathicArthritis.plot,width=10, height=4, dpi=100)

posts.diseases.juvenileRheumatoidArthritis.plot <- plotFacebookPostsByMonth(posts.diseases.juvenileRheumatoidArthritis, "JuvenileRheumatoidArthritis")
posts.diseases.juvenileRheumatoidArthritis.plot
ggsave("./img/juvenileRheumatoidArthritis_timeline_plot.png", posts.diseases.juvenileRheumatoidArthritis.plot ,width=10, height=4, dpi=100 )

posts.diseases.rheumatoid.plot <- plotFacebookPostsByMonth(posts.diseases.rheumatoid, "Rheumatoid Arthritis")
posts.diseases.rheumatoid.plot
ggsave("./img/rheumatoid-Arthritis_timeline_plot.png", posts.diseases.rheumatoid.plot ,width=10, height=4, dpi=100 )

posts.diseases.psoriasis.plot <- plotFacebookPostsByMonth(posts.diseases.psoriasis, "Psoriasis")
posts.diseases.psoriasis.plot
ggsave("./img/psoriasis_timeline_plot.png", posts.diseases.psoriasis.plot, width=10, height=4, dpi=100 )


#- Activities -#

posts.products.activities.plot <- plotFacebookPostActivites(c("Humira", "Enbrel","Adlimumab","Imbruvica","Trilipix", "Ibrutinib"), posts.products.humira, posts.products.enbrel, posts.products.adalimumab, posts.products.imbruvica,posts.products.trilipix, posts.products.ibrutinib)
posts.products.activities.plot
ggsave("./img/products_activities_plot.png",posts.products.activities.plot, width=14, height=4, dpi=300)

posts.companies.activities.plot <- plotFacebookPostActivites(c("Abbvie", "Amgen", "Bristol-Myers Squibb", "Johnson & Johnson"), posts.companies.abbvie, posts.companies.amgen, posts.companies.bristol, posts.companies.johnson)
posts.companies.activities.plot
ggsave("./img/companies_activities_plot.png",posts.companies.activities.plot, width=16, height=4, dpi=300)

posts.diseases.activities.plot <- plotFacebookPostActivites(c("HepatitisC", "Ankylosing Spondylitis","Rheumatoid Arthritis", "Psioriasis", "JIA", "JRA"),
                                                            posts.diseases.hepatitisC, posts.diseases.ankylosing, posts.diseases.rheumatoid, posts.diseases.psoriasis, posts.diseases.juvenileIdiopathicArthritis, posts.diseases.juvenileRheumatoidArthritis)
posts.diseases.activities.plot
ggsave("./img/diseases_activities_plot.png",posts.diseases.activities.plot, width=14, height=4, dpi=300)




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