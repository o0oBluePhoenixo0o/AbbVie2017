
######################### Construct DTM matrix ##########################################
url <- "http://cran.us.r-project.org/src/contrib/Archive/cldr/cldr_1.1.0.tar.gz"
pkgFile<-"cldr_1.1.0.tar.gz"
download.file(url = url, destfile = pkgFile)
install.packages(pkgs=pkgFile, type = "source", repos = NULL)
unlink(pkgFile)

install.packages("textstem")
install.packages("anytime")

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
library(textstem)
library(anytime)
library(stats)
library(translateR)
library(plyr)
library(zoo)
library(reshape2)
library(ggplot2)

#read file by navigation
ChooeseFile<- read.csv(file.choose(),encoding = "UTF-8")
Final_TW_1806<- ChooeseFile

#####Data preprocessing

###get key, tweets, time of TW dataset
Final_TW_Tweets<- Final_TW_1806[c(1,9,2)]
Final_TW_Tweets<- data.frame(na.omit(Final_TW_Tweets))
colnames(Final_TW_Tweets)<- c("key", "Text","time")

#remove non-english posts
Final_TW_Tweets_lag<- detectLanguage(Final_TW_Tweets[[2]])
Final_TW_Tweets<- cbind(Final_TW_Tweets,Final_TW_Tweets_lag)
Final_TW_Tweets<- subset(Final_TW_Tweets,detectedLanguage=="ENGLISH")[c(1,2,3)]

#subset 
Final_TW_Company<- subset(Final_TW_Tweets, key=="abbvie"|key=="amgen"|key=="bristol myers"|key=="johnson & johnson")
Final_TW_Disease<- subset(Final_TW_Tweets, key=="ankylosing spondylitis"|key=="hepatitis c"|key=="psoriasis"|key=="rheumatoid arthritis"|key=="juvenileidiopathicarthritis"|key=="juvenilerheumatoidarthritis"|key=="jia")
Final_TW_Product<- subset(Final_TW_Tweets,key=="adalimumab"|key=="enbrel"|key=="humira"|key=="imbruvica"|key=="ibrutinib"|key=="trilipix")

#construct Document terms matrix
constructDTM<- function(Final_Dataset)
{
  
  doc.corpus<- Corpus(VectorSource(lemmatize_strings(Final_Dataset$Text)))
  
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
  
  #create binaryweight dtm
  dtm_dataset_binaryweight<- weightBin(dtm_dataset)
  
  #create TFidfweight dtm
  #dtm_dataset_tfidf<- weightTfIdf(dtm_dataset)
  
  rowTotals <- apply(dtm_dataset_binaryweight , 1, sum) #Find the sum of words in each Document
  dtm_dataset_binaryweight.new<- dtm_dataset_binaryweight[rowTotals> 3, ]   
  
  #remove terms which appear in less 300 posts
  colTotals<- apply(dtm_dataset_binaryweight.new,2,sum)
  dtm_dataset_binaryweight.final<- dtm_dataset_binaryweight.new[,colTotals>300]
  
  return(dtm_dataset_binaryweight.final)
  #return(dtm_dataset_tfidf)
}

dtm_dataset_binaryweight_product<- constructDTM(Final_TW_Product)



############################### RBM Model  ############################################

install.packages("prob")
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
  
  ###the followling 4 rows helps to add terms as dimension names, 
  ###but if the dimension names is changed to terms, it can not be directly applied in the weights visualization part
  #terms<- as.matrix(dimnames(training_data)[1])
  #terms<- as.matrix(unlist(terms))
  #terms<- t(terms)
  #colnames(model)<- terms
  
  return(model)
  
}

#extract weight matrix from DTM
weightMatrix<- as.data.frame(t(as.matrix(dtm_dataset_binaryweight_product)))
weightMatrix<- as.matrix(weightMatrix)

#topic number = 10
weightsBinary_Product_10<- rbm(num_hidden=10, training_data=weightMatrix, learning_rate=.09, n_iterations=5000,
            mini_batch_size=213, momentum=0.9)
weightsBinary_Product_10_T<- t(weightsBinary_Product_10)

#visualization of weights
library(ggplot2)
library(reshape2)
mw=melt(weightsBinary_Product_10_model); mw$Var3=floor((mw$Var2 - 1)/33)+1; mw$Var2=(mw$Var2-1)%%33 + 1; mw$Var3=33-mw$Var3;
ggplot(data=mw)+geom_tile(aes(Var2,Var3,fill=value))+facet_wrap(~Var1,nrow=100)+
  scale_fill_continuous(low='white',high='red')+coord_equal()+
  labs(x=NULL,y=NULL,title="Visualization of Weights K=10")+
  theme(legend.position="none")

