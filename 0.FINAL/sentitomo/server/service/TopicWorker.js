import cron from 'cron';
import moment from 'moment';
import { convertToCsvRaw } from '../util/export';
import { Tweet, TweetTopic } from '../data/connectors';
import { detectTopicLDAStaticBatch } from "../ML/ml_wrapper";

import logger from './logger';


/**
 * @class TopicWorker
 * @description Class for simoultaneously detecting topics of tweets inside the database
 */
export default class TopicWorker {
    constructor() {
        this.running = false;
    }

    /**
     * @function start
     * @description Runs @see {@link class:TopicWorker~detectTopics} method to detect topics of tweets and posts inside the database
     * @memberof TopicWorker
     * @return {void} 
     */
    start() {
        this.running = true;
        logger.log('info', 'Topic detection worker started');
        this.detectTopics();
    }

    /**
    * @function start
    * @description Stops the topic detection of tweets
    @memberof TopicWorker
    * @return {void} 
    */
    stop() {
        this.running = false;
        logger.log('info', 'Topic detection worker started');
    }

    /**
     * @function detectTopics
     * @description Crawls n tweetsfrom the database where the topic is not yet detected. It will then use staticBatch.py file to detect the topics with LDA.
     * If no tweets are found, where the topics are missing, the function will wait for 10 minutes to let new tweets gets crawled and then starts again.
     * @see File server/ML/Python/topic/static/staticBatch.py
     * @memberof TopicWorker
     * @return {void}
     */
    detectTopics() {
        if (this.running) {
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
                        logger.log('info', '100 topics detected');
                        this.detectTopics();

                    })
                } else {
                    setTimeout(() => this.detectTopics(), 600000) // wait 10 minutes for new tweets to come ine
                }
            });
        } else {
            logger.log('warn', 'Topic detection is not running');
        }
    }

    /**
     * @function detectTopicPromise
     * @param {String} csvFile 
     * @description Wraps the result of the topic detection into a Promise to work with async and await concept
     * @see {@link module:ML_Wrapper~detectTopicLDAStaticBatch}
     * @memberof TopicWorker
     * @return {Promise} Promise object represents sum of the topic detection
     */
    detectTopicPromise(csvFile) {
        return new Promise((resolve, reject) => {
            detectTopicLDAStaticBatch(csvFile, result => {
                resolve(result);
            })
        })
    }
}
