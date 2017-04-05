##bring Google Chrome's language detection to R
url <- "http://cran.us.r-project.org/src/contrib/Archive/cldr/cldr_1.1.0.tar.gz"
pkgFile<-"cldr_1.1.0.tar.gz"
download.file(url = url, destfile = pkgFile)
install.packages(pkgs=pkgFile, type = "source", repos = NULL)
unlink(pkgFile)

install.packages("tm")
install.packages("translateR")
install.packages("mscstexta4r")

library(cldr)
library(tm)
library(translateR)
library(mscstexta4r)



#detecting examples
detectLanguage(a)
b<- detectLanguage(fb_page_psoriasisSpeaks[[5]])
b<- unique(detectLanguage(fb_page_psoriasisSpeaks[[5]])[[1]])

#diseases posts detecting
Diseases_posts_language<- detectLanguage(Hailian_Diseases_NoD[[3]])
Diseases_posts_withlanguage<- cbind(Hailian_Diseases_NoD, Diseases_posts_language)
Diseases_posts_foreignlanguage<- subset(Diseases_posts_withlanguage, detectedLanguage!="ENGLISH")

#remove links, symbols...





##remove Stopwords

#change data.frame into corpus and removing stop words
d<- tm_map(Corpus(VectorSource(psoriasis_post[[3]])), removeWords, stopwords("english"))

#transfer corpus into data.frame
f<- data.frame()
for (i in 1:nrow(psoriasis_post))
{
  e<- data.frame(d[[i]]$content)
  f<- try(rbind(f,e))
}

#add time to posts without stop words:
psoriasis_post_new<- try(cbind(f, psoriasis_post[[4]]))

##why turn the data.frame into corpus before removing stop words?
#d<- tm_map(psoriasis_post[[3]], removeWords, stopwords("english"))
#Error in UseMethod("tm_map", x) : 
  #no applicable method for 'tm_map' applied to an object of class "character"

##Topic Detection
#using package mscstexta4r
