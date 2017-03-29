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
    #print(url)
    r = requests.get(url)
    #print(type(r.json()['lang']))
    #print(r.json()['lang'])
    return(r.json()['lang'])
    
#Translate the text into English
def translation(api_key,text,lang):
    url="https://translate.yandex.net/api/v1.5/tr.json/translate?"
    url=url+"key="+api_key
    if(text!=""):
      url=url+"&text="+text
    if(lang!= ""):
      url=url+"&lang="+lang
    #print(url)
    r = requests.get(url)
    #print(type(''.join(r.json()['text'])))
    return(''.join(r.json()['text']))
    
#Add the text you want to detect and the language you want to translate
#for lang, you can check here to see the code of language you want to translate https://tech.yandex.com/translate/doc/dg/reference/getLangs-docpage/
text="******"
lang="******"

get_translation_direction(api_key,text)    
translation(api_key,text,lang)
