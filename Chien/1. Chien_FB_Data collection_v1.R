## Crawling with Rfacebook

#Install packages
install.packages("Rfacebook")
install.packages("devtools")
install.packages("ggplot2")
install.packages("scales")
install.packages("dplyr")
install.packages("plyr")
install.packages("gtools")
library(gtools)
library(plyr)
#Using Rfacebook package
require (Rfacebook)
library(devtools)
# visualize evolution in metric
library(ggplot2)
library(scales)
#Table manipulation
library(dplyr)

#Get FB_Oauth
#fb_oauth <- fbOAuth(app_id="1890776804530175", 
#                    app_secret="4ea29a731d21ba7707438e863aa2f93a",
#                    extended_permissions = TRUE)
fb_oauth <- fbOAuth(app_id="344013755993587", 
                    app_secret="6e3ccefd761b98f2e48a108173a54e01",
                    extended_permissions = TRUE)

x <- fb_oauth

searchFB <- function(key, min_count, max_count){
  
  cat(paste("Getting data for keyword: ",key,"\n", sep = " "))
  
  pagelist<- select(filter(searchPages(key,x, n = 40), 
                           (talking_about_count>=min_count & talking_about_count<=max_count & 
                              (category == "Community" | category =="Diseases" | 
                                 category == "Health/Wellness Website" | category =="Non-Profit Organization"|
                                 category == "Charity Organization" | category =="Hospital"|
                                 category == "Medical Research Center" | category =="Medical Company"|
                                 category == "Non-Governmental Organization (NGO)" | category =="Government Organization"|
                                 category =="Pharmaceuticals" | category == "Biotechnology Company"
                              ))),id)
  
  cat(paste("\n","Total of relevant pages is: ",nrow(pagelist),"\n"))
  
  begin = "2012-01-01"
  end = "2013-12-31"
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
    target_page <- getPage(pagelist[i,],x,n=100000, since=begin , until = end,
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
  
  #final_dataset <- cbind(keyword = key, final_dataset)
  return(final_dataset)
}

#"JuvenileIdiopathicArthritis",0 1
#"JuvenileRheumatoidArthritis",0 2
#final_dataset1 <- searchFB("JuvenileIdiopathicArthritis",0,1000)
#final_dataset2 <- searchFB("JuvenileRheumatoidArthritis",0,1000)
#final_dataset3 <- searchFB("HepatitisC",200,250)#1446406762332875
#final_dataset4 <- searchFB("HepatitisC",308,310)#601938559929026
#final_dataset5 <- searchFB("HepatitisC",70,80) #189959364382598 & 1593580544255890
#final_dataset6 <- searchFB("HepatitisC",36,38) #107063971566
#final_dataset7 <- searchFB("HepatitisC",35,35) #202214949822312
#final_dataset8 <- searchFB("HepatitisC",35,35) #202214949822312
#final_dataset9 <- searchFB("HepatitisC",35,35) #202214949822312
final_datasetJIA <- rbind.data.frame(final_dataset1,final_dataset2)
final_datasetHEV <- rbind.data.frame(final_dataset3,final_dataset4,final_dataset5,final_dataset6,final_dataset7,final_dataset8,final_dataset9)
final_dataset <- rbind.data.frame(final_datasetHEV,final_datasetJIA)
cat("\n Writing file to .csv")
#write.csv(final_dataset, file = "combine_utf88.csv")
write.csv(final_dataset, file = paste("Combine_utf16",".csv", sep = ""), 
          quote = TRUE, sep= ",",
          row.names=FALSE, qmethod='escape',
          fileEncoding = "UTF-16LE", na = "NA")

##########These are for manually checking process###########
pagelist<- select(filter(searchPages("HepatitisC",x, n=200), 
                         (talking_about_count>=20 & talking_about_count<=310 & 
                            (category == "Community" | category =="Diseases" | 
                               category == "Health/Wellness Website" | category =="Non-Profit Organization"|
                               category == "Charity Organization" | category =="Hospital"|
                               category == "Medical Research Center" | category =="Medical Company"|
                               category == "Non-Governmental Organization (NGO)" | category =="Government Organization"|
                               category =="Pharmaceuticals" | category == "Biotechnology Company"
                            ))),id,category,name,talking_about_count)
pagelist<- select(filter(searchPages("HepatitisC",x, n=40), 
                         (talking_about_count>=20 & talking_about_count<=300 & 
                            (category == "Community" | category =="Diseases" | 
                               category == "Health/Wellness Website" | category =="Non-Profit Organization"|
                               category == "Charity Organization" | category =="Hospital"|
                               category == "Medical Research Center" | category =="Medical Company"|
                               category == "Non-Governmental Organization (NGO)" | category =="Government Organization"|
                               category =="Pharmaceuticals" | category == "Biotechnology Company"
                            ))),id,category,name,talking_about_count)
pagelist200 <-searchPages("HepatitisC",x, n=200)
