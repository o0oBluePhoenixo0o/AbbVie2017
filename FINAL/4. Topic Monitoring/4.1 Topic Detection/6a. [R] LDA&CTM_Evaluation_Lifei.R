



# Evaluation



# LDA evaluation #############################################################################
# Here, we need to choose the three manually labeling files in our dataset folder
# "lda_hailian_label.csv"
hailiabn_df <- read.csv(file.choose(),sep = ",")
# "lda_lifei_label.csv"
lifei_df <- read.csv(file.choose(),sep = ",")
# "lda_chien_label.csv"
chien_df <- read.csv(file.choose(),sep = ",")


# Only select the lable columns
hailian_label <- as.matrix(hailiabn_df$hailian_label)
lifei_label <- as.matrix(lifei_df$Lifei_label)
chien_label <- as.matrix(chien_df$chien_check)


# LDA voting
lda_label <- hailian_label+lifei_label+chien_label
for(i in 1:500)
{
  if(lda_label[i]<=1)
  {
    lda_label[i]=0
  }
  else
  {
    lda_label[i]=1
  }
}


# LDA model confidence for assign topcis back
lda_model <- as.matrix(lifei_df$probability)
for(i in 1:500)
{
  if(lda_model[i]<=0.5)
  {
    lda_model[i]=0
  }
  else
  {
    lda_model[i]=2
  }
}


# Confusion matrisx
sum <- lda_label+lda_model
View(sum)


# Using the "Filter" button above 
# 0 indicates FF
# 1 indicates TF
# 2 indicates FT
# 3 indicates TT



# CTM evaluation #############################################################################
# Here, we need to choose the three manually labeling files in our dataset folder
# "ctm_hailian_label.csv"
hailiabn_df <- read.csv(file.choose(),sep = ",")
# "ctm_lifei_label.csv"
lifei_df <- read.csv(file.choose(),sep = ",")
# "ctm_chien_label.csv"
chien_df <- read.csv(file.choose(),sep = ",")


# Only select the lable columns
hailian_label <- as.matrix(hailiabn_df$hailian_label)
lifei_label <- as.matrix(lifei_df$Lifei_label)
chien_label <- as.matrix(chien_df$chien_check)


# LDA voting
ctm_label <- hailian_label+lifei_label+chien_label
for(i in 1:500)
{
  if(ctm_label[i]<=1)
  {
    ctm_label[i]=0
  }
  else
  {
    ctm_label[i]=1
  }
}


# LDA model confidence for assign topcis back
ctm_model <- as.matrix(lifei_df$probability)
for(i in 1:500)
{
  if(ctm_model[i]<=0.5)
  {
    ctm_model[i]=0
  }
  else
  {
    ctm_model[i]=2
  }
}


# Confusion matrisx
sum <- ctm_label+ctm_model
View(sum)


# Using the "Filter" button above 
# 0 indicates FF
# 1 indicates TF
# 2 indicates FT
# 3 indicates TT





