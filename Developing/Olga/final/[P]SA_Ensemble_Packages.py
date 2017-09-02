
# coding: utf-8

# In[1]:

#Download the libraries
import nltk
import re
import pandas as pd
import numpy as np
import csv
import os
import random
import numpy as np
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from collections import Counter
from textblob import TextBlob
from textblob import Blobber
from textblob.sentiments import NaiveBayesAnalyzer


# Setting working directory

# In[2]:

print os.getcwd();


# In[3]:

os.chdir("/Users/imacair/Desktop/Products3/")


# Read the file

# In[4]:

#Converts text into ASCII


# In[5]:

data_t= "I like Humira, but I hate it"
data_t = data_t.decode('ascii','replace')
data_t


# In[6]:

#lowercase
data_t = data_t.lower()


# Abbriviation translation

# In[7]:

with open('abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower():rows[1].lower() for rows in reader              
                  }


# In[8]:

result = pd.DataFrame()
result = data_t


# In[9]:

for i in range(len(result)):
    data_t=' '.join([replacement.get(w, w) for w in data_t.split()])


# In[10]:

from nltk.corpus import stopwords
s=set(stopwords.words('english'))
for i in range(len(result)):
    data_t=' '.join(filter(lambda w: not w in s,data_t.split()))


# In[11]:

#lowercase
data_t = data_t.lower()
#Remove urls
data_t= data_t.replace(r'(http.*) |(http.*)$|\n', "",)
#Remove twitter handles
data_t = data_t.replace(r"@\\w+", "")
#remove htmls
data_t = data_t.replace(r'<.*?>', "")
#Remove citations
data_t = data_t.replace(r'@[a-zA-Z0-9]*', "")
#remove _
#data_t = data_t.str.replace(r'\_+',"")


# Spliting the data
# 

# In[12]:

#Use vader package to get the sentiment
analyzer = SentimentIntensityAnalyzer()
res= pd.DataFrame( index=range(0,1),columns = {'SentimentVader'} )

#Convert sentiment to neu, neg, pos
for i in range(1):
    vs = analyzer.polarity_scores(data_t)
    if ((vs['pos']>0)):
        res.values[i]= 'pos' 
    elif ((vs['neg'] < 0)):
        res.values[i]= 'neg'
    else:
        res.values[i]= 'neu'
vader = res.SentimentVader


# In[13]:

#Use textblob to get polarity of text
res6= data_t
testimonial = TextBlob(data_t)
res6= testimonial.sentiment.polarity
#Convert polarity to normal pos, neg, neu
textblob1= res6
if ((res6>0)):
    textblob1= 'pos' 
elif ((res6<0)):
    textblob1= 'neg' 
else:
    textblob1= 'neu' 


# In[14]:

#Use textblob to get polarity of text with Naive Bayes analyzer
tb = Blobber(analyzer=NaiveBayesAnalyzer())
textblob2= pd.DataFrame( index=range(0,1),columns = {'sentimentNB'} )
textblob2['sentimentNB']= tb(data_t).sentiment.classification


# In[15]:

vader = np.asarray(vader)

#Create a Data Frame
df=[vader]
df = pd.DataFrame(df)
df = df.transpose()
df.columns = [ 'vader']
df["SentimentPat"] = textblob1
df["sentimentNB"] = textblob2
#df


# In[16]:

#Find the maximum in a row (Majority voting)
df2= pd.DataFrame( index=range(0,1), columns = {''} )
for i in range(1):
    d=Counter(df.ix[i,:])
    dfin=d.most_common(1)[0][0]
    df2.values[i]= dfin
#df["final"] = df2
data = df2.values[0]
data = ''.join(data)


# In[17]:

data


# In[ ]:




# In[ ]:



