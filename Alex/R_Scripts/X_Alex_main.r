# This is the main file to test

source("./1_Alex_crawl_facebook.r")
source("./2_Alex_preprocess.r")
source("./4_1_Alex_sentiment_analysis_syuzhet.r")
source("./4_2_Alex_sentiment_analysis_naiveBayes.r")
source("./4_3_Alex_sentiment_analysis_sentimentr.r")
source("./4_4_Alex_sentiment_analysis_sentr.r")
source("./translateR.r")

# Set working directory to the directoy where the file is located 
setwd("~/GitHub/AbbVie2017/Alex")


# Crawl the data from facebook

searchFB("Humira")
searchFB("Adalimumab")
searchFB("Enbrel")
searchFB("Trilipix")
searchFB("Imbruvica")

# Merge the data into one big .csv file
mergeCSVsUTF8("./products/Adalimumab.csv","./products/Enbrel.csv","./products/Humira.csv","./products/Imbruvica.csv","./products/Trilipix.csv")


# Read master files
facebookMaster.df <- read.csv("Final_FB_3103.csv", sep = ",", as.is = TRUE)
twitterMaster.df <- read.csv("Final_TW_2104.csv", sep = ",", as.is = TRUE)

# Training tweets

set.seed(2340)
trainIndex <- createDataPartition(tweets.classified$V1, p = 0.00070, 
                                  list = FALSE, 
                                  times = 1)

tweets_train <- tweets.classified[trainIndex, ]
tweets_test <- tweets.classified[-trainIndex, ]

# Take only a small portion to test
testIndex <- createDataPartition(tweets.classified$V1, p = 0.00010, 
                                 list = FALSE, 
                                 times = 1)
tweets_test <- tweets_test[testIndex, ] 




# Format dates on Facebook
facebookMaster.df$created_time.x <- as.Date(facebookMaster.df$created_time.x)
facebookMaster.df$created_time.y <- as.Date(facebookMaster.df$created_time.y)







