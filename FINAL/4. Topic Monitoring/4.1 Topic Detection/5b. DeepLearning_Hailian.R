install.packages('tm')
install.packages('text2vec')
install.packages("servr")
install.packages('textstem')
install.packages("lda")
install.packages("LDAvis")
install.packages("ggrepl")
install.packages("tidyverse")


library(tm)
library(servr)
library(text2vec)
library(textstem)
library(lda)
library(LDAvis)
library(tidyverse)


#read file by navigation
Final_TW_Newest<- read.csv(file.choose(),encoding = "UTF-8")

#get key, tweets, time of TW dataset
Final_TW_Tweets<- Final_TW_Newest[c(2,5,3,4)] #col2 is keyword, col5 is time, col3 is posts, col4 is language
Final_TW_Tweets<- subset(Final_TW_Tweets, Language=='eng')
Final_TW_Tweets<- data.frame(na.omit(Final_TW_Tweets))
colnames(Final_TW_Tweets)<- c("key", "Text","time","language")
Final_TW_Tweets<- subset(Final_TW_Tweets, key != 'johnson & johnson')

######################## Data Preprocessing#########################

preprocessed_Dataset<- function(Dataset){

  # read in some stopwords
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

  #remove noise items
  clean <- function (sentence){
  remove <- function(x) gsub('wh |â|ã|ãƒâ|šã|â€š|å|ãƒæ|iãƒæ|iƒæ |ƒæ | ƒ | ed| fc| bd| bc|wh | ba | ce | ar | wn | ne | it | ae | bb | fef | di | ale | ee | gt | ra | dr | s | d |cf | bf | cf|af | st |‚ | amp', "", x)
  sentence <- remove(sentence)
}

  
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

##Apply data preprocessing

DTM_DeepLearning<- preprocessed_Dataset(Final_TW_Tweets)


##############################################################################
######################  Deep Learning Model  #################################
##############################################################################

install.packages("prob")
install.packages("combinat")

library(prob)


visible_state_to_hidden_probabilities <- function(rbm_w, visible_state) {
  1/(1+exp(-rbm_w %*% visible_state))
}

hidden_state_to_visible_probabilities <- function(rbm_w, hidden_state) {
  1/(1+exp(-t(rbm_w) %*% hidden_state))
}

configuration_goodness <- function(rbm_w, visible_state, hidden_state) {
  out=0
  for (i in 1:dim(visible_state)[2]) {
    out=out+t(hidden_state[,i]) %*% rbm_w %*% visible_state[,i]
  }
  out/dim(visible_state)[2]
}

configuration_goodness_gradient <- function(visible_state, hidden_state) {
  hidden_state %*% t(visible_state)/dim(visible_state)[2]
}

sample_bernoulli <- function(mat) {
  dims=dim(mat)
  matr<- matrix(rbinom(prod(dims),size=1,prob=c(mat)),dims[1],dims[2])
  matr<- as.data.frame(matr)
  matr[is.na(matr)]<- 0
  matr<- as.matrix(matr)
  return(matr)
  
}

cd1 <- function(rbm_w, visible_data) {
  visible_data = sample_bernoulli(visible_data)
  #visible_data<- visible_data[is.na(visible_data[])]<- 0
  H0=sample_bernoulli(visible_state_to_hidden_probabilities(rbm_w, visible_data))
  vh0=configuration_goodness_gradient(visible_data, H0)
  V1=sample_bernoulli(hidden_state_to_visible_probabilities(rbm_w, H0))
  H1=visible_state_to_hidden_probabilities(rbm_w, V1)
  vh1=configuration_goodness_gradient(V1, H1)
  vh0-vh1
}

#rbm model
rbm <- function(num_hidden, training_data, learning_rate, n_iterations, mini_batch_size=100, momentum=0.9, quiet=FALSE) {
  #   This trains a model that's defined by a single matrix of weights.
  #    num_hidden is the number of hidden units
  
  #   cd1 is a function that takes parameters  and  and returns the gradient 
  #   (or approximate gradient in the case of CD-1) of the function that we're maximizing. 
  #   Note the contrast with the loss function that we saw in PA3, which we were minimizing. 
  #   The returned gradient is an array of the same shape as the provided parameter.
  
  #   This uses mini-batches no weight decay and no early stopping.
  #   This returns the matrix of weights of the trained model.
  
  n=dim(training_data)[2] #Docs number
  p=dim(training_data)[1] #Terms number
  
  if (n %% mini_batch_size != 0) {
    stop("the number of test cases must be divisable by the mini_batch_size")
  }
  model = (matrix(runif(num_hidden*p),num_hidden,p) * 2 - 1) * 0.1
  momentum_speed = matrix(0,num_hidden,p)
  
  start_of_next_mini_batch = 1;
  for (iteration_number in 1:n_iterations) {
    if (!quiet) {cat("Iter",iteration_number,"\n")}
    mini_batch = training_data[, start_of_next_mini_batch:(start_of_next_mini_batch + mini_batch_size - 1)]
    start_of_next_mini_batch = (start_of_next_mini_batch + mini_batch_size) %% n
    gradient = cd1(model, mini_batch)
    momentum_speed = momentum * momentum_speed + gradient
    model = model + momentum_speed * learning_rate
  }
  
  #change the colname from number to terms
  terms<- as.matrix(dimnames(training_data)[1])
  terms<- as.matrix(unlist(terms))
  terms<- t(terms)
  colnames(model)<- terms
  
  return(model)
  
}

##Transfer DTM to simple matrix

weightMatrix<- as.data.frame(t(as.matrix(dtm_test))) 
weightMatrix<- as.matrix(weightMatrix) 


## get divisors of #docs
divisors <- function(x){
  #  Vector of numberes to test against
  y <- seq_len(x)
  #  Modulo division. If remainder is 0 that number is a divisor of x so return it
  y[ x%%y == 0 &  y!= 1 & y!= x]
  
}


###################################Restricted Boltzmann Machines#######################################

#only run the activation funtion once to create RBMs topic model
#Create K=30 RBMs Topic Model
#The result is random based on the sample number(mini_batch_size), 
#because the sample number is generated randomly by function divisor()

Topic_30<- rbm(num_hidden=30, training_data=weightMatrix, learning_rate=.09, n_iterations=100000,
               mini_batch_size=sample(divisors(dim(weightMatrix)[2]),1), momentum=0.9)

#get former 10 terms of the topics
topic_list<- top.topic.words(Topic_30, num.words = 10, by.score = FALSE)
topic_list_30<- t(topic_list)
topic_list_30<- as.data.frame(topic_list_30)

topic_list_30<-paste(topic_list_30$V1,topic_list_30$V2,topic_list_30$V3,topic_list_30$V4,topic_list_30$V5,
                     topic_list_30$V6,topic_list_30$V7,topic_list_30$V8, topic_list_30$V9, topic_list_30$V10, sep = ', ')

topic_list_30<- as.data.frame(topic_list_30)
colnames(topic_list_30)<- 'Terms'

## export RBMs topic model
write.csv(topic_list_30, file = "topic_list_30.csv", quote = TRUE, sep= ",",
          row.names=FALSE, qmethod='escape',
          fileEncoding = "UTF-8", na = "NA")


######################################Deep Belief Networks########################################

# run the activation funtion multiple times to get the DBNs topic model

#for example, if the RBNs consists of two RBMs, run the RBMs twice, the output of the first RBMs serves as the input of the second RBMs

##Create K=30 RBMs Topic Model

# first step: create K=50 RBMs topic model K can be set as any proper number
Topic_50<- rbm(num_hidden=50, training_data=weightMatrix, learning_rate=.09, n_iterations=100000,
               mini_batch_size=sample(divisors(dim(weightMatrix)[2]),1), momentum=0.9)

# second step: set Topic_50 as input, create K=30 topic model
Topic_30_RBNs<- rbm(num_hidden=30, training_data=t(Topic_50), learning_rate=.09, n_iterations=100000,
                    mini_batch_size=sample(divisors(dim(t(Topic_50))[2]),1), momentum=0.9)

#get former 10 terms of the topics
topic_list<- top.topic.words(Topic_30_RBNs, num.words = 10, by.score = FALSE)
topic_list_30_RBNs<- t(topic_list)
topic_list_30_RBNs<- as.data.frame(topic_list_30_RBNs)

topic_list_30_RBNs<-paste(topic_list_30_RBNs$V1,topic_list_30_RBNs$V2,topic_list_30_RBNs$V3,topic_list_30_RBNs$V4,topic_list_30_RBNs$V5,topic_list_30_RBNs$V6,topic_list_30_RBNs$V7,topic_list_30_RBNs$V8, topic_list_30_RBNs$V9, topic_list_30_RBNs$V10, sep = ', ')

topic_list_30_RBNs<- as.data.frame(topic_list_30_RBNs)
colnames(topic_list_30_RBNs)<- 'Terms'

## export RBNs topic model
write.csv(topic_list_30_RBNs, file = "topic_list_30_RBNs.csv", quote = TRUE, sep= ",",
          row.names=FALSE, qmethod='escape',
          fileEncoding = "UTF-8", na = "NA")









