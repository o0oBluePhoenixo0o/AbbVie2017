
# coding: utf-8

# In[5]:

#Download the libraries
import nltk
import re
import pandas as pd
import numpy as np
import csv
import os
import random
import numpy as np
from sklearn.externals import joblib


# In[6]:

# Setting working directory
#print os.getcwd()
#os.chdir("/Users/imacair/Desktop/Products3/")


# In[4]:

#Converts text into ASCII


# In[8]:

data_t = sys.argv[1]
data_t = data_t.decode('ascii','replace')


# In[9]:

#lowercase
data_t = data_t.lower()


# In[6]:

#Abbriviation translation
with open('./ML/Python/abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower(): rows[1].lower() for rows in reader}


# In[10]:

result = pd.DataFrame()
result = data_t


# In[11]:

for i in range(len(result)):
    data_t=' '.join([replacement.get(w, w) for w in data_t.split()])


# In[13]:

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


# In[14]:

#Loading the models


# In[15]:

sclf = joblib.load('stacking.pkl')


# In[13]:

vec = joblib.load('vec.pkl')


# In[14]:

#Vectorization of the string
df3 = pd.Series(data_t)


# In[16]:

test_vectors = vec.transform(df3)


# In[18]:

#Predict the result with the model
prediction_sclf =sclf.predict(test_vectors)


# In[22]:

prediction_sclf
prediction = prediction_sclf.item(0)


# In[23]:

#Convert the result to "pos",""neg" or "neu"
if ((prediction>0)):
    result= 'pos' 
elif ((prediction<0)):
    result= 'neg' 
else:
    result= 'neu' 


# In[24]:

print(result)

