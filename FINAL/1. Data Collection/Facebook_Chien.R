#### Crawling Facebook data with Rfacebook package ####
### Version 1 ###

## Install packages
install.packages("Rfacebook")
install.packages("devtools")
install.packages("ggplot2")
install.packages("scales")
install.packages("dplyr")
install.packages("plyr")
install.packages("gtools")
library(gtools)
library(plyr)

## Using Rfacebook package
require(Rfacebook)
library(devtools)

# Visualize evolution in metric
library(ggplot2)
library(scales)

# Table manipulation
library(dplyr)

## Get FB_Oauth
# Here I create two accounts, so as to prevent a crash
# Crash will happen if we meet the limitation for crawling the data
# fb_oauth <- fbOAuth(app_id = "1890776804530175", 
#                    app_secret = "4ea29a731d21ba7707438e863aa2f93a",
#                    extended_permissions = TRUE)
fb_oauth <- fbOAuth(app_id = "344013755993587", 
                    app_secret = "6e3ccefd761b98f2e48a108173a54e01",
                    extended_permissions = TRUE)

x <- fb_oauth

searchFB <- function(key, min_count, max_count){
  
  cat(paste("Getting data for keyword: ", key, "\n", sep = " "))
  
  pagelist<- select(filter(searchPages(key, x, n = 40), 
                           (talking_about_count >= min_count & talking_about_count <= max_count & 
                              (category == "Community" | category == "Diseases" | 
                                 category == "Health/Wellness Website" | category == "Non-Profit Organization"|
                                 category == "Charity Organization" | category == "Hospital"|
                                 category == "Medical Research Center" | category == "Medical Company"|
                                 category == "Non-Governmental Organization (NGO)" | category == "Government Organization"|
                                 category =="Pharmaceuticals" | category == "Biotechnology Company"
                              ))), id)
  
  cat(paste("\n","Total of relevant pages is: ",nrow(pagelist),"\n"))
  
  ## Specify the time period for crawling the data
  begin = "2012-01-01"
  end = "2017-07-31"
  today = Sys.Date()
  
  ## Initiate variables
  page_df <- data.frame()
  comment_df <- data.frame()
  replies_df <- data.frame()
  
  ## Pulling data for page_df and comment_df 
  for (i in 1:nrow(pagelist))
  {
    cat("\n")
    cat(paste("Getting posts from page number ",i," with ID: ", pagelist[i,], "\n"))
    target_page <- getPage(pagelist[i,],x,n=100000, since=begin , until = end,
                           feed = TRUE, reactions = TRUE)
    
    # Adding keywords to table 
    if(!empty(target_page)){
      target_page <- cbind(key, target_page)
    }
    page_df <- try(rbind(page_df,target_page))
    
    # Taken from Alex's code for checking if page has no posts
    for (j in 1:nrow(target_page))
    {
      
      if(is.null(target_page$id[j])){
      } else {
        target_post <- getPost(target_page$id[j], n=100000,  x, comments = TRUE, likes = TRUE)
        #post_df <- try(rbind(post_df,target_post$post))
        comment_df <- try(rbind(comment_df,target_post$comments))
        if (class(comment_df) == "try-error")next;
      }
    }
    if(class(page_df) == "try-error")next;
  }
  
  # Join 2 data frame to create 1 consolidated dataset for each keyword
  cat("\n Complete collecting. Now moving to merging phase! \n") 
  if(!empty(page_df)){
    # The 1st part of ID
    for (i in 1:nrow(page_df))
    {
      x<-strsplit(page_df[i,]$id,"_")[[1]]
      y<-tolower(x)[2]
      page_df$join_id[i] <- y
    }}
  
  if(!empty(comment_df)){
    # The 2nd part of ID
    for (i in 1:nrow(comment_df))
    {
      x <- strsplit(comment_df[i,]$id, "_")[[1]]
      y <- tolower(x)[1]
      comment_df$join_id[i] <- y
    }}
  
  if(empty(page_df)) {
    final_dataset <- data.frame();
    
  } else if (empty(comment_df)){
    final_dataset <- page_df
    
  } else {
    final_dataset <- full_join(page_df, comment_df, by = c("join_id"))
  }
  
  # final_dataset <- cbind(keyword = key, final_dataset)
  return(final_dataset)
}

## From here, need to specify the page id and also the keywords we wanted to crawl from Facebook

# "JuvenileIdiopathicArthritis",0 1
# "JuvenileRheumatoidArthritis",0 2
# final_dataset1 <- searchFB("JuvenileIdiopathicArthritis",0,1000)
# final_dataset2 <- searchFB("JuvenileRheumatoidArthritis",0,1000)
# final_dataset3 <- searchFB("HepatitisC",200,250) #1446406762332875
# final_dataset4 <- searchFB("HepatitisC",308,310) #601938559929026
# final_dataset5 <- searchFB("HepatitisC",70,80) #189959364382598 & 1593580544255890
# final_dataset6 <- searchFB("HepatitisC",36,38) #107063971566
# final_dataset7 <- searchFB("HepatitisC",35,35) #202214949822312
# final_dataset8 <- searchFB("HepatitisC",35,35) #202214949822312
# final_dataset9 <- searchFB("HepatitisC",35,35) #202214949822312
final_datasetJIA <- rbind.data.frame(final_dataset1,final_dataset2)
final_datasetHEV <- rbind.data.frame(final_dataset3,final_dataset4,final_dataset5,final_dataset6,final_dataset7,final_dataset8,final_dataset9)
final_dataset <- rbind.data.frame(final_datasetHEV,final_datasetJIA)

cat("\n Writing file to .csv")
write.csv(final_dataset, file = paste("Combine_utf16",".csv", sep = ""), 
          quote = TRUE, sep= ",",
          row.names=FALSE, qmethod='escape',
          fileEncoding = "UTF-16LE", na = "NA")

##########These are for manually checking process###########
pagelist <- select(filter(searchPages("HepatitisC", x, n = 200), 
                         (talking_about_count >= 20 & talking_about_count <= 310 & 
                            (category == "Community" | category == "Diseases" | 
                               category == "Health/Wellness Website" | category == "Non-Profit Organization"|
                               category == "Charity Organization" | category == "Hospital"|
                               category == "Medical Research Center" | category == "Medical Company"|
                               category == "Non-Governmental Organization (NGO)" | category == "Government Organization"|
                               category =="Pharmaceuticals" | category == "Biotechnology Company"
                            ))), id, category, name, talking_about_count)

pagelist <- select(filter(searchPages("HepatitisC", x, n = 40), 
                         (talking_about_count >= 20 & talking_about_count <= 300 & 
                            (category == "Community" | category == "Diseases" | 
                               category == "Health/Wellness Website" | category == "Non-Profit Organization"|
                               category == "Charity Organization" | category == "Hospital"|
                               category == "Medical Research Center" | category == "Medical Company"|
                               category == "Non-Governmental Organization (NGO)" | category == "Government Organization"|
                               category == "Pharmaceuticals" | category == "Biotechnology Company"
                            ))),id,category,name,talking_about_count)
pagelist200 <- searchPages("HepatitisC", x, n = 200)

### Version 2 ###

## Install the packages we need
install.packages("devtools")
library(devtools)
install_github("Rfacebook", "pablobarbera", subdir="Rfacebook")
require (Rfacebook)

## Require the app_id and the secret token to successfully login to fb api account
fb_oauth <- fbOAuth(app_id="***************", app_secret="***************", extended_permissions = TRUE)
save(fb_oauth, file = "fb_oauth")
token <- fb_oauth
load("fb_oauth")

## Get the post from page

# Search the page id by editing the string
id_page <- searchPages(string="*****", token=fb_oauth, n=100)
id_page

# page:you can either get the post from page by its id or pagename
# n:et the maximum posts
# since, until: set the time period you want to retrieve from the page
fb_page <- getPage(page="*****", token=fb_oauth, n=100000, feed=TRUE, reactions=TRUE,
                   since='2012/01/01', until='2017/03/08')

# Save the post dataframe into csv file
write.csv(fb_page, file = "post_**********.csv")

## Get the comments of each post from page
my_data <- list()
for (i in c(1:length(fb_page$id))){
  post_page <- getPost(post=fb_page$id[i], token = fb_oauth)
  my_data[[i]] <- data.frame(post_page[3])
  if(i == 1){
    comment_page <- my_data[[1]]
  }
  else{
    comment_page <- rbind.data.frame(comment_page, my_data[[i]])
  }
}

#Save the comment dataframe into csv file
write.csv(comment_page, file = "comment_**********.csv")

## Get the post from public group
# Search the group id by editing the name
# Will see private and public group id regarding the the name you want to search
id_group <- searchGroup(name="**********", token=fb_oauth)
id_group

# group_id:you need to get the post from group by its id
# n:set the maximum posts you want to retrieve
# since, until: set the time period you want to retrieve from the public group
fb_group <- getGroup(group_id=**********, token=fb_oauth, n=100000, feed=TRUE,
                     since='2012/01/01', until='2017/03/08')

# Save the post dataframe into csv file
write.csv(fb_group, file = "post_**********.csv")
my_data <- list()

## Get the comment of each post from public group
for (i in c(1:length(fb_group$id))){
  post_group <- getPost(post=fb_group$id[i], token=fb_oauth)
  my_data[[i]] <- data.frame(post_group[3])
  if(i == 1){
    comment_group <- my_data[[1]]
  }
  else{
    comment_group <- rbind.data.frame(comment_group, my_data[[i]])
  }
}

# Save the comment dataframe into csv file
write.csv(comment_group, file = "comment_**********.csv")
