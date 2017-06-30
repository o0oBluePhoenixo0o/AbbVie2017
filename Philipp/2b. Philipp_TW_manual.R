# Extract TW dataset for manually sentiment and sentiments works
# Language == NA --> need to redetect language for Twitters
# Clean text then extract original tweets

setwd("~/GitHub/AbbVie2017/Philipp")

#Twitter
TW_df <- read.csv("Final_TW_1205_prep.csv",sep = ",", as.is = TRUE)
TW_df <- unique(TW_df)
# Clean text

clean <- function (sentence){
  #convert to lower-case 
  sentence <- tolower(sentence)
  removeURL <- function(x) gsub('"(http.*) |(https.*) |(http.*)$|\n', "", x)
  sentence <- removeURL(sentence)
}

TW_df$message <- sapply(TW_df$message, function(x) clean(x))

##########################################
# Building TW dataset for manual sentiment and trend detection

require(stringr)
TW_T <- subset(TW_df,str_sub(TW_df$message, start = 1, end = 4) != "rt @")

TW_T <- subset(TW_T,TW_T$Language == 'eng')

TW_T <- TW_T[ , which(names(TW_T) %in% c("key","created_time","Id","message"))]

TW_T <- TW_T[!duplicated(TW_T[,c('message')]),]

#Redetecting language in TW_0305


# Detect language by adding "language" column next to the dataset
# Only detect languages of Posts since comments languages will be influenced mainly by posts
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

# #24 mins
# t1 <- Sys.time()
# for (i in 1:nrow(TW_df))
# {
#   if (is.na(TW_df$Language[i])==TRUE) 
#   {TW_df$Language[i] <- detectLanguage(TW_df$message[i])}
# }
# print(difftime(Sys.time(), t1, units = 'mins'))
# 
# #change 'eng' to 'en
# TW_df$Language <- sapply(TW_df$Language, function(x) ifelse(x == 'eng','en',x ))
# 
# agg <- dplyr::summarize(dplyr::group_by(TW_df, Language),n())

# #Write new TW_df with language detection (supplement) and cleanned messages
# write.csv(TW_df, file = "Final_TW_0405_prep.csv",
#           quote = TRUE, row.names=FALSE,
#           fileEncoding = "UTF-8", na = "NA")
# 
# TW_df$Language <- sapply(TW_df$Language, function(x) ifelse(x == 'en','eng',x))
# TW_df$Language <- sapply(TW_df$Language, function(x) ifelse(x == 'de','deu',x))
# TW_df$Language <- sapply(TW_df$Language, function(x) ifelse(x %in% c('eng','deu'),x,'eng'))
# 
# #Write new TW_df with language detection (supplement) and cleanned messages
# write.csv(TW_df, file = "Final_TW_1005_prep.csv",
#           quote = TRUE, row.names=FALSE,
#           fileEncoding = "UTF-8", na = "NA")

############################################
# 04.05.17
# sentiment <- NA
# topic <- NA
# TW_T <- cbind(TW_T,sentiment)
# 
# sarcastic <- NA
# context <- NA
# TW_T <- cbind(TW_T,sarcastic, context)
# 
# TW_T <- cbind(TW_T, topic)
# 
# agg1 <- dplyr::summarize(dplyr::group_by(TW_T, key),n())

#Write new TW_T for manual sentiment detection tasks 04.05
# write.csv(TW_T, file = "TW_MANUAL_0405.CSV",
#           quote = TRUE, row.names=FALSE,
#           fileEncoding = "UTF-8", na = "NA")

############################################

# 19.05
# Extract TW for manual label (2nd) from TW update 1205 and 1905

update1205 <- read.csv("1205.csv", as.is = TRUE, sep = ",")
update1905 <- read.csv("1905.csv", as.is = TRUE, sep = ",")

TW_Manual <- rbind(update1205,update1905)

sentiment <- NA
sarcastic <- NA
context <- NA
topic <- NA

TW_Manual <- TW_Manual[, which(names(TW_Manual) %in% c("key","created_time","message","From.User","Id"))]
TW_Manual <- cbind(TW_Manual,sentiment,sarcastic,context,topic)

# Write NEW TW Manual set (non-label) for manual tasks on 19.05
write.csv(TW_Manual, file = "TW_MANUAL_1905.csv",
          quote=TRUE, row.names = FALSE,
          fileEncoding = "UTF-8", na = "NA")

###################################

#25.06 Merge to get new manual 1905

p1 <- read.csv("1.csv", as.is = TRUE, sep = ",")
p2 <- read.csv("2.csv", as.is = TRUE, sep = ",")
p3 <- read.csv("3.csv", as.is = TRUE, sep = ",")
p4 <- read.csv("4.csv", as.is = TRUE, sep = ",")

merge <- rbind(p1,p2,p3,p4)
old <- read.csv("Final_Manual_1505.csv",as.is = TRUE, sep =",")

final <- rbind(merge,old)

final$sentiment <- sapply(final$sentiment, function(x) ifelse(x == '5'|is.na(x),'N',x))



# Write manual label dataset 1905
write.csv(final, file = "Final_Manual_1905.csv",
          quote=TRUE, row.names = FALSE,
          fileEncoding = "UTF-8", na = "NA")

######################################

#30.06 Create new manual TW 

p1 <- read.csv("2605.csv", as.is = TRUE, sep = ",")
p2 <- read.csv("0206.csv", as.is = TRUE, sep = ",")
p3 <- read.csv("0906.csv", as.is = TRUE, sep = ",")
p4 <- read.csv("1606.csv", as.is = TRUE, sep = ",")
p5 <- read.csv("2306.csv", as.is = TRUE, sep = ",")

Manual3006 <- rbind(p1,p2,p3,p4,p5)

#preprocessing
Manual3006$Id <- as.factor(Manual3006$Id)
Manual3006 <- Manual3006[, which(names(Manual3006) %!in% c("X.1","X","X.2"))]
Manual3006$From.User <- conv_fun(Manual3006$From.User)
Manual3006 <- unique(Manual3006)


sentiment <- NA
sarcastic <- NA
context <- NA
topic <- NA

Manual3006 <- Manual3006[, which(names(Manual3006) %in% c("key","created_time","message","From.User","Id"))]
Manual3006 <- cbind(Manual3006,sentiment,sarcastic,context,topic)

#filter duplicated base on message column
Manual3006 <- Manual3006[!duplicated(Manual3006[,c('message')]),]

# Write NEW TW Manual set (non-label) for manual tasks on 30.06
write.csv(Manual3006, file = "TW_MANUAL_3006.csv",
          quote=TRUE, row.names = FALSE,
          fileEncoding = "UTF-8", na = "NA")