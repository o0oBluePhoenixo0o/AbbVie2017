# This file is for preprocessing the weekly Twitter update on a very basic level

source('./2_Alex_preprocess.R')
library(stringi)
options(scipen=999)
preprocessTWUpdate <- function(newData, oldData) {
  # 1. delete the first column (just a duplicate of the row numbers)
  # 2. change the 'created.at' date to a standard format
  # 3. convert 'from.user' and 'text' to ASCII format
  # 4. lower the case
  # 5. merge with the old dataset
  #
  # Returns:
  #   new merged dataset
  
  # 0.
  newData <- newData[,-1]
  
  # 2.
  newData$created_time <- string2Date(weeklyUpdate$created_time, c("%m/%d/%y %H:%M",
                                                              "%d-%m-%y %H:%M",
                                                              "%y-%m-%d %H:%M:%S",
                                                              "%y-%m-%d",
                                                              "%d-%m-%y"))
  # 3.
  newData$From.User <- convertLatin_ASCII(newData$From.User)
  newData$message <- convertLatin_ASCII(newData$message)
  newData$message <-gsub("<u+2019>", "'", newData$message, fixed = TRUE) # Placeholder, till finding a conversion function converting "SINGLE RIGHT QUOTATION MARK ' "
  
  #4.
  newData$message <- tryTolower(newData$message)
  
  # 5.
  return (rbind(newData, oldData))
}


weeklyUpdate <- read.csv("./weeklyUpdates/Final_TW_weekly_0405.csv",sep = ",", as.is = TRUE)
twitterMaster.df <- read.csv("Final_TW_1005_prep.csv", sep = ",", as.is = TRUE)
write.csv(preprocessTWUpdate(weeklyUpdate, twitterMaster.df), file = paste("./weeklyUpdates/Final_TW_",lubridate::day(Sys.Date()),lubridate::month(Sys.Date()),"_prep",".csv"), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")
newTwitterMaster.df <- read.csv("./weeklyUpdates/Final_TW_105_prep.csv", sep = ",", as.is = TRUE)

