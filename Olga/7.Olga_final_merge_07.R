setwd("~/Desktop/Products3/")


final_old <- read.csv(file="Final_TW_3103.csv", header=TRUE, sep=",")
final_new <- read.csv(file="key_up_07_04.csv", header=TRUE, sep=",")


final_new$X <-NULL
final_new$X.2 <-NULL
final_new$X.1 <-NULL
colnames(final_new)[5]<-'Created.At'
colnames(final_new)[1]<-"Text"
colnames(final_new)[10]<-"Source"
final_new$replyToSN <- NULL
final_new$truncated <- NULL
final_new$replyToSID <- NULL
final_new$replyToUID <- NULL
colnames(final_new)[5]<-"Id"
colnames(final_new)[7]<-"From.User"
colnames(final_new)[8]<-"Retweet.Count"
colnames(final_new)[11]<-"Geo.Location.Longitude"
colnames(final_new)[12]<-"Geo.Location.Latitude"
colnames(final_old)[13]<-"key"


a<- matrix ("NA",nrow = length(final_old[,1]))
a<- data.frame(favorited=a)
final_old <- cbind(final_old,a)

a<- matrix ("NA",nrow = length(final_old[,1]))
a<- data.frame(favoriteCount=a)
final_old <- cbind(final_old,a)

a<- matrix ("NA",nrow = length(final_old[,1]))
a<- data.frame(isRetweet=a)
final_old <- cbind(final_old,a)

a<- matrix ("NA",nrow = length(final_old[,1]))
a<- data.frame(retweeted=a)
final_old <- cbind(final_old,a)

a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(From.User.Id=a)
final_new <- cbind(final_new,a)

a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(To.User=a)
final_new <- cbind(final_new,a)

a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(To.User.Id=a)
final_new <- cbind(final_new,a)

a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(Language=a)
final_new <- cbind(final_new,a)

final_news<- subset(final_new, select=c(4,7,14,15,16,17,6,1,12,11,8,5,13,2,3,9,10))

for (i in 1:nrow(final_old)){
  if(final_old[i,]$key == "Abbvie")
  {
    final_old[i,]$key <- "abbvie"
  }
}

for (i in 1:nrow(final_old)){
  if(final_old[i,]$key == "Amgen")
  {
    final_old[i,]$key <- "amgen"
  }
}

for (i in 1:nrow(final_old)){
  if(final_old[i,]$key == "Bristol-Myers")
  {
    final_old[i,]$key <- "bristol myers"
  }
}

for (i in 1:nrow(final_old)){
  if(final_old[i,]$key == "hcv")
  {
    final_old[i,]$key <- "hepatitis c"
  }
}
for (i in 1:nrow(final_old)){
  if(final_old[i,]$key == "Adalimumab")
  {
    final_old[i,]$key <- "adalimumab"
  }
}

for (i in 1:nrow(final_old)){
  if(final_old[i,]$key == "Bristol-myers")
  {
    final_old[i,]$key <- "bristol myers"
  }
}

final <- rbind(final_old,final_news)

#final <- subset(final, !duplicated(Text))
final<-unique(final)

write.csv(final, file = "Final_TW_0704.csv")
