#Set working directory to the directoy where the file is located 
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

source("./functions.r")

dir.create("./products")

## Retrieve the facebook data from Abbvie Page ## 

#print("Getting the data from the Abbvie FB Page")

#abbviePageData <- retrieveAbbviePageData()

#write.csv(abbviePageData, file="./products/AbbviePageData.csv", row.names=FALSE)


## Get all the data of pages for 'Humira' ## 
searchFB("Humira")

## Get all the data of pages for 'Adalimumab' ## 
searchFB("Adalimumab")

## Get all the data of pages for 'Enbrel' ## 
searchFB("Enbrel")

## Get all the data of pages for 'Trilipix' ## 
searchFB("Trilipix")

## Get all the data of pages for 'Imbruvica' ## 
searchFB("Imbruvica")


mergeCSVs("./products/Adalimumab.csv","./products/Enbrel.csv","./products/Humira.csv","./products/Imbruvica.csv","./products/Trilipix.csv")



# From Philipp and I totally do not know why this is not working on my mashine... maybe some encoding probs...
a <- read.csv("Philipp_FB_Companies.csv", fileEncoding = "UTF-16LE", sep = ",")
b <- read.csv("Alex_FB_Products.csv", sep = ";")
c <- read.csv("Chien_FB_Diseases.csv", fileEncoding = "UTF-16LE", sep = ",")

#Change name in Alex's file
colnames(b)[1] <- "key"

#Merge
finaldf <- data.frame()
finaldf <- rbind(finaldf, a)
finaldf <- rbind(finaldf, b)