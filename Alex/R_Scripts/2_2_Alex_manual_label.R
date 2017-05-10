manual_tweets <- read.csv("TW_MANUAL_0405.csv", encoding = "UTF-8", sep = ",")

# ankylosing spondylitis 
manual_tweets.ankylosing <- head(subset(manual_tweets, key == "ankylosing spondylitis"),50)

# bristol myers
manual_tweets.bristol_myers <- head(subset(manual_tweets, key == "bristol myers"),50)

# enbrel
manual_tweets.enbrel <- head(subset(manual_tweets, key == "enbrel"),50)

myWork <- rbind(manual_tweets.ankylosing,manual_tweets.bristol_myers,manual_tweets.enbrel)
write.csv(myWork, file = paste("Alex_TW_Manual",".csv", sep = ""), fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")


manualLabeled <- read.csv("Alex_TW_Manual.csv", encoding = "UTF-8", sep = ",")
manualLabeled <- na.omit(manualLabeled)
