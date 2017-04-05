#install.packages("tm")
#install.packages("stringr")
#install.packages("tidyr")
#install.packages("wordcloud")

#Table manipulation
library(dplyr)
library(plyr)
#Text analytics
library(tidyr)
library(tm)
library(stringr)
#Visualization
library(ggplot2)

#home lap
setwd("~/GitHub/AbbVie2017/Philipp")
#work lap
setwd("~/R")

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

SA.simple <- function(txt,dataset){
  require(plyr)
  #filter original dataframe with key
  temp <- subset(dataset, dataset$key == txt)
  #convert to factor
  temp$message <- as.factor(temp$message)
  #evaluate sentiments
  scores <- score.sentiment(temp$message, pos.words, neg.words, .progress='text')
  stat <- scores
  stat$created <- temp$created_time
  stat$created <- as.Date(stat$created)
  
  #add new scores as a column
  stat <- mutate(stat, message = ifelse(stat$score > 0, 'positive', 
                                        ifelse(stat$score < 0, 'negative', 'neutral')))
  
  by.message <- group_by(stat, message, created)
  
  detach("package:plyr", unload=TRUE) 
  by.message <- summarise(by.message, number=n())
  
  #visualization
  ggplot(by.message, aes(created, number)) + geom_line(aes(group=message, color=message), size=2) +
    geom_point(aes(group=message, color=message), size=4) +
    theme(text = element_text(size=18), axis.text.x = element_text(angle=90, vjust=1)) +
    ggtitle(txt)
  
  #save plot
  ggsave(file=paste(txt, '_plot.jpeg'))
  
}

#Companies
SA.simple("AbbVie",postdf)
SA.simple("Amgen",postdf)
SA.simple("Bristol-Myers Squibb",postdf)

#Products
SA.simple("Humira",postdf)
