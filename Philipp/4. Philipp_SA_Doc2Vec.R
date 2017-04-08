# README
# - Comment out the train_model if you have the model file already with you

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

setwd("~/GitHub/AbbVie2017/Philipp")

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
tok_fun <- word_tokenizer

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

plot(glmnet_classifier)
print(paste("max AUC =", round(max(glmnet_classifier$cvm), 4)))

preds <- predict(glmnet_classifier, dtm_test_tfidf, type = 'response')[ ,1]
auc(as.numeric(tweets_test$sentiment), preds)

# save the model for future using
saveRDS(glmnet_classifier, paste(Sys.Date(),'_glmnet_classifier.RDS'))

###############################################################
# PRE-PROCESSING

Doc2Vec.PreProcessing <- function (txt, dataset)
{
  temp <- subset(dataset, dataset$key == txt)
  # converting some symbols
  dmap_at(temp,'text', conv_fun)
  
  # tokenization
  it_txt <- itoken(temp$text,
                   preprocessor = prep_fun,
                   tokenizer = tok_fun,
                   ids = temp$id,
                   progressbar = TRUE)
  
  # creating vocabulary and document-term matrix
  dtm_txt <- create_dtm(it_txt, vectorizer)
  
  # transforming data with tf-idf
  dtm_txt_tfidf <- fit_transform(dtm_txt, tfidf)
  
  # loading classification model
  glmnet_classifier <- readRDS('Models/0204_glmnet_classifier.RDS')
  
  # predict probabilities of positiveness
  preds_txt <- predict(glmnet_classifier, dtm_txt_tfidf, type = 'response')[ ,1]
  
  # adding rates to initial dataset
  temp$sentiment <- preds_txt
  
  # color palette
  cols <- c("#ce472e", "#f05336", "#ffd73e", "#eec73a", "#4ab04a")
  
  set.seed(932)
  samp_ind <- sample(c(1:nrow(temp)), nrow(temp) * 0.1) # 10% for labeling
  
  # plotting
  ggplot(temp, aes(x = created, y = sentiment, color = sentiment)) +
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
    ggtitle("Tweets Sentiment rate (probability of positiveness)")
  
}



################# TEST ZONE