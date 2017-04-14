# This is the main file to test

source("./1_Alex_crawl_facebook.r")
source("./2_Alex_preprocess.r")
source("./4_Alex_sentiment_analysis.r")
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
twitterMaster.df <- read.csv("Final_TW_0704.csv", sep = ",", as.is = TRUE)

# Format dates on Facebook
facebookMaster.df$created_time.x <- as.Date(facebookMaster.df$created_time.x)
facebookMaster.df$created_time.y <- as.Date(facebookMaster.df$created_time.y)

###################################
# Sentiment Analysis Twitter #
###################################

