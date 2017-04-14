# This files contains method to do sentiment analysis on Facebook posts and Twitter tweets with SentR

# install.packages('devtools')

library(devtools)
install_github('mananshah99/sentR')
library(sentR)


# Rather simple workflow...
twitterMaster.df$sentR <- classify.naivebayes(twitterMaster.df$Text)
outBayes <- classify.naivebayes(testdata[1:160,1])
print(table(testdata[1:160,2], outBayes[,4]))
