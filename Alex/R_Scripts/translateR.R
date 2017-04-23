#File for using text translation services

#install.packages("httr")
#install.packages("franc")
#install.packages("ISOcodes")
#install.packages("stringi")

library(httr)
library(franc)
library(ISOcodes)
library(stringi)
library(textcat)
data("ISO_639_2") # needed for language code conversion

translateMyMemory.single <- function(text, source, target, email) {
  # Uses mymemory service for text translating (http://mymemory.translated.net/doc/spec.php), this version only supports calls with 500 character texts!! Please use 'translateMyMemory' instead because it supports
  # texts above 500 chars
  #
  # Args:
  #   text: The text which needs to be translation
  #   from: ISO 639-1 encoded language code string of the source language
  #   target: ISO 639-1 encoded language code string of the target language
  #   email: Valid email address if you want to gain access to an rate limit of 10.000 words/day, if not specified you only have a rate limit of 1.000 words/day
  #
  # Returns:
  #   A translated text string, or NULL if the language is not supoorted
  
  if (missing(email)) {
    url <- paste("http://api.mymemory.translated.net/get?q=", URLencode(text), "&langpair=", source, "|", target, sep = "")
  } else {
    url <- paste("http://api.mymemory.translated.net/get?q=", URLencode(text), "&langpair=", source, "|", target, "&de=", email, sep = "")
  }
  
  message(sprintf("Sending GET request to: %s", url))
  result <- GET(url)
  message(sprintf("Reponse returned with status code: %s", status_code(result)))
  message(sprintf("Reponse content is : %s", httr::content(result, "parsed")$responseData$translatedText))
  return(httr::content(result, "parsed")$responseData$translatedText)
}

translateMyMemory <- function(text, source, target, email) {
  # Uses mymemory service for text translating (http://mymemory.translated.net/doc/spec.php)
  #
  # Args:
  #   text: The text which needs to be translation
  #   from: ISO 639-1 encoded language code string of the source language
  #   target: ISO 639-1 encoded language code string of the target language
  #   email: Valid email address if you want to gain access to an rate limit of 10.000 words/day, if not specified you only have a rate limit of 1.000 words/day
  #
  # Returns:
  #   A translated text string, or NA if the language is not supoorted

  if (missing(source) || nchar(source)==0) {
    message("You need to specify a source language code!")
    return(NA) # stop all executions and exit the function
  }
  
  if (missing(target) || nchar(target)==0) {
    message("You need to specify a target language code!")
    return(NA) # stop all executions and exit the function
  }
  
  if (source == target){
    message(sprintf('Source (%s) and target (%s) can not be the same!', source, target))
    return(NA) # stop all executions and exit the function
  }
  
  if(is.na(text)){
    message("Text was NA")
    return(NA) # stop all executions and exit the function
  }

  # MyMemory allows us to only translate 500 characters at a time, so we have to split our text into chunks
  if (nchar(text)>500) {
    text.chunked <- fixed_split(text, 400) # use 400, because fixed_split does not always return a fixed split of #x because it does not break words
    
    finalTranslation <- ''
    
    for(chunk in text.chunked){
      chunkTranslation <- translateMyMemory.single(as.character(chunk), source, target, email)
      
      # Check if translation was found
      if (!is.null(chunkTranslation)) {
        finalTranslation <- paste(finalTranslation, chunkTranslation)
      } else {
        finalTranslation <- paste(finalTranslation, "translation not found")
      }
    
    }
    return(finalTranslation)
  } else {
    finalTranslation <- translateMyMemory.single(as.character(text), source, target, email)
    
    # Check if translation was found
    if (!is.null(finalTranslation)) {
      return(finalTranslation)
    } else {
      return(NA)
    }
  }
}

toISO639_1 <- function(iso639_2) {
  # Converts a ISO 639-2 encoded language code string to IS0 639-1
  #
  # Args:
  #   iso639_2: A ISO 639-2 encoded language code string
  #
  # Returns:
  #   A IS0 639-1 encoded language string
  
  
  iso639_1 <- subset(ISO_639_2, Alpha_3_T == iso639_2)
  if (empty(iso639_1)) {
    message("empty")
    return("")
  } else if (is.na(iso639_1[1,]$Alpha_2)) {
    message("not empty but NA")
    return ("")
  } else {
    return(iso639_1[1,]$Alpha_2)
  }
}

detectLanguage <- function(text){
  # Uses 'franc' package to detect the language of a given text
  #
  # Args:
  #   text: The text to detect the language
  #
  # Returns:
  #   A ISO 639-2 encoded language code string
  
  if (!is.na(text)) {
      return (franc(text, min_length = 3))
  } else {
    message("Can not detect language of NA")
    return (NA)
  }
}

fixed_split <- function(text, n) {
  # Uses stringi package to split up a string in substring of +- length n but it pays respect to words and don't break it
  #
  # Args:
  #   text: The text to split up
  #   n: How many character should each substring contain. Be aware that it could be +- a little fraction because of not breaking up words
  #
  # Returns:
  #   A list containing all chunks
  
  
  words <- stri_split_boundaries(text, tokens_only = TRUE, simplify = TRUE) # get a list of all words in the text
  allChunks <- list() # storing chunks of size
  text_chunk <- '' # a single chunk
  
  
  for (word in words){
    if(nchar(text_chunk) < n){
      text_chunk <- paste(text_chunk, word, sep = "")
    } else {
      allChunks <- c(allChunks,text_chunk)
      text_chunk <- character()
      text_chunk <- paste(text_chunk, word, sep = "")
    }
  }
  
  if(length(allChunks)==0){
    allChunks <- list(allChunks, list(text_chunk))
  }
  return(allChunks)
}

