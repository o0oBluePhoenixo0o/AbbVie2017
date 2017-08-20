



# CTM topic model 




# Install packages #####################################################################################


# Packages
#needs(RJSONIO)
#needs(NLP)
##needs(tm)
#needs(olorBrewer)
#needs(topicmodels)
#needs(SnowballC)
#needs(text2vec)
#needs(stringr)


# Use install.packages("package") to install packages which are needed in this program
#install.packages("RJSONIO")
#install.packages("NLP")
#install.packages("tm")
#install.packages("RcolorBrewer")
#install.packages("topicmodels")
#install.packages("SnowballC")
#install.packages("text2vec")
#install.packages("stringr")
#install.packages("textstem")
#install.packages("openNLP")


# Load relevant libraries
library(RJSONIO)
library(NLP)
library(tm)
library(RColorBrewer)
library(topicmodels)
library(SnowballC)
library(text2vec)
library(stringr)
library(textstem)
library(openNLP)



# Load in data #######################################################################################
# Read in data from the whole table
#df <- attach(input[[1]])


# Read in preprocess_df
df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")


# Select english tweets only
df <- df[df$Language=="eng",]


# Select message to do the preprocessing
preprocess_df <- df$message



# Pre-processing #######################################################################################
# Build the corpus
myCorpus <- Corpus(VectorSource(preprocess_df))


# Convert to lower case
myCorpus <- tm_map(myCorpus,content_transformer(tolower))


# Remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeURL))


# Add extra stop words
myStopwords <- c(stopwords("SMART"),"via","aa","ra","dr","oz","ti","bb","gt","st","gj","la","ca","fc","mi",
                 "amp","rt","fe0f","href","th","ll","tb",
                 "im","ad","dont","lot","u","ur",
                 "mit","der","von","ist","und","ein","ich","auf","zu","den","nicht","bei","gut",
                 "day","year","time","today",
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


# Remove words which have less than 3 letters
removeWords <- function(x) gsub('\\b\\w{1,3}\\b','',x)
myCorpus <- tm_map(myCorpus,removeWords)


# Find verb
# Define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer


it_vocabulary <- itoken(as.character(myCorpus), 
                preprocessor = prep_fun, 
                tokenizer = tok_fun,
                progressbar = TRUE)


v <- create_vocabulary(it_vocabulary)%>%
  prune_vocabulary(term_count_min = 50, doc_proportion_min = 0.001)


# Pos taging function
extractPOS <- function(x, thisPOSregex) {
  x <- as.String(x)
  wordAnnotation <- annotate(x, list(Maxent_Sent_Token_Annotator(), Maxent_Word_Token_Annotator()))
  POSAnnotation <- annotate(x, Maxent_POS_Tag_Annotator(), wordAnnotation)
  POSwords <- subset(POSAnnotation, type == "word")
  tags <- sapply(POSwords$features, '[[', "POS")
  thisPOSindex <- grep(thisPOSregex, tags)
  tokenizedAndTagged <- sprintf("%s/%s", x[POSwords][thisPOSindex], tags[thisPOSindex])
  untokenizedAndTagged <- paste(tokenizedAndTagged, collapse = " ")
  untokenizedAndTagged
}


# Find word except noun, adjective and adverb
verb_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "VB")
conjunction_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "C")
determiner_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "DT")
foreigner_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "FW")
preposition_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "IN")
modal_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "MD")
partical_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "RP")
to_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "TO")
interjection_pos <- lapply(as.String(t(as.matrix(v$term))), extractPOS, "UH")
wh_pos <-lapply(as.String(t(as.matrix(v$term))), extractPOS, "W")


# Remove tag
verb <- unlist(str_extract_all(unlist(verb_pos), "\\w+(?=\\/)"))
conjunction <- unlist(str_extract_all(unlist(conjunction_pos), "\\w+(?=\\/)"))
determiner <- unlist(str_extract_all(unlist(determiner), "\\w+(?=\\/)"))
foreigner <- unlist(str_extract_all(unlist(foreigner_pos), "\\w+(?=\\/)"))
preposition <- unlist(str_extract_all(unlist(preposition_pos), "\\w+(?=\\/)"))
modal <- unlist(str_extract_all(unlist(modal_pos), "\\w+(?=\\/)"))
partical <- unlist(str_extract_all(unlist(partical_pos), "\\w+(?=\\/)"))
to <- unlist(str_extract_all(unlist(to_pos), "\\w+(?=\\/)"))
interjection <- unlist(str_extract_all(unlist(interjection), "\\w+(?=\\/)"))
wh <- unlist(str_extract_all(unlist(wh_pos), "\\w+(?=\\/)"))


# Remove except noun, adjective and adverb
myCorpus <- tm_map(myCorpus,removeWords,verb)
myCorpus <- tm_map(myCorpus,removeWords,conjunction)
myCorpus <- tm_map(myCorpus,removeWords,determiner)
myCorpus <- tm_map(myCorpus,removeWords,foreigner)
myCorpus <- tm_map(myCorpus,removeWords,preposition)
myCorpus <- tm_map(myCorpus,removeWords,modal)
myCorpus <- tm_map(myCorpus,removeWords,partical)
myCorpus <- tm_map(myCorpus,removeWords,to)
myCorpus <- tm_map(myCorpus,removeWords,interjection)
myCorpus <- tm_map(myCorpus,removeWords,wh)


# Remove extra whitespace
myCorpus <- tm_map(myCorpus,stripWhitespace)


# Change list--"myCorpus" into data frame
preprocess_begining <- do.call(rbind, lapply(myCorpus, data.frame, stringsAsFactors=FALSE))


# Rename the column
colnames(preprocess_begining)<- c("pre_message")


# Change the data type after pre preprocessing to fit the doc-term matrix function ##################
# Build the data frame after pre processing
preprocess_mid <- cbind(as.data.frame(df$Id),
                        as.data.frame(df$created_time),
                        as.data.frame(df$message),
                        as.data.frame(preprocess_begining))


# Remove null after pre processing
preprocess_remove_null <- preprocess_mid[preprocess_mid$pre_message!='',]


# Remove blank after pre processing
preprocess_remove_blank <- preprocess_remove_null[preprocess_remove_null$pre_message!=' ',]


# Change the data type to fit the doc-term matrid function
preprocess_final <- unlist(as.data.frame(preprocess_remove_blank$pre_message))


# Define preprocessing function and tokenization function
it_df <- itoken(as.character(preprocess_final), 
                preprocessor = prep_fun, 
                tokenizer = tok_fun,
                progressbar = TRUE)



# Creating vocabulary and document-term matrix #########################################
# Creating vocabulary and document-term matrix
vocab <- create_vocabulary(it_df)%>%
  prune_vocabulary(term_count_min = 50, doc_proportion_min = 0.001)
vectorizer <- vocab_vectorizer(vocab)
dtm <- create_dtm(it_df, vectorizer)



# Set values for parameters in the topic model #########################################
# Prepare for topic modeling
# TRying different K values 5,10,20,30,40,50,75,100
k = 40



# Modeling ####################################################################################
# Modeling
models <- list(
  CTM       = CTM(dtm, k = k, 
                  control = list(estimate.beta = TRUE,
                                 verbose = 1,
                                 prefix = tempfile(),
                                 save = 1,
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
topicmodel <- cbind(as.data.frame(preprocess_remove_blank$`df$Id`), 
                    as.data.frame(preprocess_remove_blank$`df$created_time`), 
                    as.data.frame(preprocess_remove_blank$`df$message`), 
                    as.data.frame(assignments),
                    assignments_change)


# Change the columns name
colnames(topicmodel) <- c("id","created_time","message","topic_id","topic")



# Write out as json ###################################################################################
# Function--write data frame as json
toJSONarray <- function(dtf){
  clnms <- colnames(dtf)
  
  name.value <- function(i){
    quote <- '';
    # If(class(dtf[, i])!='numeric'){
    if(class(dtf[, i])!='numeric' && class(dtf[, i])!= 'integer'){ 
      # Modified this line so integers are also not enclosed in quotes
      quote <- '"';
    }
    
    paste('"', i, '" : ', quote, dtf[,i], quote, sep='')
  }
  
  objs <- apply(sapply(clnms, name.value), 1, function(x){paste(x, collapse=', ')})
  objs <- paste('{', objs, '}')
  
  # Res <- paste('[', paste(objs, collapse=', '), ']')
  # Added newline for formatting output
  res <- paste('[', paste(objs, collapse=',\n'), ']') 
  
  return(res)
}


# Write out as Json
CTM_result <- toJSONarray(topicmodel)


