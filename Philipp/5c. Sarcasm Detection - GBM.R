setwd("~/GitHub/AbbVie2017/Philipp/")

train<-read.csv("train_features.csv")
test<-read.csv("test_features.csv")

train_labels=c(rep(0,51300),rep(1,39998))

test_tweet_ids<-read.csv("test_MLWARE1.csv")[,1]

library(corrplot)
M <- cor(train)
corrplot(M,method="number")


train_tot_df<-train
test_df<-test

##Sampling data into train_total into  train & validation set
library(caTools)
set.seed(101) 
sample = sample.split(train_tot_df, SplitRatio = .75)
train_df = subset(train_tot_df, sample == TRUE)
valid_df = subset(train_tot_df, sample == FALSE)
train_lb_df=subset(train_labels, sample == TRUE)
valid_lb_df=subset(train_labels, sample == FALSE)

library(h2o)
library(data.table)
library(dplyr)

h2o.server <- h2o.init( nthreads= -1)

#selCols = names(train_df)
#train_1 = train_df[,(selCols) := lapply(.SD, as.factor), .SDcols = selCols]

testHex = as.h2o(test_df)
train_score1=as.factor(train_lb_df)
train_1 = cbind(train_df,Y=train_score1)
valid_score1=as.factor(valid_lb_df)
valid_1 = cbind(valid_df,Y=valid_score1)
#Converting to H2o Data frame & splitting
train.hex1 = as.h2o(train_1)
validHex1 = as.h2o(valid_1)
features=names(train.hex1)[-c(ncol(train.hex1))]#Removing Surge_Pricing_Type,Y i.e. the dependent variables

gbmF_model_1 = h2o.gbm( x=features,
                        y = "Y",
                        training_frame =train.hex1 ,
                        validation_frame =validHex1 ,
                        max_depth = 5,
                        #distribution = "bernoulli",
                        ntrees =1000,
                        learn_rate = 0.05
                        #,nbins_cats = 5891
)


summary(gbmF_model_1)
#Variable Importances, RMSE from Validation set: Obtained from here


rf_model_1 =h2o.randomForest(x=features,y="Y",training_frame =train.hex1,
                             validation_frame =validHex1,
                             ntrees=300,max_depth = 6)
summary(rf_model_1)
#Variable Importances, RMSE from Validation set: Obtained from here


dl_model_1 = h2o.deeplearning( x=features,
                               # x=features,
                               y = "Y",
                               training_frame =train.hex1 ,
                               validation_frame =validHex1 ,
                               activation="Rectifier",
                               hidden=80,
                               epochs=50,
                               adaptive_rate =F
)

summary(dl_model_1)
#Variable Importances, RMSE from Validation set: Obtained from here

colnames(testHex)<-colnames(train.hex1)[-c(ncol(train.hex1))]
test_pred_score1 = as.data.frame(h2o.predict(rf_model_1, newdata =testHex ,type="") )
pred1_1 = test_pred_score1
###ans<-lapply(pred1_1,function(x) ifelse(x<0,mean(train$total_sales),x)) #Only when some negatives are predicted
answ<-pred1_1$predict
answer<-ifelse(answ==1,"sarcastic","non-sarcastic")
fl<-cbind(as.character(test_tweet_ids),answer)
colnames(fl)<-c("ID","label")
write.csv(file="test_submission_v1.csv",x=fl,row.names = F)