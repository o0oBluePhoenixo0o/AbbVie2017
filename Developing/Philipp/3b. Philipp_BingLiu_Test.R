setwd("~/GitHub/AbbVie2017/Philipp")

require(tm)
require(stringr)
# Test set 15.05.17
testdf <- read.csv("Final_Manual_1505.csv", as.is = TRUE, sep = ",")

testdf <- testdf[, which(names(testdf) %in% c("message","Id","sentiment"))]

#Change sentiment values to classes
testdf$sentiment <- sapply(testdf$sentiment, function(x) 
                            if (x == 1|x == 2) {'Negative'}
                            else if (x == 3|x == 4) {'Positive'}
                            else if (x == 'N') {'Neutral'})


#################################################################################
#Pulling in positive and negative wordlists
#BingLiu
pos.words <- scan('Models/Positive.txt', what='character', comment.char=';') #folder with positive dictionary
neg.words <- scan('Models/Negative.txt', what='character', comment.char=';') #folder with negative dictionary
#Adding words to positive and negative databases
pos.words=c(pos.words, 'Congrats', 'prizes', 'prize', 'thanks', 'thnx', 'Grt', 
            'gr8', 'plz', 'trending', 'recovering', 'brainstorm', 'leader')
neg.words = c(neg.words, 'Fight', 'fighting', 'wtf', 'arrest', 'no', 'not')

#evaluation function
score.sentiment <- function(sentences, pos.words, neg.words, .progress='none')
{
  scores <- laply(sentences, function(sentence, pos.words, neg.words){
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence <- gsub('[[:punct:]]', "", sentence)
    sentence <- gsub('[[:cntrl:]]', "", sentence)
    sentence <- gsub('\\d+', "", sentence)
    #convert to lower-case and remove punctuations with numbers
    sentence <- removePunctuation(removeNumbers(tolower(sentence)))
    removeURL <- function(x) gsub('"(http.*) |(http.*)$|\n', "", x)
    sentence <- removeURL(sentence)
    # split into words. str_split is in the stringr package
    word.list <- str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words <- unlist(word.list)
    # compare our words to the dictionaries of positive & negative terms
    pos.matches <- match(words, pos.words)
    neg.matches <- match(words, neg.words)
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches <- !is.na(pos.matches)
    neg.matches <- !is.na(neg.matches)
    score <- sum(pos.matches) - sum(neg.matches)
    return(score)
  }, pos.words, neg.words, .progress=.progress)
  scores.df <- data.frame(score=scores, message=sentences)
  return(scores.df)
}
########################################################################
require(plyr)

#convert to factor
testdf$message <- as.factor(testdf$message)
#evaluate sentiments
scores <- score.sentiment(testdf$message, pos.words, neg.words, .progress='text')
result <- scores

#Add ID to result set
result$Id <- testdf$Id
#add new scores as a column
result <- mutate(result, Id, sentiment = ifelse(result$score > 0, 'Positive', 
                                      ifelse(result$score < 0, 'Negative', 'Neutral')))

result <- result[, which(names(result) %in% c("message","Id","sentiment"))]

################################################################
#Calculating confusion matrix
a <- testdf$sentiment
b <- result$sentiment
?confusionMatrix
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
OneVsAll
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
count
temp
mcc_numerator
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
cm
