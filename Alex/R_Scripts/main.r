#Set working directory to the directoy where the file is located 
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

source("./functions.r")

dir.create("./products")

## Retrieve the facebook data from Abbvie Page ## 

#print("Getting the data from the Abbvie FB Page")

abbviePageData <- retrieveAbbviePageData()

write.csv(abbviePageData, file="./products/AbbviePageData.csv", row.names=FALSE)


## Get all the data of pages for 'Humira' ## 
#getPagesDataWithKey("Humira")
getPagesDataWithKeySingleFile("Humira","./products/")

## Get all the data of pages for 'Adalimumab' ## 
#getPagesDataWithKey("Adalimumab")
getPagesDataWithKeySingleFile("Adalimumab","./products/")

## Get all the data of pages for 'Enbrel' ## 
#getPagesDataWithKey("Enbrel")
getPagesDataWithKeySingleFile("Enbrel","./products/")

## !!!! THROWS ERROR !!!! ##
## Get all the data of pages for 'Trilipix' ## 
#getPagesDataWithKey("Trilipix")
getPagesDataWithKeySingleFile("Trilipix","./products/")

## Get all the data of pages for 'Imbruvica' ## 
#getPagesDataWithKey("Imbruvica")


getPagesDataWithKeySingleFile("Imbruvica","./products/")


#getGroupsDataWithKey("Humira")