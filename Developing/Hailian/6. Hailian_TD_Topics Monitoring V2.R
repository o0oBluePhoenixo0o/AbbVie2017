
library(SnowballC)
library(cldr)
library(tm)
library(tidyverse)
library(text2vec)
library(caret)
library(glmnet)
library(ggrepel)
library(textreuse)
library(mscstexta4r)
library(slam)
library(qdap)
library(zoo)
library(reshape2)
library(ggplot2)  
library(plyr)

#use Hailian_Disease as traning dataset
Hailian_Diseases_posts<- data.fraremome(unique(Hailian_Diseases[c(2,6,7)]))
Hailian_Diseases_posts<-data.frame(na.omit(Hailian_Diseases_posts))
colnames(Hailian_Diseases_posts)<-c("id","text","time")
Hailian_Diseases_comments<- data.frame(unique(Hailian_Diseases[c(25,21,22)]))
Hailian_Diseases_comments<- data.frame(na.omit(Hailian_Diseases_comments))
colnames(Hailian_Diseases_comments)<-c("id","text","time")
Hailian_Diseases_posts_comments<- rbind(Hailian_Diseases_posts,Hailian_Diseases_comments)

#language detecting
Hailian_Diseases_posts_comments1<- detectLanguage(Hailian_Diseases_posts_comments[[2]])
Hailian_Diseases_posts_comments1<- cbind(Hailian_Diseases_posts_comments,language=Hailian_Diseases_posts_comments1[[1]])
#deleting non english post
Hailian_Diseases_posts_comments2<- data.frame(unique(subset(Hailian_Diseases_posts_comments1,language=="ENGLISH")))
#remove punctuation
Hailian_Diseases_posts_comments3<- data.frame(removePunctuation(Hailian_Diseases_posts_comments2$text))
colnames(Hailian_Diseases_posts_comments3)<-"text"

#preprocessing
doc.corpus<- Corpus(VectorSource(Hailian_Diseases_posts_comments3$text))

doc.corpus <- tm_map(doc.corpus, removeNumbers)
doc.corpus <- tm_map(doc.corpus, removePunctuation)
doc.corpus <- tm_map(doc.corpus, removeWords, stopwords("english"))
#???doc.corpus <- tm_map(doc.corpus, stemDocument, "english")
doc.corpus <- tm_map(doc.corpus, stripWhitespace)
doc.corpus <- tm_map(doc.corpus, PlainTextDocument)

inspect(doc.corpus)

doc.corpus <- sapply(doc.corpus,function(row) iconv(row, "latin1", "ASCII", sub=""))
doc.corpus<- Corpus(VectorSource(doc.corpus$content))
doc.corpus <- tm_map(doc.corpus, tolower)

doc.corpus1<-doc.corpus

RemoveURL <- function(x){
  gsub("[a-z]*http|www[a-z]*","",x)
}
RemoveMail<- function(x){
  gsub("[a-z]*mail[a-z]*","",x)
}
RemoveWord<- function(x){
  gsub(c("can|just"),"",x)
}
doc.corpus1<- tm_map(doc.corpus1,content_transformer(RemoveURL))
doc.corpus1<- tm_map(doc.corpus1,content_transformer(RemoveMail))
doc.corpus1<- tm_map(doc.corpus1,content_transformer(RemoveWord))

tdm<- TermDocumentMatrix(doc.corpus)

dtm3<- DocumentTermMatrix(doc.corpus1, control = list(minDocFreq=3,minTermLength=4,stopwords=TRUE))

dtm3_binaryweight<- weightBin(dtm3)

inspect(tdm)
inspect(dtm3_binaryweight)

freqs <- as.data.frame(inspect(dtm1))
colSums(freqs)

#remove small documents in dtm
rowTotals <- apply(dtm3_binaryweight[1:10000,1:66289] , 1, sum) #Find the sum of words in each Document
dtm1.new   <- dtm3_binaryweight[1:10000,1:66289][rowTotals> 3, ]    

rowTotals2 <- apply(dtm3_binaryweight[10001:20000,1:66289] , 1, sum) #Find the sum of words in each Document
dtm2.new   <- dtm3_binaryweight[10001:20000,1:66289][rowTotals2> 3, ]    

rowTotals3 <- apply(dtm3_binaryweight[20001:30000,1:66289] , 1, sum) #Find the sum of words in each Document
dtm3.new   <- dtm3_binaryweight[20001:30000,1:66289][rowTotals3> 3, ]  

rowTotals4 <- apply(dtm3_binaryweight[30001:40000,1:66289] , 1, sum) #Find the sum of words in each Document
dtm4.new   <- dtm3_binaryweight[30001:40000,1:66289][rowTotals4> 3, ]  

rowTotals5 <- apply(dtm3_binaryweight[40001:50000,1:66289] , 1, sum) #Find the sum of words in each Document
dtm5.new   <- dtm3_binaryweight[40001:50000,1:66289][rowTotals5> 3, ]  

rowTotals6 <- apply(dtm3_binaryweight[50001:70000,1:66289] , 1, sum) #Find the sum of words in each Document
dtm6.new   <- dtm3_binaryweight[50001:70000,1:66289][rowTotals6> 3, ]  

rowTotals7 <- apply(dtm3_binaryweight[70001:90000,1:66289] , 1, sum) #Find the sum of words in each Document
dtm7.new   <- dtm3_binaryweight[70001:90000,1:66289][rowTotals7> 3, ]  

rowTotals8 <- apply(dtm3_binaryweight[90001:99866,1:66289] , 1, sum) #Find the sum of words in each Document
dtm8.new   <- dtm3_binaryweight[90001:99866,1:66289][rowTotals8> 3, ]  

#combine small dtms
list_of_dtms<- list(dtm1.new,dtm2.new,dtm3.new,dtm4.new,dtm5.new,dtm6.new,dtm7.new,dtm8.new)
dtm.final_binaryweight<- do.call(tm:::c.DocumentTermMatrix,list_of_dtms)

#sum term frequency
colTotal1<- apply(dtm.final_binaryweight[1:76255,1:10000],2,sum)
colTotal1.df<- as.data.frame(colTotal1)
colnames(colTotal1.df)<- "frequency"

colTotal2<- apply(dtm.final_binaryweight[1:76255,10001:20000],2,sum)
colTotal2.df<- as.data.frame(colTotal2)
colnames(colTotal2.df)<- "frequency"

colTotal3<- apply(dtm.final_binaryweight[1:76255,20001:30000],2,sum)
colTotal3.df<- as.data.frame(colTotal3)
colnames(colTotal3.df)<- "frequency"

colTotal4<- apply(dtm.final_binaryweight[1:76255,30001:40000],2,sum)
colTotal4.df<- as.data.frame(colTotal4)
colnames(colTotal4.df)<- "frequency"

colTotal5<- apply(dtm.final_binaryweight[1:76255,40001:63807],2,sum)
colTotal5.df<- as.data.frame(colTotal5)
colnames(colTotal5.df)<- "frequency"

termFreq.final<- rbind(colTotal1.df,colTotal2.df)
termFreq.final<- rbind(termFreq.final,colTotal3.df)
termFreq.final<- rbind(termFreq.final,colTotal4.df)
termFreq.final<- rbind(termFreq.final,colTotal5.df)

dtm_binaryweight.final<- dtm.final_binaryweight[1:76255,1:1239]


#remove low frequency terms
dtm_binaryweight1<- dtm.final_binaryweight[1:76255,1:10000][,colTotal1>199] 
dtm_binaryweight2<- dtm.final_binaryweight[1:76255,10001:20000][,colTotal2>199] 
dtm_binaryweight3<- dtm.final_binaryweight[1:76255,20001:30000][,colTotal3>199] 
dtm_binaryweight4<- dtm.final_binaryweight[1:76255,30001:40000][,colTotal4>199] 
dtm_binaryweight5<- dtm.final_binaryweight[1:76255,40001:63807][,colTotal5>199] 

colTotal<- apply(dtm.final_binaryweight[1:76255,1:30000],2,sum)
dtm_binaryweight.final<- dtm.final_binaryweight[1:76255,1:30000][,colTotal>199]


#sum term frequency
termFreq.final1<- apply(dtm_binaryweight.final,2,sum)
termFreq.final1<- as.data.frame(termFreq.final1)
colnames(termFreq.final1)<- "frequency"

#visulization the relationship between posts number and time(monthly)
topic_pain<- as.data.frame(filter(Hailian_Diseases_posts_comments2,grepl('pain',text)))

topic_help<- as.data.frame(filter(Hailian_Diseases_posts_comments2,grepl('help',text)))

topic_arthritis<- as.data.frame(filter(Hailian_Diseases_posts_comments2,grepl('arthritis',text)))

plotFacebookPostsByMonth <- function (posts, keyword){
  posts.month <- posts
  posts.month$time <- format(as.Date(posts.month$time), format ="%m-%y") # format to only show month and year
  posts.month<- ddply(posts.month, 'time', function(x) c(count=nrow(x)))
  
  posts.month <-  posts.month[order(as.yearmon(as.character(posts.month$time),"%m-%Y")),] #use zoo's as.yearmon so that we can group by month/year
  posts.month$time <- factor(posts.month$time, levels=unique(as.character(posts.month$time)) ) #so that ggplot2 respects the order of my dates
  
  
  posts.month.plot<-ggplot(data=posts.month, aes(x=posts.month$time, y=count, group = 1)) +
    geom_point() +
    geom_line(aes(colour = count), stat = "identity") + scale_colour_gradient(low="red",high = "blue") +
    geom_text(aes(label=count), vjust=-0.5, color="black", size=3.5) +
    labs(x = "Month-Year", y = "Post count", 
         title = paste("Post count on keyword", keyword, sep = " "))
  return(posts.month.plot)
}

plotFacebookPostsByMonth(topic_pain,'pain')
plotFacebookPostsByMonth(topic_help,'"help"')
plotFacebookPostsByMonth(topic_arthritis,'"arthritis"')


#random test
inspect(dtm.final_binaryweight[1:1,108:108])#value:0
isTRUE(dtm.final_binaryweight[1:1,108:108])#return:FALSE

#get term pairs appear in same post
termSet_list<- colnames(dtm_binaryweight.final, do.NULL = TRUE, prefix = col)
termSet<- as.data.frame(termSet_list)
termFreq.final<- cbind(termFreq.final1,termSet)

sl<-rep(0,sum(1:length(termSet_list)))
n=1
termPair<- list()
for(i in 1:length(termSet_list))
{
  for(j in i+1:length(termSet_list))
  {
    for(r in 1: 76255)
    {
      if(isTRUE(dtm_binaryweight.final[r:r,i:i])==TRUE && isTRUE(dtm_binaryweight.final[r:r,j:j])==TRUE)
        sl[n]=sl[n]+1
    }
    if(sl[n]>50)
    {
      c(termPair,c(termSet_list[i],termSet_list[j]))
    }
    n=n+1
  }
}

                          
termPair.df <- data.frame(matrix(unlist(termPair), nrow=2, byrow=T))                         
