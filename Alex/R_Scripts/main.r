#This is code to download products data from FB
source("./crawl_facebook.r")
source("./preprocess_facebook.r")
library(ggplot2)

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
mergeCSVsUTF8("./products/Adalimumab.csv","./products/Enbrel.csv","./products/Humira.csv","./products/Imbruvica.csv","./products/Trilipix.csv")
mergeCSVsUTF16LE("./products/Adalimumab.csv","./products/Enbrel.csv","./products/Humira.csv","./products/Imbruvica.csv","./products/Trilipix.csv")


#- Read in other files -#
myMaster.df <- read.csv("Alex_FB_Products_utf8.csv", fileEncoding = "UTF-8", sep = ",", as.is = TRUE)
chiensMaster.df <- read.csv("Chien_FB_Diseases_utf8.csv", fileEncoding = "UTF-8", sep = ",", as.is = TRUE)
hailiensMaster.df <- read.csv("Hailian_FB_Diseases.csv", fileEncoding = "UTF-8", sep = ",", as.is = TRUE)
