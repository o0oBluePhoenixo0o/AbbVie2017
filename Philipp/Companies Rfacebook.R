## Crawling with Rfacebook

#Install packages
install.packages("Rfacebook")
install.packages("devtools")
install.packages("ggplot2")
install.packages("scales")
install.packages("dplyr")

#Using Rfacebook package
require (Rfacebook)
library(devtools)
# visualize evolution in metric
library(ggplot2)
library(scales)
#Table manipulation
library(dplyr)

#Get FB_Oauth
fb_oauth <- fbOAuth(app_id="204227866723896", 
                    app_secret="e39f8a7750fd165276e0d36709201f92",
                    extended_permissions = TRUE)

x <- fb_oauth

searchFB <- function(key, directory){
  
  print(paste("Getting data for keyword: ",key, sep = " "))
  
  pagelist<- select(filter(searchPages(key,x), 
                           category == "Medical Company" | category =="Pharmaceuticals"),id)
  
  begin = "2012-01-01"
  today = Sys.Date()
  
  # Initiate variables
  
  page_df <- data.frame()
  #post_df <- data.frame()
  comment_df <- data.frame()
  replies_df <- data.frame()
  
  #pulling data for page_df and comment_df 
  for (i in 1:nrow(pagelist))
  {
    target_page <- getPage(pagelist[i,],x,n=10000, since=begin , until = today,
                           feed = TRUE, reactions = TRUE)
    page_df <- try(rbind(page_df,target_page))
    for (j in 1:nrow(target_page))
    {
      target_post <- getPost(target_page$id[j], n=10000,  x, comments = TRUE, likes = TRUE)
      #post_df<- try(rbind(post_df,target_post$post))
      comment_df <-try(rbind(comment_df,target_post$comments))
      if (class(comment_df)=="try-error")next;
    }
    if(class(page_df)=="try-error")next;
  }
  # Join 2 data frame to create 1 consolidated dataset for each keyword
  
  #the 2nd part of ID
  for (i in 1:nrow(page_df))
  {
    x<-strsplit(page_df[i,]$id,"_")[[1]]
    y<-tolower(x)[2]
    page_df$join_id[i] <-y
  }
  #the 1st part of ID
  for (i in 1:nrow(comment_df))
  {
    x<-strsplit(comment_df[i,]$id,"_")[[1]]
    y<-tolower(x)[1]
    comment_df$join_id[i] <-y
  }
  
  final_dataset<-full_join(page_df,comment_df,by = c("join_id"))
  
  dir.create(paste(directory,key, sep = ""))
  write.csv(final_dataset, file = paste(directory,key,".csv", sep = ""), 
            quote = TRUE, sep= ";",
            row.names=FALSE, qmethod='escape',
            fileEncoding = "UTF-16LE", na = "NA")
}

searchFB("AbbVie","./companies/")
searchFB("Amgen","./companies/")
searchFB("Bristol","/companies/")
#####################################################
#             IGNORE THIS PART AND ONWARDS          #
#####################################################

pagelist<- select(filter(searchPages("AbbVie",x), 
                         category == "Medical Company" | category =="Pharmaceuticals"),id)

begin = "2012-01-01"
today = Sys.Date()

# Initiate variables

page_df <- data.frame()
#post_df <- data.frame()
comment_df <- data.frame()
replies_df <- data.frame()

#pulling data for page_df and comment_df 
for (i in 1:nrow(pagelist))
{
  target_page <- getPage(pagelist[i,],x,n=10000, since=begin , until = today,
                         feed = TRUE, reactions = TRUE)
  page_df <- try(rbind(page_df,target_page))
  for (j in 1:nrow(target_page))
  {
    target_post <- getPost(target_page$id[j], n=10000,  x, comments = TRUE, likes = TRUE)
    #post_df<- try(rbind(post_df,target_post$post))
    comment_df <-try(rbind(comment_df,target_post$comments))
    if (class(comment_df)=="try-error")next;
  }
  if(class(page_df)=="try-error")next;
}

# Join 2 data frame to create 1 consolidated dataset for each keyword

#the 2nd part of ID
for (i in 1:nrow(page_df))
{
  x<-strsplit(page_df[i,]$id,"_")[[1]]
  y<-tolower(x)[2]
  page_df$join_id[i] <-y
}
#the 1st part of ID
for (i in 1:nrow(comment_df))
{
  x<-strsplit(comment_df[i,]$id,"_")[[1]]
  y<-tolower(x)[1]
  comment_df$join_id[i] <-y
}

final_dataset<-full_join(page_df,comment_df,by = c("join_id"))

setwd("C:/Users/BluePhoenix/Documents/GitHub/AbbVie2017/Philipp")
write.csv(e, file = "Abbvie.csv", quote = TRUE, sep= ";",
            row.names=FALSE, qmethod='escape',
            fileEncoding = "UTF-16LE", na = "NA")

################## Random Testing #####################
me <- getUsers("me", x)

searchGroup("AbbVie",x)

" Group ID (the only open and official group)
278782302258949  Abbvie"
AbbVie_group <- getGroup(278782302258949, x, n = 5000)

#######################################################
# Visualization for comments/likes/shares of AbbiveGlobal page

page <- getPage("AbbVieGlobal", token, n = 5000)
page[which.max(page$likes_count), ]
## convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}
## aggregate metric counts over month
aggregate.metric <- function(metric) {
  m <- aggregate(page[[paste0(metric, "_count")]], list(month = page$month), 
                 mean)
  m$month <- as.Date(paste0(m$month, "-15"))
  m$metric <- metric
  return(m)
}
# create data frame with average metric counts per month
page$datetime <- format.facebook.date(page$created_time)
page$month <- format(page$datetime, "%Y-%m")
df.list <- lapply(c("likes", "comments", "shares"), aggregate.metric)
df <- do.call(rbind, df.list)

ggplot(df, aes(x = month, y = x, group = metric)) 
+ geom_line(aes(color = metric)) 
+ scale_x_date(date_breaks = "years", 
               labels = date_format("%Y")) 
                        + scale_y_log10("Average count per post", 
               breaks = c(10, 100)) + theme_bw() + theme(axis.title.x = element_blank())
