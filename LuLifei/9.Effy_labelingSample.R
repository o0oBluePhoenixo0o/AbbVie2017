


# used for random selecting 800 tweets to do the labeling work



#read in file
df <- read.csv(file.choose(),header = TRUE,sep = ",")


#save english tweets only
df <- subset(df,df$Language=="eng")


#random select 200 tweets of keywords "abbvie" for labeling
abbvie <- subset(df,df$key=="abbvie")
rows <- nrow(abbvie)
indexes <- sample(rows,200,replace = FALSE)
abbvieSample <- abbvie[indexes,]


#random seledt 200 tweets of keywords "adalimumab" for labeling
adalimumab <- subset(df,df$key=="adalimumab")
rows <- nrow(adalimumab)
indexes <- sample(rows,200,replace = FALSE)
adalimumabSample <- adalimumab[indexes,]


#random seledt 200 tweets of keywords "amgen" for labeling
amgen <- subset(df,df$key=="amgen")
rows <- nrow(amgen)
indexes <- sample(rows,200,replace = FALSE)
amgenSample <- amgen[indexes,]


#random seledt 200 tweets of keywords "ankylosing" for labeling
ankylosing <- subset(df,df$key=="ankylosing spondylitis")
rows <- nrow(ankylosing)
indexes <- sample(rows,200,replace = FALSE)
ankylosingSample <- ankylosing[indexes,]


#combine samples together and write as .csv file
labelingSample <- rbind(abbvieSample,adalimumabSample,amgenSample,ankylosingSample)
label <- matrix(nrow = 800,ncol = 4)
colnames(label) <- c("sentiment","sarcastic","context","topic")
labelingSample <- cbind(labelingSample,label)
write.csv(labelingSample,file = "LuLifei_labelingSample.csv")


