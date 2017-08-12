import sys
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
from nltk.corpus import stopwords

data_t = sys.argv[1]
data_t = data_t.encode('ascii', 'replace')
data_t = data_t.lower()

# Abbriviation translation
with open('./ML/Python/abbrev.csv', mode='r') as infile:
    reader = csv.reader(infile)
    replacement = {rows[0].lower(): rows[1].lower() for rows in reader}

result = pd.DataFrame()
result = data_t

for i in range(len(result)):
    data_t = ' '.join([replacement.get(w, w) for w in data_t.split()])

s = set(stopwords.words('english'))
for i in range(len(result)):
    data_t = ' '.join(filter(lambda w: not w in s, data_t.split()))

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

#Use vader package to get the sentiment
analyzer = SentimentIntensityAnalyzer()
res = pd.DataFrame(index=range(0, 1), columns={'SentimentVader'})

#Convert sentiment to neu, neg, pos
for i in range(1):
    vs = analyzer.polarity_scores(data_t)
    if ((vs['pos'] > 0)):
        res.values[i] = 'positive'
    elif ((vs['neg'] < 0)):
        res.values[i] = 'negative'
    else:
        res.values[i] = 'neutral'
vader = res.SentimentVader

#Use textblob to get polarity of text
res6 = data_t
testimonial = TextBlob(data_t)
res6 = testimonial.sentiment.polarity
#Convert polarity to normal pos, neg, neu
textblob1 = res6
if ((res6 > 0)):
    textblob1 = 'positive'
elif ((res6 < 0)):
    textblob1 = 'negative'
else:
    textblob1 = 'neutral'

#Use textblob to get polarity of text with Naive Bayes analyzer
tb = Blobber(analyzer=NaiveBayesAnalyzer())
textblob2 = pd.DataFrame(index=range(0, 1), columns={'sentimentNB'})
textblob2['sentimentNB'] = tb(data_t).sentiment.classification

vader = np.asarray(vader)

#Create a Data Frame
df = [vader]
df = pd.DataFrame(df)
df = df.transpose()
df.columns = ['vader']
df["SentimentPat"] = textblob1
df["sentimentNB"] = textblob2
#df

#Find the maximum in a row (Majority voting)
df2 = pd.DataFrame(index=range(0, 1), columns={''})
for i in range(1):
    d = Counter(df.ix[i, :])
    dfin = d.most_common(1)[0][0]
    df2.values[i] = dfin
#df["final"] = df2
data = df2.values[0]
data = ''.join(data)

print(data)
