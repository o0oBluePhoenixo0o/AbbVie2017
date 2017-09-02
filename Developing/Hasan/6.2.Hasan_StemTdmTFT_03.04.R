#Continuing from last session
#I will do stemming, build Term Document Matrix and find Top frequent Words
# Install required package
install.packages("SnowballC", dependencies = TRUE)

#load package
library(SnowballC)

# Stemming
myCorpus <- tm_map(myCorpus, stemDocument) # stem words

# inspect documents (tweets) numbered 11 to 15
inspect(myCorpus[11:15])

# The code below is used for to make text fit for paper width
# for (i in 11:15) {
#  cat(paste("[[", i, "]] ", sep=""))
#  writeLines(strwrap(myCorpus[[i]], width=73))
#  }

writeLines(strwrap(myCorpus[[190]]$content, 60))

# stemcompletion function
stemCompletion2 <- function(x, dictionary) {
x <- unlist(strsplit(as.character(x), " "))
x <- x[x != ""]
x <- stemCompletion(x, dictionary=dictionary)
x <- paste(x, sep="", collapse=" ")
PlainTextDocument(stripWhitespace(x))
}

# apply function
myCorpus <- lapply(myCorpus, stemCompletion2, dictionary=myCorpusCopy)
myCorpus <- Corpus(VectorSource(myCorpus))

# see again
writeLines(strwrap(myCorpus[[190]]$content, 60))

# count word frequence
wordFreq <- function(corpus, word) {
  results <- lapply(corpus,
                  function(x) { grep(as.character(x), pattern=paste0("nn<",word)) }
)
sum(unlist(results))
}

#Issues in Stem Completion
n.miner <- wordFreq(myCorpusCopy, "miner")
n.mining <- wordFreq(myCorpusCopy, "mining")
cat(n.miner, n.mining)

# replace oldword with newword
replaceWord <- function(corpus, oldword, newword) {
  tm_map(corpus, content_transformer(gsub),
         pattern=oldword, replacement=newword)
}

#? should i do this?? need to change the words, but which words?
myCorpus <- replaceWord(myCorpus, "miner", "mining")
myCorpus <- replaceWord(myCorpus, "universidad", "university")
myCorpus <- replaceWord(myCorpus, "scienc", "science")

#Build Term Document Matrix
tdm <- TermDocumentMatrix(myCorpus,
                          control = list(wordLengths = c(1, Inf)))

#view the matrix
tdm

#reducing weight for most frequent terms
idx <- which(dimnames(tdm)$Terms %in% c("abbvie", "humira", "rt"))
as.matrix(tdm[idx, 21:30]) #subscript out of bound error

# inspect frequent words
(freq.terms <- findFreqTerms(tdm, lowfreq = 20))

term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 20)

#make a data frame of most frequent terms with their frequencies
df <- data.frame(term = names(term.freq), freq = term.freq)

#Install & load required packages for ploting
install.packages("ggplot2", dependencies = TRUE)
library(ggplot2)

#plot the most frequent words
ggplot(df, aes(x=term, y=freq)) + geom_bar(stat="identity") +
  xlab("Terms") + ylab("Count") + coord_flip() +
  theme(axis.text=element_text(size=4))

##Wordcloud, may not require but keep it for now
m <- as.matrix(tdm)
# calculate the frequency of words and sort it by frequency
word.freq <- sort(rowSums(m), decreasing = T)

#install RcolorBrewer
install.packages("RColorBrewer", dependencies = TRUE)
library(RColorBrewer)

# colors
pal <- brewer.pal(9, "BuGn")[-(1:4)]

## plot word cloud
# install & load requied packages
install.packages("wordcloud", dependencies = TRUE)
library(wordcloud)

wordcloud(words = names(word.freq), freq = word.freq, min.freq = 3,
          random.order = F, colors = pal)

#Save the session
save.image("D:/Workspace/R/TP/data/tdmTFTwc.RData")

