library(data.table)

manual_tweets <- read.csv("TW_MANUAL_1905.csv", encoding = "UTF-8", sep = ",")

# ankylosing spondylitis 
manual_tweets.ankylosing <- data.table(subset(manual_tweets, key == "ankylosing spondylitis"))[sample(.N, 75)]

# bristol myers
manual_tweets.bristol_myers <- data.table(subset(manual_tweets, key == "bristol myers"))[sample(.N, 75)]

# enbrel
manual_tweets.enbrel <- data.table(subset(manual_tweets, key == "enbrel"))[sample(.N, 75)]

#humira
manual_tweets.humira <- data.table(subset(manual_tweets, key == "humira"))[sample(.N, 75)]

#abbvie
manual_tweets.abbvie<- data.table(subset(manual_tweets, key == "abbvie"))[sample(.N, 75)]

myWork <- rbind(manual_tweets.ankylosing,manual_tweets.bristol_myers,manual_tweets.enbrel, manual_tweets.humira, manual_tweets.abbvie)
write.csv(myWork, file = paste("Alex_TW_Manual",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")


manualLabeled <- read.csv("Alex_TW_Manual.csv", encoding = "UTF-8", sep = ",")
manualLabeled <- na.omit(manualLabeled)
