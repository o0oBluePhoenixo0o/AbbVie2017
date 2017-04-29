setwd("~/GitHub/AbbVie2017/Philipp")
#Read data from final consolidate dataset
#FaceBook
FB_df <- read.csv("Final_FB_2804.csv",sep = ",", as.is = TRUE)


# for (i in 1:nrow(FB_df))
# {
#   if (is.na(FB_df$message.x[i]) == FALSE){FB_df$message.x[i] <- conv_fun(FB_df$message.x[i])} 
#   if (is.na(FB_df$message.y[i]) == FALSE){FB_df$message.y[i] <- conv_fun(FB_df$message.y[i])}  
# }
# 
# #delete unwanted columns
# FB_df <- FB_df[ , -which(names(FB_df) %in% c("X"))]
# 
# #Clear AI bots
# FB_df <- FB_df[!FB_df$from_name.x %in% c("Investment Research on Amgen Inc",
#                                          "Investment Research on Bristol-Myers Squibb Company",
#                                          "Investment Research on AbbVie Inc"),]


##################################################
# 
# # Detect language by adding "language" column next to the dataset
# # Only detect languages of Posts since comments languages will be influenced mainly by posts
# 
# # install.packages("franc")
# library(franc)
# detectLanguage <- function(text){
#   # Uses 'franc' package to detect the language of a given text
#   #
#   # Args:
#   #   text: The text to detect the language
#   #
#   # Returns:
#   #   A ISO 639-2 encoded language code string
#   
#   if (!is.na(text)) {
#     return (franc(text, min_length = 3))
#   } else {
#     message("Can not detect language of NA")
#     return (NA)
#   }
# }
# 
# a<- unique(FB_df[,c("id.x","message.x")])
# x <- NA
# a <- cbind(a, x)
# 
# for (i in 1:nrow(a)){
#   if (is.na(a$message.x[i])== FALSE){
#     a$x[i] <- conv_fun(a$message.x[i])
#   }
# }
# 
# language.x <- NA
# 
# a <- cbind(a,language.x)
# 
# #This will take sometimes ~30min with 55k posts
# t1 <- Sys.time()
# t1
# for (i in 1:nrow(a)){
#   if (is.na(a$x[i]) == FALSE){
#     a$language.x[i] <- detectLanguage(a$x[i])} 
# }
# print(difftime(Sys.time(), t1, units = 'mins'))
# 
# #list of language + counts
# agg <- dplyr::summarize(dplyr::group_by(a,language.x),n())
# 
# FB_df <- dplyr::right_join(a[,c("id.x","language.x")],FB_df, by = "id.x")

#############################################################

#change list of keywords to match with TW
FB_df$key <- tolower(FB_df$key)
FB_df$key[FB_df$key == "hepatitisc"] <- "hepatitis c"
FB_df$key[FB_df$key == "bristol-myers squibb"] <- "bristol myers"

## convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}
FB_df$created_time.x <- format.facebook.date(FB_df$created_time.x)
FB_df$created_time.y <- format.facebook.date(FB_df$created_time.y)

#Write new FB_df with language detection and keywords to lowercase 28.04.17
# write.csv(FB_df, file = "Final_FB_2804.csv",
#           quote = TRUE, row.names=FALSE,
#           fileEncoding = "UTF-8", na = "NA")

##########################################################################

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

################################################################################

#Twitter
TW_df <- read.csv("Final_TW_2804.csv",sep = ",", as.is = TRUE)
#delete the first column "X"
TW_df <- TW_df[,-1]
#change "Label" to fit with FB_df

for (i in 1:ncol(TW_df)){
  if (colnames(TW_df)[i]=="Text"){colnames(TW_df)[i] <- "message"}
  else if(colnames(TW_df)[i] == "Created.At"){colnames(TW_df)[i] <- "created_time"}
  
  if (colnames(TW_df)[i] == "key"){
    key<-TW_df[,i]
    TW_df<-TW_df[,!(names(TW_df) %in% c("key"))]}
}
TW_df<-cbind(key,TW_df)
TW_df <- TW_df[!(TW_df$message == "" | TW_df$key == 'Label' | TW_df$key == ""|
                   TW_df$created_time ==""|is.na(TW_df$key) == TRUE),]

#Filter only ENGLISH tweets
TW_df <- TW_df[TW_df$Language == 'en',]

#Create a Retweet dataset
require(stringr)
TW_RT <- subset(TW_df,str_sub(TW_df$message, start = 1, end = 4) == "RT @")

#Tweets-only dataset
TW_T <- TW_df[-grep("RT @",TW_df$message),]


######################################
# Preparation for Sentiment Analysis #
######################################

prep_fun <- tolower
conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")

TW_df$message <- conv_fun(prep_fun(TW_df$message))

time <- TW_df

TW_df$created_time<-gsub("/17/2003", "-03-2017", TW_df$created_time)
TW_df$created_time <- lubridate::parse_date_time(TW_df$created_time, 
                                                c("%m/%d/%y %H:%M",
                                                  "%d-%m-%y %H:%M",
                                                  "%y-%m-%d %H:%M:%S"))
# #Write new TW_df with date-time fixed and messages to lowercase + ASCII 29.04.17
# write.csv(TW_df, file = "Final_TW_2804_prep",
#            quote = TRUE, row.names=FALSE,
#            fileEncoding = "UTF-8", na = "NA")
