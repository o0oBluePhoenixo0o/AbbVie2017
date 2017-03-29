###First need to login and get the Yandex API key from https://tech.yandex.com/translate/

import json
import requests
from urllib.request import urlopen

#Add your own key here
api_key="***********"

#Detect the language of text
def get_translation_direction(api_key,text):
    url="https://translate.yandex.net/api/v1.5/tr.json/detect?"
    url=url+"key="+api_key
    if(text!=""):
      url=url+"&text="+text
    r = requests.get(url)
    return(r.json()['lang'])
    
#Translate the text into English
def translation(api_key,text,lang):
    url="https://translate.yandex.net/api/v1.5/tr.json/translate?"
    url=url+"key="+api_key
    if(text!=""):
      url=url+"&text="+text
    if(lang!= ""):
      url=url+"&lang="+lang
    r = requests.get(url)
    return(''.join(r.json()['text']))
    
#Add the text you want to detect and the language you want to translate
#for lang, you can check here to see the code of language you want to translate https://tech.yandex.com/translate/doc/dg/reference/getLangs-docpage/
text="******"
lang="******"

import pandas as pd
import numpy as np
import csv
import re
df_disease = pd.read_csv('Combine_disease_utf16.csv', encoding = 'utf-16LE', sep=',')
with open('trans_disease.csv', 'w', encoding='UTF-16LE', newline='') as csvfile:
    column = [['id','id.x','message.x', 'lang', 'translate.x']]
    writer = csv.writer(csvfile)
    writer.writerows(column)
for i in range(len(df_disease['message.x'])):    
    features = []
    features.append(i)
    features.append(df_disease['id.x'][i])
    features.append(df_disease['message.x'][i])
    string=df_disease['message.x'][i]
    if(str(df_disease['message.x'][i])=="nan"):
        features.append('en')
        features.append(df_disease['message.x'][i])
    elif(get_translation_direction(api_key,str(string[1:len(string)]))!='en'):
        features.append(get_translation_direction(api_key,str(string[1:len(string)])))
        lang=get_translation_direction(api_key,str(string[1:len(string)]))+'-en'
        features.append(translation(api_key,str(string),lang))
    elif(get_translation_direction(api_key,str(string[1:len(string)]))=='en'):
        features.append('en')
        features.append(df_disease['message.x'][i])
    with open('trans_disease.csv', 'a', encoding='UTF-16LE', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows([features])
#df_result = pd.read_csv('trans_disease.csv', encoding = 'utf-16LE', sep=',')
#print(df_result)
