



# CTM Assign topics back
# We need to use the "Modeling" enviroment here




# Read in data ####################################################################################################
# Here, please use the dataset that finishing the pre-processing.
# Or use the "CTM_preprocess_final.csv" to assign topics back for the whole dataset.
# For testing the result, it is better to use small dataset here
preprocess_final <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")



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
  if(length(dtm@x)==0)
  {
    probability <- c(probability,0)
    topic_id <- c(topic_id,0)
    next
  }
  else
  {
    assignments <- posterior(models$CTM,dtm)
    p <- apply(assignments$topics,1,max)
    t <- match(p,assignments$topics)
    probability <- c(probability,p)
    topic_id <- c(topic_id,t)
  }
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


# Have a look at the assigning result or click the "labeling_set" in the environment to check the whole data set
CTM_result





