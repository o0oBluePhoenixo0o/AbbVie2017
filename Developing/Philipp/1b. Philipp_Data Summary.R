#Using Rfacebook package
require (Rfacebook)
library(devtools)
# visualize evolution in metric
library(ggplot)
library(scales)


setwd("~/GitHub/AbbVie2017/Philipp")

#Get FB_Oauth
fb_oauth <- fbOAuth(app_id="204227866723896", 
                    app_secret="05eb011fc8a93ad135f7e78a8355bb57",
                    extended_permissions = TRUE)

x <- fb_oauth

x <- "EAACEdEose0cBAELk3BuRwujLqlU1OEF0HiBZAolYqu0V99UjS9OfGC8qfE3MMxO7VPKmNSobf1M4KdvBAvvpbcYjsUj7WMtKy3uxBxe1wMGZBwPljcCOf0d9Bqeitw0SbR8PP1c3x9o7Q5DJMEnHzKSxF9z216IQZBd3iVFVjMkeebclxCKB2ijOBhImDLXPGkqZB6ux5wZDZD"
#############################################
# Visualization for comments/likes/shares   #
#############################################

SummaryPage <- function(key){
  
  cat(paste("Getting data for keyword: ",key,"\n", sep = " "))
  
  #only get the highest "talking_about_count" page for visualization
  pagelist<- select(arrange(filter(searchPages(key,x, n = 1000000), 
                                   (category == "Medical Company" | category =="Pharmaceuticals" |
                                      category == "Biotechnology Company"| category =="Medical & Health")& talking_about_count>0),
                            desc(talking_about_count)),
                    id, name, talking_about_count)
  
  cat(paste("\nTotal of relevant pages is: ",nrow(pagelist),"\n"))
  
  begin = "2012-01-01"
  today = Sys.Date()
  
  #pulling data for page_df and comment_df 
  for (i in 1:nrow(pagelist))
  {
    cat("\n")
    cat(paste("Getting posts from page number ",i," with ID: ", pagelist[i,1], "\n"))
    page <- getPage(pagelist[i,1],x,n=100000, since=begin , until = today,
                    feed = TRUE, reactions = TRUE)
    
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
    # visualize evolution in metric
    ggplot(df, aes(x = month, y = x, group = metric)) + geom_line(aes(color = metric)) + 
      scale_x_date(date_breaks = "years", labels = date_format("%Y")) + scale_y_log10("Average count per post", 
                                                                                      breaks = c(10, 100, 1000, 10000, 50000)) + theme_bw() + theme(axis.title.x = element_blank())
    ggsave(paste(i, "_",pagelist[i,1],"_",pagelist[i,2],".png"))
  }
}

SummaryPage("AbbVie")
SummaryPage("Bristol-Myers Squibb")
SummaryPage("Amgen")

