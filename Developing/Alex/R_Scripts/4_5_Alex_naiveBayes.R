library(caret)
library(tm)
library(tidytext)
# load the iris dataset
data(iris)
# define training control
train_control <- trainControl(method="repeatedcv", number=20, repeats=3)
# train the model
model <- train(tweets.classified.sentiment~., data=finalset, trControl=train_control, method="nb")
# summarize results
print(model)



tweets.classified <- read.csv('./trainingandtestdata/Final_Manual_1905.csv')
tweets.classified <- tweets.classified[c("message", "sentiment" )]
corpus <- Corpus(VectorSource(tweets.classified$message))
dtm <- DocumentTermMatrix(corpus)

finalset <- as.matrix(dtm)
finalset <- data.frame(tweets.classified$sentiment, finalset)


