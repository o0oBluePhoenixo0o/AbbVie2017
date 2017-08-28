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

# Load in data #######################################################################################
args = commandArgs(trailingOnly=TRUE)
df <- read.csv("./ML/R/topic/tweets.csv") #read.csv(args[1])

df <- df[df$language=="eng",]


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
conjunction_pos <- lapply(as.String(t(as.matrix(v_pos$terms))), extractPOS, "C")
conjunction <- unlist(str_extract_all(unlist(conjunction_pos), "\\w+(?=\\/)"))
conjunction <- setdiff(conjunction,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                     "bristol","california","enbrel","hepatitis","humira",
                                     "ibrutinib","imbruvica","myers","psoriasis",
                                     "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,conjunction)


# Remove determiner
determiner_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "DT")
determiner <- unlist(str_extract_all(unlist(determiner_pos), "\\w+(?=\\/)"))
determiner <- setdiff(determiner,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                   "bristol","california","enbrel","hepatitis","humira",
                                   "ibrutinib","imbruvica","myers","psoriasis",
                                   "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,determiner)


# Remove existential there
existential_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "EX")
existential <- unlist(str_extract_all(unlist(existential_pos), "\\w+(?=\\/)"))
existential <- setdiff(existential,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                     "bristol","california","enbrel","hepatitis","humira",
                                     "ibrutinib","imbruvica","myers","psoriasis",
                                     "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,existential)


# Remove foreign words
foreigner_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "FW")
foreigner <- unlist(str_extract_all(unlist(foreigner_pos), "\\w+(?=\\/)"))
foreigner <- setdiff(foreigner,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                 "bristol","california","enbrel","hepatitis","humira",
                                 "ibrutinib","imbruvica","myers","psoriasis",
                                 "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,foreigner)


# Remove preposition or subordinating conjunction
preposition_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "IN")
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
listitem_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "LS")
listitem <- unlist(str_extract_all(unlist(listitem_pos), "\\w+(?=\\/)"))
listitem <- setdiff(listitem,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                               "bristol","california","enbrel","hepatitis","humira",
                               "ibrutinib","imbruvica","myers","psoriasis",
                               "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,listitem)


# Remove modal
modal_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "MD")
modal <- unlist(str_extract_all(unlist(modal_pos), "\\w+(?=\\/)"))
modal <- setdiff(modal,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                         "bristol","california","enbrel","hepatitis","humira",
                         "ibrutinib","imbruvica","myers","psoriasis",
                         "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,modal)


# Remove predeterminner
predeterminer_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "PDT")
predeterminer <- unlist(str_extract_all(unlist(predeterminer_pos), "\\w+(?=\\/)"))
predeterminer <- setdiff(predeterminer,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                         "bristol","california","enbrel","hepatitis","humira",
                                         "ibrutinib","imbruvica","myers","psoriasis",
                                         "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,predeterminer)


# Remove possessive ending
possessive_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "POS")
possessive <- unlist(str_extract_all(unlist(possessive_pos), "\\w+(?=\\/)"))
possessive <- setdiff(possessive,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                   "bristol","california","enbrel","hepatitis","humira",
                                   "ibrutinib","imbruvica","myers","psoriasis",
                                   "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,possessive)


# Remove personal pronoun and possessive pronoun
personal_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "PRP")
personal <- unlist(str_extract_all(unlist(personal_pos), "\\w+(?=\\/)"))
personal <- setdiff(personal,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                               "bristol","california","enbrel","hepatitis","humira",
                               "ibrutinib","imbruvica","myers","psoriasis",
                               "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,personal)


# Remove partical
partical_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "RP")
partical <- unlist(str_extract_all(unlist(partical_pos), "\\w+(?=\\/)"))
partical <-setdiff(partical,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                              "bristol","california","enbrel","hepatitis","humira",
                              "ibrutinib","imbruvica","myers","psoriasis",
                              "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,partical)


# Remove symbol
symbol_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "SYM")
symbol <- unlist(str_extract_all(unlist(symbol_pos), "\\w+(?=\\/)"))
symbol <- setdiff(symbol,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                           "bristol","california","enbrel","hepatitis","humira",
                           "ibrutinib","imbruvica","myers","psoriasis",
                           "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,symbol)

# Remove to
to_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "TO")
to <- unlist(str_extract_all(unlist(to_pos), "\\w+(?=\\/)"))
to <- setdiff(to,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                   "bristol","california","enbrel","hepatitis","humira",
                   "ibrutinib","imbruvica","myers","psoriasis",
                   "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,to)


# Remove interjection
interjection_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "UH")
interjection <- unlist(str_extract_all(unlist(interjection_pos), "\\w+(?=\\/)"))
interjection <-setdiff(interjection,c("abbv","abbvie","adalimumab","amgen","ankylosing","arthritis",
                                      "bristol","california","enbrel","hepatitis","humira",
                                      "ibrutinib","imbruvica","myers","psoriasis",
                                      "rheumatoid","spondylitis","trilipix"))
myCorpus <- tm_map(myCorpus,removeWords,interjection)


# Remove verb
verb_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "VB")
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
wh_pos <-lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "W")
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



# Sampling #############################################################
abbvie <- preprocess_final[preprocess_final$key=="abbvie",]
adalimumab <- preprocess_final[preprocess_final$key=="adalimumab",]
amgen <- preprocess_final[preprocess_final$key=="amgen",]
ankylosing <- preprocess_final[preprocess_final$key=="ankylosing spondylitis",]
#arthritis <- preprocess_final[preprocess_final$key=="arthritis",]
bristol <- preprocess_final[preprocess_final$key=="bristol myers",]
enbrel <- preprocess_final[preprocess_final$key=="enbrel",]
#hepatitis <- preprocess_final[preprocess_final$key=="hepatitis",]
hepatitisc <- preprocess_final[preprocess_final$key=="hepatitis c",]
humira <- preprocess_final[preprocess_final$key=="humira",]
ibrutinib <- preprocess_final[preprocess_final$key=="ibrutinib",]
imbruvica <- preprocess_final[preprocess_final$key=="imbruvica",]
psoriasis <- preprocess_final[preprocess_final$key=="psoriasis",]
rheumatoid <- preprocess_final[preprocess_final$key=="rheumatoid arthritis",]


count <- c(nrow(abbvie),
           nrow(adalimumab),
           nrow(amgen),
           nrow(ankylosing),
           #nrow(arthritis),
           nrow(bristol),
           nrow(enbrel),
           #nrow(hepatitis),
           nrow(hepatitisc),
           nrow(humira),
           nrow(ibrutinib),
           nrow(imbruvica),
           nrow(psoriasis),
           nrow(rheumatoid))


average <- ceiling((2*nrow(preprocess_final)/3)/length(count))


balance <- function(data,average)
{
  if(nrow(data) >= average)
  {
    data_sub <- data[sample(1:nrow(data), average),]
  }
  else if(nrow(data) == average)
  {
    data_sub <- data
  }
  else
  {
    data_sub <- data
    for(i in 1:(floor(average/nrow(data))-1))
    {
      data_sub <- rbind(data_sub, data)
      print(nrow(data_sub))
    }
    extral <- average-floor(average/nrow(data))*nrow(data)
    data_sub <- rbind(data_sub, data[sample(1:nrow(data),extral),])
  }
  return(data_sub)
}


abbvie_sub <- balance(abbvie, average)
adalimumab_sub <- balance(adalimumab, average)
amgen_sub <- balance(amgen, average)
ankylosing_sub <- balance(ankylosing, average)
#arthritis_sub <- balance(arthritis, average)
bristol_sub <- balance(bristol, average)
enbrel_sub <- balance(enbrel, average)
#hepatitis_sub <- balance(hepatitis, average)
hepatitisc_sub <- balance(hepatitisc, average)
humira_sub <- balance(humira, average)
ibrutinib_sub <- balance(ibrutinib, average)
imbruvica_sub <- balance(imbruvica, average)
psoriasis_sub <- balance(psoriasis, average)
rheumatoid_sub <- balance(rheumatoid, average)


training_set <- rbind(abbvie_sub,
                      adalimumab_sub,
                      amgen_sub,
                      ankylosing_sub,
                      #arthritis_sub,
                      bristol_sub,
                      enbrel_sub,
                      #hepatitis_sub,
                      hepatitisc_sub,
                      humira_sub,
                      ibrutinib_sub,
                      imbruvica_sub,
                      psoriasis_sub,
                      rheumatoid_sub)



# Creating vocabulary and document-term matrix ####################################################
# Change the data type to fit the doc-term matrid function
prepare_train_dtm <- unlist(as.data.frame(training_set$pre_message))


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
probability <- NULL
topic_id <- NULL


# Assign topic for the whole dataset
for(i in 1:nrow(preprocess_final))
{
  tweet <- as.character(preprocess_final$pre_message[i])
  dtm = itoken(tweet, tokenizer = word_tokenizer) %>% 
    create_dtm(vectorizer_train)
  assignments <- posterior(models$CTM,dtm)
  p <- apply(assignments$topics,1,max)
  t <- match(p,assignments$topics)
  probability <- c(probability,p)
  topic_id <- c(topic_id,t)
}


probability <- as.matrix(probability)
topic_id <- as.matrix(topic_id)


assignments_change <- topic_id
for(i in 1:nrow(preprocess_final))
{
  assignments_change[i,1] <- as.character(topic[(assignments_change[i,1]),1])
}



# Final result #######################################################################################
labeling_set <- cbind(as.data.frame(preprocess_final$id),
                      as.data.frame(preprocess_final$created_time),
                      as.data.frame(preprocess_final$message),
                      as.data.frame(topic_id),
                      assignments_change)


# Change the columns name
colnames(labeling_set) <- c("id","created_time","message","topic_id","topic")



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
CTM_result <- toJSONarray(labeling_set)
CTM_result



