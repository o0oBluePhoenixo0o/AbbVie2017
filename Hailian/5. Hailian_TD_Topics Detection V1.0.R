####topic Detection
#using package mscstexta4r: textaDetecttpoics(), textaDetecttpoicsStatus()
#using package textreuse:lsh()...

install.packages("mscstexta4r")
install.packages("textreuse")

library(mscstexta4r)
library(textreuse)

###using package mscstexta4r: textaDetecttpoics(), textaDetecttpoicsStatus()
##create file .mscskeys.json with content:
#{
  #"textanalyticsurl": "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/",
 # "textanalyticskey": "5bcb63d978b740ab9854c68f9fc45b5a"
#}


#call textaInit
tryCatch({
  
  textaInit()
  
}, error = function(err) {
  
  geterrmessage()
  
})

#random test for sentiment analysis
docsText <- c(
  "Loved the food, service and atmosphere! We'll definitely be back.",
  "Very good food, reasonable prices, excellent service.",
  "It was a great restaurant.",
  "If steak is what you want, this is the place.",
  "The atmosphere is pretty bad but the food is quite good.",
  "The food is quite good but the atmosphere is pretty bad.",
  "The food wasn't very good.",
  "I'm not sure I would come back to this restaurant.",
  "While the food was good the service was a disappointment.",
  "I was very disappointed with both the service and my entree."
)
docsLanguage <- rep("en", length(docsText))

tryCatch({
  
  # Perform sentiment analysis
  textaSentiment(
    documents = docsText,    # Input sentences or documents
    languages = docsLanguage
    # "en"(English, default)|"es"(Spanish)|"fr"(French)|"pt"(Portuguese)
  )
  
}, error = function(err) {
  
  # Print error
  geterrmessage()
  
})


##random text for topic detection

#remove na
a1<- data.frame(na.omit(subset(fb_page_psoriasisSpeaks,select = c("message","created_time"))))

documents<- sample(a1$message)

tryCatch({
  
  # Detect top topics
  textaDetectTopics(
    documents, # At least 100 docs/sentences (English only)
    stopWords = NULL,             # Stop word list (optional)
    topicsToExclude = NULL,       # Topics to exclude (optional)
    minDocumentsPerWord = NULL,   # Threshold to exclude rare topics (optional)
    maxDocumentsPerWord = NULL,   # Threshold to exclude ubiquitous topics (optional)
    resultsPollInterval = 60L,    # Poll interval (in s, default: 30s, use 0L for async)
    resultsTimeout = 1200L,       # Give up timeout (in s, default: 1200s = 20mn)
    verbose = TRUE                # If set to TRUE, print every poll status to stdout
  )
  
}, error = function(err) {
  
  # Print error
  geterrmessage()
  
})



###using package textreuse:minhash_generator(),lsh()...

corpus1<- TextReuseCorpus(text = fb_page$message, meta = list("description"="text"))

buckets<- lsh(corpus1, bands = 2)













