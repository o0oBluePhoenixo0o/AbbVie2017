# This files contains methods to crawl facebook data 

# install.packages("Rfacebook")
# install.packages("plyr")
# install.packages("dplyr")

library(Rfacebook)
library(plyr)
library(dplyr)

# Feel free to use this app credentials for testing. The app is owned by me, I will eventually delete it in the future. 
# facebook_oauth <- fbOAuth(app_id="1752159831691319", app_secret="352ab92354e2a3532496db02a6a680cc")
# save(facebook_oauth, file="facebook_oauth")
#load("facebook_oauth")

x<-facebook_oauth

searchFB <- function(key){
  # Taken from Trung Nguyen Ngoc Nam(@BluePhoenix1908), added if-statement for checking if page has no posts
  # Crawls all medical Facebook pages for a specific keyword and writes the resulting data.frame into a .csv
  #
  # Args:
  #   key: Keyword to search for

  message(paste("Getting data for keyword: ",key, sep = " "))
  
  pagelist<- select(filter(searchPages(key,x, n = 10000), 
                           category == "Medical Company" | category =="Pharmaceuticals" |
                             category == "Biotechnology Company"| category =="Medical & Health" |
                             category == "Community" | category == "Interest"),id)
  
  begin = "2012-01-01" # Start date for searching pages
  today = Sys.Date()
  
  # Initiate variables
  
  page_df <- data.frame()

  comment_df <- data.frame()
  replies_df <- data.frame()
  
  # pulling data for page_df and comment_df 
  for (i in 1:nrow(pagelist)) {
    target_page <- getPage(pagelist[i,],x,n=10000, since=begin , until = today,
                           feed = TRUE, reactions = TRUE)
    # Adding keyword to table
    if (!empty(target_page)) {
      target_page <- cbind(key = key, target_page)
    }
    page_df <- try(rbind(page_df,target_page))
    
    for (j in 1:nrow(target_page)) {
      if (is.null(target_page$id[j])) {
        #doNothing
      } else {
        target_post <- getPost(target_page$id[j], n=10000,  x, comments = TRUE, likes = TRUE)
        comment_df <-try(rbind(comment_df,target_post$comments))
        if (class(comment_df)=="try-error") next;
      }
    }
    if (class(page_df)=="try-error") next;
  }
  
  # Join 2 data frame to create 1 consolidated dataset for each keyword but also check if the dfs are empty
  # Check if the dataframes are empty
  
  if (!empty(page_df)) {
    # the 2nd part of ID
    for (i in 1:nrow(page_df)) {
      x<-strsplit(page_df[i,]$id,"_")[[1]]
      y<-tolower(x)[2]
      page_df$join_id[i] <-y
    }
  }
  
  if (!empty(comment_df)) {
    # the 1st part of ID
    for (i in 1:nrow(comment_df)) {
      x<-strsplit(comment_df[i,]$id,"_")[[1]]
      y<-tolower(x)[1]
      comment_df$join_id[i] <-y
    }
  }
  
  if (empty(page_df)) {
    final_dataset<-data.frame();
  } else if (empty(comment_df)) {
    final_dataset<-page_df
  } else {
    final_dataset<-full_join(page_df,comment_df,by = c("join_id"))
  }
  
  write.csv(final_dataset, file = paste("",key,".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")
}


mergeCSVsUTF8 <- function(...){
  # Merge a list of csv files to one encoded in UTF-8
  #
  # Args:
  #   ...: comma separated filenames
  
  files <- list(...)
  print(files)
  
  masterDF <- data.frame()

  for (file in files) {
    fileData <- tryCatch(
      {
        read.csv(file=file, header=TRUE, sep=",")
      },
      error=function(cond) {
        message("Error reading csv")
        message(cond)
        # Choose a return value in case of error
        return(NA)
      },
      warning=function(cond) {
        message("Warning reading csv")
        message(cond)
        # Choose a return value in case of warning
        return(NULL)
      },
      finally={
        message("Read CSV successfully")
      }
    )    
    masterDF <- rbind(masterDF, fileData)
    browser()
  }
  write.csv(masterDF, file = paste("./products/Alex_FB_Products_utf8",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")
}

mergeCSVsUTF16LE <- function(...){
  
  # Merge a list of csv files to one encoded in UTF-16LE
  #
  # Args:
  #   ...: comma separated filenames
  
  files <- list(...)
  print(files)
  
  masterDF <- data.frame()
  
  
  for (file in files) {
    fileData <- tryCatch(
      {
        read.csv(file=file, header=TRUE, sep=",")
      },
      error=function(cond) {
        message("Error reading csv")
        message(cond)
        # Choose a return value in case of error
        return(NA)
      },
      warning=function(cond) {
        message("Warning reading csv")
        message(cond)
        # Choose a return value in case of warning
        return(NULL)
      },
      finally={
        message("Read CSV successfully")
      }
    )    
    masterDF <- rbind(masterDF, fileData)
  }
  write.csv(masterDF, file = paste("./products/Alex_FB_Products_utf16le",".csv", sep = ""), fileEncoding = "UTF-16LE", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")
}

