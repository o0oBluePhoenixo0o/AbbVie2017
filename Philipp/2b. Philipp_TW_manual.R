# Extract TW dataset for manually sentiment and sentiments works
# Language == NA --> need to redetect language for Twitters
# Clean text then extract original tweets


#Twitter
TW_df <- read.csv("Final_TW_0305_prep.csv",sep = ",", as.is = TRUE)

# Clean text

clean <- function (sentence){
  #convert to lower-case 
  sentence <- tolower(sentence)
  removeURL <- function(x) gsub('"(http.*) |(https.*) |(http.*)$|\n', "", x)
  sentence <- removeURL(sentence)
}

TW_df$message <- sapply(TW_df$message, function(x) clean(x))

#Redetecting language in TW_0305


# Detect language by adding "language" column next to the dataset
# Only detect languages of Posts since comments languages will be influenced mainly by posts

# install.packages("franc")
library(franc)
detectLanguage <- function(text){
  # Uses 'franc' package to detect the language of a given text
  #
  # Args:
  #   text: The text to detect the language
  #
  # Returns:
  #   A ISO 639-2 encoded language code string

  if (!is.na(text)) {
    return (franc(text, min_length = 3))
  } else {
    message("Can not detect language of NA")
    return (NA)
  }
}

#24 mins
t1 <- Sys.time()
for (i in 1:nrow(TW_df))
{
  if (is.na(TW_df$Language[i])==TRUE) 
  {TW_df$Language[i] <- detectLanguage(TW_df$message[i])}
}
print(difftime(Sys.time(), t1, units = 'mins'))

#change 'eng' to 'en
TW_df$Language <- sapply(TW_df$Language, function(x) ifelse(x == 'eng','en',x ))

agg <- dplyr::summarize(dplyr::group_by(TW_df, Language),n())

#Write new TW_df with language detection (supplement) and cleanned messages
write.csv(TW_df, file = "Final_TW_0405_prep.csv",
          quote = TRUE, row.names=FALSE,
          fileEncoding = "UTF-8", na = "NA")

##########################################
# Building TW dataset for manual sentiment and trend detection

require(stringr)
TW_T <- subset(TW_df,str_sub(TW_df$message, start = 1, end = 4) != "rt @")

TW_T <- subset(TW_T,TW_T$Language == 'en'|TW_T$Language == 'sco')

TW_T <- TW_T[ , which(names(TW_T) %in% c("key","created_time","Id","message"))]

for (i in 1:nrow(TW_T))
{
  TW_T$Id[i] <- i
}

TW_T <- TW_T[!duplicated(TW_T[,c('message')]),]
############################################

sentiment <- NA
topic <- NA
TW_T <- cbind(TW_T,sentiment)

sarcastic <- NA
context <- NA
TW_T <- cbind(TW_T,sarcastic, context)

TW_T <- cbind(TW_T, topic)

agg1 <- dplyr::summarize(dplyr::group_by(TW_T, key),n())

#Write new TW_T for manual sentiment detection tasks 04.05
write.csv(TW_T, file = "TW_MANUAL_0405.CSV",
          quote = TRUE, row.names=FALSE,
          fileEncoding = "UTF-8", na = "NA")
