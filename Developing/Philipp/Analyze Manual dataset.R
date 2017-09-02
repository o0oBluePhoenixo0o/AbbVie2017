library(memisc)

setwd("~/GitHub/AbbVie2017/Philipp")
Manual <- read.csv("Final_Manual_3007.csv")

Manual <- Manual[!is.na("sentiment"),]

Manual$sentiment <- sapply(Manual$sentiment, function(x)
  x = cases (x %in% c(1,2) -> 'Negative',
             x %in% c(3,4) -> 'Positive',
             x %in% c('N',NA,'n','',' ') -> 'Neutral'))

agg <- dplyr::summarize(dplyr::group_by(Manual, sentiment),n())

agg_sc <- dplyr::summarize(dplyr::group_by(Manual, sarcastic),n())
