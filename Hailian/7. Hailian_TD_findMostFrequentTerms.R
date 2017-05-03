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

#read file by navigation
ChooeseFile<- read.csv(file.choose(),encoding = "UTF-8")
Final_TW_2804<- ChooeseFile

###get key, posts and comments, time of FB dataset e.g. for dataset Company/Product
Final_FB_posts<- Final_FB_2804[c(3,7,8)]
Final_FB_posts_Noduplicate<- data.frame(na.omit(unique(Final_FB_posts)))
colnames(Final_FB_posts_Noduplicate)<- c("key", "Text","time")

Final_FB_comments<- Final_FB_2804[c(3,22,23)]
Final_FB_comments_Noduplicate<- data.frame(na.omit(unique(Final_FB_comments)))
colnames(Final_FB_comments_Noduplicate)<- c("key", "Text","time")

Final_FB_PostsandComments<- rbind(Final_FB_posts_Noduplicate,Final_FB_comments_Noduplicate)

###get key, tweets, time of TW dataset
Final_TW_Tweets<- Final_TW_2804[c(14,9,2)]
Final_TW_Tweets<- data.frame(na.omit(unique(Final_TW_Tweets)))
colnames(Final_TW_Tweets)<- c("key", "Text","time")

Final_TW_Tweets_lag<- detectLanguage(Final_TW_Tweets[[2]])
Final_TW_Tweets<- cbind(Final_TW_Tweets,Final_TW_Tweets_lag)
Final_TW_Tweets<- subset(Final_TW_Tweets,detectedLanguage=="ENGLISH")[c(1,2,3)]

#combine FB & TW
Final_FB_TW<- rbind(Final_FB_PostsandComments,Final_TW_Tweets)

#company
abbvie
amgen
bristol myers
johnson & johnson

#diseases
ankylosing spondylitis
hepatitis c
psoriasis
rheumatoid arthritis
juvenileidiopathicarthritis
juvenilerheumatoidarthritis

#products
adalimumab
enbrel
humira
imbruvica
ibrutinib
jia
trilipix

Final_FB_TW_Company<- subset(Final_FB_TW, key=="abbvie"|key=="amgen"|key=="bristol myers"|key=="johnson & johnson")
Final_FB_TW_Disease<- subset(Final_FB_TW, key=="ankylosing spondylitis"|key=="hepatitis c"|key=="psoriasis"|key=="rheumatoid arthritis"|key=="juvenileidiopathicarthritis"|key=="juvenilerheumatoidarthritis")
Final_FB_TW_Product<- subset(Final_FB_TW,key=="adalimumab"|key=="enbrel"|key=="humira"|key=="imbruvica"|key=="ibrutinib"|key=="trilipix"|key=="jia")

#####################################################################################################################
### for small dataset, dtm<40000*200000 e.g. for dataset Company/Product


findMostFreqTerms<- function(Final_Dataset)
{
  dataset<- Final_Dataset
  
  doc.corpus<- Corpus(VectorSource(Final_Dataset$Text))
  
  doc.corpus <- tm_map(doc.corpus, removeNumbers)
  doc.corpus <- tm_map(doc.corpus, removePunctuation)
  #doc.corpus <- tm_map(doc.corpus, removeWords, stopwords("english"))
  #???doc.corpus <- tm_map(doc.corpus, stemDocument, "english")
  doc.corpus <- tm_map(doc.corpus, stripWhitespace)
  doc.corpus <- tm_map(doc.corpus, PlainTextDocument)
  
  doc.corpus <- sapply(doc.corpus,function(row) iconv(row, "latin1", "ASCII", sub=""))
  doc.corpus<- Corpus(VectorSource(doc.corpus$content))
  doc.corpus <- tm_map(doc.corpus, tolower)
  
  RemoveURL <- function(x){
    gsub("[a-z]*http|www[a-z]*","",x)
  }
  RemoveMail<- function(x){
    gsub("[a-z]*mail[a-z]*","",x)
  }
  RemoveWord<- function(x){
    gsub(c("can|just|do|now|will|get|one|dont|also|much|really|even|use|got|still|year|cant|new|going|since|every|want"),"",x)
  }
  
  
  doc.corpus<- tm_map(doc.corpus,content_transformer(RemoveURL))
  doc.corpus<- tm_map(doc.corpus,content_transformer(RemoveMail))
  doc.corpus<- tm_map(doc.corpus,content_transformer(RemoveWord))
  
  dtm_dataset<- DocumentTermMatrix(doc.corpus, control = list(minDocFreq=3,minTermLength=4,stopwords=TRUE))
  
  dtm_dataset_binaryweight<- weightBin(dtm_dataset)
  
  rowTotals <- apply(dtm_dataset_binaryweight , 1, sum) #Find the sum of words in each Document
  dtm_dataset_binaryweight.new<- dtm_dataset_binaryweight[rowTotals> 3, ]   
  
  colTotals<- apply(dtm_dataset_binaryweight.new,2,sum)
  dtm_dataset_binaryweight.final<- dtm_dataset_binaryweight.new[,colTotals>199]
  
  #dtm_dataset_binaryweight.final<- dtm_dataset_binaryweight.new[,colTotals>50] #only for Products
  
  termFreq_dataset<- apply(dtm_dataset_binaryweight.final,2,sum)
  termFreq_dataset<- as.data.frame(termFreq_dataset)
  colnames(termFreq_dataset)<- "frequency"
  
}

findMostFreqTerms(Final_FB_TW_Product)

#termFreq_Company<- termFreq_dataset #for Company
#termFreq_Product<- termFreq_dataset  #for Disease


############################################################################################################
### for large dataset, dtm>40000*200000 e.g. for dataset Disease

doc.corpus<- Corpus(VectorSource(Final_FB_TW_Disease$Text))

doc.corpus <- tm_map(doc.corpus, removeNumbers)
doc.corpus <- tm_map(doc.corpus, removePunctuation)
#doc.corpus <- tm_map(doc.corpus, removeWords, stopwords("english"))
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
  gsub(c("can|just|do|now|will|get|one|dont|also|much|really|even|use|got|still|year|cant|new|going|since|every|want"),"",x)
}
doc.corpus<- tm_map(doc.corpus,content_transformer(RemoveURL))
doc.corpus<- tm_map(doc.corpus,content_transformer(RemoveMail))
doc.corpus<- tm_map(doc.corpus,content_transformer(RemoveWord))


dtm_dataset<- DocumentTermMatrix(doc.corpus, control = list(minDocFreq=3,minTermLength=4,stopwords=TRUE))

dtm_dataset_binaryweight<- weightBin(dtm_dataset)


#inspect(tdm)


#remove small documents in dtm
rowTotals <- apply(dtm_dataset_binaryweight[1:10000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.1   <- dtm_dataset_binaryweight[1:10000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[10001:20000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.2   <- dtm_dataset_binaryweight[10001:20000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[20001:30000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.3   <- dtm_dataset_binaryweight[20001:30000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[30001:40000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.4   <- dtm_dataset_binaryweight[30001:40000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[40001:50000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.5   <- dtm_dataset_binaryweight[40001:50000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[50001:60000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.6   <- dtm_dataset_binaryweight[50001:60000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[60001:70000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.7   <- dtm_dataset_binaryweight[60001:70000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[70001:80000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.8   <- dtm_dataset_binaryweight[70001:80000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[80001:90000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.9   <- dtm_dataset_binaryweight[80001:90000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[90001:100000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.10   <- dtm_dataset_binaryweight[90001:100000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[100001:110000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.11   <- dtm_dataset_binaryweight[100001:110000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[110001:120000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.12   <- dtm_dataset_binaryweight[110001:120000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[120001:130000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.13   <- dtm_dataset_binaryweight[120001:130000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[130001:140000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.14   <- dtm_dataset_binaryweight[130001:140000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[140001:150000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.15   <- dtm_dataset_binaryweight[140001:150000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[150001:160000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.16   <- dtm_dataset_binaryweight[150001:160000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[160001:170000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.17   <- dtm_dataset_binaryweight[160001:170000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[170001:180000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.18   <- dtm_dataset_binaryweight[170001:180000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[180001:190000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.19   <- dtm_dataset_binaryweight[180001:190000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[190001:200000,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.20   <- dtm_dataset_binaryweight[190001:200000,1:182252][rowTotals> 3, ]    

rowTotals <- apply(dtm_dataset_binaryweight[200001:214146,1:182252] , 1, sum) #Find the sum of words in each Document
dtm_dataset_binaryweight.21   <- dtm_dataset_binaryweight[200001:214146,1:182252][rowTotals> 3, ]    


#combine small dtms
#list_of_dtms<- list(dtm_dataset_binaryweight.1,dtm_dataset_binaryweight.2)
list_of_dtms<- list(dtm_dataset_binaryweight.1,dtm_dataset_binaryweight.2,dtm_dataset_binaryweight.3,dtm_dataset_binaryweight.4,dtm_dataset_binaryweight.5,dtm_dataset_binaryweight.6,dtm_dataset_binaryweight.7,dtm_dataset_binaryweight.8,dtm_dataset_binaryweight.9,dtm_dataset_binaryweight.10,dtm_dataset_binaryweight.11,dtm_dataset_binaryweight.12,dtm_dataset_binaryweight.13,dtm_dataset_binaryweight.14,dtm_dataset_binaryweight.15,dtm_dataset_binaryweight.16,dtm_dataset_binaryweight.17,dtm_dataset_binaryweight.18,dtm_dataset_binaryweight.19,dtm_dataset_binaryweight.20,dtm_dataset_binaryweight.21)
dtm_dataset_binaryweight.total1<- do.call(tm:::c.DocumentTermMatrix,list_of_dtms)

#sum term frequency
colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,1:10000],2,sum)
colTotal1.df<- as.data.frame(colTotals)
colnames(colTotal1.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,10001:20000],2,sum)
colTotal2.df<- as.data.frame(colTotals)
colnames(colTotal2.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,20001:30000],2,sum)
colTotal3.df<- as.data.frame(colTotals)
colnames(colTotal3.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,30001:40000],2,sum)
colTotal4.df<- as.data.frame(colTotals)
colnames(colTotal4.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,40001:50000],2,sum)
colTotal5.df<- as.data.frame(colTotals)
colnames(colTotal5.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,50001:60000],2,sum)
colTotal6.df<- as.data.frame(colTotals)
colnames(colTotal6.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,60001:70000],2,sum)
colTotal7.df<- as.data.frame(colTotals)
colnames(colTotal7.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,70001:80000],2,sum)
colTotal8.df<- as.data.frame(colTotals)
colnames(colTotal8.df)<- "frequency"


colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,80001:90000],2,sum)
colTotal9.df<- as.data.frame(colTotals)
colnames(colTotal9.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,90001:100000],2,sum)
colTotal10.df<- as.data.frame(colTotals)
colnames(colTotal10.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,100001:110000],2,sum)
colTotal11.df<- as.data.frame(colTotals)
colnames(colTotal11.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,110001:120000],2,sum)
colTotal12.df<- as.data.frame(colTotals)
colnames(colTotal12.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,120001:130000],2,sum)
colTotal13.df<- as.data.frame(colTotals)
colnames(colTotal13.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,130001:140000],2,sum)
colTotal14.df<- as.data.frame(colTotals)
colnames(colTotal14.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,140001:150000],2,sum)
colTotal15.df<- as.data.frame(colTotals)
colnames(colTotal15.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,150001:160000],2,sum)
colTotal16.df<- as.data.frame(colTotals)
colnames(colTotal16.df)<- "frequency"

colTotals<- apply(dtm_dataset_binaryweight.total1[1:167562,160001:175415],2,sum)
colTotal17.df<- as.data.frame(colTotals)
colnames(colTotal17.df)<- "frequency"

termFreq_Disease<- rbind(colTotal1.df,colTotal2.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal3.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal4.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal5.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal6.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal7.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal8.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal9.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal10.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal11.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal12.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal13.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal14.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal15.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal16.df)
termFreq_Disease<- rbind(termFreq_Disease,colTotal17.df)



