setwd("~/Desktop/Products3/key0405_update")
c <- data.frame()

#Reed the files
file_list <- list.files() 
list_of_files <- lapply(file_list, read.csv)
#Run bind
for (i in 1:(length(file_list)))
{
  c <- rbind(c,list_of_files[[i]])
}
#write.csv(c,file="key_up_04_05.csv")
#final_new <- read.csv(file="key_up_04_05.csv", header=TRUE, sep=",",stringsAsFactors=FALSE)
final_new <- c
colnames(final_new)
final_new$X <-NULL
#final_new$X.2 <-NULL
final_new$X.1 <-NULL
colnames(final_new)[5]<-'created_time'
colnames(final_new)[1]<-"message"
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
a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(From.User.Id=a)
final_new <- cbind(final_new,a)

a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(To.User=a)
final_new <- cbind(final_new,a)

a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(To.User.Id=a)
final_new <- cbind(final_new,a)



#final_news<- subset(final_new, select=c(4,7,14,15,16,17,6,1,12,11,8,5,13,2,3,9,10))
final_news<- subset(final_new, select=c(13,4,7,15,16,17,14,6,1,12,11,8,5,2,3,9,10))
write.csv(final_news, file = "Final_TW_weekly_0405.csv")