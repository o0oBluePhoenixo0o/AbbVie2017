# This files contains methods on preprocess FB data

#-Language detection with n-grams-#
library(textcat)


detectLanguage <- function(text){
  return(textcat(text))
}


for (i in 1:nrow(myMaster.df)){
  print(detectLanguage(myMaster.df[i]))
}

