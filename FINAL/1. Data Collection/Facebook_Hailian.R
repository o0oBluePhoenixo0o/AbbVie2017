
#######################Crawl data from facebook based on public pages id#########################
#######################Crawl all posts and first level comments of the page######################

install.packages("Rfacebook")
install.packages("ggplot2")
install.packages("scales")
install.packages("dplyr")

library(ggplot2)
library(scales)
library(dplyr)

require(Rfacebook)

#Call API
fb_oauth <- fbOAuth(app_id="259715667786273", app_secret="7e35add14d76f215b4e3f3a5a3c74bb2",extended_permissions = TRUE)
#It's necessaryto create a new facebook and create an APP to get the API key

x <- fb_oauth

#get all of the pages info according to keywords, for example "PsoriasisHealthCentral"
pagelist<- select(filter(searchPages("PsoriasisHealthCentral",x), username=="PsoriasisHealthCentral"),id)

#set the time frame to crawl post from "begin" to "today"
begin = "2012-01-01"
today = Sys.Date()

# Initiate variables
page_df <- data.frame() #dataframe for post
comment_df <- data.frame() #dataframe for comments
replies_df <- data.frame()

#pulling data for page_df and comment_df 
for (i in 1:nrow(pagelist))
{
  target_page <- getPage(pagelist[i,],x,n=100000, since=begin , until = today,
                         feed = TRUE, reactions = TRUE)
  page_df <- try(rbind(page_df,target_page))
  for (j in 1:nrow(target_page))
  {
    target_post <- getPost(target_page$id[j], n=100000,  x, comments = TRUE, likes = TRUE)
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

PsoriasisHealthCentral_final_dataset<-full_join(page_df,comment_df,by = c("join_id"))

PsoriasisHealthCentral_final_dataset<- cbind(key="Psoriasis", PsoriasisHealthCentral_final_dataset)
write.csv(PsoriasisHealthCentral_final_dataset, file = "PsoriasisHealthCentral.csv", quote = TRUE, sep= ",",
          row.names=FALSE, qmethod='escape',
          fileEncoding = "UTF-8", na = "NA")
