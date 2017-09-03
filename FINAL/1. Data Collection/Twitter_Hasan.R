#Twitter Data Collection based on disease keywords
#Setting local working directory
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

#merging data files of different disease keywords
# path to folder that holds multiple .csv files
folder1 <- "D:/Uni mannheim/Study/TeamProject_ABBVIE/5. Data/Preprocessed/1. Twitter/Diseasesdata/"      
# create list of all .csv files in folder
file_list1 <- list.files(path=folder1, pattern="*.csv") 

# read in each .csv file in file_list and rbind them into a data frame called data 
data <- 
  do.call("rbind", 
          lapply(file_list1, 
                 function(x) 
                 read.csv(paste(folder1, x, sep=','), 
                 stringsAsFactors = FALSE)))

write.csv(data,"D:/Uni mannheim/Study/TeamProject_ABBVIE/5. Data/Preprocessed/1. Twitter/update_disease_31.3.csv", sep=",", row.names=FALSE, stringsAsFactors=FALSE)

# Appending update with master file
folder2 <- "D:/Uni mannheim/Study/TeamProject_ABBVIE/5. Data/Preprocessed/1. Twitter/"      # path to folder that holds multiple .csv files
file_list2 <- list.files(path=folder2, pattern="*.csv") # create list of all .csv files in folder

fulldata <- 
  do.call("rbind", 
          lapply(file_list2, 
                 function(x) 
                 read.csv(paste(folder2, x, sep=','), 
                 stringsAsFactors = FALSE)))


write.csv(fulldata,"D:/Uni mannheim/Study/TeamProject_ABBVIE/5. Data/Preprocessed/1. Twitter/Twitter_31.03.csv", sep=",", row.names=FALSE, stringsAsFactors=FALSE)


