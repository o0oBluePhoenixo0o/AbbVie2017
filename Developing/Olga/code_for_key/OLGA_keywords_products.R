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
Adalimumab <- searchTwitter("adalimumab",n=5000, lang='en')
enbrel <- searchTwitter("enbrel",n=5000, lang='en')
humira <- searchTwitter("humira",n=5000, lang='en')
ibrutinib <- searchTwitter("ibrutinib",n=5000, lang='en')
imbruvica <- searchTwitter("imbruvica",n=2000, lang='en')
trilipix <- searchTwitter("trilipix",n=2000, lang='en')




#collect data in german
Adalimumab_g <- searchTwitter("adalimumab",n=2000, lang='de')
enbrel_g <- searchTwitter("enbrel",n=2000, lang='de')
humira_g <- searchTwitter("humira",n=2000, lang='de')
ibrutinib_g <- searchTwitter("ibrutinib",n=2000, lang='de')
imbruvica_g <- searchTwitter("imbruvica",n=2000, lang='de')
trilipix_g <- searchTwitter("trilipix",n=2000, lang='de')

#transfer data to datafram
ad <-twListToDF(Adalimumab)
en <-twListToDF(enbrel)
hu <-twListToDF(humira)
ib <-twListToDF(ibrutinib)
im <-twListToDF(imbruvica)
tr <-twListToDF(trilipix)

#german
ad_g <-twListToDF(Adalimumab_g)
en_g <-twListToDF(enbrel_g)
hu_g <-twListToDF(humira_g)
ib_g <-twListToDF(ibrutinib_g)
im_g <-twListToDF(imbruvica_g)
tr_g <-twListToDF(trilipix_g)

setwd("~/Desktop/Products3/key_1404_products")
#Using prevoius file
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

tri<- matrix ("trilipix",nrow = length(tr[,1]))
tri<- data.frame(label=tri)

#German
ada_g<- matrix ("adalimumab",nrow = length(ad_g[,1]))
ada_g<- data.frame(label=ada_g)

enb_g<- matrix ("enbrel",nrow = length(en_g[,1]))
enb_g<- data.frame(label=enb_g)

hum_g<- matrix ("humira",nrow = length(hu_g[,1]))
hum_g<- data.frame(label=hum_g)

ibr_g<- matrix ("ibrutinib",nrow = length(ib_g[,1]))
ibr_g<- data.frame(label=ibr_g)

imb_g<- matrix ("imbruvica",nrow = length(im_g[,1]))
imb_g<- data.frame(label=imb_g)

tri_g<- matrix ("trilipix",nrow = length(tr_g[,1]))
tri_g<- data.frame(label=tri_g)

#Add them
ada <- cbind(ad,ada)
enb <- cbind(en,enb)
hum <- cbind(hu,hum)
ibr <- cbind(ib,ibr)
imb <- cbind(im,imb)
tri <- cbind(tr,tri)

#German
ada_g <- cbind(ad_g,ada_g)
enb_g <- cbind(en_g,enb_g)
hum_g <- cbind(hu_g,hum_g)
ibr_g <- cbind(ib_g,ibr_g)
imb_g <- cbind(im_g,imb_g)
tri_g <- cbind(tr_g,tri_g)

setwd("~/Desktop/Products3/key0704")

#write as csv file
write.csv(ada,file="adalimumab.csv")
write.csv(enb,file="enbrel.csv")
write.csv(hum,file="humira.csv")
write.csv(ibr,file="ibrutinib.csv")
write.csv(imb,file="imbruvica.csv")
write.csv(tri,file="trilipix.csv")


#write as csv file german
write.csv(ada_g,file="adalimumab_g.csv")
write.csv(enb_g,file="enbrel_g.csv")
write.csv(hum_g,file="humira_g.csv")
write.csv(ibr_g,file="ibrutinib_g.csv")
write.csv(imb_g,file="imbruvica_g.csv")
write.csv(tri_g,file="trilipix_g.csv")

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
colnames(c)[18]<-"key"

#Write the file
write.csv(c,file="products_14_04.csv")

