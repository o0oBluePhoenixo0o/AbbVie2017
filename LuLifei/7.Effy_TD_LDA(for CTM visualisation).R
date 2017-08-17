

#package
install.packages("jsonlite")
install.packages("tm")
install.packages("lda")
install.packages("LDAvis")
install.packages("SnowballC")


#library
library(jsonlite)
library(tm)
library(lda)
library(LDAvis)
library(SnowballC)


#read in file
df <- read.csv(file.choose(),header = TRUE,sep = ",")


#build corpus
cp <- Corpus(VectorSource(df$message))


#preprocessing
dtm.control <- list(tolower = TRUE,
                    removePunctuation = TRUE,
                    removeNumbers = TRUE,
                    stopwords = c(stopwords("SMART"),
                                  stopwords("en")),
                    stemming = TRUE,
                    wordLengths = c(3, "inf"),
                    weighting = weightTf)


#record the term occurrences per document in a sparse matrix and set up parameters
sparse.dtm <- DocumentTermMatrix(cp, control = dtm.control)
dtm <- as.matrix(sparse.dtm)
class(dtm) <- "integer"


vocab <- sparse.dtm$dimnames$Terms


# Compute some statistics related to the data set:
# number of documents
D <- length(cp)
# number of terms in the vocab
W <- length(vocab)
# number of tokens per document
doc.length <- rowSums(dtm)
# total number of tokens in the data
N <- sum(doc.length)  
# frequencies of terms in the corpus
term.frequency <- colSums(dtm)  


# MCMC and model tuning parameters:
K <- 20
G <- 5000
alpha <- 0.02
eta <- 0.02


#using the term frequencies we attempt to find clusters or words that tend to co-occur.
lda.input <- lapply(1:nrow(dtm), function (i) {
  docfreq <- t(dtm[i,])
  keepers <- docfreq > 0
  rbind( (0:(ncol(dtm)-1))[keepers], t(dtm[i,])[keepers] )
} )

fit <- lda.collapsed.gibbs.sampler(documents = lda.input,
                                   K = K, vocab = vocab,
                                   num.iterations = G, alpha = alpha,
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)

#plug the topic model into an interactive visualization
theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))



# create the JSON object to feed the visualization:
json <- createJSON(phi = phi,
                   theta = theta,
                   doc.length = doc.length,
                   vocab = vocab,
                   term.frequency = term.frequency)

serVis(json)
str(json)

system.file("htmljs", package = "LDAvis")



