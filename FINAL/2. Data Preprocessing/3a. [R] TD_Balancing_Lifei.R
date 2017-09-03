




# Balancing the whole dataset
# The whole dataset is needed here. Please choose the file "Final_TW_0807_prep.csv" in the dataset folder.
# After balancing, the dataset still need preprocessing




# Read in data ##################################################################
df <- read.csv(file.choose(), encoding = "UTF-8", header = TRUE, sep = ",")



# Sampling #######################################################################
# Dividing dataset according to keywords
abbvie <- preprocess_final[preprocess_final$key=="abbvie",]
adalimumab <- preprocess_final[preprocess_final$key=="adalimumab",]
amgen <- preprocess_final[preprocess_final$key=="amgen",]
ankylosing <- preprocess_final[preprocess_final$key=="ankylosing spondylitis",]
#arthritis <- preprocess_final[preprocess_final$key=="arthritis",]
bristol <- preprocess_final[preprocess_final$key=="bristol myers",]
enbrel <- preprocess_final[preprocess_final$key=="enbrel",]
#hepatitis <- preprocess_final[preprocess_final$key=="hepatitis",]
hepatitisc <- preprocess_final[preprocess_final$key=="hepatitis c",]
humira <- preprocess_final[preprocess_final$key=="humira",]
ibrutinib <- preprocess_final[preprocess_final$key=="ibrutinib",]
imbruvica <- preprocess_final[preprocess_final$key=="imbruvica",]
psoriasis <- preprocess_final[preprocess_final$key=="psoriasis",]
rheumatoid <- preprocess_final[preprocess_final$key=="rheumatoid arthritis",]


# Counting the total tweets
count <- c(nrow(abbvie),
           nrow(adalimumab),
           nrow(amgen),
           nrow(ankylosing),
           #nrow(arthritis),
           nrow(bristol),
           nrow(enbrel),
           #nrow(hepatitis),
           nrow(hepatitisc),
           nrow(humira),
           nrow(ibrutinib),
           nrow(imbruvica),
           nrow(psoriasis),
           nrow(rheumatoid))


# Using 2/3 of the data
average <- ceiling((2*nrow(preprocess_final)/3)/length(count))


# Balancing function
balance <- function(data,average)
{
  if(nrow(data) >= average)
  {
    data_sub <- data[sample(1:nrow(data), average),]
    # Down sampling
  }
  else if(nrow(data) == average)
  {
    data_sub <- data
  }
  else
  {
    data_sub <- data
    for(i in 1:(floor(average/nrow(data))-1))
    {
      data_sub <- rbind(data_sub, data)
      # Over Sampling
      print(nrow(data_sub))
    }
    extral <- average-floor(average/nrow(data))*nrow(data)
    data_sub <- rbind(data_sub, data[sample(1:nrow(data),extral),])
  }
  return(data_sub)
}


# Implement 
abbvie_sub <- balance(abbvie, average)
adalimumab_sub <- balance(adalimumab, average)
amgen_sub <- balance(amgen, average)
ankylosing_sub <- balance(ankylosing, average)
#arthritis_sub <- balance(arthritis, average)
bristol_sub <- balance(bristol, average)
enbrel_sub <- balance(enbrel, average)
#hepatitis_sub <- balance(hepatitis, average)
hepatitisc_sub <- balance(hepatitisc, average)
humira_sub <- balance(humira, average)
ibrutinib_sub <- balance(ibrutinib, average)
imbruvica_sub <- balance(imbruvica, average)
psoriasis_sub <- balance(psoriasis, average)
rheumatoid_sub <- balance(rheumatoid, average)


# The training data set
training_set <- rbind(abbvie_sub,
                      adalimumab_sub,
                      amgen_sub,
                      ankylosing_sub,
                      #arthritis_sub,
                      bristol_sub,
                      enbrel_sub,
                      #hepatitis_sub,
                      hepatitisc_sub,
                      humira_sub,
                      ibrutinib_sub,
                      imbruvica_sub,
                      psoriasis_sub,
                      rheumatoid_sub)


view(training_set)




