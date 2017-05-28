# This file provides function for analysing confusion matrixes http://blog.revolutionanalytics.com/2016/03/com_class_eval_metrics_r.html#macro

mcc <- function(cm) {
  # Calculates the Matthew Correlation Coefficient for a given confusion matrix
  # This is based on the Micro Average TP,TN,FP and FN values
  #
  # Args:
  #   cm: Confusion Matrix
  #
  # Returns:
  #   MCC value
  

  mcc_numerator <- 0
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
  return(mcc)
}

analyzeConfusinMatrix <- function(cm) {
  # Calculates basic evaluation of a cunfusion Matrix
  #
  # Args:
  #   originalSentiment: original sentiment Vector
  #   predictedSentiment: predicted sentiment Vector
  
  #cm = as.matrix(table(originalSentiment,predictedSentiment)) # build confusion matrix
  
  n = sum(cm) # number of instances
  nc = nrow(cm) # number of classes
  diag = diag(cm) # number of correctly classified instances per class 
  rowsums = apply(cm, 1, sum) # number of instances per class
  colsums = apply(cm, 2, sum) # number of predictions per class
  p = rowsums / n # distribution of instances over the actual classes
  q = colsums / n # distribution of instances over the predicted classes
  
  
  # Accuracy
  
  accuracy = sum(diag) / n 
  
  # Precision recall and F1
  
  precision = diag / colsums 
  recall = diag / rowsums 
  f1 = 2 * precision * recall / (precision + recall) 
  
  data.frame(precision, recall, f1) 
  
  # MACRO precision, recall and F!
  
  macroPrecision = mean(precision)
  macroRecall = mean(recall)
  macroF1 = mean(f1)
  data.frame(macroPrecision, macroRecall, macroF1)
  
  # One-vs-all
  
  oneVsAll = lapply(1 : nc,
                    function(i){
                      v = c(cm[i,i],
                            rowsums[i] - cm[i,i],
                            colsums[i] - cm[i,i],
                            n-rowsums[i] - colsums[i] + cm[i,i]);
                      return(matrix(v, nrow = 2, byrow = T))})
  oneVsAll
  s = matrix(0, nrow = 2, ncol = 2)
  for(i in 1 : nc){s = s + oneVsAll[[i]]}
  
  # --> Average Accuracy 
  avgAccuracy = sum(diag(s)) / sum(s)
  avgAccuracy
  
  #Micro averaged Metrics
  
  micro_prf = (diag(s) / apply(s,1, sum))[1];
  micro_prf
  

  
  #Matthew Correlation Coefficient
  mcc <- mcc(cm)
  
  
  cm
  print("Overall Statistics")
  print(paste0("Accuracy: ",accuracy ))
  cat("\n")
  print("Class based evaluations")
  print(data.frame(precision, recall, f1) )
  cat("\n")
  print("Macro values")
  print(data.frame(macroPrecision, macroRecall, macroF1))
  print(paste0("Average accuracy: ", avgAccuracy ))
  print(paste0("MCC: ", mcc ))
  print(paste0("Micro Performance: ", micro_prf ))

}

table <- matrix(c(1227,516,505,1268,1125,1060,1570,1110,3138),ncol=3,byrow=TRUE)
colnames(table) <- c("true bad","true neutral","true good")
rownames(table) <- c("pred. bad","pred. neutral","pred. good")
table <- as.table(table)
table


analyzeConfusinMatrix(table)
