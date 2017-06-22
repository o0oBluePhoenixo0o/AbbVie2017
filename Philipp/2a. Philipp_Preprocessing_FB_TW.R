
#Set R to read ID normally
options(scipen=999)

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

###############################################################################
#Twitter
TW_df <- read.csv("Final_TW_1205_prep.csv", sep = ",", as.is = TRUE)
TW_df$Id <- as.factor(TW_df$Id)
TW_df <- unique(TW_df)

# not %in% function
'%!in%' <- function(x,y)!('%in%'(x,y))
##

TW_df <- TW_df[which(TW_df$Id %!in% c('Id',NA)),]
TW_df<- TW_df[which(TW_df$Geo.Location.Latitude %!in% c('ibrutinib','humira')),]


# #Filter only ENGLISH tweets
# TW_df <- TW_df[TW_df$Language == 'eng',]
# 
# #Create a Retweet dataset
# require(stringr)
# TW_RT <- subset(TW_df,str_sub(TW_df$message, start = 1, end = 4) == "rt @")
# 
# #Tweets-only dataset
# TW_T <- TW_df[-grep("rt @",TW_df$message),]

###############################################################
# 18.05.17
# Re-merge the original "messages" of Twitter to the current set
# Using Final_TW_2804.csv

TW_df_2804 <- read.csv("Final_TW_2804.csv", as.is = TRUE, sep = ",")
#cleanning some irrelevant data
TW_df_2804$Id <- as.factor(TW_df_2804$Id)
TW_df_2804 <- unique(TW_df_2804)
TW_df_2804 <- TW_df_2804[which(TW_df_2804$Id %!in% c('Id',NA)),]
TW_df_2804 <- TW_df_2804[which(TW_df_2804$Text %!in% c(NA,'')),]
TW_df_2804<- TW_df_2804[which(TW_df_2804$Geo.Location.Latitude %!in% c('ibrutinib','humira')),]

#TW_df_2804 <- TW_df_2804[, which(names(TW_df_2804) %in% c("Created.At","Text","Id"))]
TW_df_2804$From.User <- conv_fun(TW_df_2804$From.User)
TW_df_2804 <- TW_df_2804[,-1]
colnames(TW_df_2804)[1] <- "created_time"
colnames(TW_df_2804)[8] <- "message"

TW_df_2804 <- unique(TW_df_2804)


# #Clean the 12.05 prep TW
# TW_df$Id <- as.factor(TW_df$Id)
# TW_df <- unique(TW_df)
# 
# TW_df_current <- TW_df[, which(names(TW_df) %in% c("message","Id"))]
# TW_df_current <- unique(TW_df_current)
# 
# TW_df_final <- dplyr::left_join(TW_df,TW_df_2804, by = "Id")

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

# Detect language by adding "language" column next to the dataset
# Only detect languages of Posts since comments languages will be influenced mainly by posts

# install.packages("franc")
library(franc)
detectLanguage <- function(text){
  # Uses 'franc' package to detect the language of a given text
  #
  # Args:
  #   text: The text to detect the language
  #
  # Returns:
  #   A ISO 639-2 encoded language code string

  if (!is.na(text)) {
    return (franc(text, min_length = 3))
  } else {
    message("Can not detect language of NA")
    return (NA)
  }
}

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
clean <- function (sentence){
  #convert to lower-case
  sentence <- tolower(sentence)
  removeURL <- function(x) gsub('"(http.*) |(https.*) |(http.*)$|\n', "", x)
  sentence <- removeURL(sentence)
}
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

#Twitter
#TW_df <- read.csv("Final_TW_2804.csv",sep = ",", as.is = TRUE)
#delete the first column "X"
#  TW_df_2804 <- TW_df_2804[,-1]
# #change "Label" to fit with FB_df
#  
#  for (i in 1:ncol(TW_df_2804)){
#    if (colnames(TW_df_2804)[i]=="Text"){colnames(TW_df_2804)[i] <- "message"}
#    else if(colnames(TW_df_2804)[i] == "Created.At"){colnames(TW_df_2804)[i] <- "created_time"}
#    
#    if (colnames(TW_df_2804)[i] == "key"){
#      key<-TW_df_2804[,i]
#      TW_df_2804<-TW_df_2804[,!(names(TW_df_2804) %in% c("key"))]}
#  }
#  TW_df_2804<-cbind(key,TW_df_2804)
#  TW_df_2804 <- TW_df_2804[!(TW_df_2804$message == "" | TW_df_2804$key == 'Label' | TW_df_2804$key == ""|
#                     TW_df_2804$created_time ==""|is.na(TW_df_2804$key) == TRUE),]


######################################
# Preparation for Sentiment Analysis #
######################################
# 
# prep_fun <- tolower
conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")
# 
# TW_df$message <- conv_fun(prep_fun(TW_df$message))
# 
# backup <- TW_df

#####################################################################################
# 18.05 Modify to reclean the data

backup <- TW_df_2804

#get backup

TW_df_2804 <- backup

#Start parsing time-date

 TW_df_28041 <- TW_df_2804
 TW_df_28041<-TW_df_28041[grep("[0-9]*/[0-9]{2}/2017",TW_df_28041$created_time),]
 TW_df_28041$created_time <- lubridate::parse_date_time(TW_df_28041$created_time, "mdy HM")

 TW_df_28042 <- TW_df_2804
 TW_df_28042<-TW_df_28042[grep("[0-9]*/[0-9]{2}/2003",TW_df_28042$created_time),]
 TW_df_28042$created_time<-gsub("/17/2003", "-03-2017", TW_df_28042$created_time)
 TW_df_28042$created_time <- lubridate::parse_date_time(TW_df_28042$created_time, "dmy HM")

 TW_df_28043 <- TW_df_2804
 tmp <- rbind(TW_df_28041,TW_df_28042)
 TW_df_28043 <- dplyr::anti_join(TW_df_28043,tmp, by = "Id")
 
 
 #### Merge to get final file
 test <- rbind(TW_df_28041,TW_df_28042,TW_df_28043)
 test<- test[!(is.na(test$created_time)),]

 TW_df_2804 <- test
 
 #remove df
 rm(TW_df_28041,TW_df_28042,TW_df_28043,test,tmp)
 
 #######################################################3
 #Add diseases_28_04.csv and delete duplicates

 disease <- read.csv("diseases_28_04.csv",sep = ",", as.is = TRUE)
 disease$Id  <- as.factor(disease$Id)
 
 disease <- disease[which(disease$Id %!in% c('Id',NA)),]
 disease <- disease[which(disease$Text %!in% c(NA,'')),]
 disease <- disease[, which(names(disease) %!in% c("X.1","X","created"))]
 colnames(disease)[1] <- "created_time"
 colnames(disease)[8] <- "message"
 colnames(disease)[13] <- "key"
 disease$From.User <- conv_fun(disease$From.User)
 ###### 
 # Apply same method for "disease" dataset
 disease1 <- disease
 disease1<-disease1[grep("[0-9]*/[0-9]*/2017",disease1$created_time),]
 disease1$created_time <- lubridate::parse_date_time(disease1$created_time, "mdy HM")
 
 disease2 <- disease
 disease2<-disease2[grep("[0-9]*/[0-9]*/2003",disease2$created_time),]
 disease2$created_time<-gsub("/17/2003", "-03-2017", disease2$created_time)
 disease2$created_time <- lubridate::parse_date_time(disease2$created_time, "dmy HM")
 
 disease3 <- disease
 tmp <- rbind(disease1,disease2)
 disease3 <- dplyr::anti_join(disease3,tmp, by = "Id")
 
 #### Merge to get final file
 test <- rbind(disease1,disease2,disease3)
 
 #Merge and delete duplicates
 TW_df_2804 <- rbind(TW_df_2804, test)
 TW_df_2804 <- unique(TW_df_2804)
 TW_df_2804$Id <- as.factor(TW_df_2804$Id)
 #Remove dataset
 rm(disease1,disease2,disease3,tmp,test, disease)
 
 #put column "key" to first
 key  <- TW_df_2804$key
 TW_df_2804 <- TW_df_2804[, which(names(TW_df_2804) %!in% c("key"))]
 TW_df_2804 <- cbind(key,TW_df_2804)
 rm(key)
 #####################################################
 # Add update of first 2 weeks of May 2017
 
 update1 <- read.csv("0405.csv", as.is = TRUE, sep = ",")
 update2 <- read.csv("1205.csv", as.is = TRUE, sep = ",")
 
 #Clean updates
 
 update1$Id <- as.factor(update1$Id)
 update1 <- update1[which(update1$Id %!in% c('Id',NA)),]
 update1 <- update1[which(update1$Text %!in% c(NA,'')),]
 update1 <- update1[, which(names(update1) %!in% c("X.1","X","X.2"))]
 update1$From.User <- conv_fun(update1$From.User)
 colnames(update1)[1] <-"created_time"
 colnames(update1)[8] <- "message"
 update1 <- unique(update1)
 #put column "key" to first
 key  <- update1$key
 update1 <- update1[, which(names(update1) %!in% c("key"))]
 update1 <- cbind(key,update1)
 rm(key)
 
 update2$Id <- as.factor(update2$Id)
 update2 <- update2[which(update2$Id %!in% c('Id',NA)),]
 update2 <- update2[which(update2$message %!in% c(NA,'')),]
 update2 <- update2[, which(names(update2) %!in% c("X.1","X","X.2"))]
 update2$From.User <- conv_fun(update2$From.User)
 colnames(update2)[2] <-"created_time"
 colnames(update2)[9] <- "message"
 update2 <- unique(update2)

 
 TW_fix <- rbind(update1, update2)
 TW_fix <- rbind(TW_df_2804,TW_fix)

 rm(update1,update2,backup)
 
 #update for 19.05 batch
 update3 <- read.csv("1905.csv", as.is = TRUE, sep = ",")
 update3$Id <- as.factor(update3$Id)
 update3 <- update3[, which(names(update3) %!in% c("X.1","X","X.2"))]
 update3$From.User <- conv_fun(update3$From.User)
 
 TW_fix <- rbind(TW_fix, update3)
 rm(update3)
 
 #update for 26.05 batch
 update4 <- read.csv("2605.csv", as.is = TRUE, sep = ",")
 update4$Id <- as.factor(update4$Id)
 update4 <- update4[, which(names(update4) %!in% c("X.1","X","X.2"))]
 update4$From.User <- conv_fun(update4$From.User)
 
 TW_fix <- rbind(TW_fix, update4)
 rm(update4)
 
 # Write CSV for TW_fix on 26.05
 # + CONVERTED From.UserID
 # + RAW text for messages
 # + Parse date time with HOURS
 # + FULL language features
 # + UPDATED with 26.05 TW weekly
 write.csv(TW_fix, file = "Final_TW_2605_prep.csv",
           quote = TRUE, row.names=FALSE,
            fileEncoding = "UTF-8", na = "NA")
 
 ############################################################3
 # update for June (3)
 
 update0206 <- read.csv("0206.csv", as.is = TRUE, sep = ",")
 update0906 <- read.csv("0906.csv", as.is = TRUE, sep = ",")
 update1606 <- read.csv("1606.csv", as.is = TRUE, sep = ",")
 update <- rbind(update0206,update0906,update1606)
 
 update$Id <- as.factor(update$Id)
 update <- update[, which(names(update) %!in% c("X.1","X","X.2"))]
 update$From.User <- conv_fun(update$From.User)
 
 TW_final <- rbind(TW_fix, update)
 
 # Scan language for TW_fix 1806
 
 TW_final$Language <- sapply(TW_final$Language, function(x) ifelse(x == 'en','eng',x))
 TW_final$Language <- sapply(TW_final$Language, function(x) ifelse(x == 'de','deu',x))
 TW_final$Language <- sapply(TW_final$Language, function(x) ifelse(x %in% c('eng','deu'),x,'eng'))
 
 agg <- dplyr::summarize(dplyr::group_by(TW_final, Language),n())
 
 
 write.csv(TW_final, file = "Final_TW_1806_prep.csv",
           quote = TRUE, row.names=FALSE,
           fileEncoding = "UTF-8", na = "NA")
 
 #####
 # 
 # disease$Created.At <- lubridate::parse_date_time(disease$Created.At, "%m/%d/%y HM") 
 # 
 # created <- lubridate::parse_date_time(disease$Created.At, "%m/%d/%y HM") 
 # 
 # key <- disease$label
 # disease <- disease[ , -which(names(disease) %in% c("created","Created.At","X.1","X","label"))]
 # disease<-cbind(created,disease)
 # colnames(disease)[1]<- "created_time"
 # colnames(disease)[8] <- "message"
 # disease <- cbind(key,disease)
 # disease$message <- conv_fun(prep_fun(disease$message))
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
