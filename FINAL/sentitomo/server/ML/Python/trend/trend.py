import pandas as pd
import csv
import json
import sys
import numpy


class MyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, numpy.integer):
            return int(obj)
        elif isinstance(obj, numpy.floating):
            return float(obj)
        elif isinstance(obj, numpy.ndarray):
            return obj.tolist()
        else:
            return super(MyEncoder, self).default(obj)


df = pd.read_csv(sys.argv[1], encoding='UTF-8', sep=',', quotechar='"')
final_tp = []


def trend_detection(topicid):
    selectid = df.loc[df['topicId'] == topicid]
    topic = pd.DataFrame(selectid, columns=['created', 'topicId'])
    topic.index = range(len(topic))
    topic['created'] = pd.to_datetime(topic['created'])
    df_count = topic.set_index('created').resample('1D').count()

    df_count.columns = ['count']

    #M #D #H #T #S
    df_count['counter name'] = '#topic' + str(topicid)
    df_count['interval start time'] = df_count.index

    import datetime
    c = 86400.0

    df_count['interval duration in sec.'] = c
    df_count.index = range(len(df_count))

    df_count['interval start time'] = df_count[
        'interval start time'].dt.strftime('%Y-%m-%d %H:%M:%S')
    df_count.to_csv(
        './ML/PYthon/trend/result/trend_detection_topics.csv',
        encoding='UTF-8',
        header=None,
        index=False,
        columns=['interval start time', 'interval duration in sec.', 'count'])
    import gnip_trend_detection
    import os
    os.system(
        "cat ./ML/PYthon/trend/result/trend_detection_topics.csv | trend_analyze.py -c ./ML/PYthon/trend/result/config_poisson.cfg > ./ML/Python/trend/result/topics_analyzed_poisson.csv"
    )


for k in range(1, 41):
    selectid = df.loc[df['topicId'] == k]
    topic = pd.DataFrame(selectid, columns=['created', 'topicId'])
    if (len(topic) != 0):
        trend_detection(k)

        count = pd.read_csv(
            './ML/Python/trend/result/topics_analyzed_poisson.csv',
            encoding='UTF-8',
            sep=',',
            header=None)

        count.columns = ['date', 'count', 'result']
        count['date'] = pd.to_datetime(count['date']).dt.strftime('%Y-%m-%d')
        tp_dict = {}
        tp_dict['topicId'] = str(k)
        tp_dict['trendGraph'] = []
        for i in range(len(count)):
            freq_dict = {}
            freq_dict['date'] = count['date'][i]
            freq_dict['count'] = str(int(count['count'][i]))
            freq_dict['poisson'] = count['result'][i]
            tp_dict['trendGraph'].append(freq_dict)
        final_tp.append(tp_dict)
print(json.dumps(final_tp, cls=MyEncoder))