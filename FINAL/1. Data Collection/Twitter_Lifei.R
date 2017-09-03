



# Twitter Data Collection ################################################################



# Install the necessary packages
install.packages("twitteR")


library("twitteR")


# Necessary file for Windows
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")


# !!!!
# Get consumerKey and consumerSecret see the twitteR documentation for instructions
# Firstly, "Create New App" here https://apps.twitter.com
consumer_key <- 'Effy_key'
consumer_secret <- 'Effy_secret'
access_token <- 'Effy_token'
access_secret <- 'Effy_secret'
setup_twitter_oauth(consumer_key,
                    consumer_secret,
                    access_token,
                    access_secret)


# Collect data in english
abbvie <- searchTwitter("abbvie", n=20000,lang='en')
amgen <- searchTwitter("amgen",n=20000,lang='en')
bristol <- searchTwitter("bristol-myers",n=20000,lang='en')


# Removal retweets
#strip_retweets(abbvie, strip_manual = TRUE, strip_mt = TRUE)
#strip_retweets(amgen, strip_manual = TRUE, strip_mt = TRUE)
#strip_retweets(bristol, strip_manual = TRUE, strip_mt = TRUE)


# Transfer data to datafram
ab=twListToDF(abbvie)
am=twListToDF(amgen)
br=twListToDF(bristol)


# Label vectors
label_ab <- matrix(rep("abbvie",length(ab[,1])),nrow=length(ab[,1]),byrow=TRUE)
label_am <- matrix(rep("amgen",length(am[,1])),nrow=length(am[,1]),byrow=TRUE)
label_br <- matrix(rep("bristol-myers",length(br[,1])),nrow=length(br[,1]),byrow=TRUE)


# Add name
colnames(label_ab) <- c("label")
colnames(label_am) <- c("label")
colnames(label_br) <- c("label")


# Add label
comabbvie <- cbind(ab,label_ab)
comamgen <- cbind(am,label_am)
combristol <- cbind(br,label_br)


# Merge all
companies_two <- rbind(comabbvie,comamgen)
companies_three <- rbind(companies_two,combristol)


# Write as csv file
write.csv(companies_three,file="companies_three.csv")



