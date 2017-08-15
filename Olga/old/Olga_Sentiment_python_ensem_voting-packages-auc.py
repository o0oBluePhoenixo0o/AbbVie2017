
# coding: utf-8

# In[2]:

#Download the libraries
import nltk
import re
from sklearn.metrics import confusion_matrix
import pandas as pd
import numpy as np
import csv
import os
import matplotlib.pyplot as plt
import sys
import time
import random
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn import svm
from sklearn.metrics import classification_report
from sklearn.cross_validation import train_test_split
import numpy as np
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from collections import Counter
from textblob import TextBlob
from textblob import Blobber
from textblob.sentiments import NaiveBayesAnalyzer
from sklearn.externals import joblib
import cPickle as pickle


# Setting working directory

# In[3]:

print os.getcwd();


# In[4]:

os.chdir("/Users/imacair/Desktop/Products3/")


# Read the file

# In[5]:

data= pd.read_csv('Final_Manual_3006.csv',
                    encoding='latin-1',delimiter=',')


# In[6]:

#Converts text into ASCII


# In[7]:

#data.text = data.text.str.encode('ascii','replace')


# In[8]:

data.message = data.message.str.encode('ascii','replace')


# In[9]:

len(data)


# In[10]:

#sample_data= data.sample(n=64000)


# In[ ]:




# In[11]:

sample_data= data


# In[12]:

#data_t=sample_data["text"]


# In[13]:

data_t=sample_data["message"]


# In[14]:

len(data_t)


# In[ ]:




# In[15]:

#lowercase
data_t = data_t.str.lower()


# In[16]:

data_s=sample_data["sentiment"]


# In[17]:

np.unique(data_s)


# In[18]:

#data_s= data_s[~np.isnan(data_s)]


# In[19]:

#Convert to the neg, pos and neu scale
final = data
res5= pd.DataFrame( index=range(0,len(data_t)),columns = {'new_sent'} )
res5[(final.sentiment==u'2')] = 'neg'
res5[(final.sentiment==u'1')] = 'neg'
res5[(final['sentiment']==u'3')] = 'pos'
res5[(final['sentiment']==u'4')] = 'pos'
res5[(final['sentiment']==u'N')] = 'neu'
res5[(final['sentiment']==u"n")] = 'neu'
final=pd.concat([final, res5], axis=2)
#What result we have in sentiment now
np.unique(final.new_sent)


# In[20]:

#final['sentiment'] = final['sentiment'][~pd.isnull(final['sentiment'])]


# In[21]:

#final['sentiment']=np.nan_to_num(final['sentiment'])
#final['sentiment'] = final[~np.isnan('sentiment')]
#y = 
#final['sentiment'][~np.isfinite(final['sentiment'])]


# In[22]:

np.unique(final.new_sent)


# Abbriviation translation

# In[23]:

with open('abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower():rows[1].lower() for rows in reader              
                  }


# In[24]:

#replacement


# In[25]:

#replacement = {
##'r':'are',
#'y':'why',
#'u':'you'}


# In[26]:

##How in works
s1 = 'y r u l8'

s2 = ' '.join([replacement.get(w, w) for w in s1.split()])
s2


# In[27]:

result = pd.DataFrame()
result = final


# In[28]:

for i in range(len(result)):
    data_t.values[i]=' '.join([replacement.get(w, w) for w in data_t.values[i].split()])


# In[29]:


text = data_t.to_string()
text = nltk.word_tokenize(text)
fdist = nltk.FreqDist(text)
s2 = set([w for w in set(text) if len(w) > 2 and fdist[w] > 2])
for i in range(len(result)):
    data_t.values[i]=' '.join(filter(lambda w: w in s2,data_t.values[i].split()))


# In[ ]:




# In[30]:

from nltk.corpus import stopwords
s=set(stopwords.words('english'))
for i in range(len(result)):
    data_t.values[i]=' '.join(filter(lambda w: not w in s,data_t.values[i].split()))


# In[31]:

data_t


# In[32]:

data_t.head(10)


# In[33]:

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


# In[34]:

data_t.head(10)


# Spliting the data
# 

# In[35]:

from sklearn.cross_validation import train_test_split
import numpy as np
from sklearn.model_selection import KFold


# In[36]:

data_train, data_test, label_train, label_test = train_test_split(data_t, final.new_sent, test_size=0.3, random_state=2340)


# In[37]:

#data_train, data_test, label_train, label_test = train_test_split(data_t, data_s, test_size=0.3, random_state=2340)


# In[38]:

t0 = time.time()
vectorizer = TfidfVectorizer(    sublinear_tf=True,
                                 use_idf=True,stop_words = 'english')
train_vectors = vectorizer.fit_transform(data_train)
test_vectors = vectorizer.transform(data_test)
t1 = time.time()
time_vec = t1-t0


# In[39]:

print(time_vec)


# In[40]:

#Use vader package to get the sentiment
analyzer = SentimentIntensityAnalyzer()
res= pd.DataFrame( index=range(0,len(data_test)),columns = {'SentimentVader'} )
#Convert sentiment to neu, neg, pos
for i in range(len(data_test)):
    vs = analyzer.polarity_scores(data_test.values[i])
    if ((vs['compound']==0)):
        res.values[i]= 'neu' 
    elif ((vs['compound'] < 0)):
        res.values[i]= 'neg'
    else:
        res.values[i]= 'pos'
vader = res.SentimentVader


# In[41]:

#Readjust index so it won't affect the loops
data_test.index = range(0,len(data_test))


# In[42]:

#Use textblob to get polarity of text
res6= pd.DataFrame( index=range(0,len(data_test)),columns = {'SentimentPat'} )
for i in range(len(data_test)):
    testimonial = TextBlob(data_test.values[i])
    res6.values[i]= testimonial.sentiment.polarity
#Convert polarity to normal pos, neg, neu
textblob1= pd.DataFrame( index=range(0,len(data_test)),columns = {'SentimentPat'} )
textblob1.SentimentPat[(res6['SentimentPat']>0)]='pos'
textblob1.SentimentPat[(res6['SentimentPat']<0)]='neg'
textblob1.SentimentPat[(res6['SentimentPat']==0)]='neu'


# In[43]:

#Use textblob to get polarity of text with Naive Bayes analyzer
tb = Blobber(analyzer=NaiveBayesAnalyzer())
textblob2= pd.DataFrame( index=range(0,len(data_test)),columns = {'sentimentNB'} )
for i in range(len(data_test)):
    textblob2['sentimentNB'][i]= tb(data_test[i]).sentiment.classification


# In[44]:

vader = np.asarray(vader)
#label_tests = np.asarray(label_test)
#Create a Data Frame
df=[vader]
df = pd.DataFrame(df)
df = df.transpose()
df.columns = [ 'vader']
df["SentimentPat"] = textblob1
df["sentimentNB"] = textblob2
#df["True labels"] =label_tests
df


# In[45]:

#Find the maximum in a row (Majority voting)
df2= pd.DataFrame( index=range(0,len(data_test)),columns = {'final'} )
for i in range(len(data_test)):
    d=Counter(df.ix[i,:])
    dfin=d.most_common(1)[0][0]
    df2.values[i]= dfin
df["final"] = df2


# In[46]:

df2


# In[47]:

label_tests = np.asarray(label_test)
df["True labels"] =label_tests
df


# In[48]:

from sklearn.metrics import roc_curve, auc, roc_auc_score


# In[49]:

label_tests = np.asarray(label_test)
vader = np.asarray(vader)


# In[50]:

vader[1]


# In[51]:

final.new_sent.shape


# In[52]:

from sklearn.metrics import roc_auc_score
from sklearn.preprocessing import LabelBinarizer

def multiclass_roc_auc_score(truth, pred, average="macro"):

    lb = LabelBinarizer()
    lb.fit(truth)

    truth = lb.transform(truth)
    pred = lb.transform(pred)

    return roc_auc_score(truth, pred, average=average)


# In[53]:

multiclass_roc_auc_score(label_test, vader, average="macro")


# In[54]:

multiclass_roc_auc_score(label_test, textblob1, average="macro")


# In[55]:

multiclass_roc_auc_score(label_test, textblob2, average="macro")


# In[56]:

multiclass_roc_auc_score(label_test, df2, average="macro")


# In[ ]:




# In[ ]:



