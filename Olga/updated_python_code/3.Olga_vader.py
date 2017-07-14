
# coding: utf-8

# Download libraries

# In[3]:

import sys
import os
import time
import csv


# In[4]:

from nltk.sentiment.vader import SentimentIntensityAnalyzer


# In[5]:

import pandas as pd
import numpy as np


# In[6]:

from sklearn.cross_validation import train_test_split
import numpy as np


# In[7]:


from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn import svm
from sklearn.metrics import classification_report


# In[ ]:




# Set working directory

# In[8]:

print os.getcwd();


# Reads the file

# In[9]:

os.chdir("/Users/imacair/Desktop/Products3/")


# In[10]:

data = pd.read_csv('Final_Manual_1905.csv', encoding= "latin-1",delimiter=',',low_memory=False)


# In[11]:

#Converts text into ASCII
data.message = data.message.str.encode('ascii','replace')
data.sentiment = data.sentiment.str.encode('utf-8','replace')


# In[12]:

len(data)


# Take a sample from data

# In[13]:

data_t=data["message"]


# In[14]:

#lowercase before abbriviation translation
data_t = data_t.str.lower()


# In[15]:

#takes sentiment
data_s=data["sentiment"]


# Preprocess the data

# Replacement of abbriviations

# In[16]:

with open('abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower():rows[1].lower() for rows in reader              
                  }


# In[17]:

##How in works
s1 = 'y r u l8'

s2 = ' '.join([replacement.get(w, w) for w in s1.split()])
s2


# In[18]:

result = pd.DataFrame()
result = data_t


# In[19]:

for i in range(len(result)):
    data_t.values[i]=' '.join([replacement.get(w, w) for w in data_t.values[i].split()])


# In[20]:

data_t.head()


# In[21]:

type(result)


# In[22]:

data_t=result


# In[23]:

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


# In[24]:

#Start of sentiment analysis


# In[25]:

analyzer = SentimentIntensityAnalyzer()


# In[26]:

analyzer.polarity_scores(data_t[190])


# In[27]:

res= pd.DataFrame( index=range(0,len(data_t)),columns = {'SentimentVader'} )


# In[28]:

for i in range(len(data_t)):
    vs = analyzer.polarity_scores(data_t.values[i])
    if ((vs['compound']==0)):
        res.values[i]= 'neu' 
    elif ((vs['compound'] < 0)):
        res.values[i]= 'neg'
    else:
        res.values[i]= 'pos'
    


# In[29]:

res.SentimentVader


# In[30]:

data_t.head(10)


# In[31]:

from textblob import TextBlob


# In[32]:

final=pd.concat([data_t, res], axis=1)
final=pd.concat([final, data_s], axis=1)


# In[33]:

res5= pd.DataFrame( index=range(0,len(data_t)),columns = {'new_sent'} )
res5[(final.sentiment==u'2')] = 'neg'
res5[(final.sentiment==u'1')] = 'neg'
res5[(final['sentiment']==u'3')] = 'pos'
res5[(final['sentiment']==u'4')] = 'pos'
res5[(final['sentiment']==u'N')] = 'neu'
final=pd.concat([final, res5], axis=2)


# In[34]:

final


# In[35]:

from sklearn.metrics import confusion_matrix


# In[36]:

print(confusion_matrix(final.new_sent, final.SentimentVader).transpose())


# In[37]:

print(len(final[(final['SentimentVader']=='neg') & (final['new_sent']=='pos')]))


# In[ ]:



