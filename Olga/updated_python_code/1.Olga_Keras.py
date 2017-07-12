
# coding: utf-8

# LSTM for sentiment analysis on 1.6 dataset

# In[77]:

import os
os.chdir("/Users/imacair/Desktop/Products3/")


# In[78]:

import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)

from sklearn.feature_extraction.text import CountVectorizer
from keras.preprocessing.text import Tokenizer
from keras.preprocessing.sequence import pad_sequences
from keras.models import Sequential
from keras.layers import Dense, Embedding, LSTM
from sklearn.model_selection import train_test_split
from keras.utils.np_utils import to_categorical
import re


# In[79]:

data = pd.read_csv('Final_Manual_1905.csv', encoding='latin1',delimiter=',')
data.message = data.message.str.encode('ascii','replace')


# In[80]:

#data= data.sample(n=10000)


# In[81]:

data = data[['message','sentiment']]


# In[82]:

from unidecode import unidecode


# In[83]:

#data2 = pd.read_csv('Final_Manual_0805.csv', encoding='latin1',delimiter=',')
#data2 = data2[['message','sentiment']]


# In[84]:

print(data[ data['sentiment'] == 0].size)
print(data[ data['sentiment'] == 4].size)


# In[85]:

#[0 if i < 0 else i for i in a]


# In[86]:

data['sentiment'] = np.where(data['sentiment'] == u'2', u'1', data['sentiment'])


# In[87]:

data['sentiment'] = np.where(data['sentiment'] == u'N', u'0', data['sentiment'])


# In[88]:

data['sentiment'] = np.where(data['sentiment'] == u'3', u'4', data['sentiment'])


# In[89]:

data.size


# In[90]:

data['sentiment']


# In[91]:

#data['message'].values.astype('U13')


# In[92]:

#unidecode(data['message'].values.astype('U13'))


# In[93]:

max_fatures = 2000
tokenizer = Tokenizer(nb_words=max_fatures, split=' ')
tokenizer.fit_on_texts(data['message'].values)
X = tokenizer.texts_to_sequences(data['message'].values)
X = pad_sequences(X)


# In[94]:

embed_dim = 128
lstm_out = 196

model = Sequential()
model.add(Embedding(max_fatures, embed_dim,input_length = X.shape[1], dropout=0.2))
model.add(LSTM(lstm_out, dropout_U=0.2, dropout_W=0.2))
model.add(Dense(3,activation='softmax'))
model.compile(loss = 'categorical_crossentropy', optimizer='adam',metrics = ['accuracy'])
print(model.summary())


# In[95]:

Y = pd.get_dummies(data['sentiment']).values
X_train, X_test, Y_train, Y_test = train_test_split(X,Y, test_size = 0.33, random_state = 24)
print(X_train.shape,Y_train.shape)
print(X_test.shape,Y_test.shape)


# In[ ]:




# In[96]:

batch_size = 32
model.fit(X_train, Y_train, nb_epoch = 7, batch_size=batch_size, verbose = 2)


# In[97]:

X_test


# In[98]:

validation_size = 206

X_validate = X_test[-validation_size:]
Y_validate = Y_test[-validation_size:]
X_test = X_test[:-validation_size]
Y_test = Y_test[:-validation_size]
score,acc = model.evaluate(X_test, Y_test, verbose = 2, batch_size = batch_size)
print("score: %.2f" % (score))
print("acc: %.2f" % (acc))


# In[99]:

from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix


# In[100]:

out=model.predict(X_validate)


# In[101]:

b = np.zeros_like(out)
b[np.arange(len(out)), out.argmax(1)] = 1


# In[102]:


#for x in range(len(X_validate)):
    
#    result = model.predict(X_validate[x].reshape(1,X_test.shape[1]),batch_size=1,verbose = 2)[0]


# In[103]:

print(classification_report(Y_validate,b))


# In[104]:

c = np.argmax(b, axis=1)


# In[105]:

d =  np.argmax(Y_validate, axis=1)


# In[106]:

print(confusion_matrix(d,c).transpose())


# In[124]:

np.argmax(out[6])


# Link https://www.kaggle.com/ngyptr/lstm-sentiment-analysis-keras
