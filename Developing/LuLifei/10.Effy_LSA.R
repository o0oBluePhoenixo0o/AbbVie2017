



# LSA topic model 




# Install packages #####################################################################################
install.packages("RJSONIO")
install.packages("NLP")
install.packages("tm")
install.packages("RcolorBrewer")
install.packages("topicmodels")
install.packages("SnowballC")
install.packages("text2vec")
install.packages("stringr")
install.packages("textstem")
install.packages("scatterplot3d")


library(NLP)
library(tm)
library(RColorBrewer)
library(topicmodels)
library(SnowballC)
library(text2vec)
library(stringr)
library(textstem)
library(ggplot2)
library(scatterplot3d)



# Load in data #######################################################################################
# Read in data
# Here, please use the dataset that finishing the balancing and pre-processing.
# Moreover, you can use the "CTM_preprocess_final.csv" directly in our dataset folder.
# For testing the model, it is better to choose less data here.
df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")


# Change the data type to fit the doc-term matrid function
preprocess_final <- unlist(as.data.frame(df$pre_message))


# Define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer


it_df <- itoken(as.character(preprocess_final), 
                preprocessor = prep_fun, 
                tokenizer = tok_fun,
                progressbar = TRUE)



# Creating vocabulary and document-term matrix #########################################
# Creating vocabulary and document-term matrix
vocab <- create_vocabulary(it_df)
vectorizer <- vocab_vectorizer(vocab)
dtm <- create_dtm(it_df, vectorizer)



# LSA Modeling ########################################################################
# Perform tf-idf scaling and fit LSA mode
tfidf = TfIdf$new()
lsa = LSA$new(n_topics = 10)


# Pipe friendly transformation
doc_embeddings = dtm %>% 
  fit_transform(tfidf) %>% 
  fit_transform(lsa)


# Have a look at the result
View(doc_embeddings)



