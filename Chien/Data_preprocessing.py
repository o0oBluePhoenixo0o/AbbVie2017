import pandas as pd
import numpy as np
import re
import csv
import nltk
nltk.download('punkt')
nltk.download('maxent_treebank_pos_tagger')
nltk.download('wordnet')
nltk.download('averaged_perceptron_tagger')
nltk.download('stopwords')
from nltk.corpus import stopwords
from nltk import wordpunct_tokenize
#pip install langdetect
from langdetect import detect

#Detect the text language by majority vote
def calculate_languages_ratios(text):
    languages_ratios = {}
    tokens = wordpunct_tokenize(text)
    words = [word.lower() for word in tokens]
    for language in stopwords.fileids():
        stopwords_set = set(stopwords.words(language))
        words_set = set(words)
        common_elements = words_set.intersection(stopwords_set)
        languages_ratios[language] = len(common_elements)
    return languages_ratios
    
def detect_language(text):
    ratios = calculate_languages_ratios(text)
    most_rated_language = max(ratios, key=ratios.get)
    return most_rated_language

#Read csv file
df_disease = pd.read_csv('Final_utf16.csv', encoding = 'utf-16LE', sep=',',
                         dtype={"key": object, "id.x": object,"like_count.x": float, "from_id.x":float,
                                "from_name.x":object, "message.x":object, "created_time.x":object, "type":object,
                                "link":object, "story":object, "comments_count.x":float,"shares_count":float,
                                "love_count":float, "haha_count":float, "wow_count":float, "sad_count": float,
                                "angry_count":float, "join_id":object, "from_id.y":float, "from_name.y":object,
                                "message.y":object, "created_time.y":object, "likes_count.y":float, 
                                "comments_count.y": float, "id.y":object})
                                
#Create a new csv file to store the result after data preprocessing
with open('post_comment_utf16.csv', 'w', encoding='UTF-16LE', newline='') as csvfile:
    column = [['id','id.x','message.x','message.y','lang.x','re_message.x','lang.y','re_message.y']]
    writer = csv.writer(csvfile)
    writer.writerows(column)

#Data preprocessing by implementing tokenization, stopwords and language detection
for i in range(len(df_disease['message.x'])):    
    features = []
    features.append(i)
    features.append(df_disease['id.x'][i])
    features.append(df_disease['message.x'][i])
    features.append(df_disease['message.y'][i])
    if(str(df_disease['message.x'][i])=="nan"):
        features.append('english')
        features.append(df_disease['message.x'][i])
    else:
        tokens = nltk.word_tokenize(str(df_disease['message.x'][i]))
        postag=nltk.pos_tag(tokens)
        adjandn = [word for word,pos in postag if pos!='.' and pos!=',']
        lang=detect_language(df_disease['message.x'][i])
        features.append(lang)
        #print(i,lang)
        stop = set(stopwords.words(lang))
        wordlist = [i for i in adjandn if i not in stop]
        features.append(' '.join(wordlist))
    if(str(df_disease['message.y'][i])=="nan"):
        features.append('english')
        features.append(df_disease['message.y'][i])
    else:
        tokens = nltk.word_tokenize(str(df_disease['message.y'][i]))
        postag=nltk.pos_tag(tokens)
        adjandn = [word for word,pos in postag if pos!='.' and pos!=',']
        lang=detect_language(df_disease['message.y'][i])
        features.append(lang)
        stop = set(stopwords.words(lang))
        wordlist = [i for i in adjandn if i not in stop]
        features.append(' '.join(wordlist))
    with open('post_comment_utf16.csv', 'a', encoding='UTF-16LE', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows([features])
        
#df_postncomment = pd.read_csv('post_comment_utf16.csv', encoding = 'UTF-16LE', sep=',')
#print(df_postncomment)
