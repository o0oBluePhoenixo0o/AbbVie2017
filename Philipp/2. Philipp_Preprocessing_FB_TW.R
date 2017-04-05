setwd("~/R")
#Read data from final consolidate dataset
#FaceBook
FB_df <- read.csv("Final_FB_3103.csv",sep = ",", as.is = TRUE)

## convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}
FB_df$created_time.x <- format.facebook.date(FB_df$created_time.x)
FB_df$created_time.y <- format.facebook.date(FB_df$created_time.y)

#Get postdfs & comments from final df
postdf <- subset(FB_df, select = c(key,id.x,message.x,created_time.x))
colnames(postdf)[2] <- "id"
colnames(postdf)[3] <- "message"
colnames(postdf)[4] <- "created_time"
postdf <- subset(postdf, !duplicated(message))

commentdf <- subset(FB_df, select = c(key,id.y,message.y,created_time.y))
colnames(commentdf)[2] <- "id"
colnames(commentdf)[3] <- "message"
colnames(commentdf)[4] <- "created_time"
commentdf <- subset(commentdf, !duplicated(message))

#Twitter
TW_df <- read.csv("Final_TW_3103.csv",sep = ",", as.is = TRUE)
#change "Label" to "key"
colnames(TW_df)[13] <- "key"
colnames(TW_df)[8] <- "text"
colnames(TW_df)[1] <- "created"
#Remove RT
#TW_df <- TW_df[-grep("RT @",TW_df$Text),]
