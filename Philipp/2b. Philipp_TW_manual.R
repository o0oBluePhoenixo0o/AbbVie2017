# Extract TW dataset for manually sentiment and sentiments works
# Language == NA --> need to redetect language for Twitters
# Clean text then extract original tweets


#Twitter
TW_df <- read.csv("Final_TW_0305_prep.csv",sep = ",", as.is = TRUE)

require(stringr)
TW_T <- subset(TW_df,str_sub(TW_df$message, start = 1, end = 4) != "rt @")

TW_T <- subset(TW_T,TW_T$Language == 'en')

TW_T <- TW_T[ , which(names(TW_T) %in% c("key","created_time","Id","message"))]

for (i in 1:nrow(TW_T))
{
  TW_T$Id[i] <- i
}

ID <- TW_T$Id
Created <- TW_T$created_time
key <- TW_T$key

library(tidyr)
library(tm)
library(stringr)

clean <- function (sentence){
  sentence <- gsub('[[:punct:]]', "", sentence)
  sentence <- gsub('[[:cntrl:]]', "", sentence)
  sentence <- gsub('\\d+', "", sentence)
  #convert to lower-case and remove punctuations with numbers
  sentence <- removePunctuation(removeNumbers(tolower(sentence)))
  removeURL <- function(x) gsub('"(http.*) |(http.*)$|\n', "", x)
  sentence <- removeURL(sentence)
}

for (i in 1:nrow(TW_T))
{
  TW_T$message[i]<-clean(TW_T$message[i])
}

TW_T <- unique(TW_T)
############################################

sentiment <- NA
topic <- NA
TW_T <- cbind(TW_T,sentiment)

sarcastic <- NA
context <- NA
TW_T <- cbind(TW_T,sarcastic, context)

TW_T <- cbind(TW_T, topic)

TW_T[TW_T$Id %in% c(21:23),"message"]

