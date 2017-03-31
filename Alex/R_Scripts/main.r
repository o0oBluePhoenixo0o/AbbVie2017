#This is code to download products data from FB
source("./1_crawl_facebook.r")
source("./translateR.R")
#Set working directory to the directoy where the file is located 
setwd("~/GitHub/AbbVie2017/Alex")


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
myMaster.df <- read.csv("./products/Alex_FB_Products_utf8.csv", fileEncoding = "UTF-8", sep = ",", as.is = TRUE)


# detect the language of all posts
myMaster.df$lang.x <- lapply(myMaster.df$message.x, detectLanguage)

# Tanslate every message.x from the posts
myMaster.df <- myMaster.df %>% 
  rowwise() %>% 
  dplyr::mutate(translated.x = translateMyMemory(message.x, toISO639_1(lang.x) ,"en", "weiss_alex@gmx.net"))

View(myMaster.df)

write.csv(myMaster.df, file = "./products/Alex_FB_Products_utf8.csv", fileEncoding = "UTF-8", row.names=FALSE, qmethod='escape', quote=TRUE, sep = ",")





chiensMaster.df <- read.csv("Chien_FB_Diseases_utf8.csv", fileEncoding = "UTF-8", sep = ",", as.is = TRUE)
hailiensMaster.df <- read.csv("Hailian_FB_Diseases.csv", fileEncoding = "UTF-8", sep = ",", as.is = TRUE)
