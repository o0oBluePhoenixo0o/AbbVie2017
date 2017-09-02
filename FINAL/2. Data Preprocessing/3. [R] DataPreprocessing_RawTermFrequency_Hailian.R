
##########################################Data Preprocessing##########################################

# This preprocess method suits both for RawTermFrequency and DeepLearning methods

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

#apply the function to dataset
preprocessed_Dataset<- preprocessed_Dataset(dataset)




