library(Rfacebook)
library(openxlsx)
library(dplyr)
library(plyr)
library(textcat)

#facebook_oauth <- fbOAuth(app_id="1752159831691319", app_secret="352ab92354e2a3532496db02a6a680cc")


#save(facebook_oauth, file="facebook_oauth")
load("facebook_oauth")

x<-facebook_oauth



#Taken from Trung Nguyen Ngoc Nam(@BluePhoenix1908), added if-statement for checking if page has no posts
searchFB <- function(key){
  
  print(paste("Getting data for keyword: ",key, sep = " "))
  
  pagelist<- select(filter(searchPages(key,x)),id)
  
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

    #Adding keyword to table
    if(!empty(target_page)){
      target_page <- cbind(keyword = key, target_page)
    }
    page_df <- try(rbind(page_df,target_page))
    
    for (j in 1:nrow(target_page))
    {
      print(textcat(target_page$message[j]))
      if(is.null(target_page$id[j])){
      } else {
        target_post <- getPost(target_page$id[j], n=10000,  x, comments = TRUE, likes = TRUE)
        #post_df<- try(rbind(post_df,target_post$post))
        comment_df <-try(rbind(comment_df,target_post$comments))
        if (class(comment_df)=="try-error")next;
      }
    }
    if(class(page_df)=="try-error")next;
  }
  
  # Join 2 data frame to create 1 consolidated dataset for each keyword but also check if the dfs are empty
  #Check if the dataframes are empty
  
  if(!empty(page_df)){
    #the 2nd part of ID
    for (i in 1:nrow(page_df))
    {
      x<-strsplit(page_df[i,]$id,"_")[[1]]
      y<-tolower(x)[2]
      page_df$join_id[i] <-y
    }
  }
  
  if(!empty(comment_df)){
    #the 1st part of ID
    for (i in 1:nrow(comment_df))
    {
      x<-strsplit(comment_df[i,]$id,"_")[[1]]
      y<-tolower(x)[1]
      comment_df$join_id[i] <-y
    }
  }
  
  if(empty(page_df)) {
    final_dataset<-data.frame();
  } else if (empty(comment_df)){
    final_dataset<-page_df
  } else {
    final_dataset<-full_join(page_df,comment_df,by = c("join_id"))
  }
  
  write.csv2(final_dataset, file = paste("./products/",key,".csv", sep = ""),row.names=FALSE, qmethod='escape', quote=TRUE)#
}

# Helper function for iterating over rows in a data.frame
rows = function(tab) lapply(
  seq_len(nrow(tab)),
  function(i) unclass(tab[i,,drop=F])
)


mergeCSVs <- function(...){
  files <- list(...)
  print(files)
  
  masterDF <- data.frame()
  
  
  for(file in files){
    fileData <- tryCatch(
      {
        # Just to highlight: if you want to use more than one 
        # R expression in the "try" part then you'll have to 
        # use curly brackets.
        # 'tryCatch()' will return the last evaluated expression 
        # in case the "try" part was completed successfully
        
        message("This is the 'try' part")
        
        read.csv(file=file, header=TRUE, sep=";")
        # The return value of `readLines()` is the actual value 
        # that will be returned in case there is no condition 
        # (e.g. warning or error). 
        # You don't need to state the return value via `return()` as code 
        # in the "try" part is not wrapped insided a function (unlike that
        # for the condition handlers for warnings and error below)
      },
      error=function(cond) {
        message("Error reading csv")
        message("Here's the original error message:")
        message(cond)
        # Choose a return value in case of error
        return(NA)
      },
      warning=function(cond) {
        message("Error reading csv")
        message("Here's the original warning message:")
        message(cond)
        # Choose a return value in case of warning
        return(NULL)
      },
      finally={
        # NOTE:
        # Here goes everything that should be executed at the end,
        # regardless of success or error.
        # If you want more than one expression to be executed, then you 
        # need to wrap them in curly brackets ({...}); otherwise you could
        # just have written 'finally=<expression>' 
        message("Read CSV successfully")
        message("Some other message at the end")
      }
    )    
    masterDF <- rbind(masterDF, fileData)
  }
  View(masterDF)
  write.csv2(masterDF, file = paste("./products/masterProducts",".csv", sep = ""),row.names=FALSE, qmethod='escape', quote=TRUE)
}



