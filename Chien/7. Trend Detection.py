###Reference: https://github.com/tw-ddis/Gnip-Trend-Detection
###pip install pip install gnip_trend_detection[plotting]
###Create a folder and with a subfolder:example
###In the subfolder example, config_[model name].cfg is required to specify the hyperparameter of the trend detection model

import pandas as pd
import csv
from IPython.display import Image
from IPython.display import display

df = pd.read_csv('twitter_topic_utf16_0713.csv', encoding = 'UTF-16LE', sep=',',index_col=0)
#display(df)
selectid = df.loc[df['topicid'] == 1]
topic1 = pd.DataFrame(selectid, columns = ['created_time','topicid'])
topic1.index=range(len(topic1))
topic1['created_time'] = pd.to_datetime(topic1['created_time'])
#type(topic1['created_time'][0])
#topic1.created_time = pd.to_datetime(topic1.created_time, unit='s')
#topic1['created_time']=topic1['created_time'].astype('datetime64[ns]')
df_count = topic1.set_index('created_time').resample('1D', how='count')
df_count.columns = ['count']
#M #D #H #T #S
df_count['counter name']='#topic1'
#df_count = topic1.resample('1D', how='count')
#df_count.index=range(len(df_count))
df_count['interval start time'] = df_count.index
import datetime
c=(df_count['interval start time'][1]-df_count['interval start time'][0]).total_seconds()
df_count['interval duration in sec.']=c
df_count.index=range(len(df_count))
#display(df_count)
#df_count['interval start time'].astype(str)
df_count['interval start time']=df_count['interval start time'].dt.strftime('%Y-%m-%d %H:%M:%S')
df_count.to_csv('./example/trend_detection_topic1.csv', encoding='UTF-8',header=None,index=False,columns = ['interval start time','interval duration in sec.','count'])
#print(df_count['interval start time'][0])
display(df_count)

#%%bash 
#cat example/trend_detection_topic1.csv | trend_analyze.py -c example/config_poisson.cfg > example/topic1_analyzed_poisson.csv
import gnip_trend_detection
import os
os.system("cat example/trend_detection_topic1.csv | trend_analyze.py -c example/config_poisson.cfg > example/topic1_analyzed_poisson.csv")
os.system("cat example/trend_detection_topic1.csv | trend_analyze.py -c example/config_MannKendall.cfg > example/topic1_analyzed_MannKendall.csv")
os.system("cat example/trend_detection_topic1.csv | trend_analyze.py -c example/config_LinearRegressionModel.cfg > example/topic1_analyzed_LinearRegressionModel.csv")

#import configparser
import pandas as pd
import numpy as np
import csv
import json
count=pd.read_csv('./example/topic1_analyzed_Poisson.csv', encoding = 'UTF-8', sep=',',header=None)
#count=pd.read_csv('./example/topic1_analyzed_MannKendall.csv', encoding = 'UTF-8', sep=',',header=None)
#count=pd.read_csv('./example/topic1_analyzed_LinearRegressionModel.csv', encoding = 'UTF-8', sep=',',header=None)
count.columns = ['date','count','poisson']
#count.columns = ['date','count','MannKendall']
#count.columns = ['date','count','LinearRegressionModel']
count['date'] = pd.to_datetime(count['date']).dt.strftime('%Y-%m-%d')
k=[]
for i in range(len(count)):
    freq_dict={}
    freq_dict['date']=count['date'][i]
    freq_dict['count']=str(int(count['count'][i]))
    freq_dict['poisson']=count['poisson'][i]
    #freq_dict['MannKendall']=count['MannKendall'][i]
    #freq_dict['LinearRegressionModel']=count['LinearRegressionModel'][i]
    k.append(freq_dict)
print(json.dumps(k))
