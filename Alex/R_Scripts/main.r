#This is code to download products data from FB
source("./crawl_facebook.r")
source("./preprocess_facebook.r")

#Set working directory to the directoy where the file is located 
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)


#- Crawl the data from facebook -#

searchFB("Humira")
searchFB("Adalimumab")
searchFB("Enbrel")
searchFB("Trilipix")
searchFB("Imbruvica")

#- Merge the data into one big .csv file -#
mergeCSVs("./products/Adalimumab.csv","./products/Enbrel.csv","./products/Humira.csv","./products/Imbruvica.csv","./products/Trilipix.csv")


#- Read in other files -#
myMaster.df <- read.csv("Alex_FB_Products.csv", fileEncoding = "UTF-8", sep = ",", as.is = TRUE)
chiensMaster.df <- read.csv("Chien_FB_Diseases.csv", encoding = "UTF-8", fileEncoding = "UTF-16LE", sep = ",", as.is = TRUE)
philippsMaster.df <- read.csv("Philipp_FB_Companies.csv", fileEncoding = "UTF-16LE", sep = ",", as.is = TRUE, skipNul = TRUE)



for (i in 1:nrow(myMaster.df)){
  print(detectLanguage(myMaster.df[i]))
}

