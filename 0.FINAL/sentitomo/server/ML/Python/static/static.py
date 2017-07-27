import pandas as pd
import numpy as np
import re
import nltk
import csv
import sys
#from nltk import wordpunct_tokenize
from nltk.corpus import stopwords
import time
start_time = time.time()
#print("Hello")
#import os
#os.remove('./ML/Python/static/final_twitter_preprocessing_0720.csv')
#os.remove('./ML/Python/static/twitter_preprocessing_0720.csv')
start_time = time.time()
#df = pd.read_csv('./ML/Python/static/twitter_utf16_0720.csv', encoding='UTF-16LE',index_col=0)
#df = pd.read_csv(sys.argv[1], encoding='UTF-16LE',index_col=0)
disease = pd.read_csv(sys.argv[1], encoding='UTF-8')
df = pd.DataFrame(disease, columns = ['id','created','language', 'message'])
df.columns=['id', 'created_time', 'language','message']
#print(df)
#df.to_csv("twitter_utf16_0720.csv", encoding='UTF-16LE',columns = ['id', 'created_time', 'language','message'])
rm_duplicates = df.drop_duplicates(subset=['id','message'])
rm_na = rm_duplicates.dropna()
dtime = rm_na.sort_values(['created_time'])
dtime.index=range(len(dtime))
dlang=dtime[dtime['language'] == 'eng']
dlang.index=range(len(dlang))
with open('./ML/Python/static/twitter_preprocessing_0720.csv', 'w', encoding='UTF-16LE', newline='') as csvfile:
    column = [['id', 'created_time', 'language','message','re_message']]
    writer = csv.writer(csvfile)
    writer.writerows(column)
for i in range(len(dlang['message'])):
    #for i in range(10):
    features = []
    #features.append(i)
    features.append(dlang['id'][i])
    features.append(dlang['created_time'][i])
    features.append(dlang['language'][i])
    features.append(dlang['message'][i])
    tokens=' '.join(re.findall(r"[\w']+", str(dlang['message'][i]))).lower().split()
    postag=nltk.pos_tag(tokens)
    irlist=[',','.',':','#',';','CD','WRB','RB','PRP','...',')','(','-','``','@']
    wordlist=['co', 'https', 'http','rt','com']
    adjandn = [word for word,pos in postag if pos not in irlist and word not in wordlist and len(word)>2]
    #lang=detect_language(dlang['message'][i])
    #features.append(lang)
    stop = set(stopwords.words('english'))
    wordlist = [i for i in adjandn if i not in stop]
    features.append(' '.join(wordlist))
    with open('./ML/Python/static/twitter_preprocessing_0720.csv', 'a', encoding='UTF-16LE', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows([features])
df_postncomment = pd.read_csv('./ML/Python/static/twitter_preprocessing_0720.csv', encoding = 'UTF-16LE', sep=',')
#df_english= df_postncomment.loc[df_postncomment['lang'] == 'english']
df_rm = df_postncomment.drop_duplicates(subset=['id','re_message'])
rm_english_na = df_rm.dropna()
#display(rm_english_na)
rm_english_na.index=range(len(rm_english_na))
dfinal_tw = pd.DataFrame(rm_english_na, columns = ['id', 'created_time', 'language','message','re_message'])
dfinal_tw.to_csv('./ML/Python/static/final_twitter_preprocessing_0720.csv', encoding='UTF-16LE',columns = ['id', 'created_time', 'language','message','re_message'])
#df_postn = pd.read_csv('./ML/Python/static/final_twitter_preprocessing_0720.csv', encoding = 'UTF-16LE', sep=',',index_col=0)
#print(len(df_postn))
#print("Stage 1: Data preprocessing finished")
#print((time.time() - start_time))

import gensim
from gensim import corpora
from nltk.corpus import stopwords 
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from nltk.stem import WordNetLemmatizer
import string
import time
start_time = time.time()
df_postn = pd.read_csv('./ML/Python/static/final_twitter_preprocessing_0720.csv', encoding = 'UTF-16LE', sep=',',index_col=0)
df_postn.index=range(len(df_postn))
#display(df_postn.head(3))
#print(len(df_postn))
stop = set(stopwords.words('english'))
exclude = set(string.punctuation) 
lemma = WordNetLemmatizer()
#corpus=list(df_postn['re_message'])
def tokenize(doc):
    tokens = ' '.join(re.findall(r"[\w']+", str(doc))).lower().split()
    x = [''.join(c for c in s if c not in string.punctuation) for s in tokens]
    x=' '.join(x)
    #print(x)
    stop_free = " ".join([i for i in x.lower().split() if i not in stop])
    #print(doc.lower().split())
    punc_free = ''.join(ch for ch in stop_free if ch not in exclude)
    normalized = " ".join(lemma.lemmatize(word,pos='n') for word in punc_free.split())
    normalized = " ".join(lemma.lemmatize(word,pos='v') for word in normalized.split())
    word = " ".join(word for word in normalized.split() if len(word)>3)
    #print(word.split())
    postag=nltk.pos_tag(word.split())
    #print(postag)
    #irlist=[',','.',':','#',';','CD','WRB','RB','PRP','...',')','(','-','``','@']
    poslist=['NN','NNP','NNS','RB','RBR','RBS','JJ','JJR','JJS']
    wordlist=['co', 'https', 'http','rt','www','ve','dont',"i'm","it's"]
    adjandn = [word for word,pos in postag if pos in poslist and word not in wordlist and len(word)>3]
    #normalized = adjandn.split()
    return ' '.join(adjandn)
#type(df_postn['created_time'][0])
import datetime
import dateutil.relativedelta
def dateselect(day):
    d = datetime.datetime.strptime(str(datetime.date.today()), "%Y-%m-%d")
    d2 = d - dateutil.relativedelta.relativedelta(days=day)
    #df_postn['created_time']=pd.to_datetime(df_postn['created_time'])
    df_time=df_postn['created_time']
    df_time=pd.to_datetime(df_time)
    mask = (df_time > d2) & (df_time <= d)
    period = df_postn.loc[mask]
    return period
corpus=list(df_postn['re_message'])
doc_clean = [tokenize(doc).split() for doc in corpus]
dictionary = corpora.Dictionary(doc_clean)
doc_term_matrix = [dictionary.doc2bow(doc) for doc in doc_clean]
from gensim.models import CoherenceModel, LdaModel, LsiModel, HdpModel
#ldamodel = LdaModel(doc_term_matrix, num_topics=40, id2word = dictionary, update_every=10, chunksize=10000, passes=10)
#print((time.time() - start_time))
import pyLDAvis.gensim as gensimvis
import pyLDAvis
ldamodel=LdaModel.load('./ML/Python/static/lda.model')
vis_data = gensimvis.prepare(ldamodel, doc_term_matrix, dictionary)
pyLDAvis.save_html(vis_data, './ML/Python/static/lda_tw40_0720.html')
vistopicid=vis_data[6]
idlist=[]
for j in range(1,len(vistopicid)+1):
    idlist.append([i for i,x in enumerate(vistopicid) if x == j][0])
topicwords={}
no=0
for prob in ldamodel.show_topics(20,10):
    tokens = ' '.join(re.findall(r"[\w']+", str(prob[1]))).lower().split()
    x = [''.join(c for c in s if c not in string.punctuation) for s in tokens]
    result = ' '.join([i for i in x if not i.isdigit()])
    topicwords[idlist[no]]=result.split()
    no+=1
#import json
#tp=[]
#for i in range(40):
#    tw={}
#    tw['id']=i+1
#    tw['topic']=', '.join(topicwords[i])
#    tp.append(tw)   
#print(json.dumps(tp))
def getTopicForQuery_lda(question):
    temp = tokenize(question).split()
    #print(temp)
    ques_vec = []
    ques_vec = dictionary.doc2bow(temp)
    topic_vec = []
    topic_vec = ldamodel[ques_vec]
    word_count_array = np.empty((len(topic_vec), 2), dtype = np.object)
    for i in range(len(topic_vec)):
        word_count_array[i, 0] = topic_vec[i][0]
        word_count_array[i, 1] = topic_vec[i][1]
    idx = np.argsort(word_count_array[:, 1])
    idx = idx[::-1]
    word_count_array = word_count_array[idx]
    #print(idlist[word_count_array[0, 0]]+1)
    final = []
    final = ldamodel.print_topic(word_count_array[0, 0], 100)
    question_topic = final.split('*') ## as format is like "probability * topic"
    tokens = ' '.join(re.findall(r"[\w']+", str(final))).lower().split()
    x = [''.join(c for c in s if c not in string.punctuation) for s in tokens]
    #print(x)
    result = ' '.join([i for i in x if not i.isdigit()])
    #x=' '.join(x)
    #print("Original Query: ",question)
    topic_prob = list(reversed(sorted(ldamodel.get_document_topics(ques_vec),key=lambda tup: tup[1])))
    topic_prob = [list(t) for t in topic_prob]
    for i in range(len(topic_prob)):
        topic_prob[i][0]=idlist[topic_prob[i][0]]+1
    #print("(Topic, Probability): ",topic_prob)
    #print(result.split()[0:10])
    return topic_prob[0][1], idlist[word_count_array[0, 0]]+1, result.split()[0:5]
import json
#start_time = time.time()
df_postn.index=range(len(df_postn))
k=[]
for i in range(100):
    tp_dict={}
    question=df["message"][i]
    if str(df['id'][i])=='nan':
        tp_dict['key']='nan'
    else:
        tp_dict['key']=str(int(df['id'][i])) #convert to string 
    tp_dict['id']=getTopicForQuery_lda(question)[1]
    tp_dict['topic']=', '.join(getTopicForQuery_lda(question)[2])
    tp_dict['probability']=getTopicForQuery_lda(question)[0]
    k.append(tp_dict)    
    #print(getTopicForQuery_lda(question)[0])
    #print(getTopicForQuery_lda(question)[1])
    #print(', '.join(getTopicForQuery_lda(question)[2]))
#r="{"+str(k)+"}"
#print(json.dumps(r))
print(json.dumps(k))
#print("Stage 2: Topic Model finished")
#print((time.time() - start_time))
#pyLDAvis.display(vis_data)
