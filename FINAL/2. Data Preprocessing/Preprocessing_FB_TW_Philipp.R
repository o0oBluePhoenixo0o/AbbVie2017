#####
#
# The purpose of this file is to assemble the files of Twitter and FaceBook
# - Merge weekly Twitter update to the main consolidated dataset
# - Converted columns to factor type (UserID and IDs of tweets)
# - Detect languages of the datase
# - Parse date-time to fit the universal types
#
####

# not %in% function
'%!in%' <- function(x,y)!('%in%'(x,y))
##

conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")

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

TW_df_2804$From.User <- conv_fun(TW_df_2804$From.User)
TW_df_2804 <- TW_df_2804[,-1]
colnames(TW_df_2804)[1] <- "created_time"
colnames(TW_df_2804)[8] <- "message"

TW_df_2804 <- unique(TW_df_2804)

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

a<- unique(FB_df[,c("id.x","message.x")])
x <- NA
a <- cbind(a, x)

for (i in 1:nrow(a)){
  if (is.na(a$message.x[i])== FALSE){
    a$x[i] <- conv_fun(a$message.x[i])
  }
}

language.x <- NA

a <- cbind(a,language.x)

#This will take sometimes ~30min with 55k posts
t1 <- Sys.time()
t1
for (i in 1:nrow(a)){
  if (is.na(a$x[i]) == FALSE){
    a$language.x[i] <- detectLanguage(a$x[i])}
}
print(difftime(Sys.time(), t1, units = 'mins'))

#list of language + counts
agg <- dplyr::summarize(dplyr::group_by(a,language.x),n())

FB_df <- dplyr::right_join(a[,c("id.x","language.x")],FB_df, by = "id.x")

#############################################################


# 03_05 
clean <- function (sentence){
  #convert to lower-case
  sentence <- tolower(sentence)
  removeURL <- function(x) gsub('"(http.*) |(https.*) |(http.*)$|\n', "", x)
  sentence <- removeURL(sentence)
}

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
 
 #######################################
 # update June 30
 
 update3006 <- read.csv("2306.csv", as.is = TRUE, sep = ",")
 update3006$Id <- as.factor(update3006$Id)
 update3006 <- update3006[, which(names(update3006) %!in% c("X.1","X","X.2"))]
 update3006$From.User <- conv_fun(update3006$From.User)
 
 TW_df <- read.csv("Final_TW_1806_prep.csv", as.is = TRUE, sep =",")
 
 TW_final <- rbind(TW_df,update3006)
 TW_final <- unique(TW_final)
 
 #filter duplicated base on message column
 TW_final <- TW_final[!duplicated(TW_final[,c('message')]),]
 
 write.csv(TW_final, file = "Final_TW_3006_prep.csv",
           quote = TRUE, row.names=FALSE,
           fileEncoding = "UTF-8", na = "NA")
 
 #update 08.07
 TW_df <- read.csv("Final_TW_3006_prep.csv", as.is = TRUE, sep =",")
 
 update0707 <- read.csv("0707.csv", as.is=TRUE, sep = ",")
 update0707$Id <- as.factor(update0707$Id)
 update0707 <- update0707[, which(names(update0707) %!in% c("X.1","X","X.2"))]
 update0707$From.User <- conv_fun(update0707$From.User)
 
 
 TW_final <- rbind(TW_df,update0707)
 TW_final <- unique(TW_final)
 
 #filter duplicated base on message column
 TW_final <- TW_final[!duplicated(TW_final[,c('message')]),]
 
 write.csv(TW_final, file = "Final_TW_0807_prep.csv",
           quote = TRUE, row.names=FALSE,
           fileEncoding = "UTF-8", na = "NA")

 #update 1507
 
 TW_df <- read.csv("Final_TW_0807_prep.csv", as.is = TRUE, sep =",")
 
 update1507 <- read.csv("1407.csv", as.is=TRUE, sep = ",")
 update1507$Id <- as.factor(update1507$Id)
 update1507 <- update1507[, which(names(update1507) %!in% c("X.1","X","X.2"))]
 update1507$From.User <- conv_fun(update1507$From.User)
 
 
 TW_final <- rbind(TW_df,update1507)
 TW_final <- unique(TW_final)
 
 #filter duplicated base on message column
 TW_final <- TW_final[!duplicated(TW_final[,c('message')]),]
 
 write.csv(TW_final, file = "Final_TW_1507_prep.csv",
           quote = TRUE, row.names=FALSE,
           fileEncoding = "UTF-8", na = "NA")