install.packages('tm')
install.packages('text2vec')
install.packages("servr")
install.packages('textstem')
install.packages("lda")
install.packages("LDAvis")
install.packages("grepl")
#install.packages("topicmodels")
#install.packages("modeltools")



library(tm)
library(servr)
library(text2vec)
library(textstem)
library(lda)
library(LDAvis)
library(grepl)
#library(topicmodels)

#read file by navigation
Final_TW_Newest<- read.csv(file.choose(),encoding = "UTF-8")
###get key, tweets, time of TW dataset
Final_TW_Tweets<- Final_TW_Newest[c(1,9,2,7)]
Final_TW_Tweets<- subset(Final_TW_Tweets, Language=='eng')
Final_TW_Tweets<- data.frame(na.omit(Final_TW_Tweets))
colnames(Final_TW_Tweets)<- c("key", "Text","time")

#remove non-english posts
#Final_TW_Tweets_lag<- detectLanguage(Final_TW_Tweets[[2]])
#Final_TW_Tweets<- cbind(Final_TW_Tweets,Final_TW_Tweets_lag)
#Final_TW_Tweets<- subset(Final_TW_Tweets,detectedLanguage=="ENGLISH")[c(1,2,3)]



# read in some stopwords:
stop_words <- stopwords("SMART")
word_bag<- c("â€š","johnson","rt","ed","fc","â","pa","sta","cdc")
stop_words<- c(stop_words, word_bag)

#deeper clean
removeURL <- function (sentence){
  #convert to lower-case 
  sentence <- tolower(sentence)
  removeURL <- function(x) gsub('(http.*) |(https.*) |(http.*)$|\n|ã|„|â€š|â', "", x)
  sentence <- removeURL(sentence)
}

clean <- function (sentence){
  remove <- function(x) gsub('wh |ã€|ãš|â€š|Å¡ã£|ã¥|ã£Æã¦|iã£Æã¦|rt | ed| fc| bd| bc|wh |ba | ce | ar | wn | ne | it | ae | bb | fef | di | ale | ee | gt | ra | dr | s | d |cf | bf | cf|af | st |‚ | amp', "", x)
  sentence <- remove(sentence)
}

# pre-processing:
Final_TW_Tweets$Text <- sapply(Final_TW_Tweets$Text, function(x) removeURL(x))
Final_TW_Tweets$Text <- removeNumbers(Final_TW_Tweets$Text)
Final_TW_Tweets$Text <- lemmatize_strings(Final_TW_Tweets$Text)
Final_TW_Tweets$Text <- removeWords(Final_TW_Tweets$Text, stop_words)
Final_TW_Tweets$Text <- gsub("'", "", Final_TW_Tweets$Text)  # remove apostrophes
Final_TW_Tweets$Text <- gsub("[[:punct:]]", " ", Final_TW_Tweets$Text)  # replace punctuation with space
Final_TW_Tweets$Text <- sapply(Final_TW_Tweets$Text, function(x) clean(x))
Final_TW_Tweets$Text <- removeWords(Final_TW_Tweets$Text, stop_words)
Final_TW_Tweets$Text <- gsub("[[:cntrl:]]", " ", Final_TW_Tweets$Text)  # replace control characters with space
Final_TW_Tweets$Text <- gsub("^[[:space:]]+", "", Final_TW_Tweets$Text) # remove whitespace at beginning of documents
Final_TW_Tweets$Text <- gsub("[[:space:]]+$", "", Final_TW_Tweets$Text) # remove whitespace at end of documents


doc.corpus<- Corpus(VectorSource(lemmatize_strings(Final_TW_Tweets$Text)))

dtm_dataset<- DocumentTermMatrix(doc.corpus, control = list(minDocFreq=3,minTermLength=3,stopwords=TRUE)) 
 
 #create binaryweight dtm 
dtm_dataset_binaryweight<- weightBin(dtm_dataset) 


#reduce DocumentTermMatrix Dimension 
# if there are more than 10000 terms, select terms with frequency > minfreq1
# if there are less than 10000 terms, select terms with frequency > minfreq2

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
dtm_test<- reduceDims(dtm_dataset_binaryweight, 800, 100)
# if there are more than 10000 terms, select terms with frequency > 800
# if there are less than 10000 terms, select terms with frequency > 100
# if the  
t2<- Sys.time()
t2-t1


##############################################################################
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
  #    is the number of hidden units
  
  #   cd1 is a function that takes parameters  and  and returns the gradient 
  #   (or approximate gradient in the case of CD-1) of the function that we're maximizing. 
  #   Note the contrast with the loss function that we saw in PA3, which we were minimizing. 
  #   The returned gradient is an array of the same shape as the provided  parameter.
  
  #   This uses mini-batches no weight decay and no early stopping.
  #   This returns the matrix of weights of the trained model.
  n=dim(training_data)[2] #Docs
  p=dim(training_data)[1] #Terms
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

#extract weight matrix from DTM
weightMatrix<- as.data.frame(t(as.matrix(dtm_test))) 
weightMatrix<- as.matrix(weightMatrix) 


# get divisors of #docs
divisors <- function(x){
  #  Vector of numberes to test against
  y <- seq_len(x)
  #  Modulo division. If remainder is 0 that number is a divisor of x so return it
  y[ x%%y == 0 &  y!= 1 & y!= x]
  
}

Topic_20<- rbm(num_hidden=20, training_data=weightMatrix, learning_rate=.09, n_iterations=50000,
                               mini_batch_size=sample(divisors(dim(weightMatrix)[2]),1), momentum=0.9)

topic_list<- top.topic.words(Topic_20, num.words = 15, by.score = FALSE)

topic_list_20<- as.data.frame(t(topic_list))
topic_list_20<- paste(topic_list_20$V1,topic_list_20$V2,topic_list_20$V3,topic_list_20$V4,topic_list_20$V5,topic_list_20$V6,topic_list_20$V7,topic_list_20$V8, topic_list_20$V9, topic_list_20$V10, topic_list_20$V11, topic_list_20$V12, topic_list_20$V13, topic_list_20$V14, topic_list_20$V15, sep = ",")
topic_list_20<- as.data.frame(topic_list_20)
colnames(topic_list_20)<- "Terms"
