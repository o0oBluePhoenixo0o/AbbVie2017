#read dataset by navigation, dataset neme: Dataset_RawTermFrequency_FB.csv
Dataset_RawTermFrequency_FB<- read.csv(file.choose(),encoding = "UTF-8")


#get key, posts and time of FB dataset
Final_FB_posts<- Dataset_RawTermFrequency_FB[c(3,7,8)]
Final_FB_posts_Noduplicate<- data.frame(na.omit(unique(Final_FB_posts)))
colnames(Final_FB_posts_Noduplicate)<- c("key", "Text","time")

#get key, comments and time of FB dataset
Final_FB_comments<- Final_FB_2804[c(3,22,23)]
Final_FB_comments_Noduplicate<- data.frame(na.omit(unique(Final_FB_comments)))
colnames(Final_FB_comments_Noduplicate)<- c("key", "Text","time")

#combine posts and comments together
Final_FB_PostsandComments<- rbind(Final_FB_posts_Noduplicate,Final_FB_comments_Noduplicate)


#read dataset by navigation, dataset neme: Dataset_RawTermFrequency_TW.csv
Dataset_RawTermFrequency_TW<- read.csv(file.choose(),encoding = "UTF-8")
#get key, posts and time of TW dataset
Final_TW_Tweets<- Dataset_RawTermFrequency_TW[c(3,7,8)]
Final_TW_Tweets<- data.frame(na.omit(Final_TW_Tweets))
colnames(Final_TW_Tweets)<- c("key", "Text","time")

Final_TW_Tweets_lag<- detectLanguage(Final_TW_Tweets[[2]])
Final_TW_Tweets<- cbind(Final_TW_Tweets,Final_TW_Tweets_lag)
Final_TW_Tweets<- subset(Final_TW_Tweets,detectedLanguage=="ENGLISH")[c(1,2,3)]

#change TW time to standard time
standardTime<- data.frame(anytime(Final_TW_Tweets$time))
colnames(standardTime)<- "time"
Final_TW_Tweets<- cbind(Final_TW_Tweets[c(1,2)], standardTime)


#combine FB & TW
Final_FB_TW<- rbind(Final_TW_Tweets, Final_FB_PostsandComments)


#extract subset from the whole dataset
Final_FB_TW_Company<- subset(Final_FB_TW, key=="abbvie"|key=="amgen"|key=="bristol myers"|key=="johnson & johnson")
Final_FB_TW_Disease<- subset(Final_FB_TW, key=="ankylosing spondylitis"|key=="hepatitis c"|key=="psoriasis"|key=="rheumatoid arthritis"|key=="juvenileidiopathicarthritis"|key=="juvenilerheumatoidarthritis"|key=="jia")
Final_FB_TW_Product<- subset(Final_FB_TW,key=="adalimumab"|key=="enbrel"|key=="humira"|key=="imbruvica"|key=="ibrutinib"|key=="trilipix")

# read in some stopwords:
stop_words <- stopwords("SMART")
word_bag<- c("â€š","johnson","rt","ed","johnsons","jack","hold","stop","show","thing","time","call","due","man","play","read","make","add","lead","link","year","today","leave","lose","watch","check")
stop_words<- c(stop_words, word_bag)

# remove url
removeURL <- function (sentence){
  #convert to lower-case 
  sentence <- tolower(sentence)
  removeURL <- function(x) gsub('(http.*) |(https.*) |(http.*)$|\n', "", x)
  sentence <- removeURL(sentence)
}

clean <- function (sentence){
  remove <- function(x) gsub('wh |â|ã|ãƒâ|šã|â€š|å|ãƒæ|iãƒæ|iƒæ |ƒæ | ƒ | ed| fc| bd| bc|wh | ba | ce | ar | wn | ne | it | ae | bb | fef | di | ale | ee | gt | ra | dr | s | d |cf | bf | cf|af | st |‚ | amp', "", x)
  sentence <- remove(sentence)
}

preprocessed_Dataset<- function(Dataset){
  
  # pre-processing, "Text" is the colname of the posts
  
  Dataset$Text <- sapply(Dataset$Text, function(x) removeURL(x)) #remove URL
  Dataset$Text <- removeNumbers(Dataset$Text) #remove number
  Dataset$Text <- lemmatize_strings(Dataset$Text)
  Dataset$Text <- removeWords(Dataset$Text, stop_words) #remove stopwords
  Dataset$Text <- gsub("'", "", Dataset$Text)  # remove apostrophes
  Dataset$Text <- gsub("[[:punct:]]", " ", Dataset$Text)  # replace punctuation with space
  Dataset$Text <- sapply(Dataset$Text, function(x) clean(x)) #remove niose terms
  Dataset$Text <- removeWords(Dataset$Text, stop_words) #remove stopwords again
  Dataset$Text <- gsub("[[:cntrl:]]", " ", Dataset$Text)  # replace control characters with space
  Dataset$Text <- gsub("^[[:space:]]+", "", Dataset$Text) # remove whitespace at beginning of documents
  Dataset$Text <- gsub("[[:space:]]+$", "", Dataset$Text) # remove whitespace at end of documents
  
  #remove null post
  #Dataset<- subset(Dataset, Text != '')
  
  
  doc.corpus<- Corpus(VectorSource(lemmatize_strings(Dataset$Text)))
  
  dtm_dataset<- DocumentTermMatrix(doc.corpus, control = list(minDocFreq=3,minTermLength=3,stopwords=TRUE)) 
  
  #create binaryweighted dtm 
  dtm_dataset_binaryweight<- weightBin(dtm_dataset) 
  
  ##reduce DocumentTermMatrix Dimension 
  # if there are more than 10000 terms, select terms with frequency > minfreq1
  # if there are less than 10000 terms, select terms with frequency > minfreq2
  # the threshold of the term number can be adjusted
  
  reduceDims<- function(dtm, minfreq1, minfreq2){
    
    if(dim(dtm)[2]>10000){
      
      dim2<- dim(dtm)[2]
      k<- dim(dtm)[2] %/% 10000
      dtm_test<- NULL
      m<- 1
      n<- 10000
      
      for(i in 0:k){
        
        if(n<= k*10000){
          
          rowTotals <- apply(dtm[,m:n] , 2, sum) #Find the sum of frequency of a term in all docs
          dtm_x   <- dtm[,m:n][,rowTotals> minfreq1]
          #assign(paste("dtm",i,sep = "_"), dtm_x)
          
          dtm_test<- cbind(dtm_test, dtm_x)
          
          m<- m+10000
          n<- n+10000
          
        }else{
          
          m<- k*10000+1
          n<- dim2
          rowTotals <- apply(dtm[,m:n] , 2, sum) #Find the sum of frequency of a term in all docs 
          dtm_x   <- dtm[,m:n][,rowTotals> minfreq1]
          #assign(paste("dtm",i,sep = "_"), dtm_x)
          
          dtm_test<- cbind(dtm_test, dtm_x)
          
        }
        
      }
    }else{
      
      rowTotals <- apply(dtm, 2, sum) #Find the sum of words in each Document 
      dtm_test   <- dtm[,rowTotals> minfreq2]
    }
    
    return(dtm_test)
    
  }
  
  t1<- Sys.time()
  dtm_test<- reduceDims(dtm_dataset_binaryweight, 1500, 100)
  # if there are more than 10000 terms, select terms with frequency > 1500
  # if there are less than 10000 terms, select terms with frequency > 100
  # if the  
  t2<- Sys.time()
  t2-t1

}

##################Apply the data preprocessing to RawTermFrequency

preprocessed_Dataset<- preprocessed_Dataset(Final_FB_TW_Product)
termFreq_dataset<- apply(preprocessed_Dataset,2,sum)
termFreq_dataset<- as.data.frame(termFreq_dataset)
colnames(termFreq_dataset)<- "frequency"

write.csv(termFreq_****, file = "termFreq_dataset.csv", 
          fileEncoding = "UTF-8")
