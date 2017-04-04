install.packages("tm")
library(tm)


##bring Google Chrome's language detection to R
url <- "http://cran.us.r-project.org/src/contrib/Archive/cldr/cldr_1.1.0.tar.gz"
pkgFile<-"cldr_1.1.0.tar.gz"
download.file(url = url, destfile = pkgFile)
install.packages(pkgs=pkgFile, type = "source", repos = NULL)
unlink(pkgFile)

library(cldr)

#detecting examples
detectLanguage(a)
b<- detectLanguage(fb_page_psoriasisSpeaks[[5]])
b<- unique(detectLanguage(fb_page_psoriasisSpeaks[[5]])[[1]])

#diseases posts detecting
Diseases_posts_language<- detectLanguage(Hailian_Diseases_NoD[[3]])
Diseases_posts_language<- cbind(Hailian_Diseases_NoD, Diseases_posts_language)
