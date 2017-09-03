



# CTM Pre-Processing 



# A large number steps are doing here: 
# Build the corpus for our data set
# To lower case
# Remove URLs
# Remove stopwords from corpus
# Remove anything other than English letters or space
# Remove extra whitespace
# Lemmantization
# Remove words which have less than 3 letters
# Use POS tagging to remove coordinating conjunction, cardinal number  and so on
# Change the data format




## Install packages #####################################################################################
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



# Load in data #######################################################################################
# Read in data from the whole table
#df <- attach(input[[1]])


# !!!!
# Read in data
# There are two datasets need to do the preprocessing
# Please choose the file "Final_TW_0807_prep.csv" in the dataset folder. 
# After pre-processing, this data set is used to assign topics back.
# Choose the dataset which is finishing balancing in the previous "3a.[R] balancing_Lifei.R" file.
# After pre-processing, this data set is used to do the CTM modeling.
df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")
df <- df[df$Language=="eng",]


# Select only "ID" "key" "created_time" and "message" colunms
df <- cbind(as.data.frame(df$Id),
            as.data.frame(df$key),
            as.data.frame(df$created_time),
            as.data.frame(df$message))


# Remove NA 
df <- na.omit(df)


# Change the colunms names
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


# Lemmantization
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


# Find words not useful---POS tagging #########################################################################
# Define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer


# Tokenization
it_pos <- itoken(as.character(myCorpus), 
                 preprocessor = prep_fun, 
                 tokenizer = tok_fun,
                 progressbar = TRUE)


# Build the vocabulary
v_pos <- create_vocabulary(it_pos)


# Define Pos taging function
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


# !!!
# Because package version issues, for some version, "v_pos$term" cannot be find.
# It is needed to figure out where is the "term" inside the "v_pos"
# Remove coordinating conjunction and cardinal number
conjunction_pos <- lapply(as.String(t(as.matrix(v_pos$term))), extractPOS, "C")
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



# Preprocessing final ######################################################################
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


# Remove NA again
preprocess_final <- na.omit(preprocess_remove_blank)


# Change the columns names
colnames(preprocess_final) <- c("id","key","created_time","message","pre_message")


# view "preprocess_final"
view(preprocess_final)


# Pre-processing final data frame
write.csv(preprocess_final,"preprocess_final.csv")






