
#Run 2a and 3 first

setwd("~/GitHub/AbbVie2017/Philipp")

backup <- testdf
testdf$sentiment <- NA

require(plyr)

#convert to factor
testdf$message <- as.factor(testdf$message)
#evaluate sentiments
scores <- score.sentiment(testdf$message, pos.words, neg.words, .progress='text')
stat$id <- testdf$Id
stat <- scores
stat$created <- testdf$created_time
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
for (i in 1:length(keywords)){
  try(SA.simple(keywords[i],testdf,"TEST"))
  if(class(SA.simple)=="try-error")next;
}
