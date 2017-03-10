## Crawling with Rfacebook

#Install packages
install.packages("Rfacebook")
install.packages("devtools")
install.packages("ggplot2")
install.packages("scales")
install.packages("dplyr")

#Using Rfacebook package
require (Rfacebook)
library(devtools)
# visualize evolution in metric
library(ggplot2)
library(scales)
#Table manipulation
library(dplyr)

#Get FB_Oauth
fb_oauth <- fbOAuth(app_id="204227866723896", 
                    app_secret="e39f8a7750fd165276e0d36709201f92",
                    extended_permissions = TRUE)
token <- fb_oauth

#random Testing
me <- getUsers("me", token = fb_oauth)

searchGroup("AbbVie",token)
" Group ID (the only open and official group)
278782302258949  Abbvie"
AbbVie_group <- getGroup(278782302258949, token, n = 5000)

#AbbvieGlobal page
searchPages("AbbVieGlobal",token)
AbbvieGlobal <- getPage(1213879395322100, token, n = 5000)

#Amgen page
#################################################################################

begin = "2012-01-01"
today = Sys.Date()

pagelist<-searchPages("AbbVie",token)
a<- select(filter(pagelist, category == "Medical Company"),id)
b<- nrow(a)

#Insert first page
e <- getPage(a[1,],fb_oauth,n=10000, since=begin , until = today)

for(i in 2:b)
{
  e<-try(rbind(e,getPage(a[i,], fb_oauth,n=10000, since=begin , until = today)))
  if(class(e)=="try-error")next;
}

e <- data.frame(e)

setwd("C:/Users/D065347/Downloads/Team Proj")
write.table(e, file = "Abbvie.csv", quote = TRUE, sep= ";",
            col.names = TRUE, qmethod = "double",
            fileEncoding = "UTF-16LE", na = "NA")
#Insert list of "crawling pages"?

page_crawl <- 1213879395322100
#Crawl all post from specific page

e=getPage(page_crawl, fb_oauth, n= 1000, since=begin ,  until = today)


#######################################################################
# Visualization for comments/likes/shares of AbbiveGlobal page

page <- getPage("AbbVieGlobal", token, n = 5000)
page[which.max(page$likes_count), ]
## convert Facebook date format to R date format
format.facebook.date <- function(datestring) {
  date <- as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%S+0000", tz = "GMT")
}
## aggregate metric counts over month
aggregate.metric <- function(metric) {
  m <- aggregate(page[[paste0(metric, "_count")]], list(month = page$month), 
                 mean)
  m$month <- as.Date(paste0(m$month, "-15"))
  m$metric <- metric
  return(m)
}
# create data frame with average metric counts per month
page$datetime <- format.facebook.date(page$created_time)
page$month <- format(page$datetime, "%Y-%m")
df.list <- lapply(c("likes", "comments", "shares"), aggregate.metric)
df <- do.call(rbind, df.list)

ggplot(df, aes(x = month, y = x, group = metric)) 
+ geom_line(aes(color = metric)) 
+ scale_x_date(date_breaks = "years", 
               labels = date_format("%Y")) 
                        + scale_y_log10("Average count per post", 
               breaks = c(10, 100)) + theme_bw() + theme(axis.title.x = element_blank())
