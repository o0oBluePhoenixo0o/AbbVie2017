
#random test
test<- cbind(key="keyword", fb_page)

#file combinetion
Hailian_Diseases<- rbind(AnkylosingSpondylitis_final_dataset, RheumatoidArthritis_final_dataset)
Hailian_Diseases<- rbind(Hailian_Diseases, PsoriasisSpeaks_final_dataset)
Hailian_Diseases<- rbind(Hailian_Diseases, PsoriasisMaghreb_final_dataset)
Hailian_Diseases<- rbind(Hailian_Diseases, PsoriasisDrLuqman_final_dataset)
Hailian_Diseases<- rbind(Hailian_Diseases, PsoriasisFoundation_final_dataset)
Hailian_Diseases<- rbind(Hailian_Diseases, PsoriasisTeam_final_dataset)
Hailian_Diseases<- rbind(Hailian_Diseases, newlifeoutlookpsoriasis_final_dataset)
Hailian_Diseases<- rbind(Hailian_Diseases, eczemapsoriasisshowergel_final_dataset)
Hailian_Diseases<- rbind(Hailian_Diseases, PsoriasisHealthCentral_final_dataset)

#final file export
write.csv(Hailian_Diseases, file = "Hailian_Diseases.csv", quote = TRUE, sep= ",",
          row.names=FALSE, qmethod='escape',
          fileEncoding = "UTF-8", na = "NA")

#read FB_final file

Final_FB_2403<- read.csv("/Users/hailianhou/Documents/2nd Semester/Team Project/Data/Final_FB_2403.csv")




