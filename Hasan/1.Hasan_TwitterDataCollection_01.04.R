#Hasan's Experiment 1
#Twitter Data Collection
setwd("D:/Workspace/R/TP/data")

#Install necessary packages
install.packages("twitteR", dependencies=TRUE)
install.packages("RCurl", dependencies=TRUE)

#Load the packages
library(twitteR)
library(RCurl)

#create an app on dev.twitter.com with phone number
#get the consumer_key, consumer_secret, access_token, access_secret
consumer_key <- 'yO6HMXQfaAazZfdyOQpPicX0M'
consumer_secret <- 'wT1lq9bd7WWJjoVw3aHKfdHbpdjxd8r8RKc56fGiQPGRaJgILP'
access_token <- '379008223-8gPeX8OJ5wxjILXYUMxKwTSOH30UJbYdUWNqCE53'
access_secret <- 'P3anD6dTrrQb6RUP4Me6HAMpgY8RU9QuORCrGI14f1Wis'

#setup access authorization
setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)

#select 1 on prompt after running the previous code and hit enter
1


#try for loop for automation. didn't work, next time

#key <- c("hcv","psoriasis","ankylosing spondylitis","rheumatoid arthritis")
hcv_en <- searchTwitter("hcv", n = 5000, lang="en")
hcv_en.df=twListToDF(hcv_en)
hcv_de <- searchTwitter("hcv", n = 5000, lang="de")
hcv_de.df=twListToDF(hcv_de)
HCV <- merge(hcv_en.df,hcv_de.df)
write.csv(HCV,file="HCV.csv")


pso_en <- searchTwitter("psoriasis", n = 10000, lang="en")
pso_en.df <- twListToDF(pso_en)
pso_de <- searchTwitter("psoriasis", n = 1000, lang="de")
pso_de.df <- twListToDF(pso_de)
PSO <- merge(pso_en.df, pso_de.df)
write.csv(PSO,file="Psoriasis.csv")

ank_en <- searchTwitter("ankylosing spondylitis", n = 3000, lang="en")
ank_en.df <- twListToDF(ank_en)

#no german tweets, so disable
#ank_de <- searchTwitter("ankylosing spondylitis", n = 1000, lang="de")
#ank_de.df <- twListToDF(ank_de)
#ANK <- merge(ank_en.df,ank_de.df)
write.csv(ank_en.df,file="Ankylosing.csv")

rhe_en <- searchTwitter("rheumatoid arthritis", n = 5000, lang="en" )
rhe_en.df <- twListToDF(rhe_en)
rhe_de <- searchTwitter("rheumatoid arthritis", n = 5000, lang="de" )
rhe_de.df <- twListToDF(rhe_de)
RHE <- merge(rhe_en.df,rhe_de.df)
write.csv(RHE,file="Rheumatoid.csv")

#something wrong, maybe the merge function; dataframe has lots of data but nothing in the csv file ???
#in dataset there is no column for lang attribute..?
#need to find a way to add a column for "Key"
