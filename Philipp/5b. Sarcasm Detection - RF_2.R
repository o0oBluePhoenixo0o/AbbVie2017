# Random forest model building on master.factor and master.numeric
# and saving the model 


# loading required package
require(h2o) # to implement random forest quick

# Initializing h2o cluster
h2o.init(nthreads = -1)

#check h2o cluster status
h2o.init()

set.seed(123)

# loading data to h2o clusters 
h.train.num <- as.h2o(train.num)
h.train     <- as.h2o(train)


# creating predictor and target indices
x <- 2:ncol(train)
y <- 1
# Building random forest model on numeric data 
rf.model.num <- h2o.randomForest(x=x, y=y, training_frame = h.train.num, ntrees = 1000)

# Building random forest model on factor data
rf.model     <- h2o.randomForest(x=x, y=y, training_frame = h.train, ntrees = 1000)

# saving both models for evaluation 
save(rf.model.num, rf.model, file = 'RF_models.dat')

# Initializing h2o cluster
h2o.init(nthreads = -1)

#check h2o cluster status
h2o.init()

# loading data to h2o clusters 
h.test.num  <- as.h2o(test.num)
h.test      <- as.h2o(test)

# loading RF models
load('RF_models.dat')

# Evaluating random forest models

# Random forest evaluation for Numeric data
pred.num <- as.data.frame(h2o.predict(rf.model.num, h.test.num))
caret::confusionMatrix(table('Actual class' = test$label,'Predicted class' =  pred.num$predict))

# Random forest evaluation for Factor data
pred <- as.data.frame(h2o.predict(rf.model, h.test))
caret::confusionMatrix(table('Actual class' = test$label, 'Predicted class' = pred$predict))

# shuting down h2o cluster
h2o.shutdown(prompt = F)