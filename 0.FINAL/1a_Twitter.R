#Library to 
library("twitteR")

#Products category

#Setting the Twitter authentication1
consumer_key <- 'yO6HMXQfaAazZfdyOQpPicX0M'
consumer_secret <- 'wT1lq9bd7WWJjoVw3aHKfdHbpdjxd8r8RKc56fGiQPGRaJgILP'
access_token <- '379008223-8gPeX8OJ5wxjILXYUMxKwTSOH30UJbYdUWNqCE53'
access_secret <- 'P3anD6dTrrQb6RUP4Me6HAMpgY8RU9QuORCrGI14f1Wis'
setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)

#Collecting data in english
Adalimumab <- searchTwitter("adalimumab",n=5000, lang='en')
enbrel <- searchTwitter("enbrel",n=5000, lang='en')
humira <- searchTwitter("humira",n=5000, lang='en')
ibrutinib <- searchTwitter("ibrutinib",n=5000, lang='en')
imbruvica <- searchTwitter("imbruvica",n=2000, lang='en')
trilipix <- searchTwitter("trilipix",n=2000, lang='en')

#Collecting data in german
Adalimumab_g <- searchTwitter("adalimumab",n=2000, lang='de')
enbrel_g <- searchTwitter("enbrel",n=2000, lang='de')
humira_g <- searchTwitter("humira",n=2000, lang='de')
ibrutinib_g <- searchTwitter("ibrutinib",n=2000, lang='de')
imbruvica_g <- searchTwitter("imbruvica",n=2000, lang='de')
trilipix_g <- searchTwitter("trilipix",n=2000, lang='de')

#Transfer data to dataframe
ad <-twListToDF(Adalimumab)
en <-twListToDF(enbrel)
hu <-twListToDF(humira)
ib <-twListToDF(ibrutinib)
im <-twListToDF(imbruvica)
tr <-twListToDF(trilipix)

ad_g <-twListToDF(Adalimumab_g)
en_g <-twListToDF(enbrel_g)
hu_g <-twListToDF(humira_g)
ib_g <-twListToDF(ibrutinib_g)
im_g <-twListToDF(imbruvica_g)
tr_g <-twListToDF(trilipix_g)

#Create columns with keyword names
ada<- matrix ("adalimumab",nrow = length(ad[,1]))
ada<- data.frame(key=ada)

enb<- matrix ("enbrel",nrow = length(en[,1]))
enb<- data.frame(key=enb)

hum<- matrix ("humira",nrow = length(hu[,1]))
hum<- data.frame(key=hum)

ibr<- matrix ("ibrutinib",nrow = length(ib[,1]))
ibr<- data.frame(key=ibr)

imb<- matrix ("imbruvica",nrow = length(im[,1]))
imb<- data.frame(key=imb)

tri<- matrix ("trilipix",nrow = length(tr[,1]))
tri<- data.frame(key=tri)

ada_g<- matrix ("adalimumab",nrow = length(ad_g[,1]))
ada_g<- data.frame(key=ada_g)

enb_g<- matrix ("enbrel",nrow = length(en_g[,1]))
enb_g<- data.frame(key=enb_g)

hum_g<- matrix ("humira",nrow = length(hu_g[,1]))
hum_g<- data.frame(key=hum_g)

ibr_g<- matrix ("ibrutinib",nrow = length(ib_g[,1]))
ibr_g<- data.frame(key=ibr_g)

imb_g<- matrix ("imbruvica",nrow = length(im_g[,1]))
imb_g<- data.frame(key=imb_g)

tri_g<- matrix ("trilipix",nrow = length(tr_g[,1]))
tri_g<- data.frame(key=tri_g)

# Merge the keywords names with search results
ada <- cbind(ad,ada)
enb <- cbind(en,enb)
hum <- cbind(hu,hum)
ibr <- cbind(ib,ibr)
imb <- cbind(im,imb)
tri <- cbind(tr,tri)

ada_g <- cbind(ad_g,ada_g)
enb_g <- cbind(en_g,enb_g)
hum_g <- cbind(hu_g,hum_g)
ibr_g <- cbind(ib_g,ibr_g)
imb_g <- cbind(im_g,imb_g)
tri_g <- cbind(tr_g,tri_g)

#Merge of different keywords (english)

prod_e <- rbind(ada,enb)
prod_e <- rbind(prod_e,hum)
prod_e <- rbind(prod_e,ibr)
prod_e <- rbind(prod_e,imb)
prod_e <- rbind(prod_e,tri)


#Add language column english
a<- matrix ("eng",nrow = length(prod_e[,1]))
a<- data.frame(Language=a)
prod_el <- cbind(prod_e,a)

#Merge for german 
prod_g  <- rbind(ada_g,enb_g)
prod_g <- rbind(prod_g ,hum_g)
prod_g  <- rbind(prod_g ,ibr_g)
prod_g  <- rbind(prod_g ,imb_g)
prod_g <- rbind(prod_g ,tri_g)

#Add language column german

b<- matrix ("deu",nrow = length(prod_g[,1]))
b<- data.frame(Language=b)
prod_gl <- cbind(prod_g,b)

#Merge of german and english
prod <- rbind(prod_el,prod_gl)

#Companies

#Setting the Twitter authentication2
api_key="hNgXlxwQYcL71SxCddwvpTEVf"
api_secret="ZSXtL7Yq5QwkAvyCnm9hACaC6CosyHUOOnewv2ufL6IG8tQBCU"
access_token="838380485843763200-pAQXVTl89Dn1Pz2GnQzOacBmJnXPZz6"
access_token_secret="MtqyBbhUxM0zOTJIuRXUWtZMRmVnnjfFT0rs5X4odItdq"
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)


#Collecting data in english
bri <- searchTwitter("bristol myers",n=6000, lang='en')
joh <- searchTwitter("johnson & johnson",n=6000, lang='en')
amg <- searchTwitter("amgen",n=6000, lang='en')
abb <- searchTwitter("abbvie",n=6000, lang='en')

#Collecting data in german
bri_g <- searchTwitter("bristol myers",n=2000, lang='de')
joh_g <- searchTwitter("johnson & johnson",n=2000, lang='de')
amg_g <- searchTwitter("amgen",n=2000, lang='de')
abb_g <- searchTwitter("abbvie",n=2000, lang='de')


#transfer data to datafram
bri <-twListToDF(bri)
joh <-twListToDF(joh)
amg <-twListToDF(amg)
abb <-twListToDF(abb)

bri_g <-twListToDF(bri_g)
joh_g <-twListToDF(joh_g)
amg_g <-twListToDF(amg_g)
abb_g <-twListToDF(abb_g)

#Create columns with keyword names
bris<- matrix ("bristol myers",nrow = length(bri[,1]))
bris<- data.frame(key=bris)

john<- matrix ("johnson & johnson",nrow = length(joh[,1]))
john<- data.frame(key=john)

amge<- matrix ("amgen",nrow = length(amg[,1]))
amge<- data.frame(key=amge)

abbv<- matrix ("abbvie",nrow = length(abb[,1]))
abbv<- data.frame(key=abbv)

bris_g<- matrix ("bristol myers",nrow = length(bri_g[,1]))
bris_g<- data.frame(key=bris_g)

john_g<- matrix ("johnson & johnson",nrow = length(joh_g[,1]))
john_g<- data.frame(key=john_g)

amge_g<- matrix ("amgen",nrow = length(amg_g[,1]))
amge_g<- data.frame(key=amge_g)

abbv_g<- matrix ("abbvie",nrow = length(abb_g[,1]))
abbv_g<- data.frame(key=abbv_g)


# Merge the keywords names with search results
bris <- cbind(bri,bris)
john <- cbind(joh,john)
amge <- cbind(amg,amge)
abbv <- cbind(abb,abbv)

bris_g <- cbind(bri_g,bris_g)
john_g <- cbind(joh_g,john_g)
amge_g <- cbind(amg_g,amge_g)
abbv_g <- cbind(abb_g,abbv_g)

#Merge of different keywords (english)


comp_e <- rbind(bris,john)
comp_e <- rbind(comp_e,amge)
comp_e <- rbind(comp_e,abbv)
#Add language column english
a2<- matrix ("eng",nrow = length(comp_e[,1]))
a2<- data.frame(Language=a2)
comp_el <- cbind(comp_e,a2)

#Merge of different keywords (german)

comp_g <- rbind(bris_g,john_g)
comp_g <- rbind(comp_g,amge_g)
comp_g <- rbind(comp_g,abbv_g)

#Add language column german
b2<- matrix ("deu",nrow = length(comp_g[,1]))
b2<- data.frame(Language=b2)
comp_gl <- cbind(comp_g,b2)

#Merge of german and english
comp <- rbind(comp_el,comp_gl)
#Diseases

#Setting the Twitter authentication3
api_key <- "zow0fQ6Lv0j79gx4lDhBKVUDu"
api_secret = "fp33fr0VBkIIoPzpwgbCPemkZJ1E718TFqb8b86DKd0nVgGFEs"
access_token = "836598863582617600-Tjmc0MqCtcOZVjx9dto5wSBkdRgxDmh"
access_token_secret = "57THIHAlttLUf3y8x1P5U2JnQmcDIfDqq8xmZrwgD5Qo6"
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)

#Collecting data in english
hepc <- searchTwitter("hepatitis c",n=5000, lang='en')
psor <- searchTwitter("psoriasis",n=5000, lang='en')
anky <- searchTwitter("ankylosing spondylitis",n=5000, lang='en')
rheu <- searchTwitter("rheumatoid arthritis",n=5000, lang='en')


#Collecting data in german
hepc_g <- searchTwitter("hepatitis c",n=2000, lang='de')
psor_g <- searchTwitter("psoriasis",n=2000, lang='de')
anky_g <- searchTwitter("ankylosing spondylitis",n=2000, lang='de')
rheu_g <- searchTwitter("rheumatoid arthritis",n=2000, lang='de')


#Transfer data to datafram
hepc <-twListToDF(hepc)
psor <-twListToDF(psor)
anky <-twListToDF(anky)
rheu <-twListToDF(rheu)

hepc_g <-twListToDF(hepc_g)
psor_g <-twListToDF(psor_g)
anky_g <-twListToDF(anky_g)
rheu_g <-twListToDF(rheu_g)


#Create columns with keyword names
hepct<- matrix ("hepatitis c",nrow = length(hepc[,1]))
hepct<- data.frame(key=hepct)

psori<- matrix ("psoriasis",nrow = length(psor[,1]))
psori<- data.frame(key=psori)

ankyl<- matrix ("ankylosing spondylitis",nrow = length(anky[,1]))
ankyl<- data.frame(key=ankyl)

rheum<- matrix ("rheumatoid arthritis",nrow = length(rheu[,1]))
rheum<- data.frame(key=rheum)

hepct_g<- matrix ("hepatitis c",nrow = length(hepc_g[,1]))
hepct_g<- data.frame(key=hepct_g)

psori_g<- matrix ("psoriasis",nrow = length(psor_g[,1]))
psori_g<- data.frame(key=psori_g)

ankyl_g<- matrix ("ankylosing spondylitis",nrow = length(anky_g[,1]))
ankyl_g<- data.frame(key=ankyl_g)

rheum_g<- matrix ("rheumatoid arthritis",nrow = length(rheu_g[,1]))
rheum_g<- data.frame(key=rheum_g)

# Merge the keywords names with search results
hepct <- cbind(hepc,hepct)
psori <- cbind(psor,psori)
ankyl <- cbind(anky,ankyl)
rheum <- cbind(rheu,rheum)

hepct_g <- cbind(hepc_g,hepct_g)
psori_g <- cbind(psor_g,psori_g)
ankyl_g <- cbind(anky_g,ankyl_g)
rheum_g <- cbind(rheu_g,rheum_g)

#Merge of different keywords (english)

disea_e <- rbind(hepct,psori)
disea_e <- rbind(disea_e,ankyl)
disea_e <- rbind(disea_e,rheum)

#Add language column english
a<- matrix ("eng",nrow = length(disea_e[,1]))
a<- data.frame(Language=a)
disea_el <- cbind(disea_e,a)


#Merge of different keywords (german)

disea_g <- rbind(hepct_g,psori_g)
disea_g <- rbind(disea_g,ankyl_g)
disea_g <- rbind(disea_g,rheum_g)


#Add language column german
b2<- matrix ("deu",nrow = length(disea_g[,1]))
b2<- data.frame(Language=b2)
disea_gl <- cbind(disea_g,b2)
#Merge of german and english
disea <- rbind(disea_el,disea_gl)

#Merge categories final files


merge1 <- rbind(prod,comp)
c <- rbind(merge1,disea)

#Changing the final file look (renaming and deleting columns)
final_new <- c
colnames(final_new)
final_new$X <-NULL
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

#Add From.User.Id, To.User, To.User.Id column
a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(From.User.Id=a)
final_new <- cbind(final_new,a)

a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(To.User=a)
final_new <- cbind(final_new,a)

a<- matrix ("NA",nrow = length(final_new[,1]))
a<- data.frame(To.User.Id=a)
final_new <- cbind(final_new,a)


#Rearrage the order of columns

final_news<- subset(final_new, select=c(13,4,7,15,16,17,14,6,1,12,11,8,5,2,3,9,10))
#Writting a final file
write.csv(final_news, file = "name.csv")

