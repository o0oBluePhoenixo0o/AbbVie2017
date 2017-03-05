install_github("Rfacebook", "pablobarbera", subdir="Rfacebook")
install.packages("devtools")
install.packages("ggplot2")
install.packages("scales")
#Using Rfacebook package
require (Rfacebook)
library(devtools)
# visualize evolution in metric
library(ggplot2)
library(scales)

#Get FB_Oauth
fb_oauth <- fbOAuth(app_id="204227866723896", 
                    app_secret="e39f8a7750fd165276e0d36709201f92",
                    extended_permissions = TRUE)
token <- fb_oauth

#random Testing
me <- getUsers("me", token = fb_oauth)

me

searchGroup("AbbVie",token)
" Group ID (the only open and official group)
278782302258949  Abbvie"

AbbVie_group <- getGroup(278782302258949, token, n = 5000)
AbbvieGlobal <- getPage("AbbVieGlobal", token, n = 5000)
searchGroup("AbbVie",token)

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

ggplot(df, aes(x = month, y = x, group = metric)) + geom_line(aes(color = metric)) + 
  scale_x_date(date_breaks = "years", 
               labels = date_format("%Y")) + scale_y_log10("Average count per post", 
              breaks = c(10, 100)) + theme_bw() + theme(axis.title.x = element_blank())