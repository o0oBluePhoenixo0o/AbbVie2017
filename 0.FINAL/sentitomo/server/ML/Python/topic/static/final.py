import pandas as pd
import numpy as np
import re
import nltk
import csv
import sys
#from nltk import wordpunct_tokenize
from nltk.corpus import stopwords
import time
import os
#os.remove('./ML/Python/static/final_twitter_preprocessing_0720.csv')
#os.remove('./ML/Python/static/twitter_preprocessing_0720.csv')
start_time = time.time()
#df = pd.read_csv('./ML/Python/static/twitter_utf16_0720.csv', encoding='UTF-16LE',index_col=0)
#df = pd.read_csv(sys.argv[1], encoding='UTF-16LE',index_col=0)
#disease = pd.read_csv('./ML/Python/static/Final_TW_0807_prep.csv', encoding='ISO-8859-2', low_memory=False)
#disease = pd.read_csv(sys.argv[1], encoding='UTF-8', low_memory=False)
#df = pd.DataFrame(disease, columns = ['Id','key','created_time','Language', 'message'])
#df.columns=['id', 'key', 'created_time', 'language','message']
#df.to_csv("twitter_utf8_0720.csv", encoding='UTF-8',columns = ['id', 'key','created_time', 'language','message'])
#df = pd.read_csv('twitter_utf16_0720.csv', encoding='UTF-16LE',index_col=0)
import gensim
from gensim import corpora
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from nltk.stem import WordNetLemmatizer
import string
import time
df_postn = pd.read_csv(
    './ML/Python/topic/static/final_twitter_preprocessing_0720.csv',
    encoding='UTF-16LE',
    sep=',',
    index_col=0)
df_postn.index = range(len(df_postn))
#display(df_postn.head(3))
#print(len(df_postn))
stop = set(stopwords.words('english'))
exclude = set(string.punctuation)
lemma = WordNetLemmatizer()


#corpus=list(df_postn['re_message'])
def tokenize(doc):
    tokens = ' '.join(re.findall(r"[\w']+", str(doc))).lower().split()
    x = [''.join(c for c in s if c not in string.punctuation) for s in tokens]
    x = ' '.join(x)
    #print(x)
    stop_free = " ".join([i for i in x.lower().split() if i not in stop])
    #print(doc.lower().split())
    punc_free = ''.join(ch for ch in stop_free if ch not in exclude)
    normalized = " ".join(
        lemma.lemmatize(word, pos='n') for word in punc_free.split())
    normalized = " ".join(
        lemma.lemmatize(word, pos='v') for word in normalized.split())
    word = " ".join(word for word in normalized.split() if len(word) > 3)
    #print(word.split())
    postag = nltk.pos_tag(word.split())
    #print(postag)
    #irlist=[',','.',':','#',';','CD','WRB','RB','PRP','...',')','(','-','``','@']
    poslist = ['NN', 'NNP', 'NNS', 'RB', 'RBR', 'RBS', 'JJ', 'JJR', 'JJS']
    wordlist = [
        'co', 'https', 'http', 'rt', 'www', 've', 'dont', "i'm", "it's"
    ]
    adjandn = [
        word for word, pos in postag
        if pos in poslist and word not in wordlist and len(word) > 3
    ]
    #normalized = adjandn.split()
    return ' '.join(adjandn)


#type(df_postn['created_time'][0])
import datetime
import dateutil.relativedelta


def dateselect(day):
    d = datetime.datetime.strptime(str(datetime.date.today()), "%Y-%m-%d")
    d2 = d - dateutil.relativedelta.relativedelta(days=day)
    #df_postn['created_time']=pd.to_datetime(df_postn['created_time'])
    df_time = df_postn['created_time']
    df_time = pd.to_datetime(df_time)
    mask = (df_time > d2) & (df_time <= d)
    period = df_postn.loc[mask]
    return period


corpus = list(df_postn['re_message'])
import pickle
directory = "./ML/Python/topic/static/doc_clean.txt"
if os.path.exists(directory):
    with open("./ML/Python/topic/static/doc_clean.txt",
              "rb") as fp:  # Unpickling
        doc_clean = pickle.load(fp)
else:
    doc_clean = [tokenize(doc).split() for doc in corpus]
    with open("./ML/Python/topic/static/doc_clean.txt", "wb") as fp:  #Pickling
        pickle.dump(doc_clean, fp)
directory = "./ML/Python/topic(static/corpus.dict"
if os.path.exists(directory):
    dictionary = corpora.Dictionary.load(
        './ML/Python/topic/static/corpus.dict')
else:
    dictionary = corpora.Dictionary(doc_clean)
    dictionary.save('./ML/Python/topic/static/corpus.dict')
doc_term_matrix = [dictionary.doc2bow(doc) for doc in doc_clean]

from gensim.models import CoherenceModel, LdaModel, LsiModel, HdpModel
directory = "./ML/Python/topic/static/lda.model"
if os.path.exists(directory):
    ldamodel = LdaModel.load('./ML/Python/topic/static/lda.model')
else:
    ldamodel = LdaModel(
        doc_term_matrix,
        num_topics=40,
        id2word=dictionary,
        update_every=10,
        chunksize=10000,
        passes=10)
    ldamodel.save('./ML/Python/topic/static/lda.model')
#ldamodel = LdaModel(doc_term_matrix, num_topics=40, id2word = dictionary, update_every=10, chunksize=10000, passes=10)
#print((time.time() - start_time))
import pyLDAvis.gensim as gensimvis
import pyLDAvis
#ldamodel=LdaModel.load('./ML/Python/static/lda.model')
vis_data = gensimvis.prepare(ldamodel, doc_term_matrix, dictionary)
pyLDAvis.save_html(vis_data, './ML/Python/topic/static/lda_tw40_0720.html')
vistopicid = vis_data[6]
idlist = []
for j in range(1, len(vistopicid) + 1):
    idlist.append([i for i, x in enumerate(vistopicid) if x == j][0])
topicwords = {}
no = 0
for prob in ldamodel.show_topics(20, 10):
    tokens = ' '.join(re.findall(r"[\w']+", str(prob[1]))).lower().split()
    x = [''.join(c for c in s if c not in string.punctuation) for s in tokens]
    result = ' '.join([i for i in x if not i.isdigit()])
    topicwords[idlist[no]] = result.split()
    no += 1


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
    ques_vec = []
    ques_vec = dictionary.doc2bow(temp)
    topic_vec = []
    topic_vec = ldamodel[ques_vec]
    word_count_array = np.empty((len(topic_vec), 2), dtype=np.object)
    for i in range(len(topic_vec)):
        word_count_array[i, 0] = topic_vec[i][0]
        word_count_array[i, 1] = topic_vec[i][1]
    idx = np.argsort(word_count_array[:, 1])
    idx = idx[::-1]
    word_count_array = word_count_array[idx]
    final = []
    final = ldamodel.print_topic(word_count_array[0, 0], 100)
    question_topic = final.split(
        '*')  ## as format is like "probability * topic"
    tokens = ' '.join(re.findall(r"[\w']+", str(final))).lower().split()
    x = [''.join(c for c in s if c not in string.punctuation) for s in tokens]
    result = ' '.join([i for i in x if not i.isdigit()])
    topic_prob = list(
        reversed(
            sorted(
                ldamodel.get_document_topics(ques_vec),
                key=lambda tup: tup[1])))
    topic_prob = [list(t) for t in topic_prob]
    for i in range(len(topic_prob)):
        topic_prob[i][0] = idlist[topic_prob[i][0]] + 1
    return topic_prob[0][
        1], idlist[word_count_array[0, 0]] + 1, result.split()[0:5]


import json
df_postn.index = range(len(df_postn))
k = []
tp_dict = {}
#use sys.argv[1] to change it
#print(sys.argv[1])
question = sys.argv[1]
load_json = json.loads(question)
tpid = load_json['id']
tpmessage = load_json['message']
#print(question)
#print(tpid)
#print(tpmessage)

if str(tpid) == 'nan':
    tp_dict['key'] = 'nan'
else:
    tp_dict['key'] = str(int(tpid))  #convert to string
    tp_dict['id'] = getTopicForQuery_lda(tpmessage)[1]
    tp_dict['topic'] = ', '.join(getTopicForQuery_lda(tpmessage)[2])
    tp_dict['probability'] = getTopicForQuery_lda(tpmessage)[0]
    k.append(tp_dict)
print(json.dumps(k))