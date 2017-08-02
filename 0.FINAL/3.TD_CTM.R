


######################################################################################
# Use install.packages("package") to install packages which are needed in this program
install.packages("NLP")
install.packages("tm")
install.packages("RcolorBrewer")
install.packages("topicmodels")
install.packages("SnowballC")
install.packages("text2vec")
install.packages("stringr")



# Load relevant libraries
library(NLP)
library(tm)
library(RColorBrewer)
library(topicmodels)
library(SnowballC)
library(text2vec)
library(stringr)



########################################################################################
#need the file that has been preprocessed already
#read in preprocess_df
df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")


# select re_message which has been pre_processed already
preprocess_df <- df$re_message




########################################################################################
#build the corpus
#myCorpus <- Corpus(VectorSource(preprocess_df))


#convert to lower case
#myCorpus <- tm_map(myCorpus,content_transformer(tolower))


#remove URLs
#removeURL <- function(x) gsub("http[^[:space:]]*","",x)
#myCorpus <- tm_map(myCorpus,content_transformer(removeURL))


#remove anything other than English letters or space
#removeNumPunct <-function(x) gsub("[^[:alpha:][:space:]]*","",x)
#myCorpus <- tm_map(myCorpus,content_transformer(removeNumPunct))


#add two extra stop words:"rt" and "via"
#myStopwords <- c(stopwords("SMART"),"rt","via")
#remove "r" and "big" from stopwords
#myStopwords <- setdiff(myStopwords,c("r","big"))
#remove stopwords from corpus
#myCorpus <- tm_map(myCorpus,removeWords,myStopwords)


#remove extra whitespace
#myCorpus <- tm_map(myCorpus,stripWhitespace)


# change list--"myCorpus" into data frame
#preprocess_file <- do.call(rbind, lapply(myCorpus, data.frame, stringsAsFactors=FALSE))
#a<-do.call(rbind,sapply(myCorpus, numeric))


#colnames(preprocess_file)<- c("pre_message")


#preprocess_f <- sapply(as.numeric(preprocess_file$pre_message))
#preprocess_final <- cbind(as.data.frame(df$id),
#                          as.data.frame(df$created_time),
#                          as.data.frame(df$message),
#                          as.data.frame(preprocess_file))


#preprocess_a <- preprocess_final[preprocess_final$pre_message!='',]
#preprocess_b <- preprocess_a[preprocess_a$pre_message!=' ',]


#file_model <- preprocess_b$pre_message


#for(i in 1:length(preprocess_file))
#{
#  if(length(preprocess_file[i,1])==1)
#  {
#    preprocess_file[i,1]<-'nothing'
#  }
#}



# loop for change list--"myCorpus" into data frame
# it takes time
#preprocess_file <- as.data.frame(matrix(NA,length(preprocess_df),1))
#for(i in 1:length(preprocess_df))
#{
#  preprocess_file[i,1] <- as.character(myCorpus[[i]][1])
#}


# change data type to fit the method
#preprocess_file <- as.character(preprocess_file)


#define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer


it_df <- itoken(as.character(preprocess_df), 
                preprocessor = prep_fun, 
                tokenizer = tok_fun,
                progressbar = TRUE)



#####################################################################################
# creating vocabulary and document-term matrix
vocab <- create_vocabulary(it_df)
vectorizer <- vocab_vectorizer(vocab)
dtm <- create_dtm(it_df, vectorizer)



#####################################################################################
# prepare for topic modeling


# Pick a random seed for replication
SEED = sample(1:1000000, 1)  
#  10 topics and 5 terms for each topic
k = 10
m = 10



######################################################################################
# Modeling
models <- list(
  CTM       = CTM(dtm, k = k, 
                  control = list(seed = SEED,
                                 var = list(tol = 10^-4), 
                                 em = list(tol = 10^-2)))
  #LDA       = LDA(dtm, k = k, control = list(seed = SEED))
  #VEM_Fixed = LDA(dtm, k = k, control = list(estimate.alpha = FALSE, seed = SEED)),
  #Gibbs     = LDA(dtm, k = k, method = "Gibbs", control = list(seed = SEED, burnin = 1000,
  #                                                            thin = 100,    iter = 1000)) 
)



#######################################################################################
# write topics into data fram
topic_terms <- t(as.data.frame(lapply(models, terms, m)))
topic_names <- as.data.frame(rownames(topic_terms))
topic_fram <- t(as.data.frame(cbind(topic_names,topic_terms)))
colnames(topic_fram) <- c(1:k)
for(i in 1:k)
{
  topic_fram[,i] <- as.String(as.matrix(topic_fram[,i]))
}
topic <- as.data.frame(topic_fram[1,])
for(i in 1:k)
{
  topic[i,1] <- as.character(topic[i,1])
}
colnames(topic) <- c("CTM.Topic")



#######################################################################################
# matrix of tweet assignments to predominate topic on that tweet for each of the models
assignments <- as.data.frame(sapply(models, topics))
assignments_change <- as.matrix(assignments)


# sign each message a string topic
for(i in 1:length(preprocess_df))
{
  assignments_change[i,1] <- as.character(topic[(assignments_change[i,1]),1])
}



#######################################################################################
# build the data fram for messages and topics
topicmodel <- cbind(as.data.frame(df$id), 
                    as.data.frame(df$created_time), 
                    as.data.frame(df$message), 
                    assignments_change)




#########################################################################################

