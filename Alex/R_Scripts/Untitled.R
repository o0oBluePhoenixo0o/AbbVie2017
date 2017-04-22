library(dplyr)
posts <- unique(select(facebookMaster.df, 2, 4, 5, 6, 7, 8, 12, 13)) #key, likes_count.x, message.x, from.id, from.name, created_time.x, comments_count, shares_count

# Companies 
posts.companies <- subset(posts, key == "AbbVie" | key == "Amgen" | key == "Bristol-Myers Squibb" )


# AbbVie
posts.companies.abbvie = subset(posts.companies, key == "AbbVie")
posts.companies.abbvie$created_time.x <- as.Date(posts.companies.abbvie$created_time.x)
posts.companies.abbvie$created_time.x.day <- format(posts.companies.abbvie$created_time.x, '%d')
posts.companies.abbvie$created_time.x.month <- format(posts.companies.abbvie$created_time.x, '%m')
posts.companies.abbvie$created_time.x.year <- format(posts.companies.abbvie$created_time.x, '%Y')

df2 <- aggregate(message.x ~created_time.x.month + created_time.x.year + from_name.x, data = posts.companies.abbvie, NROW)


# Bristol
posts.companies.bristol = subset(posts.companies, key == "Bristol-Myers Squibb")
posts.companies.bristol$created_time.x <- as.Date(posts.companies.bristol$created_time.x)
posts.companies.bristol$created_time.x.day <- format(posts.companies.bristol$created_time.x, '%d')
posts.companies.bristol$created_time.x.month <- format(posts.companies.bristol$created_time.x, '%m')
posts.companies.bristol$created_time.x.year <- format(posts.companies.bristol$created_time.x, '%Y')

df2 <- aggregate(message.x ~ created_time.x.day + created_time.x.month + created_time.x.year + from_name.x, data = posts.companies.bristol, NROW)

# Amgen
posts.companies.amgen = subset(posts.companies, key == "Amgen")
posts.companies.amgen$created_time.x <- as.Date(posts.companies.amgen$created_time.x)
posts.companies.amgen$created_time.x.day <- format(posts.companies.amgen$created_time.x, '%d')
posts.companies.amgen$created_time.x.month <- format(posts.companies.amgen$created_time.x, '%m')
posts.companies.amgen$created_time.x.year <- format(posts.companies.amgen$created_time.x, '%Y')

df2 <- aggregate(message.x ~ created_time.x.day + created_time.x.month + created_time.x.year + from_name.x, data = posts.companies.amgen, NROW)
