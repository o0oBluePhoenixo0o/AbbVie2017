# This file is for preprocessing the weekly Twitter update on a very basic level

source('./2_Alex_preprocess.R')
options(scipen=999)
preprocessTWUpdate <- function(newData, oldData) {
  # 0. delete the first column (just a duplicate of the row numbers)
  # 1. change the 'created.at' date to a standard format
  # 2. change the labels for 'created.at' and message to match with the Facebook data set
  # 3. convert 'from.user' and 'text' to ASCII format
  # 4. lower the case
  # 5. merge with the old dataset
  #
  # Returns:
  #   new merged dataset
  
  # 0.
  newData <- newData[,-1]
  newData[c("truncated")] <- list(NULL)
  
  # 1.
  for (i in 1:ncol(newData)){
    if (colnames(newData)[i]=="Text") {
      colnames(newData)[i] <- "message"
    }
    if (colnames(newData)[i] == "created") {
      colnames(newData)[i] <- "created_time"
    }
    if (colnames(newData)[i] == "statusSource") {
      colnames(newData)[i] <- "Source"
    }
    if (colnames(newData)[i] == "screenName") {
      colnames(newData)[i] <- "From.User"
    }
    if (colnames(newData)[i] == "replyToSn") {
      colnames(newData)[i] <- "To.User"
    }
    if (colnames(newData)[i] == "replyToSID") {
      colnames(newData)[i] <- "To.User.Id"
    }
    if (colnames(newData)[i] == "longitude") {
      colnames(newData)[i] <- "Geo.Location.Longitude"
    }
    if (colnames(newData)[i] == "latitude") {
      colnames(newData)[i] <- "Geo.Location.Latitude"
    }
    if (colnames(newData)[i] == "retweetCount") {
      colnames(newData)[i] <- "Retweet.Count"
    }
    
    if (colnames(newData)[i] == "key"){
      key<-newData[,i]
      newData<-newData[,!(names(newData) %in% c("key"))]
    }
  }
  
  # 2.
  newData$created_time <- string2Date(weeklyUpdate$created, c("%m/%d/%y %H:%M",
                                                              "%d-%m-%y %H:%M",
                                                              "%y-%m-%d %H:%M:%S",
                                                              "%y-%m-%d",
                                                              "%d-%m-%y"))
  # 3.
  newData$From.User <- convertLatin_ASCII(newData$From.User)
  newData$text <- convertLatin_ASCII(newData$text)
  
  #4.
  newData$text <- tryTolower(newData$text)
  
  # 5.
  return (rbind(newData, oldData))
}


weeklyUpdate <- read.csv("key_up_04_05.csv",sep = ",", as.is = TRUE)
twitterMaster.df <- read.csv("Final_TW_0405_prep.csv", sep = ",", as.is = TRUE)
write.csv(preprocessTWUpdate(weeklyUpdate, twitterMaster.df), file = paste("Final_TW_",lubridate::day(Sys.Date()),lubridate::month(Sys.Date()),"_prep",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")


