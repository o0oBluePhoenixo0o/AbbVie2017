# This file provides function for analysing confusion matrixes

print_and_capture <- function(x){
  # Print function, for printing data.frames in message(x)
  #
  # Args:
  #   x: Object to print
  #
  # Returns:
  #   Printable String of the object
  
  paste(capture.output(print(x)), collapse = "\n")
}

analyzeConfusinMatrix <- function(originalSentiment, predictedSentiment) {
  
  cm = as.matrix(table(tweets.test$sentiment,test.syuzhet$sent)) # build confusion matrix
  
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
  
  
  print(cm)
  print("Overall Statistics")
  print(paste0("Accuracy: ",accuracy ))
  cat("\n")
  print("Class based evaluations")
  print(data.frame(precision, recall, f1) )
  cat("\n")
  print("Macro values")
  print(data.frame(macroPrecision, macroRecall, macroF1))
  print(paste0("Average accuracy: ", avgAccuracy ))
  
  print(micro_prf)

}
