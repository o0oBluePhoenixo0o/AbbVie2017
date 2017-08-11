####To add language column#####
setwd("~/Desktop/Products3/key0405/en")
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
#Create a column with the english language
a<- matrix ("eng",nrow = length(c[,1]))
a<- data.frame(Language=a)
#Merge it with the rest of the file
c <- cbind(c,a)


setwd("~/Desktop/Products3/key0405/ger")
#Create new "c"
d <- data.frame()

#Reed the files
file_list <- list.files() 
list_of_files <- lapply(file_list, read.csv)
#Run bind
for (i in 1:(length(file_list)))
{
  d <- rbind(d,list_of_files[[i]])
}
#Create a column with the german language
b<- matrix ("deu",nrow = length(d[,1]))
b<- data.frame(Language=b)
#Merge it with the rest of the file
d <- cbind(d,b)
fin <- rbind(c,d)
colnames(fin)[18]<-"key"
setwd("~/Desktop/Products3/key0405/")
write.csv(fin,file="key_up_04_05_products.csv")
