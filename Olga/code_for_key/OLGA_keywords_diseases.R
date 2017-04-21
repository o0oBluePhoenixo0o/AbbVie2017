#install the necessary packages
install.packages("twitteR")

library("twitteR")

#set a working directory
setwd("~/Desktop/Products3/")

#to get your consumerKey and consumerSecret see the twitteR documentation for instructions
consumer_key <- 'key'
consumer_secret <- 'secret'
access_token <- 'token'
access_secret <- 'ac_secret'
setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)

#collect data in english
hepc <- searchTwitter("hepatitis c",n=5000, lang='en')
psor <- searchTwitter("psoriasis",n=5000, lang='en')
anky <- searchTwitter("ankylosing spondylitis",n=5000, lang='en')
rheu <- searchTwitter("rheumatoid arthritis",n=5000, lang='en')


#collect data in german
hepc_g <- searchTwitter("hepatitis c",n=2000, lang='de')
psor_g <- searchTwitter("psoriasis",n=2000, lang='de')
anky_g <- searchTwitter("ankylosing spondylitis",n=2000, lang='de')
rheu_g <- searchTwitter("rheumatoid arthritis",n=2000, lang='de')


#transfer data to datafram
hepc <-twListToDF(hepc)
psor <-twListToDF(psor)
anky <-twListToDF(anky)
rheu <-twListToDF(rheu)


#german
hepc_g <-twListToDF(hepc_g)
psor_g <-twListToDF(psor_g)
anky_g <-twListToDF(anky_g)
rheu_g <-twListToDF(rheu_g)


setwd("~/Desktop/Products3/word")
#Using prevoius file
#Create columns
hepct<- matrix ("hepatitis c",nrow = length(hepc[,1]))
hepct<- data.frame(key=hepct)

psori<- matrix ("psoriasis",nrow = length(psor[,1]))
psori<- data.frame(key=psori)

ankyl<- matrix ("ankylosing spondylitis",nrow = length(anky[,1]))
ankyl<- data.frame(key=ankyl)

rheum<- matrix ("rheumatoid arthritis",nrow = length(rheu[,1]))
rheum<- data.frame(key=rheum)



#German
hepct_g<- matrix ("hepatitis c",nrow = length(hepc_g[,1]))
hepct_g<- data.frame(key=hepct_g)

psori_g<- matrix ("psoriasis",nrow = length(psor_g[,1]))
psori_g<- data.frame(key=psori_g)

ankyl_g<- matrix ("ankylosing spondylitis",nrow = length(anky_g[,1]))
ankyl_g<- data.frame(key=ankyl_g)

rheum_g<- matrix ("rheumatoid arthritis",nrow = length(rheu_g[,1]))
rheum_g<- data.frame(key=rheum_g)


#Add them
hepct <- cbind(hepc,hepct)
psori <- cbind(psor,psori)
ankyl <- cbind(anky,ankyl)
rheum <- cbind(rheu,rheum)


#German
hepct_g <- cbind(hepc_g,hepct_g)
psori_g <- cbind(psor_g,psori_g)
ankyl_g <- cbind(anky_g,ankyl_g)
rheum_g <- cbind(rheu_g,rheum_g)


setwd("~/Desktop/Products3/key1404_diseases")

#write as csv file
write.csv(hepct,file="hepatitisc.csv")
write.csv(psori,file="psoriasis.csv")
write.csv(ankyl,file="ankylosing.csv")
write.csv(rheum,file="rheumatoid.csv")



#write as csv file german
write.csv(hepct_g,file="hepatitisc_g.csv")
write.csv(psori_g,file="psoriasis_g.csv")
write.csv(ankyl_g,file="ankylosing_g.csv")
write.csv(rheum_g,file="rheumatoid_g.csv")


#Create new "c"
c <- data.frame()

#Reed the files
file_list <- list.files() 
list_of_files <- lapply(file_list, read.csv)
#Run bind
for (i in 1:(length(file_list)))
{
  c <- rbind(c,list_of_files[[i]])
}
#rename
#colnames(c)[18]<-"key"

#Write the file
write.csv(c,file="diseases_14_04.csv")

