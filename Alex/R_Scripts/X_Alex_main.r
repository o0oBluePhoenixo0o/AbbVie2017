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


# syuzhet's method
twitterMaster.df$Text <- lapply(twitterMaster.df$Text, convert)
twitterMaster.df$Text <- lapply(twitterMaster.df$Text, removeURL)
twitterMaster.df$Text <- lapply(twitterMaster.df$Text, removeTags)
twitterMaster.df$Sentiment_syuzhet <- lapply(twitterMaster.df$Text, syuzhet::get_sentiment)

# sentimentr method
print(lapply(twitterMaster.df$Text, sentimentr::sentiment_by))

# e1071
twitter.matrix = RTextTools::create_matrix(twitterMaster.df[, 9], language = "english", removeStopwords = FALSE, 
                                           removeNumbers = TRUE, stemWords = FALSE, tm::weightTfIdf)

twitterMaster.df$Sentiment_e1071 <- sentimentE1071(as.matrix(twitter.matrix))












# Extracting product posts
posts <- unique(select(facebookMaster.df, 2, 4, 7, 8, 12, 13)) #key, likes_count.x, message.x, created_time.x, comments_count, shares_count
posts.products <- subset(posts, key == "Imbruvica" | key == "Adalimumab" | key == "Trilipix" | key == "Enbrel" | key == "Humira" )

posts.products.preprocessed <- preProcessPosts(posts.products, stemWords = FALSE, removeStopWords = TRUE, translate = TRUE)

# Sentiment analysis with twitter 
twitterMaster.df.test <- select(twitterMaster.df,3, 9) # created.at, text
#twitterMaster.df <- head(twitterMaster.df, 30)




# sentimentr
sentiment_by(posts.products$message.x) # 0 is negative and 1 is positive

# e1071
twitter.matrix = RTextTools::create_matrix(twitterMaster.df[, 1], language = "english", removeStopwords = FALSE, 
                                        removeNumbers = TRUE, stemWords = FALSE, tm::weightTfIdf) # It seems we can preprocess the data here also ;) 

sentimentTwitter(as.matrix(twitter.matrix ))


