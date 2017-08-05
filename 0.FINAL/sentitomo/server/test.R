# loading required packages
source("./ML/R/needs.R");
needs(e1071)
needs(tm)
needs(data.table)


# Load pre-trained model 23.07
load('./ML/R/SD_NB_2307.dat')
# Load list of delete words 23.07
load('./ML/R/del_word.dat')

# Get the command line arguments
args = commandArgs(trailingOnly=TRUE)

## Assume CORE dataset is TW_df
# Extract out only ID & Message

TW_df <- args[1]
print(TW_df)
print("Hey you are in the R file")

conv_fun <- function(x) iconv(x, "latin1", "ASCII", "") 
removeURL <- function(x) gsub('"(http.*) |(http.*)$|\n', "", x) 

print(removeURL("Look at http://www.googl.ede"))