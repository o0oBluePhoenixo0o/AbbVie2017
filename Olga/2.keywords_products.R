#install the necessary packages
install.packages("twitteR")

library("twitteR")

#set a working directory
setwd("~/Desktop/Products3")

#to get your consumerKey and consumerSecret see the twitteR documentation for instructions
api_key <- 'key'
api_secret = "secret"
access_token = "token"
access_token_secret = "token_secret"
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)

#collect data in english
Adalimumab <- searchTwitter("Adalimumab",lang='en')
enbrel <- searchTwitter("enbrel",lang='en')
humira <- searchTwitter("humira",lang='en')
ibrutinib <- searchTwitter("ibrutinib",lang='en')
imbruvica <- searchTwitter("imbruvica",lang='en')
#trilipix <- searchTwitter("trilipix",lang='en')

#collect data in german
Adalimumab_g <- searchTwitter("Adalimumab",lang='de')
enbrel_g <- searchTwitter("enbrel",lang='de')
humira_g <- searchTwitter("humira",lang='de')

#removal retweets
Adalimumab<-strip_retweets(Adalimumab, strip_manual = TRUE, strip_mt = TRUE)
enbrel<- strip_retweets(enbrel, strip_manual = TRUE, strip_mt = TRUE)
humira<- strip_retweets(humira, strip_manual = TRUE, strip_mt = TRUE)
ibrutinib<- strip_retweets(ibrutinib, strip_manual = TRUE, strip_mt = TRUE)
imbruvica<- strip_retweets(imbruvica , strip_manual = TRUE, strip_mt = TRUE)
#trilipix<- strip_retweets(trilipix, strip_manual = TRUE, strip_mt = TRUE)

#removal retweets (german)

Adalimumab_g <- strip_retweets(Adalimumab_g, strip_manual = TRUE, strip_mt = TRUE)
enbrel_g <- strip_retweets(enbrel_g, strip_manual = TRUE, strip_mt = TRUE)
humira_g <- strip_retweets(humira_g, strip_manual = TRUE, strip_mt = TRUE)

#transfer data to datafram
ad <-twListToDF(Adalimumab)
en <-twListToDF(enbrel)
hu <-twListToDF(humira)
ib <-twListToDF(ibrutinib)
im <-twListToDF(imbruvica)
#tr <-twListToDF(trilipix)


