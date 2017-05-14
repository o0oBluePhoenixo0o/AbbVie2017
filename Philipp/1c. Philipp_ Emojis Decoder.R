options(stringsAsFactors = FALSE)
library(dplyr)
library(stringr)
library(rvest)

library(tm)
library(ggplot2)

# reference website
url <- "http://apps.timwhitlock.info/emoji/tables/unicode"

# get emoticons
emoticons <- url %>%
  read_html() %>%
  html_nodes(xpath='/html/body/div[2]/div/div/table[1]') %>%
  html_table()
emoticons <- data.frame(emoticons[[1]]$Native, emoticons[[1]]$Bytes, 
                        emoticons[[1]]$Description, stringsAsFactors = FALSE)
names(emoticons) <- c("Native", "Bytes", "Description")

# get additional emoticons
addemoticons <- url %>%
  read_html() %>%
  html_nodes(xpath='/html/body/div[2]/div/div/table[6]') %>%
  html_table()
addemoticons <- data.frame(addemoticons[[1]]$Native, addemoticons[[1]]$Bytes, 
                           addemoticons[[1]]$Description, stringsAsFactors = FALSE)
names(addemoticons) <- c("Native", "Bytes", "Description")

# get dingbats
dingbats <- url %>%
  read_html() %>%
  html_nodes(xpath='/html/body/div[2]/div/div/table[2]') %>%
  html_table()
dingbats <- data.frame(dingbats[[1]]$Native, dingbats[[1]]$Bytes, 
                       dingbats[[1]]$Description, stringsAsFactors = FALSE)
names(dingbats) <- c("Native", "Bytes", "Description")

# get transports
transport <- url %>%
  read_html() %>%
  html_nodes(xpath='/html/body/div[2]/div/div/table[3]') %>%
  html_table()
transport <- data.frame(transport[[1]]$Native, transport[[1]]$Bytes, 
                        transport[[1]]$Description, stringsAsFactors = FALSE)
names(transport) <- c("Native", "Bytes", "Description")

# get additional transports
addtransport <- url %>%
  read_html() %>%
  html_nodes(xpath='/html/body/div[2]/div/div/table[7]') %>%
  html_table()
addtransport <- data.frame(addtransport[[1]]$Native, addtransport[[1]]$Bytes, 
                           addtransport[[1]]$Description, stringsAsFactors = FALSE)
names(addtransport) <- c("Native", "Bytes", "Description")

# get enclosed emoticons
enclosed <- url %>%
  read_html() %>%
  html_nodes(xpath='/html/body/div[2]/div/div/table[4]') %>%
  html_table()
enclosed <- data.frame(enclosed[[1]]$Native, enclosed[[1]]$Bytes, 
                       enclosed[[1]]$Description, stringsAsFactors = FALSE)
names(enclosed) <- c("Native", "Bytes", "Description")

# get uncategorized emoticons
uncategorized <- url %>%
  read_html() %>%
  html_nodes(xpath='/html/body/div[2]/div/div/table[5]') %>%
  html_table()
uncategorized <- data.frame(uncategorized[[1]]$Native, uncategorized[[1]]$Bytes, 
                            uncategorized[[1]]$Description, stringsAsFactors = FALSE)
names(uncategorized) <- c("Native", "Bytes", "Description")

# get additional other emoticons
addothers <- url %>%
  read_html() %>%
  html_nodes(xpath='/html/body/div[2]/div/div/table[8]') %>%
  html_table()
addothers <- data.frame(addothers[[1]]$Native, addothers[[1]]$Bytes, 
                        addothers[[1]]$Description, stringsAsFactors = FALSE)
names(addothers) <- c("Native", "Bytes", "Description")

# combine all dataframes to overall dataframe
alltogether <- bind_rows(list(emoticons, addemoticons, dingbats, transport, 
                              addtransport, enclosed, uncategorized, addothers))

#alltogether$Description <- paste0('| ',tolower(alltogether$Description),' |')
alltogether$Description <- tolower(alltogether$Description)
colnames(alltogether)[3] <- c("description")

rm(addothers)
rm(addemoticons)
rm(addtransport)
rm(dingbats)
rm(enclosed)
rm(emoticons)
rm(uncategorized)
rm(transport)

###

#get emoji list with sentiment
url <- "http://kt.ijs.si/data/Emoji_sentiment_ranking/index.html"

# get emoticons
emojis_raw <- url %>%
  read_html() %>%
  html_table() %>%
  data.frame %>%
  select(-Image.twemoji., -Sentiment.bar.c.i..95..)
names(emojis_raw) <- c("char", "unicode", "occurrences", "position", "negative", "neutral", 
                       "positive", "sentiment_score", "description", "block")
# change numeric unicode to character unicode to be able to match with emDict 
emojis <- emojis_raw %>%
  mutate(unicode = as.u_char(unicode)) %>%
  mutate(description = tolower(description)) 

rm(emojis_raw)
emojis <- emojis[ , -which(names(emojis) %in% c("block","negative","positive","neutral","position",
                                                "occurrences"))]
str(emojis)

#### Merge sentiments to create complete sets with UNICODE and SENTIMENT scores
emoji_final <- inner_join(emojis,alltogether, by = "description")

#Need to capitalize all messages
Testdf <- subset(TW_df,select = c("message","Id"))
Testdf$message <- toupper(Testdf$message)


###################################################################################
## ---- utility functions ----
# this function outputs the emojis found in a string as well as their occurences
count_matches <- function(string, matchto, description, sentiment = NA) {
  vec <- str_count(string, matchto)
  matches <- which(vec != 0)
  descr <- NA
  cnt <- NA
  
  if (length(matches) != 0) {
    descr <- description[matches]
    cnt <- vec[matches]}
  
  df <- data.frame(text = string, description = descr, count = cnt, sentiment = NA)
  
  if (!is.na(sentiment) & length(sentiment[matches]) != 0) {
    df$sentiment <- sentiment[matches]}
  return(df)
}

# this function applies count_matches on a vector o texts and outputs a data.frame
emojis_matching <- function(texts, matchto, description, sentiment = NA) {
  
  texts %>% 
    lapply(count_matches, matchto = matchto, description = description, sentiment = sentiment) %>%
    bind_rows
  
}


# read in emoji dictionary
# input your custom path to file
emDict <- read.csv2("emDict.csv")
colnames(emDict)[1] <- c("description")
emDict$description <- tolower(emDict_raw$description)

# all emojis with more than one unicode codepoint become NA 

matchto <- emDict$r.encoding
description <- emDict$description


#####################################################

emojis_matching <- function(texts, matchto, description, sentiment = NA) {
  
  texts %>% 
    lapply(count_matches, matchto = matchto, description = description, sentiment = sentiment) %>%
    bind_rows
  
}