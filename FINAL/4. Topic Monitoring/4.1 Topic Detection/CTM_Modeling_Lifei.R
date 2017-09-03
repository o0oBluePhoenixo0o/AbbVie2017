



# Correlated topic models
# There is an example in data folder "CTM30.RData"



# Install packages ################################################################################
# Use install.packages("package") to install packages which are needed in this program
install.packages("NLP")
install.packages("tm")
install.packages("RcolorBrewer")
install.packages("topicmodels")
install.packages("SnowballC")
install.packages("text2vec")
install.packages("stringr")
install.packages("textstem")


# Load relevant libraries
library(NLP)
library(tm)
library(RColorBrewer)
library(topicmodels)
library(SnowballC)
library(text2vec)
library(stringr)
library(textstem)



# Read in data that has already doing the pre-processing ##########################################
# Here, please use the dataset that finishing the balancing and pre-processing.
# Moreover, you can use the "CTM_training_set.csv" directly in our dataset folder.
# For testing the model, it is better to choose less data here because the modeling step will use about one hour.
df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")



# Creating vocabulary and document-term matrix ###################################################
# Change the data type to fit the doc-term matrid function
prepare_train_dtm <- unlist(as.data.frame(df$pre_message))


# Define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer


# Define preprocessing function and tokenization function
it_train <- itoken(as.character(prepare_train_dtm), 
                   preprocessor = prep_fun, 
                   tokenizer = tok_fun,
                   progressbar = TRUE)


# Creating vocabulary and document-term matrix
vocab_train <- create_vocabulary(it_train)
vectorizer_train <- vocab_vectorizer(vocab_train)
train_dtm <- create_dtm(it_train, vectorizer_train)


# Define tfidf model
tfidf <- TfIdf$new()
# Change the document term matrix as tf-idf matrix
train_dtm_tfidf <- fit_transform(train_dtm, tfidf)
# Change tf-idf matrix to fit the model
train_dtm_tfidf@x <- ceiling(train_dtm_tfidf@x)



# Modeling ######################################################################################
# If the best K is changed, you can change the k here.
k = 30


# Modeling
models <- list(
  CTM       = CTM(train_dtm_tfidf, k = k, 
                  control = list(estimate.beta = TRUE,
                                 verbose = 1,
                                 prefix = tempfile(),
                                 save = 0,
                                 keep = 0,
                                 seed = as.integer(Sys.time()), 
                                 nstart = 1L, 
                                 best = TRUE,
                                 var = list(iter.max = 50, tol = 10^-5), 
                                 em = list(iter.max = 100, tol = 10^-3),
                                 initialize = "random",
                                 cg = list(iter.max = 1000, tol = 10^-4)
                  )
  )
  #LDA       = LDA(dtm, k = k, control = list(seed = SEED))
  #VEM_Fixed = LDA(dtm, k = k, control = list(estimate.alpha = FALSE, seed = SEED)),
  #Gibbs     = LDA(dtm, k = k, method = "Gibbs", control = list(seed = SEED, burnin = 1000,
  #                                                            thin = 100,    iter = 1000)) 
)



# Write topics out ######################################################################################
# Write topics into data fram
m = 10 
topic_terms <- t(as.data.frame(lapply(models, terms, m)))
topic_names <- as.data.frame(rownames(topic_terms))
topic_fram <- t(as.data.frame(cbind(topic_names,topic_terms)))
topic_fram <- topic_fram[-1,]
colnames(topic_fram) <- c(1:k)


# Combine terms into 1 string for each topic
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


# View the topics herer
view(topic)


# !!!
# Save the enviroment here or just leave them in the workspace.
# Then we will use the model here on the training dataset to assign topics back to the whole dataset.



