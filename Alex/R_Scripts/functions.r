library(Rfacebook)
library(openxlsx)

#facebook_oauth <- fbOAuth(app_id="1752159831691319", app_secret="352ab92354e2a3532496db02a6a680cc")


#save(facebook_oauth, file="facebook_oauth")
load("facebook_oauth")


# Helper function for iterating over rows in a data.frame
rows = function(tab) lapply(
  seq_len(nrow(tab)),
  function(i) unclass(tab[i,,drop=F])
)

## ABBVIE PAGE ##
retrieveAbbviePageData <- function(){
  abbviePageData <- getPage(1213879395322100, token = facebook_oauth, feed=TRUE, n = 1000 )
  return(abbviePageData)
}

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

getGroupsDataWithKey <- function(key){
  search_groups <- searchGroup(key, facebook_oauth)
}
