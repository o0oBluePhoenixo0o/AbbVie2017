library(Rfacebook)
library(openxlsx)
library(dplyr)
library(plyr)

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
    page_df <- try(rbind(page_df,target_page))
    for (j in 1:nrow(target_page))
    {
      print(target_page$id[j])
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
  
  View(final_dataset)
  
  write.csv2(final_dataset, file = paste(key,".csv", sep = ""),row.names=FALSE, qmethod='escape', quote=TRUE)
  
  
}



# Helper function for iterating over rows in a data.frame
rows = function(tab) lapply(
  seq_len(nrow(tab)),
  function(i) unclass(tab[i,,drop=F])
)
getPagesDataWithKey <- function(key){
  print(paste("Getting the data from all FB Pages with the keyword",key, sep = " "))
  
  dir <- paste("./products/",key,"/",sep="")
  dirPages <- paste(dir,"/pages/",sep="")
  dir.create(dir) 
  dir.create(dirPages)
  pageSearchResult <- searchPages(key, facebook_oauth, n = 200)
  for(page in rows(pageSearchResult)){
    
    currentDir <- paste(dirPages,page$id,sep = "")
    dir.create(currentDir)
    
    #Get the page with it's posts#
    pageData <- getPage(page$id, token = facebook_oauth, feed=TRUE, n = 1000 )
    write.csv(pageData, file=paste(currentDir,"/",page$id,".csv", sep = ""), row.names=FALSE)
    
    
    currentDirPosts <- paste(currentDir,"/posts", sep="")
    dir.create(currentDirPosts)
    for (post in rows(pageData)) {
      
      postDetailDir <- paste(currentDirPosts,"/",post$id, sep = "")
      postDetail <- getPost(post$id, facebook_oauth, n = 500, comments = TRUE, likes = TRUE)
      postReactions <- getReactions(post$id, facebook_oauth)
      
      
      dir.create(postDetailDir)
      
      write.csv(postDetail$post, file=paste(postDetailDir,"/postDetail",".csv", sep = ""),row.names=FALSE)
      write.csv(postDetail$comments, file=paste(postDetailDir,"/postComments",".csv", sep = ""),row.names=FALSE)
      write.csv(postDetail$likes, file=paste(postDetailDir,"/postLikes",".csv", sep = ""),row.names=FALSE)
      write.csv(postReactions, file=paste(postDetailDir,"/postReactions",".csv", sep = ""),row.names=FALSE)
      
    }
  }
}

getPagesDataWithKeySingleFile <- function(key, directory){
  
  print(paste("Getting the data from all FB Pages with the keyword",key, sep = " "))
  
  pagesSearchResult <- searchPages(key, facebook_oauth, n = 200)
  postsOnPages <- data.frame()
  commentsOnPosts <- data.frame()
  reactionsOnPosts <- data.frame()
  
  for(page in rows(pagesSearchResult)){
    
    #Get the page with it's posts#
    pageData <- getPage(page$id, token = facebook_oauth, feed=TRUE, n = 1000 )
    postsOnPages <- rbind(postsOnPages, pageData)
    
    for (post in rows(pageData)) {
      
      postDetail <- getPost(post$id, facebook_oauth, n = 5000, comments = TRUE, likes = TRUE)
      postReactions <- getReactions(post$id, facebook_oauth)
      
      
      comments <- postDetail$comments
      commentsOnPosts <- rbind(commentsOnPosts, comments)
      
      reactionsOnPosts <-  rbind(reactionsOnPosts, postReactions)
      
    }
  }
  
  dir.create(paste(directory,key, sep = ""))
  write.csv(pagesSearchResult, file = paste(directory,"/",key,"/","pages.csv", sep = ""), row.names=FALSE, qmethod='escape', quote=TRUE)
  write.csv(postsOnPages, file = paste(directory,"/",key,"/","posts.csv", sep = ""),row.names=FALSE, qmethod='escape', quote=TRUE)
  write.csv(commentsOnPosts, file = paste(directory,"/",key,"/","comments.csv", sep = ""),row.names=FALSE, qmethod='escape', quote=TRUE)
  write.csv(reactionsOnPosts, file = paste(directory,"/",key,"/","reactions.csv", sep = ""),row.names=FALSE, qmethod='escape', quote=TRUE)
}




