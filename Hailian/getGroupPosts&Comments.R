require(Rfacebook)

fb_oauth <- fbOAuth(app_id="259715667786273", app_secret="7e35add14d76f215b4e3f3a5a3c74bb2",extended_permissions = TRUE)

save(fb_oauth, file="fb_oauth")

load("fb_oauth")


fb_group_Psoriasis <- getGroup("2204404890", token=fb_oauth, n=100000,
                           since='2012/03/05', until='2017/03/07')
write.csv(fb_group_Psoriasis, file = "groupPosts_Psoriasis.csv")
my_Groupdata <- list()
## Getting information and likes/comments about most recent post
#for (i in c(1:length(fb_page_nytimes$id))){
for (i in c(1:length(fb_group_Psoriasis$id))){
  post_psoriasis <- getPost(post=fb_group_Psoriasis$id[i], token=fb_oauth)
  my_Groupdata[[i]] <- data.frame(post_psoriasis[3])
  if(i==1){
    psoriasisComment <- my_Groupdata[[1]]
  }
  else{
    psoriasisComment <- rbind.data.frame(psoriasisComment, my_Groupdata[[i]])
  }
}
write.csv(psoriasisComment, file = "groupComments_Psoriasis.csv")



