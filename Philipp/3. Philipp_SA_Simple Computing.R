# 
# install.packages("dplyr")
# install.packages("plyr")
# install.packages("tidyr")
# install.packages("tm")
# install.packages("stringr")
# install.packages("ggplot2")

#Text analytics
library(tidyr)
library(tm)
library(stringr)
#Visualization
library(ggplot2)

setwd("~/GitHub/AbbVie2017/Philipp")

#Pulling in positive and negative wordlists
#BingLiu
pos.words <- scan('Models/Positive.txt', what='character', comment.char=';') #folder with positive dictionary
neg.words <- scan('Models/Negative.txt', what='character', comment.char=';') #folder with negative dictionary
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

SA.simple <- function(txt,dataset,folder){
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
  
  by.message <- dplyr::group_by(stat, message, created)
  
  by.message <- dplyr::summarise(by.message, number=n())
  
  #visualization
  ggplot(by.message, aes(created, number)) + geom_line(aes(group=message, color=message), size=2) +
    geom_point(aes(group=message, color=message), size=4) +
    theme(text = element_text(size=18), axis.text.x = element_text(angle=90, vjust=1)) +
    ggtitle(txt)
  
  #save plot
  ggsave(file= paste0('SA_Simple/',folder,'/',txt,'_plot.jpeg'))
  
  #Extract examples for top negative and positive observations
  top_pos <- head(plyr::arrange(subset(stat,select = c(text,score)),desc(score)),n = 20)
  top_neg <-  head(plyr::arrange(subset(stat,select = c(text,score)),score),n = 20)
  examples <-rbind('Positive',top_pos,'Negative',top_neg)
  
  
  #Write down examples to a csv file
  write.csv2(examples,file = paste0('SA_Simple/',folder,'/',txt,'_examples.csv'))
}

#######################################################
keywords <- c("abbvie","bristol myers", "johnson & johnson","amgen",
              "enbrel","hepatisis c","psoriasis","ankylosing spondylitis","rheumatoid arthritis",
              "inbrutinib","humira","trilipix","imbruvica")

Apply.SA.simple <- function(keywords, dataset){
  folder <- ""
  if (deparse(substitute(dataset)) == 'postdf'){folder <- "FB_post"}
  if (deparse(substitute(dataset)) == 'commentdf'){folder <- "FB_comment"}
  if (deparse(substitute(dataset)) == 'TW_T'){folder <- "TW_tweets"}
  if (deparse(substitute(dataset)) == 'TW_RT'){folder <- "TW_RT"}
  
  for (i in 1:length(keywords)){
    SA.simple(keywords[i],dataset,folder)
  }
}

Apply.SA.simple(keywords,postdf)
Apply.SA.simple(keywords,commentdf)
Apply.SA.simple(keywords,TW_T)
Apply.SA.simple(keywords,TW_RT)



testdf$sentiment <- NA

for (i in 1:length(keywords)){
  SA.simple(keywords[i],testdf,"TEST")
}

