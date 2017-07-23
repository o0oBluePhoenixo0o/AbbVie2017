tweets.classified.java <- tweets.classified
tweets.classified.java$date <- NULL
tweets.classified.java$query <- NULL
tweets.classified.java$user <- NULL
tweets.classified.java <- tweets.classified.java[c("id", "sentiment", "text")]
tweets.classified.java$sentiment <- ifelse(tweets.classified.java$sentiment == "0", "negative", "positive")
head(tweets.classified.java)


write.csv(tweets.classified.java, file = paste("tweets_sentiment_training",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")


options(scipen=999)
library(readr)
library(compare)
latest_manual <- read.csv('./Final_Manual_3006_label.csv', sep = ",")
drive_manual <- read_csv('./Final_Manual_3006_drive.csv')

a1NotIna2 <- sqldf('SELECT Id FROM drive_manual EXCEPT SELECT Id FROM latest_manual')

drive_manual <- drive_manual[!(drive_manual$Id %in% c(865142871841795968, 866988610595061760, 867399563065180160, 868009650284892160,868038909191528448, 868093110546567040, 868093860773319040,871711529216777984)), ]
write.csv(drive_manual, file = paste("Final_Manual_3006_label",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")


latest_manual <- latest_manual[c("Id", "sentiment", "message")]
latest_manual$message <- sub("\n", "", latest_manual$message , fixed = TRUE)
latest_manual$message <- sub("\r", "", latest_manual$message , fixed = TRUE)
latest_manual$sentiment <- ifelse(latest_manual$sentiment == "N", "neutral", ifelse(latest_manual$sentiment=="1"|latest_manual$sentiment==2, "negative", "positive"))
write.table(latest_manual, file = paste("Final_TW_3006_prep_java",".csv", sep = ""), eol = "\r", fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ";")

write.table(drive_manual, file = paste("Final_Manual_3006_label.csv",".csv", sep = ""), eol = "\r", fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")


