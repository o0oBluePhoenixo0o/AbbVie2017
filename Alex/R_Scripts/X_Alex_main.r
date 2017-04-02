# This is the main file to test

source("./1_Alex_crawl_facebook.r")
source("./2_Alex_preprocess_facebook.r")
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
twitterMaster.df <- read.csv("Twitter_31.03.17.csv", sep = ",", as.is = TRUE)

# Format dates on Facebook
facebookMaster.df$created_time.x <- as.Date(facebookMaster.df$created_time.x)
facebookMaster.df$created_time.y <- as.Date(facebookMaster.df$created_time.y)

# Extracting product posts
posts <- unique(select(facebookMaster.df, 2, 4, 7, 8, 12, 13)) #key, likes_count.x, message.x, created_time.x, comments_count, shares_count
posts.products <- subset(posts, key == "Imbruvica" | key == "Adalimumab" | key == "Trilipix" | key == "Enbrel" | key == "Humira" )

posts.products.preprocessed <- preProcessPosts(posts.products, stemWords = TRUE, removeStopWords = TRUE)

# Sentiment analysis with twitter 
twitterMaster.df <- select(twitterMaster.df, 9) # text
twitterMaster.df <- head(twitterMaster.df, 30)


# sentimentr
sentiment_by(posts.products$message.x) # 0 is negative and 1 is positive

# e1071
twitter.matrix = RTextTools::create_matrix(twitterMaster.df[, 1], language = "english", removeStopwords = FALSE, 
                                        removeNumbers = TRUE, stemWords = FALSE, tm::weightTfIdf) # It seems we can preprocess the data here also ;) 
sentimentTwitter(as.matrix(twitter.matrix ))


