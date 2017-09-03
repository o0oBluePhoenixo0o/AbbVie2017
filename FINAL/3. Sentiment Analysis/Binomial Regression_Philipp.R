
# - Binomial Regression model using the 1.6 million tweets set from the Standford NLP program
# - Testing with the final manual label dataset

# # install packages
# install.packages("tidyverse")
# install.packages("text2vec")
# install.packages("caret")
# install.packages("glmnet")
# install.packages("ggrepel")

# loading packages
library(tidyverse)
library(text2vec)
library(caret)
library(glmnet)
library(ggrepel)


### loading and preprocessing a training set of tweets
# function for converting some symbols
conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")

##### loading classified tweets ######
# source: http://help.sentiment140.com/for-students/
# 0 - the polarity of the tweet (0 = negative, 4 = positive)
# 1 - the id of the tweet
# 2 - the date of the tweet
# 3 - the query. If there is no query, then this value is NO_QUERY.
# 4 - the user that tweeted
# 5 - the text of the tweet

# Use the file "5.Dataset/training.1600000.processed.noemoticon.csv"
tweets_classified <- read_csv(file.choose(),
                              col_names = c('sentiment', 'id', 'date', 'query', 'user', 'text')) %>%
  # converting some symbols
  dmap_at('text', conv_fun) %>%
  # replacing class values
  mutate(sentiment = ifelse(sentiment == 0, 0, 1))

# there are some tweets with NA ids that we replace with dummies
tweets_classified_na <- tweets_classified %>%
  filter(is.na(id) == TRUE) %>%
  mutate(id = c(1:n()))
tweets_classified <- tweets_classified %>%
  filter(!is.na(id)) %>%
  rbind(., tweets_classified_na)

#convert to lower case / remove URLs

# Clean text

clean <- function (sentence){
  #convert to lower-case 
  sentence <- tolower(sentence)
  removeURL <- function(x) gsub('"(http.*) |(https.*) |(http.*)$|\n', "", x)
  sentence <- removeURL(sentence)
}
tweets_classified$text <- sapply(tweets_classified$text, function(x) clean(x))

# data splitting on train and test
set.seed(2340)
trainIndex <- createDataPartition(tweets_classified$sentiment, p = 0.8, 
                                  list = FALSE, 
                                  times = 1)
tweets_train <- tweets_classified[trainIndex, ]
tweets_test <- tweets_classified[-trainIndex, ]

##### doc2vec #####
# define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer
  
it_train <- itoken(tweets_train$text, 
                   preprocessor = prep_fun, 
                   tokenizer = tok_fun,
                   ids = tweets_train$id,
                   progressbar = TRUE)
it_test <- itoken(tweets_test$text, 
                  preprocessor = prep_fun, 
                  tokenizer = tok_fun,
                  ids = tweets_test$id,
                  progressbar = TRUE)

#####################################################################################
# creating vocabulary and document-term matrix
vocab <- create_vocabulary(it_train)
vectorizer <- vocab_vectorizer(vocab)
dtm_train <- create_dtm(it_train, vectorizer)
dtm_test <- create_dtm(it_test, vectorizer)

# define tf-idf model
tfidf <- TfIdf$new()

# fit the model to the train data and transform it with the fitted model
dtm_train_tfidf <- fit_transform(dtm_train, tfidf)
dtm_test_tfidf <- fit_transform(dtm_test, tfidf)

# train the model
# t1 <- Sys.time()
# t1
# glmnet_classifier <- cv.glmnet(x = dtm_train_tfidf,
#                                y = tweets_train[['sentiment']],
#                                family = 'binomial',
#                                # L1 penalty
#                                alpha = 1,
#                                # interested in the area under ROC curve
#                                type.measure = "auc",
#                                # 5-fold cross-validation
#                                nfolds = 5,
#                                # high value is less accurate, but has faster training (def: 1e-3)
#                                thresh = 1e-5,
#                                # again lower number of iterations for faster training (def: 1e3)
#                                maxit = 1e4)
# print(difftime(Sys.time(), t1, units = 'mins'))

# plot(glmnet_classifier)
# print(paste("max AUC =", round(max(glmnet_classifier$cvm), 4)))
#
# preds <- predict(glmnet_classifier, dtm_test_tfidf, type = 'response')[ ,1]
# auc(as.numeric(tweets_test$sentiment), preds)
# 
# # save the model for future using
# saveRDS(glmnet_classifier, paste(Sys.Date(),'_glmnet_classifier.RDS'))

###############################################################

Doc2Vec <- function (txt, dataset, folder)
{
  temp <- subset(dataset, dataset$key == txt)
  
  # loading classification model (87.5%)
  glmnet_classifier <- readRDS('./input_data/0204_glmnet_classifier.RDS')
  
  if (nrow(temp)>=1){
    # converting some symbols
    dmap_at(temp,'message', conv_fun)
    
    # tokenization
    it_txt <- itoken(temp$message,
                     preprocessor = prep_fun,
                     tokenizer = tok_fun,
                     ids = temp$id,
                     progressbar = TRUE)
    
    # creating vocabulary and document-term matrix
    dtm_txt <- create_dtm(it_txt, vectorizer)
    
    # transforming data with tf-idf
    dtm_txt_tfidf <- fit_transform(dtm_txt, tfidf)
    
    # predict probabilities of positiveness
    preds_txt <- predict(glmnet_classifier, dtm_txt_tfidf, type = 'response')[ ,1]
    
    # adding rates to initial dataset
    temp$sentiment <- preds_txt
    
    # color palette
    cols <- c("#ce472e", "#f05336", "#ffd73e", "#eec73a", "#4ab04a")
    
    set.seed(932)
    samp_ind <- sample(c(1:nrow(temp)), nrow(temp) * 0.1) # 10% for labeling
    
    # plotting
    ggplot(temp, aes(x = created_time, y = sentiment, color = sentiment)) +
      theme_minimal() +
      scale_color_gradientn(colors = cols, limits = c(0, 1),
                            breaks = seq(0, 1, by = 1/4),
                            labels = c("0", round(1/4*1, 1), round(1/4*2, 1), round(1/4*3, 1), round(1/4*4, 1)),
                            guide = guide_colourbar(ticks = T, nbin = 50, barheight = .5, label = T, barwidth = 10)) +
      geom_point(aes(color = sentiment), alpha = 0.8) +
      geom_hline(yintercept = 0.65, color = "#4ab04a", size = 1.5, alpha = 0.6, linetype = "longdash") +
      geom_hline(yintercept = 0.35, color = "#f05336", size = 1.5, alpha = 0.6, linetype = "longdash") +
      geom_smooth(size = 1.2, alpha = 0.2) +
      geom_label_repel(data = temp[samp_ind, ],
                       aes(label = round(sentiment, 2)),
                       fontface = 'bold',
                       size = 2.5,
                       max.iter = 100) +
      theme(legend.position = 'bottom',
            legend.direction = "horizontal",
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.title = element_text(size = 20, face = "bold", vjust = 2, color = 'black', lineheight = 0.8),
            axis.title.x = element_text(size = 16),
            axis.title.y = element_text(size = 16),
            axis.text.y = element_text(size = 8, face = "bold", color = 'black'),
            axis.text.x = element_text(size = 8, face = "bold", color = 'black')) +
      ggtitle(paste('Sentiment rate ',txt))
    
    ggsave(file= paste0('SA_Doc2Vec/',folder,'/',txt,'_plot.jpeg'))
    
    #Extract examples for top negative and positive observations
    top_pos <- head(plyr::arrange(subset(temp,select = c(message,sentiment)),desc(sentiment)),n = 20)
    top_neg <-  head(plyr::arrange(subset(temp,select = c(message,sentiment)),sentiment),n = 20)
    examples <-rbind('Positive',top_pos,'Negative',top_neg)
    
    #Write down examples to a csv file
    write.csv2(examples,file = paste0('SA_Doc2Vec/',folder,'/',txt,'_examples.csv'))
  }
}

#################
keywords <- c("abbvie","bristol myers", "johnson & johnson","amgen",
              "enbrel","hepatisis c","psoriasis","ankylosing spondylitis","rheumatoid arthritis",
              "inbrutinib","humira","trilipix","imbruvica")

Apply.Doc2Vec <- function(keywords, dataset){
  folder <- ""
  if (deparse(substitute(dataset)) == 'postdf'){folder <- "FB_post"}
  if (deparse(substitute(dataset)) == 'commentdf'){folder <- "FB_comment"}
  if (deparse(substitute(dataset)) == 'TW_T'){folder <- "TW_tweets"}
  if (deparse(substitute(dataset)) == 'TW_RT'){folder <- "TW_RT"}
  
  for (i in 1:length(keywords)){
    Doc2Vec(keywords[i],dataset,folder)
  }
}


Apply.Doc2Vec(keywords,TW_T)
Apply.Doc2Vec(keywords,TW_RT)

Apply.Doc2Vec(keywords,postdf)
Apply.Doc2Vec(keywords,commentdf)


#########################################
library(memisc)

# function for converting some symbols
conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")

# Use the file "5.Dataset/Final_Manual_3007.csv"
testdf <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",", stringsAsFactors = F)

testdf$sentiment <- sapply(testdf$sentiment, function(x)
  x = cases (x %in% c(1,2) -> 'Negative',
             x %in% c(3,4) -> 'Positive',
             x == 'N' -> 'Neutral'))

testdf <- testdf[, which(names(testdf) %in% c("message","Id","sentiment"))]
# converting some symbols
testdf$message <- sapply(testdf$message, function(x) conv_fun(x))

#####################################################################
# loading packages
library(tidyverse)
library(text2vec)
library(caret)
library(glmnet)
library(ggrepel)

### loading and preprocessing a training set of tweets
# function for converting some symbols
conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")

##### loading classified tweets ######
# source: http://help.sentiment140.com/for-students/
# 0 - the polarity of the tweet (0 = negative, 4 = positive)
# 1 - the id of the tweet
# 2 - the date of the tweet
# 3 - the query. If there is no query, then this value is NO_QUERY.
# 4 - the user that tweeted
# 5 - the text of the tweet

tweets_classified <- read_csv('trainingandtestdata/training.1600000.processed.noemoticon.csv',
                              col_names = c('sentiment', 'id', 'date', 'query', 'user', 'text')) %>%
  # converting some symbols
  dmap_at('text', conv_fun) %>%
  # replacing class values
  mutate(sentiment = ifelse(sentiment == 0, 0, 1))

# there are some tweets with NA ids that we replace with dummies
tweets_classified_na <- tweets_classified %>%
  filter(is.na(id) == TRUE) %>%
  mutate(id = c(1:n()))
tweets_classified <- tweets_classified %>%
  filter(!is.na(id)) %>%
  rbind(., tweets_classified_na)

# data splitting on train and test
set.seed(2340)
trainIndex <- createDataPartition(tweets_classified$sentiment, p = 0.8, 
                                  list = FALSE, 
                                  times = 1)
tweets_train <- tweets_classified[trainIndex, ]
tweets_test <- tweets_classified[-trainIndex, ]

##### doc2vec #####
# define preprocessing function and tokenization function
prep_fun <- tolower
tok_fun <- text2vec::word_tokenizer

it_train <- itoken(tweets_train$text, 
                   preprocessor = prep_fun, 
                   tokenizer = tok_fun,
                   ids = tweets_train$id,
                   progressbar = TRUE)
it_test <- itoken(tweets_test$text, 
                  preprocessor = prep_fun, 
                  tokenizer = tok_fun,
                  ids = tweets_test$id,
                  progressbar = TRUE)

#####################################################################################

# creating vocabulary and document-term matrix
vocab <- create_vocabulary(it_train)
vectorizer <- vocab_vectorizer(vocab)
dtm_train <- create_dtm(it_train, vectorizer)
dtm_test <- create_dtm(it_test, vectorizer)

# define tf-idf model
tfidf <- TfIdf$new()

# fit the model to the train data and transform it with the fitted model
dtm_train_tfidf <- fit_transform(dtm_train, tfidf)
dtm_test_tfidf <- fit_transform(dtm_test, tfidf)

#############################################################
### Apply model on test dataset

# loading classification model (87.5%)
glmnet_classifier <- readRDS('Models/0204_glmnet_classifier.RDS')

# tokenization
it_txt <- itoken(testdf$message,
                 preprocessor = prep_fun,
                 tokenizer = tok_fun,
                 ids = testdf$id,
                 progressbar = TRUE)

# creating vocabulary and document-term matrix
dtm_txt <- create_dtm(it_txt, vectorizer)

# transforming data with tf-idf
dtm_txt_tfidf <- fit_transform(dtm_txt, tfidf)

# predict probabilities of positiveness
preds_txt <- predict(glmnet_classifier, dtm_txt_tfidf, type = 'response')[ ,1]

# adding rates to initial dataset
testdf$preds_txt <- preds_txt
testdf$sentiment_result <- cases(preds_txt >=0.65 -> 'Positive',
                                 preds_txt >=0.35 -> 'Neutral',
                                 preds_txt < 0.35 -> 'Negative',
                                 check.xor = FALSE)

################################################################
#Calculating confusion matrix
a <- testdf$sentiment
b <- testdf$sentiment_result

cm <- caret::confusionMatrix(a,b)$table
cm
n = sum(cm) # number of instances
nc = nrow(cm) # number of classes
diag = diag(cm) # number of correctly classified instances per class 
rowsums = apply(cm, 1, sum) # number of instances per class
colsums = apply(cm, 2, sum) # number of predictions per class
p = rowsums / n # distribution of instances over the actual classes
q = colsums / n # distribution of instances over the predicted classes

#Accuracy
accuracy = sum(diag) / n
accuracy
#Per-class Precision, Recall, and F-1
precision = diag / colsums 
recall = diag / rowsums 
f1 = 2 * precision * recall / (precision + recall) 

#One-For-All
OneVsAll = lapply(1 : nc,
                  function(i){
                    v = c(cm[i,i],
                          rowsums[i] - cm[i,i],
                          colsums[i] - cm[i,i],
                          n-rowsums[i] - colsums[i] + cm[i,i]);
                    return(matrix(v, nrow = 2, byrow = T))})

s = matrix(0, nrow = 2, ncol = 2)
for(i in 1 : nc){s = s + OneVsAll[[i]]}

#Average Accuracy
avgAccuracy = sum(diag(s)) / sum(s)

#Macro Averaging
macroPrecision = mean(precision)
macroRecall = mean(recall)
macroF1 = mean(f1)
data.frame(macroPrecision, macroRecall, macroF1)

#Micro Averageing
micro_prf = (diag(s) / apply(s,1, sum))[1]
micro_prf

#####################################
#Matthew Correlation Coefficient
mcc_numerator<- 0
temp <- array()
count <- 1

for (k in 1:nrow(cm)){
  for (l in 1:nrow(cm)){
    for (m in 1:nrow(cm)){
      temp[count] <- (cm[k,k]*cm[m,l])-(cm[l,k]*cm[k,m])
      count <- count+1}}}
sum(temp)
mcc_numerator <- sum(temp)

mcc_denominator_1 <- 0 
count <- 1
mcc_den_1_part1 <- 0
mcc_den_1_part2 <- 0

for (k in 1:nrow(cm)){
  mcc_den_1_part1 <- 0
  for (l in 1:nrow(cm)){
    mcc_den_1_part1 <- mcc_den_1_part1 + cm[l,k]}
  
  mcc_den_1_part2 <- 0;
  
  for (f in 1:nrow(cm)){
    if (f != k){
      for (g in 1:nrow(cm)){
        mcc_den_1_part2 <- mcc_den_1_part2+cm[g,f]
      }}}
  mcc_denominator_1=(mcc_denominator_1+(mcc_den_1_part1*mcc_den_1_part2));
}


mcc_denominator_2 <- 0 
count <- 1
mcc_den_2_part1 <- 0
mcc_den_2_part2 <- 0

for (k in 1:nrow(cm)){
  mcc_den_2_part1 <- 0
  for (l in 1:nrow(cm)){
    mcc_den_2_part1 <- mcc_den_2_part1 + cm[k,l]}
  
  mcc_den_2_part2 <- 0;
  
  for (f in 1:nrow(cm)){
    if (f != k){
      for (g in 1:nrow(cm)){
        mcc_den_2_part2 <- mcc_den_2_part2+cm[f,g]
      }}}
  mcc_denominator_2=(mcc_denominator_2+(mcc_den_2_part1*mcc_den_2_part2));
}

mcc = (mcc_numerator)/((mcc_denominator_1^0.5)*(mcc_denominator_2^0.5))
mcc

