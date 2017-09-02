


# Install packages #####################################################################################
# Use install.packages("package") to install packages which are needed in this program
install.packages("NLP")
install.packages("tm")
install.packages("RcolorBrewer")
install.packages("topicmodels")
install.packages("SnowballC")
install.packages("text2vec")
install.packages("stringr")
install.packages("textstem")
install.packages("openNLP")
install.packages("koRpus")


# Load relevant libraries
library(NLP)
library(tm)
library(RColorBrewer)
library(topicmodels)
library(SnowballC)
library(text2vec)
library(stringr)
library(textstem)
library(openNLP)
library(koRpus)



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



