#load the csv file
tweets.df = read.csv(file="Final_TW_0405_prep.csv", sep = ",", as.is = TRUE)


#view the file
View(tweets.df)


#library(dplyr)

posts <- unique(select(tweets.df, 1, 2, 3, 4, 7, 9)) #key, created_time, From.User, From.User.Id, language, message

# keywords for hasan 
posts.hasan <- subset(posts, key == "imbruvica" | key == "johnson & johnson" | key == "psoriasis" | key == "rheumatoid arthritis" | key == "trilipix" )

posts.hasan.imbruvica <- subset(posts.hasan, key == "imbruvica")
posts.hasan.johnson <- subset(posts.hasan, key == "johnson & johnson")
posts.hasan.psoriasis <- subset(posts.hasan, key == "psoriasis")
posts.hasan.rheumatoid <- subset(posts.hasan, key == "rheumatoid arthritis")
posts.hasan.trilipix <- subset(posts.hasan, key == "trilipix")

posts.hasan.imbruvica1 <- posts.hasan.imbruvica[1:50,]
posts.hasan.johnson1 <- posts.hasan.johnson[1:50,]
posts.hasan.psoriasis1 <- posts.hasan.psoriasis[1:50,]
posts.hasan.rheumatoid1 <- posts.hasan.rheumatoid[1:50,]
posts.hasan.trilipix1 <- posts.hasan.trilipix[1:32,]

write.csv(posts.hasan.imbruvica1, file = "imbruvica.csv",
            quote = TRUE, row.names=FALSE,
            fileEncoding = "UTF-8", na = "NA")

write.csv(posts.hasan.johnson1, file = "johnson.csv",
            quote = TRUE, row.names=FALSE,
            fileEncoding = "UTF-8", na = "NA")

write.csv(posts.hasan.psoriasis1, file = "psoriasis.csv",
            quote = TRUE, row.names=FALSE,
            fileEncoding = "UTF-8", na = "NA")

write.csv(posts.hasan.rheumatoid1, file = "rheumatoid.csv",
            quote = TRUE, row.names=FALSE,
            fileEncoding = "UTF-8", na = "NA")

write.csv(posts.hasan.trilipix1, file = "trilipix.csv",
            quote = TRUE, row.names=FALSE,
            fileEncoding = "UTF-8", na = "NA")
