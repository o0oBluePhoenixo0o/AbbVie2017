# This file is for preprocessing the weekly Twitter update on a very basic level

source('./2_Alex_preprocess.R')

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
  
  # 1.
  for (i in 1:ncol(newData)){
    if (colnames(newData)[i]=="Text"){colnames(newData)[i] <- "message"}
    else if(colnames(newData)[i] == "Created.At"){colnames(newData)[i] <- "created_time"}
    
    if (colnames(newData)[i] == "key"){
      key<-newData[,i]
      newData<-newData[,!(names(newData) %in% c("key"))]}
  }
  
  # 2.
  newData$Created.at <- lubridate::parse_date_time(data_tw$Created.At, 
                                                   c("%m/%d/%y %H:%M",
                                                     "%d-%m-%y %H:%M",
                                                     "%y-%m-%d %H:%M:%S"))
  # 3.
  newData$From.User <- convertLatin_ASCII(newData$From.User)
  newData$text <- convertLatin_ASCII(newData$text)
  
  #4.
  newData$text <- tryTolower(newData$text)
  
  # 5.
  return (rbind(newData, oldData))
}


weeklyUpdate <- read.csv("",sep = ",", as.is = TRUE)
twitterMaster.df <- read.csv("Final_TW_0405_prep.csv", sep = ",", as.is = TRUE)
write.csv(preprocessTWUpdate(weeklyUpdate, twitterMaster.df), file = paste("Final_TW_",lubridate::day(Sys.Date()),lubridate::month(Sys.Date()),"_prep",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")



