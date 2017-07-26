
# coding: utf-8

# In[45]:

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
from sklearn.model_selection import KFold
from sklearn.naive_bayes import MultinomialNB
from sklearn.ensemble import RandomForestClassifier
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from collections import Counter
from textblob import TextBlob
from textblob import Blobber
from textblob.sentiments import NaiveBayesAnalyzer


# In[46]:

#Setting working directory
print os.getcwd();
os.chdir("/Users/imacair/Desktop/Products3/")


# In[47]:

#Read the file
data= pd.read_csv('Final_Manual_3006.csv',
                    encoding='latin-1',delimiter=',')


# In[48]:

#Converts text into ASCII
data.message = data.message.str.encode('ascii','replace')


# In[49]:

#Take only one column with text
data_t=data["message"]
#Lowercase
data_t = data_t.str.lower()
#Take only one column with sentiment
data_s=data["sentiment"]


# In[50]:

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


# In[60]:

#Abbriviation translation
#Reading file with abbriviation
with open('abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower():rows[1].lower() for rows in reader              
                  }
result = pd.DataFrame()
result = final
#Replacement in file
for i in range(len(result)):
    data_t.values[i]=' '.join([replacement.get(w, w) for w in data_t.values[i].split()])


# In[61]:

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


# In[62]:

#Splittig the file for training and testing
data_train, data_test, label_train, label_test = train_test_split(data_t, final.new_sent, test_size=0.33, random_state=2340)


# In[64]:

#Vectorization
vectorizer = TfidfVectorizer(    sublinear_tf=True,
                                 use_idf=True,stop_words = 'english')
train_vectors = vectorizer.fit_transform(data_train)
test_vectors = vectorizer.transform(data_test)


# In[16]:

# Perform classification with SVM, kernel=linear
classifier_linear = svm.SVC(kernel='linear')
classifier_linear.fit(train_vectors, label_train)
prediction_linear = classifier_linear.predict(test_vectors)


# In[17]:

# Perform classification with SVM, kernel=linear
classifier_liblinear = svm.LinearSVC()
classifier_liblinear.fit(train_vectors, label_train)
prediction_liblinear = classifier_liblinear.predict(test_vectors)


# In[18]:

# Perform classification with random forest
classifier_rf = RandomForestClassifier()
classifier_rf.fit(train_vectors, label_train)
prediction_rf = classifier_rf.predict(test_vectors)


# In[19]:

# Perform classification with Multinomial Naïve Bayes.
classifier_nb = MultinomialNB()
classifier_nb.fit(train_vectors, label_train)
prediction_nb = classifier_nb.predict(test_vectors)


# In[21]:

#from sklearn.ensemble import VotingClassifier
#from sklearn import model_selection
#kfold = model_selection.KFold(n_splits=10, random_state=8)


# In[67]:

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


# In[68]:

#Readjust index so it won't affect the loops
data_test.index = range(0,len(data_test))


# In[27]:

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


# In[70]:

#Use textblob to get polarity of text with Naive Bayes analyzer
tb = Blobber(analyzer=NaiveBayesAnalyzer())
textblob2= pd.DataFrame( index=range(0,len(data_test)),columns = {'sentimentNB'} )
for i in range(len(data_test)):
    textblob2['sentimentNB'][i]= tb(data_test[i]).sentiment.classification


# In[72]:

#Convert to np arrays
label_tests = np.asarray(label_test)
vader = np.asarray(vader)

#Create a Data Frame
df=[label_tests, prediction_linear, prediction_liblinear, prediction_rf,prediction_nb,vader]
df = pd.DataFrame(df)
df = df.transpose()
df.columns = ['label_tests','prediction_linear', 'prediction_liblinear', 'prediction_rf','prediction_nb','vader']
df["SentimentPat"] = textblob1
df["sentimentNB"] = textblob2
#df


# In[73]:

#Find the maximum in a row (Majority voting)
df2= pd.DataFrame( index=range(0,len(data_test)),columns = {'final'} )
for i in range(len(data_test)):
    d=Counter(df.ix[i,:])
    dfin=d.most_common(1)[0][0]
    df2.values[i]= dfin
df["final"] = df2


# In[74]:

#Dataframe preview
df


# In[76]:

#Output column
df2


# In[ ]:




# In[ ]:




# In[ ]:



