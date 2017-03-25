## Crawling with Rfacebook

#Install packages
install.packages("Rfacebook")
install.packages("devtools")
install.packages("ggplot2")
install.packages("scales")
install.packages("dplyr")
install.packages(c("curl", "httr"))

#Using Rfacebook package
require (Rfacebook)
library(devtools)
# visualize evolution in metric
library(ggplot2)
library(scales)
#Table manipulation
library(plyr)
library(dplyr)

setwd("~/GitHub/AbbVie2017/Philipp")
#Get FB_Oauth
fb_oauth <- fbOAuth(app_id="204227866723896", 
                    app_secret="e39f8a7750fd165276e0d36709201f92",
                    extended_permissions = TRUE)

x <- fb_oauth

searchFB <- function(key){
  
  cat(paste("Getting data for keyword: ",key,"\n", sep = " "))
  
  pagelist<- select(filter(searchPages(key,x, n = 10000), 
                           category == "Medical Company" | category =="Pharmaceuticals" |
                             category == "Biotechnology Company"| category =="Medical & Health"),id)
  
  cat(paste("\nTotal of relevant pages is: ",nrow(pagelist),"\n"))
  
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
    cat("\n")
    cat(paste("Getting posts from page number ",i," with ID: ", pagelist[i,], "\n"))
    target_page <- getPage(pagelist[i,],x,n=100000, since=begin , until = today,
                           feed = TRUE, reactions = TRUE)
    
    #Adding keyword to table 
    if(!empty(target_page)){
      target_page <- cbind(key, target_page)
    }
    page_df <- try(rbind(page_df,target_page))
    
    #Taken from Alex's code for checking if page has no posts
    for (j in 1:nrow(target_page))
    {
      
      if(is.null(target_page$id[j])){
      } else {
        target_post <- getPost(target_page$id[j], n=100000,  x, comments = TRUE, likes = TRUE)
        #post_df<- try(rbind(post_df,target_post$post))
        comment_df <-try(rbind(comment_df,target_post$comments))
        if (class(comment_df)=="try-error")next;
      }
    }
    if(class(page_df)=="try-error")next;
  }
  
  cat("\n Complete collecting. Now moving to merging phase! \n")
  # Join 2 data frame to create 1 consolidated dataset for each keyword
  
  if(!empty(page_df)){
  #the 2nd part of ID
  for (i in 1:nrow(page_df))
  {
    x<-strsplit(page_df[i,]$id,"_")[[1]]
    y<-tolower(x)[2]
    page_df$join_id[i] <-y
  }}
  
  if(!empty(comment_df)){
  #the 1st part of ID
  for (i in 1:nrow(comment_df))
  {
    x<-strsplit(comment_df[i,]$id,"_")[[1]]
    y<-tolower(x)[1]
    comment_df$join_id[i] <-y
  }}
  
  if(empty(page_df)) {
    final_dataset<-data.frame();
  } else if (empty(comment_df)){
    final_dataset<-page_df
  } else {
    final_dataset<-full_join(page_df,comment_df,by = c("join_id"))
  }
  
  
  cat("\n Writing file to .csv")
  write.csv(final_dataset, file = paste(key,".csv", sep = ""), 
            quote = TRUE, sep= ";",
            row.names=FALSE, qmethod='escape',
            fileEncoding = "UTF-8", na = "NA")
}
# Get data for AbbVie and competitors

searchFB("AbbVie")
searchFB("Bristol-Myers Squibb")
searchFB("Amgen")

#merge csv files
AbbVie = read.csv2(file = "AbbVie.csv", header = TRUE, 
                  sep=",",
                  fileEncoding = "UTF-8")

Amgen = read.csv2(file = "Amgen.csv", header = TRUE, 
                  sep=",",
                  fileEncoding = "UTF-8")

Bristol = read.csv2(file = "Bristol-Myers Squibb.csv", header = TRUE, 
                    sep=",",
                    fileEncoding = "UTF-8")

masterDF <- data.frame()
masterDF <- rbind(AbbVie, masterDF)
masterDF <- rbind(Amgen, masterDF)
masterDF <- rbind(Bristol, masterDF)
write.csv(masterDF, file = "FB_Companies.csv", 
          quote = TRUE, row.names=FALSE, 
          fileEncoding = "UTF-8", na = "NA")
