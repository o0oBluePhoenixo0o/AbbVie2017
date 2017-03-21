#install.packages("tm")
#install.packages("stringr")
setwd("~/GitHub/AbbVie2017/Philipp")
# Merging all data to 1 set

a <- read.csv("Philipp_FB_Companies.csv", fileEncoding = "UTF-16LE", sep = ",")
b <- read.csv("Alex_FB_Products.csv", sep = ";")
c <- read.csv("Chien_FB_Disease.csv", fileEncoding = "UTF-16LE")

#Change name in Alex's file
colnames(b)[1] <- "key"

#Merge
finaldf <- data.frame()
finaldf <- rbind(finaldf, a)
finaldf <- rbind(finaldf, b)

postdf<- setNames(data.frame(matrix(ncol = 1, nrow = nrow(finaldf))), c("message"))
commentdf<- setNames(data.frame(matrix(ncol = 1, nrow = nrow(finaldf))), c("message"))

#Get posts & comments from final df
postdf$message<-  finaldf$message.x
commentdf$message <- finaldf$message.y
#Clean duplicate
postdf <- unique(postdf)
commentdf <- unique(commentdf)

#Data Preprocessing for Posts
require(tm); require(stringr)
  clean_text <- function(df){
  # avoid encoding issues by dropping non-unicode characters
  utf8text <- iconv(df$message, to='UTF-8', sub = "byte")
  # cleaning text
  text <- removePunctuation(removeNumbers(tolower(df$message)))
  removeURL <- function(x) gsub('"(http.*) |(http.*)$|\n', "", x)
  text <- removeURL(text)
  # putting it all together
  text <- paste0(text, collapse=" ")
  return(text)
  }  
  
post <-clean_text(postdf)
comment <- clean_text(commentdf)

#Convert to vectors
post <- unlist(post)
comment <-unlist(comment)

#Reading text to corpus
post <- Corpus(VectorSource(post))
comment <- Corpus(VectorSource(comment))
