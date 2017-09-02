import sys
import nltk
import re
import pandas as pd
import numpy as np
import csv
import os
import random
import numpy as np
#from collections import Counter
from sklearn.externals import joblib
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from collections import Counter
from textblob import TextBlob
from textblob import Blobber
from textblob.sentiments import NaiveBayesAnalyzer

data_t = sys.argv[1]
data_t = data_t.decode('ascii', 'replace')

#lowercase
data_t = data_t.lower()

#Abbriviation translation
with open('./ML/Python/abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower(): rows[1].lower() for rows in reader}

result = pd.DataFrame()
result = data_t

for i in range(len(result)):
    data_t = ' '.join([replacement.get(w, w) for w in data_t.split()])

#lowercase
data_t = data_t.lower()
#Remove urls
data_t = data_t.replace(
    r'(http.*) |(http.*)$|\n',
    "", )
#Remove twitter handles
data_t = data_t.replace(r"@\\w+", "")
#remove htmls
data_t = data_t.replace(r'<.*?>', "")
#Remove citations
data_t = data_t.replace(r'@[a-zA-Z0-9]*', "")
#remove _
#data_t = data_t.str.replace(r'\_+',"")

vec = joblib.load('./ML/Python/sentiment/vec.pkl')

data_tt = data_t

data_tt = data_tt.split(" ")
data_text = pd.DataFrame(data_tt)
old = len(data_text)
names = vec.get_feature_names()
names_text = pd.DataFrame(names)
new = len(data_text.merge(names_text, how='inner'))

if (old == new):
    sclf = joblib.load('./ML/Python/sentiment/stacking.pkl')
    #Vectorization of the string
    df3 = pd.Series(data_t)
    test_vectors = vec.transform(df3)
    #Predict the result with the model
    prediction_sclf = sclf.predict(test_vectors)
    prediction_sclf
    prediction = prediction_sclf.item(0)
    #Convert the result to "pos",""neg" or "neu"
    if ((prediction > 0)):
        result = 'pos'
    elif ((prediction < 0)):
        result = 'neg'
    else:
        result = 'neu'
    #print(result)
else:
    #Use vader package to get the sentiment
    analyzer = SentimentIntensityAnalyzer()
    res = pd.DataFrame(index=range(0, 1), columns={'SentimentVader'})
    #Convert sentiment to neu, neg, pos
    for i in range(1):
        vs = analyzer.polarity_scores(data_t)
        if ((vs['pos'] > 0)):
            res.values[i] = 'pos'
        elif ((vs['neg'] < 0)):
            res.values[i] = 'neg'
        else:
            res.values[i] = 'neu'
    vader = res.SentimentVader

    #Use textblob to get polarity of text
    res6 = data_t
    testimonial = TextBlob(data_t)
    res6 = testimonial.sentiment.polarity
    #Convert polarity to normal pos, neg, neu
    textblob1 = res6
    if ((res6 > 0)):
        textblob1 = 'pos'
    elif ((res6 < 0)):
        textblob1 = 'neg'
    else:
        textblob1 = 'neu'

    #Use textblob to get polarity of text with Naive Bayes analyzer
    tb = Blobber(analyzer=NaiveBayesAnalyzer())
    textblob2 = pd.DataFrame(index=range(0, 1), columns={'sentimentNB'})
    #textblob2['sentimentNB']= tb(data_t).sentiment.classification
    if (tb(data_t).sentiment.p_pos > 0.7):
        textblob2['sentimentNB'] = "pos"
    elif (tb(data_t).sentiment.p_neg > 0.7):
        textblob2['sentimentNB'] = "neg"
    else:
        textblob2['sentimentNB'] = "neu"

    vader = np.asarray(vader)

    #Create a Data Frame
    df = [vader]
    df = pd.DataFrame(df)
    df = df.transpose()
    df.columns = ['vader']
    df["SentimentPat"] = textblob1
    df["sentimentNB"] = textblob2

    #Find the maximum in a row (Majority voting)
    df2 = pd.DataFrame(index=range(0, 1), columns={''})
    for i in range(1):
        d = Counter(df.ix[i, :])
        dfin = d.most_common(1)[0][0]
        df2.values[i] = dfin
    #df["final"] = df2
    data = df2.values[0]
    result = ''.join(data)

if (result == "pos"):
    print("positive")
elif (result == "neg"):
    print("negative")
else:
    print("neutral")