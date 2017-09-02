
# coding: utf-8

# In[3]:

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
from sklearn import tree
from sklearn.naive_bayes import MultinomialNB
from sklearn import model_selection
from mlxtend.classifier import StackingClassifier


# In[4]:

#Set the directory
os.chdir("/Users/imacair/Desktop/Products3/")


# In[5]:

#Read the file
data= pd.read_csv('Final_Manual_3006.csv',
                    encoding='latin-1',delimiter=',')


# In[6]:

#Converts text into ASCII
data.message = data.message.str.encode('ascii','replace')


# In[7]:

sample_data= data


# In[8]:

data_t=sample_data["message"]


# In[9]:

#lowercase
data_t = data_t.str.lower()


# In[10]:

data_s=sample_data["sentiment"]


# In[11]:

np.unique(data_s)


# In[12]:

#Rename the sentiment
final = data
res5= pd.DataFrame( index=range(0,len(data_t)),columns = {'new_sent'} )
res5[(final.sentiment==u'2')] = '-1'
res5[(final.sentiment==u'1')] = '-1'
res5[(final['sentiment']==u'3')] = '1'
res5[(final['sentiment']==u'4')] = '1'
res5[(final['sentiment']==u'N')] = '0'
res5[(final['sentiment']==u"n")] = '0'
final=pd.concat([final, res5], axis=2)


# In[13]:

np.unique(final.new_sent)


# In[14]:

#Abbriviation translation
with open('abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower():rows[1].lower() for rows in reader              
                  }


# In[15]:

result = pd.DataFrame()
result = final


# In[16]:

for i in range(len(result)):
    data_t.values[i]=' '.join([replacement.get(w, w) for w in data_t.values[i].split()])


# In[17]:

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


# In[18]:

#Spliting the data
from sklearn.cross_validation import train_test_split
import numpy as np
from sklearn.model_selection import KFold


# In[19]:

data_train, data_test, label_train, label_test = train_test_split(data_t, final.new_sent, test_size=0.03, random_state=2340)


# In[21]:

#Vectorization
vectorizer = TfidfVectorizer(    sublinear_tf=True,
                                 use_idf=True,stop_words = 'english')
train_vectors = vectorizer.fit_transform(data_train)
test_vectors = vectorizer.transform(data_test)


# In[424]:

#Save vectorizer
joblib.dump(vectorizer, 'vec.pkl')


# In[22]:

# Perform classification with SVM, kernel=linear
classifier_linear = svm.SVC(C=0.6, kernel='linear')
t0 = time.time()
classifier_linear.fit(train_vectors, label_train)
t1 = time.time()
prediction_linear = classifier_linear.predict(test_vectors)
t2 = time.time()
time_linear_train = t1-t0
time_linear_predict = t2-t1


# In[23]:

print("Results for SVC(kernel=linear)")
print("Training time: %fs; Prediction time: %fs" % (time_linear_train, time_linear_predict))
print(classification_report(label_test, prediction_linear))
confusion_matrix(label_test, prediction_linear)


# In[24]:

# Perform classification with SVM, kernel=linear
classifier_liblinear = svm.LinearSVC(C=0.8)
t0 = time.time()
classifier_liblinear.fit(train_vectors, label_train)
t1 = time.time()
prediction_liblinear = classifier_liblinear.predict(test_vectors)
t2 = time.time()
time_liblinear_train = t1-t0
time_liblinear_predict = t2-t1


# In[25]:

# Perform classification with Multinomial Naïve Bayes.
classifier_nb = MultinomialNB(alpha=0.9)
t0 = time.time()
classifier_nb.fit(train_vectors, label_train)
t1 = time.time()
prediction_nb = classifier_nb.predict(test_vectors)
t2 = time.time()
time_nb_train = t1-t0
time_nb_predict = t2-t1


# In[26]:


print("Results for SVC(kernel=linear)")
print("Training time: %fs; Prediction time: %fs" % (time_linear_train, time_linear_predict))
print(classification_report(label_test, prediction_linear))
print("Results for LinearSVC()")
print("Training time: %fs; Prediction time: %fs" % (time_liblinear_train, time_liblinear_predict))
print(classification_report(label_test, prediction_liblinear))
print("Results for MultinomialNB()")
print("Training time: %fs; Prediction time: %fs" % (time_nb_train, time_nb_predict))
print(classification_report(label_test, prediction_nb))


# In[27]:

label_tests = np.asarray(label_test)


# In[28]:

df=[prediction_linear, prediction_liblinear, prediction_nb,label_tests]


# In[29]:

df = pd.DataFrame(df)
df = df.transpose()
df.columns = ['prediction_linear', 'prediction_liblinear', 'prediction_nb','label_tests']
#df


# In[30]:

from sklearn import model_selection
from mlxtend.classifier import StackingClassifier
#Stacking ensembling

lr = classifier_linear
sclf = StackingClassifier(classifiers=[classifier_liblinear, classifier_nb], 
                          meta_classifier=lr)

print('3-fold cross validation:\n')

for clf, label in zip([classifier_liblinear,classifier_nb,sclf], 
                      ['linear_svm', 
                       'multi_naive',
                       'StackingClassifier']):

    scores = model_selection.cross_val_score(clf, train_vectors, label_train, 
                                              cv=10, scoring='accuracy')
    print("Accuracy: %0.2f (+/- %0.2f) [%s]" 
          % (scores.mean(), scores.std(), label))


# In[31]:

sclf.fit(train_vectors, label_train)


# In[446]:

#Save the model
from sklearn.externals import joblib
joblib.dump(sclf, 'stacking.pkl')


# In[32]:

#Predictions of the stacking model
prediction_sclf =sclf.predict(test_vectors)


# In[33]:

#Convert to np arrays
label_tests = np.asarray(label_test)


#Create a Data Frame
df=[ prediction_linear, prediction_liblinear,prediction_nb, prediction_sclf]
df = pd.DataFrame(df)
df = df.transpose()
df.columns = ['prediction_linear', 'prediction_liblinear','prediction_nb','staking']
df


# In[269]:

#Convert to np arrays
label_tests = np.asarray(label_test)


#Create a Data Frame
df=[ prediction_linear, prediction_liblinear,prediction_nb]
df = pd.DataFrame(df)
df = df.transpose()
df.columns = ['prediction_linear', 'prediction_liblinear','prediction_nb']
df


# In[34]:

# ROC curve
from sklearn.metrics import roc_auc_score
from sklearn.preprocessing import LabelBinarizer

def multiclass_roc_auc_score(truth, pred, average="macro"):

    lb = LabelBinarizer()
    lb.fit(truth)

    truth = lb.transform(truth)
    pred = lb.transform(pred)

    return roc_auc_score(truth, pred, average=average)


# In[35]:

multiclass_roc_auc_score(label_test, prediction_linear, average="macro")


# In[36]:

multiclass_roc_auc_score(label_test,  prediction_liblinear, average="macro")


# In[37]:

multiclass_roc_auc_score(label_test,  prediction_nb, average="macro")


# In[38]:

multiclass_roc_auc_score(label_test, prediction_sclf, average="macro")


# In[ ]:



