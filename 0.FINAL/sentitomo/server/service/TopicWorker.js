import cron from 'cron';
import moment from 'moment';
import { convertToCsvRaw } from '../util/export';
import { Tweet, TweetTopic } from '../data/connectors';
import { detectTopicLDAStaticBatch } from "../ML/ml_wrapper";

import logger from './logger';


export default class TopicWorker {
    constructor() {
        this.running = false;
    }

    start() {
        this.running = true;
        this.detectTopics();
    }

    stop() {
        this.running = false;
    }


    detectTopics() {
        if (this.running) {
            logger.log('Info', 'Topic detection is running');
            Tweet.findAll({
                where: {
                    '$TW_Topic.topicID$': { $eq: null }
                },
                limit: 100,
                raw: true,
                order: [['createdAt', 'ASC']],
                include: [{
                    model: TweetTopic, as: TweetTopic.tableName
                }],
            }).then(async (tweets) => {
                if (tweets.length > 0) {
                    tweets.forEach(function (tweet, index) {
                        // part and arr[index] point to the same object
                        // so changing the object that part points to changes the object that arr[index] points to
                        tweet.created = moment(tweet.created).format('YYYY-MM-DD hh:mm').toString();
                        tweet.createdAt = moment(tweet.createdAt).format('YYYY-MM-DD hh:mm')
                        tweet.updatedAt = moment(tweet.updatedAt).format('YYYY-MM-DD hh:mm')
                    });

                    const filename = './ML/Python/topic/static/batchTweets.csv';

                    convertToCsvRaw(tweets, filename, async () => {
                        var topicArray = await this.detectTopicPromise(filename);
                        var topicArrayObj = JSON.parse(topicArray);
                        for (let topicObj of topicArrayObj) {
                            console.log(topicObj)
                            TweetTopic.upsert({
                                id: topicObj.key,
                                topicId: topicObj.id,
                                topicContent: topicObj.topic,
                                probability: topicObj.probability
                            })
                        }
                        this.detectTopics();
                        logger.log('info', '100 topics detected');
                    })


                }
            });
        } else {
            logger.log('warn', 'Topic detection is not running');
        }
    }

    detectTopicPromise(csvFile) {
        return new Promise((resolve, reject) => {
            detectTopicLDAStaticBatch(csvFile, result => {
                resolve(result);
            })
        })
    }
}
