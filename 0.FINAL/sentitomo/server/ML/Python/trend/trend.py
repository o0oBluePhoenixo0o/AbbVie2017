import pandas as pd
import csv
import sys
#from IPython.display import Image
#from IPython.display import display

df = pd.read_csv(sys.argv[1], encoding='UTF-8', sep=',')
#display(df[])
print(df.head(1))
selectid = df.loc[df['topicId'] == "1"]
topic1 = pd.DataFrame(selectid, columns=['created', 'topicId'])
topic1.index = range(len(topic1))
topic1['created'] = pd.to_datetime(topic1['created'])
#type(topic1['created_time'][0])
#topic1.created_time = pd.to_datetime(topic1.created_time, unit='s')
#topic1['created_time']=topic1['created_time'].astype('datetime64[ns]')
df_count = topic1.set_index('created').resample('1D').count()
df_count.columns = ['count']
#M #D #H #T #S
df_count['counter name'] = '#topic1'
#df_count = topic1.resample('1D', how='count')
#df_count.index=range(len(df_count))
df_count['interval start time'] = df_count.index
print(df_count)
import datetime
c = (df_count['interval start time'][1] -
     df_count['interval start time'][0]).total_seconds()
df_count['interval duration in sec.'] = c
df_count.index = range(len(df_count))
#display(df_count)
#df_count['interval start time'].astype(str)
df_count['interval start time'] = df_count['interval start time'].dt.strftime(
    '%Y-%m-%d %H:%M:%S')
df_count.to_csv(
    './ML/PYthon/trend/result/trend_detection_topics.csv',
    encoding='UTF-8',
    header=None,
    index=False,
    columns=['interval start time', 'interval duration in sec.', 'count'])
#print(df_count['interval start time'][0])
#display(df_count.head(3))
import gnip_trend_detection
import os
os.system(
    "cat ./ML/PYthon/trend/result/trend_detection_topics.csv | trend_analyze.py -c ./ML/PYthon/trend/result/config_poisson.cfg > ./ML/Python/trend/result/topics_analyzed_poisson.csv"
)
#os.system("cat example/trend_detection_topic1.csv | trend_analyze.py -c example/config_MannKendall.cfg > example/topic1_analyzed_MannKendall.csv")
#os.system("cat example/trend_detection_topic1.csv | trend_analyze.py -c example/config_LinearRegressionModel.cfg > example/topic1_analyzed_LinearRegressionModel.csv")
#headers = ['interval start time','count','result']
#poisson=pd.read_csv('./ML/Python/result/topics_analyzed_poisson.csv', encoding = 'UTF-8', sep=',',names=headers)
#import configparser
import pandas as pd
import numpy as np
import csv
import json
count = pd.read_csv(
    './ML/Python/trend/result/topics_analyzed_poisson.csv',
    encoding='UTF-8',
    sep=',',
    header=None)
#count=pd.read_csv('./example/topic1_analyzed_MannKendall.csv', encoding = 'UTF-8', sep=',',header=None)
#count=pd.read_csv('./example/topic1_analyzed_LinearRegressionModel.csv', encoding = 'UTF-8', sep=',',header=None)
count.columns = ['date', 'count', 'result']
#count.columns = ['date','count','MannKendall']
#count.columns = ['date','count','LinearRegressionModel']
count['date'] = pd.to_datetime(count['date']).dt.strftime('%Y-%m-%d')
k = []
for i in range(len(count)):
    freq_dict = {}
    freq_dict['date'] = count['date'][i]
    freq_dict['count'] = str(int(count['count'][i]))
    freq_dict['poisson'] = count['result'][i]
    #freq_dict['MannKendall']=lr['result'][i]
    #freq_dict['LinearRegressionModel']=mannkendall['result'][i]
    k.append(freq_dict)
print(json.dumps(k))