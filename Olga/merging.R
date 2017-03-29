setwd("~/Desktop/Products3/word")
#Using prevoius file
source(keywords_products.R)
#Create columns
ada<- matrix ("adalimumab",nrow = length(ad[,1]))
ada<- data.frame(label=ada)

enb<- matrix ("enbrel",nrow = length(en[,1]))
enb<- data.frame(label=enb)

hum<- matrix ("humira",nrow = length(hu[,1]))
hum<- data.frame(label=hum)

ibr<- matrix ("ibrutinib",nrow = length(ib[,1]))
ibr<- data.frame(label=ibr)

imb<- matrix ("imbruvica",nrow = length(im[,1]))
imb<- data.frame(label=imb)

#tri<- matrix ("trilipix",nrow = length(tr[,1]))
#tri<- data.frame(label=ada)

#Add them
ada <- cbind(ad,ada)
enb <- cbind(en,enb)
hum <- cbind(hu,hum)
ibr <- cbind(ib,ibr)
imb <- cbind(im,imb)
#tri <- cbind(tr,tri)
setwd("~/Desktop/Products3/word/file")
#write as csv file
write.csv(ada,file="adalimumab.csv")
write.csv(enb,file="enbrel.csv")
write.csv(hum,file="humira.csv")
write.csv(ibr,file="ibrutinib.csv")
write.csv(imb,file="imbruvica.csv")
#write.csv(tri,file="trilipix.csv")

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

#Write the file
write.csv(c,file="products.csv")