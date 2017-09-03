




# CTM K selection



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
# For testing the model, it is better to choose less data here because the selection K takes lot of time.
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



# Find best value for k ################################################################
# Function for find the best k vaule
bestK <- function(ap_dtm = dtm)
{
  perplexity_CTM = NULL
  for(i in 1:10)
  {
    models <- list(
      ap_CTM       = CTM(ap_dtm, k = 10*i, 
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
    perplexity_CTM <- c(perplexity_CTM, perplexity(models))
  }
  return(perplexity_CTM)
}


# Apply function
k_perplexity <- bestK(train_dtm_tfidf)


# Show all perplexity for each K here
k_perplexity



# Set values for parameters in the topic model #########################################
# Prepare for topic modeling


# Find the k that can achieve the smallest perplexity
k = which.min(k_perplexity)


# The best K
k



