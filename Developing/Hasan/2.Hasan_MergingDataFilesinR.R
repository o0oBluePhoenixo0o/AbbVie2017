#merging data files of different disease keywords
folder1 <- "D:/Uni mannheim/Study/TeamProject_ABBVIE/5. Data/Preprocessed/1. Twitter/Diseasesdata/"      # path to folder that holds multiple .csv files
file_list1 <- list.files(path=folder1, pattern="*.csv") # create list of all .csv files in folder

# read in each .csv file in file_list and rbind them into a data frame called data 
data <- 
  do.call("rbind", 
          lapply(file_list1, 
                 function(x) 
                 read.csv(paste(folder1, x, sep=','), 
                 stringsAsFactors = FALSE)))

write.csv(data,"D:/Uni mannheim/Study/TeamProject_ABBVIE/5. Data/Preprocessed/1. Twitter/update_disease_31.3.csv", sep=",", row.names=FALSE, stringsAsFactors=FALSE)

# Appending update with master file
folder2 <- "D:/Uni mannheim/Study/TeamProject_ABBVIE/5. Data/Preprocessed/1. Twitter/"      # path to folder that holds multiple .csv files
file_list2 <- list.files(path=folder2, pattern="*.csv") # create list of all .csv files in folder

fulldata <- 
  do.call("rbind", 
          lapply(file_list2, 
                 function(x) 
                 read.csv(paste(folder2, x, sep=','), 
                 stringsAsFactors = FALSE)))


write.csv(fulldata,"D:/Uni mannheim/Study/TeamProject_ABBVIE/5. Data/Preprocessed/1. Twitter/Twitter_31.03.csv", sep=",", row.names=FALSE, stringsAsFactors=FALSE)


