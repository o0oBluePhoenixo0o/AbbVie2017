#install.packages("tm")
#install.packages("stringr")
#install.packages("topicmodels")
#install.packages("tidytext")
#install.packages("tidyr")
#install.packages("wordcloud")

#Tables manipulation
library(dplyr)
library(plyr)
#Text analytics
library(tidyr)
library(topicmodels)
library(tidytext)
require(tm)
require(stringr)
require(wordcloud)
#Visualization
library(ggplot2)

setwd("~/GitHub/AbbVie2017/Philipp")

#Read data from final consolidate dataset
finaldf <- read.csv("Final_FB_2403.csv",sep = ",", as.is = TRUE)

## convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}
finaldf$created_time.x <- format.facebook.date(finaldf$created_time.x)
finaldf$created_time.y <- format.facebook.date(finaldf$created_time.y)

#Get posts & comments from final df
post <- subset(finaldf, select = c(message.x,created_time.x))
comment <- subset(finaldf, select = c(message.y,created_time.y))

#Clean duplicate
post <- unique(post)
comment <- unique(comment)

#Pulling in positive and negative wordlists
pos.words <- scan('Positive.txt', what='character', comment.char=';') #folder with positive dictionary
neg.words <- scan('Negative.txt', what='character', comment.char=';') #folder with negative dictionary
#Adding words to positive and negative databases
pos.words=c(pos.words, 'Congrats', 'prizes', 'prize', 'thanks', 'thnx', 'Grt', 
            'gr8', 'plz', 'trending', 'recovering', 'brainstorm', 'leader')
neg.words = c(neg.words, 'Fight', 'fighting', 'wtf', 'arrest', 'no', 'not')

#evaluation function
score.sentiment <- function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)
  scores <- laply(sentences, function(sentence, pos.words, neg.words){
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence <- gsub('[[:punct:]]', "", sentence)
    sentence <- gsub('[[:cntrl:]]', "", sentence)
    sentence <- gsub('\\d+', "", sentence)
    #convert to lower-case and remove punctuations with numbers
    sentence <- removePunctuation(removeNumbers(tolower(sentence)))
    removeURL <- function(x) gsub('"(http.*) |(http.*)$|\n', "", x)
    sentence <- removeURL(sentence)
    # split into words. str_split is in the stringr package
    word.list <- str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words <- unlist(word.list)
    # compare our words to the dictionaries of positive & negative terms
    pos.matches <- match(words, pos.words)
    neg.matches <- match(words, neg.words)
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches <- !is.na(pos.matches)
    neg.matches <- !is.na(neg.matches)
    score <- sum(pos.matches) - sum(neg.matches)
    return(score)
  }, pos.words, neg.words, .progress=.progress)
  scores.df <- data.frame(score=scores, text=sentences)
  return(scores.df)
}


#Evaluate post and comment datasets
post$message.x <- as.factor(post$message.x)
scores <- score.sentiment(post$message.x, pos.words, neg.words, .progress='text')
stat <- scores
stat$created <- post$created_time.x
stat$created <- as.Date(stat$created)

#add new scores as a column
stat <- mutate(stat, message = ifelse(stat$score > 0, 'positive', 
                                      ifelse(stat$score < 0, 'negative', 'neutral')))

by.message <- group_by(stat, message, created)
by.message <- summarise(by.message, number=n())

#visualization
ggplot(by.message, aes(created, number)) + geom_line(aes(group=message, color=message), size=2) +
  geom_point(aes(group=message, color=message), size=4) +
  theme(text = element_text(size=18), axis.text.x = element_text(angle=90, vjust=1))

#############################################
#########       TEST ZONE       #############
#############################################

#Reading text to corpus
post_corpus <- Corpus(VectorSource(post))
comment_corpus <- Corpus(VectorSource(comment))

# Remove stopwords
post_corpus=tm_map(post_corpus,function(x) removeWords(x,stopwords()))
comment_corpus=tm_map(comment_corpus,function(x) removeWords(x,stopwords()))

# convert corpus to a Plain Text Document
post_corpus=tm_map(post_corpus,PlainTextDocument)
comment_corpus=tm_map(comment_corpus,PlainTextDocument)