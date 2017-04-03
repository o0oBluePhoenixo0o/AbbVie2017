## Install the packages we need
install.packages("devtools")
library(devtools)
install_github("Rfacebook", "pablobarbera", subdir="Rfacebook")
require (Rfacebook)

## Require the app_id and the secret token to successfully login to fb api account
fb_oauth <- fbOAuth(app_id="***************", app_secret="***************",extended_permissions = TRUE)
save(fb_oauth, file="fb_oauth")
token <- fb_oauth
load("fb_oauth")

## Get the post from page

# Search the page id by editing the string
id_page <- searchPages(string="*****", token=fb_oauth, n=100)
id_page

# page:you can either get the post from page by its id or pagename
# n:et the maximum posts
# since, until: set the time period you want to retrieve from the page
fb_page <- getPage(page="*****", token=fb_oauth, n=100000, feed=TRUE, reactions=TRUE,
                   since='2012/01/01', until='2017/03/08')

# Save the post dataframe into csv file
write.csv(fb_page, file = "post_**********.csv")

## Get the comments of each post from page
my_data <- list()
for (i in c(1:length(fb_page$id))){
  post_page <- getPost(post=fb_page$id[i], token=fb_oauth)
  my_data[[i]] <- data.frame(post_page[3])
  if(i==1){
    comment_page <- my_data[[1]]
  }
  else{
    comment_page <- rbind.data.frame(comment_page, my_data[[i]])
  }
}

#Save the comment dataframe into csv file
write.csv(comment_page, file = "comment_**********.csv")

## Get the post from public group
# Search the group id by editing the name
# Will see private and public group id regarding the the name you want to search
id_group <- searchGroup(name="**********", token=fb_oauth)
id_group

# group_id:you need to get the post from group by its id
# n:set the maximum posts you want to retrieve
# since, until: set the time period you want to retrieve from the public group
fb_group <- getGroup(group_id=**********, token=fb_oauth, n=100000, feed=TRUE,
                     since='2012/01/01', until='2017/03/08')

# Save the post dataframe into csv file
write.csv(fb_group, file = "post_**********.csv")
my_data <- list()

## Get the comment of each post from public group
for (i in c(1:length(fb_group$id))){
  post_group <- getPost(post=fb_group$id[i], token=fb_oauth)
  my_data[[i]] <- data.frame(post_group[3])
  if(i==1){
    comment_group <- my_data[[1]]
  }
  else{
    comment_group <- rbind.data.frame(comment_group, my_data[[i]])
  }
}

#Save the comment dataframe into csv file
write.csv(comment_group, file = "comment_**********.csv")
