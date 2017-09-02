
# coding: utf-8

# Import of libraries

# In[3]:

import nltk


# In[4]:

import re
from sklearn.metrics import confusion_matrix


# In[5]:

import pandas as pd
import numpy as np


# In[6]:

import csv


# In[7]:

import os
import matplotlib.pyplot as plt


# In[8]:


import sys
import os
import time


# In[9]:

import random


# In[10]:


from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn import svm
from sklearn.metrics import classification_report


# Setting working directory

# In[11]:

print os.getcwd();


# In[12]:

os.chdir("/Users/imacair/Desktop/Products3/")


# Read the file

# In[13]:

data = pd.read_csv('Final_Manual_1905.csv', encoding= "latin-1",delimiter=',',low_memory=False)
#data



# In[14]:

data.head(10)


# In[15]:

#Converts text into ASCII


# In[16]:

data.message = data.message.str.encode('ascii','replace')


# In[17]:

data.sentiment = data.sentiment.str.encode('utf-8','replace')


# In[18]:

#number of elements
len(data)


# In[19]:

#In case if you need a sample of data
#sample_data= data.sample(n=64000)


# In[20]:

sample_data= data


# In[21]:

data_t=sample_data["message"]


# In[22]:

len(data_t)


# In[23]:

#lowercase before abbriviation translation
data_t = data_t.str.lower()


# In[24]:

data_s=sample_data["sentiment"]


# In[ ]:




# Abbriviation translation raplacing elements from file 

# In[25]:

with open('abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower():rows[1].lower() for rows in reader              
                  }


# In[26]:

#replacement


# In[27]:

#replacement = {
##'r':'are',
#'y':'why',
#'u':'you'}


# In[28]:

##How in works
s1 = 'y r u l8'

s2 = ' '.join([replacement.get(w, w) for w in s1.split()])
s2


# In[29]:

result = pd.DataFrame()
result = data_t


# In[30]:

for i in range(len(result)):
    data_t.values[i]=' '.join([replacement.get(w, w) for w in data_t.values[i].split()])


# In[31]:

data_t.head(10)


# In[32]:

#lowercase
data_t = data_t.str.lower()
#Remove urls
data_t= data_t.str.replace(r'(http.*) |(http.*)$|\n', "",)
#Remove twitter handles
data_t = data_t.str.replace(r"@\\w+", "")
#remove htmls
data_t = data_t.str.replace(r'<.*?>', "")
#Remove citations
data_t = data_t.str.replace(r'@[a-zA-Z0-9]*', "")

#remove _
#data_t = data_t.str.replace(r'\_+',"")


# In[33]:

data_t.head(10)


# In[34]:

from textblob import TextBlob


# In[35]:

data_t.head(10)


# In[36]:

#Creating a column for polarity
res= pd.DataFrame(np.random.randn(len(data_t), 1),columns = {'polarity'} )


# In[37]:

#Creating a column for subjectivity
res2= pd.DataFrame(np.random.randn(len(data_t), 1),columns = {'subjectivity'} )


# Filling the columns with values

# In[38]:

for i in range(len(data_t)):
    testimonial = TextBlob(data_t.values[i])
    res.values[i]= testimonial.sentiment.polarity


# In[39]:

for i in range(len(data_t)):
    testimonial = TextBlob(data_t.values[i])
    res2.values[i]= testimonial.sentiment.subjectivity


# Merging with initial df

# In[40]:

final=pd.concat([data_t, res], axis=1)


# In[41]:

final=pd.concat([final, res2], axis=1)


# In[42]:

final=pd.concat([final, data_s], axis=1)


# In[43]:

#Test on one value
testimonial = TextBlob(data_t.values[2])
testimonial.sentiment.polarity


# In[44]:

final


# In[45]:

res6= pd.DataFrame( index=range(0,len(data_t)),columns = {'SentimentPat'} )


# In[46]:

#Creating a clumn with clear sentiment
res6.SentimentPat[(final['polarity']>0)]='pos'
res6.SentimentPat[(final['polarity']<0)]='neg'
res6.SentimentPat[(final['polarity']==0)]='neu'


# In[47]:

final=pd.concat([final, res6], axis=1)


# In[48]:

from sklearn.metrics import confusion_matrix

#final.sentiment[which(final.sentiment=="1")]<-"neg"


# In[49]:

final


# Applying second method from Textblob NB

# In[50]:

from textblob.sentiments import NaiveBayesAnalyzer


# In[51]:

from textblob import Blobber
tb = Blobber(analyzer=NaiveBayesAnalyzer())

print tb("sentence you want to test").sentiment.classification


# In[52]:

tb(data_t[3]).sentiment.p_pos


# In[53]:

#Creating a column for results
res4= pd.DataFrame( index=range(0,len(data_t)),columns = {'sentimentNB','pposNB','pnegNB'} )


# In[54]:

res4


# In[55]:

for i in range(len(data_t)):
    res4['sentimentNB'][i]= tb(data_t[i]).sentiment.classification
    res4['pposNB'].values[i]= tb(data_t[i]).sentiment.p_pos
    res4['pnegNB'].values[i]= tb(data_t[i]).sentiment.p_neg


# In[56]:

res4


# In[57]:

final=pd.concat([final, res4], axis=2)


# In[58]:

final


# In[59]:

final.sentimentNB[(final['pposNB']<0.7) &(final['pposNB']>0.3) & (final['pnegNB']<0.7) & (final['pnegNB']>0.3)]='neu'


# In[60]:

res5= pd.DataFrame( index=range(0,len(data_t)),columns = {'new_sent'} )
#final.sentiment[1][(final['sentiment']==u'2') &(final['sentiment']==u'1')] = 'neg'
#final=pd.concat([final, res5], axis=2)


# In[61]:

final.sentiment[0]


# In[62]:

res5[(final.sentiment==u'2')] = 'neg'
res5[(final.sentiment==u'1')] = 'neg'
res5[(final['sentiment']==u'3')] = 'pos'
res5[(final['sentiment']==u'4')] = 'pos'
res5[(final['sentiment']==u'N')] = 'neu'
final=pd.concat([final, res5], axis=2)
#res5


# In[63]:

final


# In[64]:

from sklearn.metrics import confusion_matrix


# Creating confusion matrix

# In[65]:

print(confusion_matrix(final.new_sent, final.sentimentNB).transpose())


# In[66]:

print(confusion_matrix(final.new_sent, final.SentimentPat).transpose())


# In[67]:

print(len(final[(final['SentimentPat']=='neg') & (final['new_sent']=='pos')]))
##print(len(final[(final['sentimentNB']=='pos') & (final['sentiment']<u'3')]))
#print(len(final[(final['sentimentNB']=='neg') & (final['sentiment']>u'2')]))
#print(len(final[(final['sentimentNB']=='neg') & (final['sentiment']<u'3')])) 


# In[ ]:



