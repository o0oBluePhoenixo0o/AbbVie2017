setwd("~/GitHub/AbbVie2017/Philipp")
#Read data from final consolidate dataset
#FaceBook
FB_df <- read.csv("Final_FB_0405_prep.csv",sep = ",", as.is = TRUE)

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

# ## convert date format to R date format
# format.date <- function(datestring) {
#   date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
# }

###############################################################################
#Twitter
TW_df <- read.csv("Final_TW_1205_prep.csv", sep = ",", as.is = TRUE)
TW_df$Id <- as.factor(TW_df$Id)
#Filter only ENGLISH tweets
TW_df <- TW_df[TW_df$Language == 'eng',]

#Create a Retweet dataset
require(stringr)
TW_RT <- subset(TW_df,str_sub(TW_df$message, start = 1, end = 4) == "rt @")

#Tweets-only dataset
TW_T <- TW_df[-grep("rt @",TW_df$message),]



# 16.05.17
# Re-merge the original "messages" of Twitter to the current set
# Using Final_TW_2804.csv

TW_df_2804 <- read.csv("Final_TW_2804.csv", as.is = TRUE, sep = ",")
TW_df_2804 <- TW_df_2804[, which(names(TW_df_2804) %in% c("Text","Id"))]
TW_df_2804$Id <- as.factor(TW_df_2804$Id)
TW_df_2804 <- TW_df_2804[TW_df_2804$Id != 'Id',]

TW_df_2804 <- unique(TW_df_2804)

#Clean the 12.05 prep TW
TW_df <- TW_df[TW_df$Geo.Location.Latitude != 'ibrutinib' & TW_df$Geo.Location.Latitude != 'humira',]
TW_df$Id <- as.factor(TW_df$Id)
TW_df <- unique(TW_df)

TW_df_current <- TW_df[, which(names(TW_df) %in% c("message","Id"))]
TW_df_current <- unique(TW_df_current)

TW_df_final <- dplyr::left_join(TW_df,TW_df_2804, by = "Id")

###############################################################################

# 
# testdf <- read.csv("Final_Manual_0805.csv", as.is = TRUE, sep = ",")
# 
# bkup <- testdf[testdf$key %in% c("enbrel","ankylosing spondylitis","bristol myers"),]
# 
# testdf <- testdf[!testdf$key %in% c("enbrel","ankylosing spondylitis","bristol myers"),]
# 
# # #Update 15.05 for date time parse (again)
# 
# testdf$created_time <- lubridate::parse_date_time(testdf$created_time,c("%m/%d/%y"))
# 
# #delete those "failed to parse"
# testdf <- rbind(testdf, bkup)
# 
# 
# write.csv(testdf,"Final_Manual_1505.csv",
#            quote = TRUE, row.names=FALSE,
#          fileEncoding = "UTF-8", na = "NA")

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
# FB_df$key <- tolower(FB_df$key)
# FB_df$key[FB_df$key == "hepatitisc"] <- "hepatitis c"
# FB_df$key[FB_df$key == "bristol-myers squibb"] <- "bristol myers"


# FB_df$created_time.x <- format.facebook.date(FB_df$created_time.x)
# FB_df$created_time.y <- format.facebook.date(FB_df$created_time.y)

#Write new FB_df with language detection and keywords to lowercase 28.04.17
# write.csv(FB_df, file = "Final_FB_2804.csv",
#           quote = TRUE, row.names=FALSE,
#           fileEncoding = "UTF-8", na = "NA")

##########################################################################

# 03_05
# # Clean  dataset (remove punctuation, links)
# library(tidyr)
# library(tm)
# library(stringr)
# 
# clean <- function (sentence){
#   #convert to lower-case 
#   sentence <- tolower(sentence)
#   removeURL <- function(x) gsub('"(http.*) |(https.*) |(http.*)$|\n', "", x)
#   sentence <- removeURL(sentence)
# }
# t1 <- Sys.time()
# 
# FB_df$message.x <- sapply(FB_df$message.x, function(x) clean(x))
# FB_df$message.y <- sapply(FB_df$message.y, function(x) clean(x))
# 
# print(difftime(Sys.time(), t1, units = 'mins'))
# # Write new FB_df_prep with messages cleaned (remove punctuation and links) 03.05.17
# # write.csv(FB_df, file = "Final_FB_0305_prep.csv",
# #           quote = TRUE, row.names=FALSE,
# #           fileEncoding = "UTF-8", na = "NA")
# 

################################################################################

# #Twitter
# TW_df <- read.csv("Final_TW_2804.csv",sep = ",", as.is = TRUE)
# #delete the first column "X"
# TW_df <- TW_df[,-1]
#change "Label" to fit with FB_df
# 
# for (i in 1:ncol(TW_df)){
#   if (colnames(TW_df)[i]=="Text"){colnames(TW_df)[i] <- "message"}
#   else if(colnames(TW_df)[i] == "Created.At"){colnames(TW_df)[i] <- "created_time"}
#   
#   if (colnames(TW_df)[i] == "key"){
#     key<-TW_df[,i]
#     TW_df<-TW_df[,!(names(TW_df) %in% c("key"))]}
# }
# TW_df<-cbind(key,TW_df)
# TW_df <- TW_df[!(TW_df$message == "" | TW_df$key == 'Label' | TW_df$key == ""|
#                    TW_df$created_time ==""|is.na(TW_df$key) == TRUE),]


######################################
# Preparation for Sentiment Analysis #
######################################
# 
# prep_fun <- tolower
# conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")
# 
# TW_df$message <- conv_fun(prep_fun(TW_df$message))
# 
# backup <- TW_df

# TW_df$created_time<-gsub("/17/2003", "-03-2017", TW_df$created_time)
# 
# #This one mixed up between both d/m/y and m/d/y
# TW_df$created_time <- lubridate::parse_date_time(TW_df$created_time, 
#                                                 c("%m/%d/%y %H:%M",
#                                                   "%d-%m-%y %H:%M",
#                                                   "%y-%m-%d %H:%M:%S"))

# Test Olga's method to check how many were left out
# About 600 tweets missing...
# 
# TW_df1 <- TW_df
# TW_df1<-TW_df1[grep("[0-9]*/[0-9]{2}/2017",TW_df1$created_time),]
# TW_df1$created_time <- as.Date(TW_df1$created_time, format="%m/%d/%Y")
# 
# TW_df2 <- TW_df
# TW_df2<-TW_df2[grep("[0-9]*/[0-9]{2}/2003",TW_df2$created_time),]
# TW_df2$created_time<-gsub("/17/2003", "-03-2017", TW_df2$created_time)
# TW_df2$created_time <- as.Date(TW_df2$created_time, format="%d-%m-%Y")
# 
# TW_df3 <- TW_df
# TW_df3$created_time <- as.Date(TW_df3$created_time, format="%Y-%m-%d")
# 
# test <- rbind(TW_df1,TW_df2,TW_df3)
# test<- test[!(is.na(test$created_time)),]
# 
# TW_df <- test
# differences <- test[!(test$created_time %in% TW_df$created_time),]
# 
# #Add diseases_28_04.csv and delete duplicates
# 
# disease <- read.csv("diseases_28_04.csv",sep = ",", as.is = TRUE)
# 
# created <- disease$created
# key <- disease$label
# disease <- disease[ , -which(names(disease) %in% c("created","Created.At","X.1","X","label"))]
# disease<-cbind(created,disease)
# colnames(disease)[1]<- "created_time"
# colnames(disease)[8] <- "message"
# disease <- cbind(key,disease)
# disease$message <- conv_fun(prep_fun(disease$message))
#   
# #Merge and delete duplicates
# TW_df <- rbind(TW_df, disease)
# TW_df <- unique(TW_df)
# 
# #Filter only ENGLISH tweets
# TW_df <- TW_df[TW_df$Language == 'eng',]
# 
# #Create a Retweet dataset
# require(stringr)
# TW_RT <- subset(TW_df,str_sub(TW_df$message, start = 1, end = 4) == "RT @")
# 
# #Tweets-only dataset
# TW_T <- TW_df[-grep("RT @",TW_df$message),]

 #Write new TW_df with date-time fixed and messages to lowercase + ASCII 29.04.17
 # write.csv(TW_df, file = "Final_TW_0305_prep",
 #           quote = TRUE, row.names=FALSE,
 #            fileEncoding = "UTF-8", na = "NA")
