#####################################################################################################
################################## Multi Trends Comparison ##########################################

# After LDA on R detect out the topics and assign topic back to each post, 
# multi-trends comparison is used to make comparison for trends of different topics

## generate post dataset for each topic
dataset_topic1<- subset(Final_TW_Tweets_Topic_Final, TopicID="1")
dataset_topic2<- subset(Final_TW_Tweets_Topic_Final, TopicID="2")
dataset_topic3<- subset(Final_TW_Tweets_Topic_Final, TopicID="3")

library(zoo)
library(reshape2)
library(ggplot2)  
library(plyr)

trendComparisonByDay <- function (dataset1,dataset2,dataset3, keyword1, keyword2, keyword3){
  
  getFrequencyByDay<- function(dataset,n){
    datasetFreq<- dataset
    datasetFreq$time <- format(datasetFreq$time, format="%m-%d") # only select dany and month
    datasetFreq<- ddply( datasetFreq, 'time', function(x) c(count=nrow(x)))
    datasetFreq <- datasetFreq[order(as.Date(as.character( datasetFreq$time),"%m-%d")),] 
    datasetFreq$time <- factor(datasetFreq$time, levels=unique(as.character(datasetFreq$time)) ) #order the dates
    #names(datasetFreq)<- paste('datasetFreq',n, sep = "")
    return(datasetFreq)
  }
  
  getFrequencyByDay1<- getFrequencyByDay(dataset1, 1)
  colnames(getFrequencyByDay1)[2]<- 'count1'
  
  getFrequencyByDay2<- getFrequencyByDay(dataset2, 2)
  colnames(getFrequencyByDay2)[2]<- 'count2'
  
  getFrequencyByDay3<- getFrequencyByDay(dataset3, 3)
  colnames(getFrequencyByDay3)[2]<- 'count3'
  
  timefinal<- merge(x=getFrequencyByDay1, y=getFrequencyByDay2, by="time", all=TRUE)
  timefinal<- merge(x=timefinal,y=getFrequencyByDay3, by='time', all=TRUE)
  timefinal <-  timefinal[order(as.Date(as.character( timefinal$time),"%m-%d")),] 
  timefinal$time <- factor(timefinal$time, levels=unique(as.character(timefinal$time)) ) #order the dates
  timefinal[is.na(timefinal)]<-0
  
  
  comparison.day.plot<- ggplot(data= timefinal, aes(time, group = 1, stat="identity"))+
    geom_line(aes(y=count1, colour = keyword1))+ 
    geom_line(aes(y=count2, colour = keyword2))+
    geom_line(aes(y=count3, colour = keyword3))+
    
    #geom_line(aes(y=count1, colour=keyword1),colour="red")+
    #geom_line(aes(y=count2, colour=keyword2),colour="blue")+
    #geom_line(aes(y=count3, colour=keyword3),colour="green")+
    
    labs(x = "Month-Day", y = "Post Count", 
         title = paste("Trend comparison between", keyword1, ",", keyword2, "and", keyword3, sep = " "))
  
  return(comparison.day.plot)
  
}

## apply multi-trends comparison graph
trendComparisonByDay(dataset_topic1,dataset_topic2,datase_topic3,'Topic1','Topic2','Topic3')
