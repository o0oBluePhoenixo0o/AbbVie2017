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
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)

#collect data in english
bri <- searchTwitter("bristol myers",n=6000, lang='en')
joh <- searchTwitter("johnson & johnson",n=6000, lang='en')
amg <- searchTwitter("amgen",n=6000, lang='en')
abb <- searchTwitter("abbvie",n=6000, lang='en')


#collect data in german
bri_g <- searchTwitter("bristol myers",n=2000, lang='de')
joh_g <- searchTwitter("johnson & johnson",n=2000, lang='de')
amg_g <- searchTwitter("amgen",n=2000, lang='de')
abb_g <- searchTwitter("abbvie",n=2000, lang='de')


#transfer data to datafram
bri <-twListToDF(bri)
joh <-twListToDF(joh)
amg <-twListToDF(amg)
abb <-twListToDF(abb)


#german
bri_g <-twListToDF(bri_g)
joh_g <-twListToDF(joh_g)
amg_g <-twListToDF(amg_g)
abb_g <-twListToDF(abb_g)


#Using prevoius file
#Create columns
bris<- matrix ("bristol myers",nrow = length(bri[,1]))
bris<- data.frame(key=bris)

john<- matrix ("johnson & johnson",nrow = length(joh[,1]))
john<- data.frame(key=john)

amge<- matrix ("amgen",nrow = length(amg[,1]))
amge<- data.frame(key=amge)

abbv<- matrix ("abbvie",nrow = length(abb[,1]))
abbv<- data.frame(key=abbv)



#German
bris_g<- matrix ("bristol myers",nrow = length(bri_g[,1]))
bris_g<- data.frame(key=bris_g)

john_g<- matrix ("johnson & johnson",nrow = length(joh_g[,1]))
john_g<- data.frame(key=john_g)

amge_g<- matrix ("amgen",nrow = length(amg_g[,1]))
amge_g<- data.frame(key=amge_g)

abbv_g<- matrix ("abbvie",nrow = length(abb_g[,1]))
abbv_g<- data.frame(key=abbv_g)


#Add them
bris <- cbind(bri,bris)
john <- cbind(joh,john)
amge <- cbind(amg,amge)
abbv <- cbind(abb,abbv)


#German
bris_g <- cbind(bri_g,bris_g)
john_g <- cbind(joh_g,john_g)
amge_g <- cbind(amg_g,amge_g)
abbv_g <- cbind(abb_g,abbv_g)


setwd("~/Desktop/Products3/key1404_company")

#write as csv file
write.csv(bris,file="bristol.csv")
write.csv(john,file="johnson.csv")
write.csv(amge,file="amgen.csv")
write.csv(abbv,file="abbvie.csv")



#write as csv file german
write.csv(bris_g,file="bristol_g.csv")
write.csv(john_g,file="johnson_g.csv")
write.csv(amge_g,file="amgen_g.csv")
write.csv(abbv_g,file="abbvie_g.csv")


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
write.csv(c,file="company14_04.csv")

