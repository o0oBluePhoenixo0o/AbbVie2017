# CTM topic model 
source("./ML/R/needs.R")
# Install packages #####################################################################################
# Packages
needs(RJSONIO)
needs(NLP)
needs(tm)
needs(RColorBrewer)
needs(topicmodels)
needs(SnowballC)
needs(text2vec)
needs(stringr)
needs(jsonlite)
needs(textstem)
options(scipen = 999)
# Pre-Processing
# Load in data #######################################################################################
# Read in data from the whole table
#df <- attach(input[[1]])
#filename <- filepath # comes from JS
#filename
# Read in preprocess_df
#df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")
args = commandArgs(trailingOnly=TRUE)
df <- read.csv("./ML/R/topic/tweets.csv") #read.csv(args[1])

preprocess_df <- df$message

# Pre-processing #######################################################################################
# Build the corpus
# Build the corpus
myCorpus <- Corpus(VectorSource(preprocess_df))


# Convert to lower case
myCorpus <- tm_map(myCorpus,content_transformer(tolower))


# Remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeURL))


# Add extra stop words
myStopwords <- c(stopwords("SMART"),"rt","via","amp","aa","ra","im","ad","dr","dont","th","today","oz","tb",
                 "mit","der","von","ist","und","ein",
                 "abbv","abbvies","amgn","boris","bmy","bristolmyers","johnson","rheum","llc","inc"
                 #"abbvie","amgen","adalimumab","ankylosing","spondylitis",
                 #"bristol","myers","enbrel","hepatitis","humira","trilipix",
                 #"ibrutinib","imbruvica","johnson","psoriasis","rheumatoid","arthritis"
                 )
# Remove stopwords from corpus
myCorpus <- tm_map(myCorpus,removeWords,myStopwords)


# Remove anything other than English letters or space
removeNumPunct <-function(x) gsub("[^[:alpha:][:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeNumPunct))


# Remove extra whitespace
myCorpus <- tm_map(myCorpus,stripWhitespace)


# Stemming
lemma_dictionary <- make_lemma_dictionary(myCorpus$content, engine = 'hunspell')
for(i in 1:length(myCorpus))
{
  myCorpus$content[[i]] <- lemmatize_strings(myCorpus$content[[i]], dictionary = lemma_dictionary)
}


# Remove stopwords from corpus again
myCorpus <- tm_map(myCorpus,removeWords,myStopwords)


# Change list--"myCorpus" into data frame
preprocess_begining <- do.call(rbind, lapply(myCorpus, data.frame, stringsAsFactors=FALSE))


# Rename the column
colnames(preprocess_begining)<- c("pre_message")


# Change the data type after pre preprocessing to fit the doc-term matrix function ################
# Build the data frame after pre processing
preprocess_mid <- cbind(as.data.frame(df$id),
                        as.data.frame(df$created),
                        as.data.frame(df$message),
                        as.data.frame(preprocess_begining))

colnames(preprocess_mid) <- c("id", "created", "message", "pre_message")

# Remove null after pre processing
preprocess_remove_null <- preprocess_mid[preprocess_mid$pre_message!='',]


# Remove blank after pre processing
preprocess_remove_blank <- preprocess_remove_null[preprocess_remove_null$pre_message!=' ',]


# Change the data type to fit the doc-term matrid function
preprocess_final <- unlist(as.data.frame(preprocess_remove_blank$pre_message))


# Remove words which have less than 3 letters
#preprocess_f <- gsub('\\b\\w{1,3}\\b','',preprocess_f)


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



# Set values for parameters in the topic model #########################################
# Prepare for topic modeling






# Modeling ####################################################################################
# Modeling
k = 40



# Modeling ####################################################################################
# Modeling
models <- list(
  CTM       = CTM(dtm, k = k, 
                  control = list(estimate.beta = TRUE,
                                 verbose = 1,
                                 prefix = tempfile(),
                                 save = 0,
                                 keep =0,
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
m=10
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



# Assing topic to each tweet ######################################################################################
# Matrix of tweet assignments to predominate topic on that tweet for each of the models
assignments <- as.data.frame(sapply(models, topics))
assignments_change <- as.matrix(assignments)


# Sign each message a string topic
for(i in 1:length(preprocess_final))
{
  assignments_change[i,1] <- as.character(topic[(assignments_change[i,1]),1])
}



# Final result ######################################################################################
# Build the data fram for messages and topics
topicmodel <- cbind(as.data.frame(preprocess_remove_blank$id), 
                    as.data.frame(preprocess_remove_blank$created), 
                    as.data.frame(preprocess_remove_blank$message), 
                    as.data.frame(assignments),
                    as.data.frame(assignments_change))


# Change the columns name
colnames(topicmodel) <- c("id","created_time","message","topic_id","topic")


# Write out as Json
CTM_result <- toJSON(topicmodel)
CTM_result

