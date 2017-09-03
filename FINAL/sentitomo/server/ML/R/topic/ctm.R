# CTM topic model 
source("./ML/R/needs.R")
dyn.load('/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/server/libjvm.dylib')
Sys.setenv(JAVA_HOME = '/Library/Java//Home')
Sys.setenv(LD_LIBRARY_PATH = '$LD_LIBRARY_PATH:$JAVA_HOME/lib')
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
needs(openNLP)
options(scipen = 999)



# Load in data #######################################################################################
args = commandArgs(trailingOnly=TRUE)
df <- read.csv("./ML/R/topic/tweets.csv") #read.csv(args[1])

df <- df[df$language=="en",]


df <- cbind(as.data.frame(df$id),
            as.data.frame(df$keyword),
            as.data.frame(df$created),
            as.data.frame(df$message))
df <- na.omit(df)
colnames(df) <- c("id","key","created_time","message")



# Pre-processing #######################################################################################
# Build the corpus
myCorpus <- Corpus(VectorSource(df$message))


# Convert to lower case
myCorpus <- tm_map(myCorpus,content_transformer(tolower))


# Remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*","",x)
myCorpus <- tm_map(myCorpus,content_transformer(removeURL))


# Add extra stop words
myStopwords <- c(stopwords("SMART"),"via","amp","rt","fe0f","href","th","ll","tb",
                 "dont","day","year","time","today","cant",
                 "llc","inc"
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
removeShortWords <- function(x) gsub('\\b\\w{1,3}\\b','',x)
myCorpus <- tm_map(myCorpus,content_transformer(removeShortWords))


# Find words not useful
# Define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer


it_pos <- itoken(as.character(myCorpus), 
                 preprocessor = prep_fun, 
                 tokenizer = tok_fun,
                 progressbar = TRUE)
v_pos <- create_vocabulary(it_pos)

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


# Remove coordinating conjunction and cardinal number
conjunction_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "C")
conjunction <- unlist(str_extract_all(unlist(conjunction_pos), "\\w+(?=\\/)"))
conjunction <- setdiff(conjunction,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                     "bristol","california","enbrel","hepatitis","humira",
                                     "ibrutinib","imbruvica","myers","psoriasis",
                                     "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,conjunction)


# Remove determiner
determiner_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "DT")
determiner <- unlist(str_extract_all(unlist(determiner_pos), "\\w+(?=\\/)"))
determiner <- setdiff(determiner,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                   "bristol","california","enbrel","hepatitis","humira",
                                   "ibrutinib","imbruvica","myers","psoriasis",
                                   "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,determiner)


# Remove existential there
existential_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "EX")
existential <- unlist(str_extract_all(unlist(existential_pos), "\\w+(?=\\/)"))
existential <- setdiff(existential,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                     "bristol","california","enbrel","hepatitis","humira",
                                     "ibrutinib","imbruvica","myers","psoriasis",
                                     "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,existential)


# Remove foreign words
foreigner_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "FW")
foreigner <- unlist(str_extract_all(unlist(foreigner_pos), "\\w+(?=\\/)"))
foreigner <- setdiff(foreigner,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                 "bristol","california","enbrel","hepatitis","humira",
                                 "ibrutinib","imbruvica","myers","psoriasis",
                                 "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,foreigner)


# Remove preposition or subordinating conjunction
preposition_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "IN")
preposition <- unlist(str_extract_all(unlist(preposition_pos), "\\w+(?=\\/)"))
preposition <- setdiff(preposition,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                     "bristol","california","enbrel","hepatitis","humira",
                                     "ibrutinib","imbruvica","myers","psoriasis",
                                     "rheumatoid","spondylitis","trilipix"))
for(i in 1:ceiling(length(preposition)/1000))
{
  if(i!=ceiling(length(preposition)/1000))
  {
    sub_preposition <- preposition[((i-1)*1000+1):i*1000]
    myCorpus <- tm_map(myCorpus,removeWords,sub_preposition)
  }
  else
  {
    sub_preposition <- preposition[((i-1)*1000+1):length(preposition)]
    myCorpus <- tm_map(myCorpus,removeWords,sub_preposition)
  }
}


# Remove list item marker
listitem_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "LS")
listitem <- unlist(str_extract_all(unlist(listitem_pos), "\\w+(?=\\/)"))
listitem <- setdiff(listitem,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                               "bristol","california","enbrel","hepatitis","humira",
                               "ibrutinib","imbruvica","myers","psoriasis",
                               "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,listitem)


# Remove modal
modal_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "MD")
modal <- unlist(str_extract_all(unlist(modal_pos), "\\w+(?=\\/)"))
modal <- setdiff(modal,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                         "bristol","california","enbrel","hepatitis","humira",
                         "ibrutinib","imbruvica","myers","psoriasis",
                         "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,modal)


# Remove predeterminner
predeterminer_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "PDT")
predeterminer <- unlist(str_extract_all(unlist(predeterminer_pos), "\\w+(?=\\/)"))
predeterminer <- setdiff(predeterminer,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                         "bristol","california","enbrel","hepatitis","humira",
                                         "ibrutinib","imbruvica","myers","psoriasis",
                                         "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,predeterminer)


# Remove possessive ending
possessive_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "POS")
possessive <- unlist(str_extract_all(unlist(possessive_pos), "\\w+(?=\\/)"))
possessive <- setdiff(possessive,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                   "bristol","california","enbrel","hepatitis","humira",
                                   "ibrutinib","imbruvica","myers","psoriasis",
                                   "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,possessive)


# Remove personal pronoun and possessive pronoun
personal_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "PRP")
personal <- unlist(str_extract_all(unlist(personal_pos), "\\w+(?=\\/)"))
personal <- setdiff(personal,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                               "bristol","california","enbrel","hepatitis","humira",
                               "ibrutinib","imbruvica","myers","psoriasis",
                               "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,personal)


# Remove partical
partical_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "RP")
partical <- unlist(str_extract_all(unlist(partical_pos), "\\w+(?=\\/)"))
partical <-setdiff(partical,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                              "bristol","california","enbrel","hepatitis","humira",
                              "ibrutinib","imbruvica","myers","psoriasis",
                              "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,partical)


# Remove symbol
symbol_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "SYM")
symbol <- unlist(str_extract_all(unlist(symbol_pos), "\\w+(?=\\/)"))
symbol <- setdiff(symbol,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                           "bristol","california","enbrel","hepatitis","humira",
                           "ibrutinib","imbruvica","myers","psoriasis",
                           "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,symbol)

# Remove to
to_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "TO")
to <- unlist(str_extract_all(unlist(to_pos), "\\w+(?=\\/)"))
to <- setdiff(to,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                   "bristol","california","enbrel","hepatitis","humira",
                   "ibrutinib","imbruvica","myers","psoriasis",
                   "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,to)


# Remove interjection
interjection_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "UH")
interjection <- unlist(str_extract_all(unlist(interjection_pos), "\\w+(?=\\/)"))
interjection <-setdiff(interjection,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                      "bristol","california","enbrel","hepatitis","humira",
                                      "ibrutinib","imbruvica","myers","psoriasis",
                                      "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,interjection)


# Remove verb
verb_pos <- lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "VB")
verb <- unlist(str_extract_all(unlist(verb_pos), "\\w+(?=\\/)"))
verb <- setdiff(verb,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                       "bristol","california","enbrel","hepatitis","humira",
                       "ibrutinib","imbruvica","myers","psoriasis",
                       "rheumatoid","spondylitis","trilipix"))

for(i in 1:ceiling(length(verb)/1000))
{
  if(i!=ceiling(length(verb)/1000))
  {
    sub_verb <- verb[((i-1)*1000+1):i*1000]
    myCorpus <- tm_map(myCorpus,removeWords,sub_verb)
  }
  else
  {
    sub_verb <- verb[((i-1)*1000+1):length(verb)]
    myCorpus <- tm_map(myCorpus,removeWords,sub_verb)
  }
}


# Remove wh-determiner, wh-pronoun, possessive wh-pronoun and wh-adverb
wh_pos <-lapply(as.String(t(as.matrix(v_pos$vocab$terms))), extractPOS, "W")
wh <- unlist(str_extract_all(unlist(wh_pos), "\\w+(?=\\/)"))
wh <- setdiff(wh,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                   "bristol","california","enbrel","hepatitis","humira",
                   "ibrutinib","imbruvica","myers","psoriasis",
                   "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,wh)


# Remove extra whitespace
myCorpus <- tm_map(myCorpus,stripWhitespace)


# Change list--"myCorpus" into data frame
preprocess_begining <- do.call(rbind, lapply(myCorpus, data.frame, stringsAsFactors=FALSE))


# Rename the column
colnames(preprocess_begining)<- c("pre_message")


# Build the data frame after pre processing
preprocess_mid <- cbind(as.data.frame(df$id),
                        as.data.frame(df$key),
                        as.data.frame(df$created_time),
                        as.data.frame(df$message),
                        as.data.frame(preprocess_begining))


# Remove null after pre processing
preprocess_remove_null <- preprocess_mid[preprocess_mid$pre_message!='',]


# Remove blank after pre processing
preprocess_remove_blank <- preprocess_remove_null[preprocess_remove_null$pre_message!=' ',]
preprocess_remove_blank <- preprocess_remove_blank[preprocess_remove_blank$pre_message!='  ',]
preprocess_remove_blank <- preprocess_remove_blank[preprocess_remove_blank$pre_message!='   ',]
preprocess_remove_blank <- preprocess_remove_blank[preprocess_remove_blank$pre_message!='    ',]


# Pre-processing final data frame
preprocess_final <- na.omit(preprocess_remove_blank)
colnames(preprocess_final) <- c("id","key","created_time","message","pre_message")
#write.csv(preprocess_final,"preprocess_final.csv")


# Creating vocabulary and document-term matrix ####################################################
# Change the data type to fit the doc-term matrix function
prepare_train_dtm <- unlist(as.data.frame(preprocess_final$pre_message))


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
# Modeling
k = 30
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
topicmodel <- cbind(as.data.frame(preprocess_final$id), 
                    as.data.frame(preprocess_final$created), 
                    as.data.frame(preprocess_final$message), 
                    as.data.frame(assignments),
                    as.data.frame(assignments_change))


# Change the columns name
colnames(topicmodel) <- c("id","created_time","message","topic_id","topic")


# Write out as Json
CTM_result <- toJSON(topicmodel)
CTM_result
