import moment from 'moment';
import { convertRawToCsv } from '../util/export';
import { Tweet, TweetSentiment } from '../data/connectors';
import { detectSentimentEnsembleR, detectSarcasm, detectSentimentEnsemblePython } from "../ML/ml_wrapper";
import logger from './logger';

/**
 * @class SentimentWorker
 * @description Class for simoultaneously detecting the sentiment of tweets inside the database
 */
export default class SentimentWorker {
    constructor() {
        this.running = false;
    }

    /**
     * @function start
     * @description Runs @see {@link class:SentimentWorker~detectSentiments} method to detect the sentiment of tweets and posts inside the database
     * @memberof SentimentWorker
     * @return {void} 
     */
    start() {
        this.running = true;
        logger.log('info', 'Sentiment detection worker started');
        this.detectSentiments();
    }

    /**
    * @function stop
    * @description Stops the topic detection of tweets
    * @memberof SentimentWorker
    * @return {void} 
    */
    stop() {
        this.running = false;
        logger.log('info', 'Sentiment detection worker stopped');
    }

    /**
     * @function detectSentiments
     * @description Crawls 100 tweets from the database where the sentiment is not yet detected. It will then use different sentiment detection algorithms to detect the sentiments
     * If no tweets are found, where the sentiment is missing, the function will wait for 10 minutes to let new tweets gets crawled and then starts again.
     * @see {@link module:ML_Wrapper~detectSentimentEnsembleR}
     * @see {@link module:ML_Wrapper~detectSentimentEnsemblePython}
     * @see {@link module:ML_Wrapper~detectSarcasm}
     * @memberof SentimentWorker
     * @return {void}
     */
    detectSentiments() {
        if (this.running) {
            Tweet.findAll({
                where: {
                    '$TW_Sentiment.id$': { $eq: null }
                },
                limit: 10,
                raw: true,
                order: [['createdAt', 'ASC']],
                include: [{
                    model: TweetSentiment, as: TweetSentiment.tableName
                }],
            }).then(async tweets => {


                if (tweets.length > 0) {

                    for (var index in tweets) {
                        var tweet = tweets[index];
                        logger.log('debug', 'Tweet message: ' + tweet.message)
                        const sentiment = await detectSentimentEnsembleR(tweet.message);
                        logger.log('debug', 'R sentiment : ' + sentiment)
                        const sarcasticValue = await detectSarcasm(tweet.message);
                        logger.log('debug', 'R sarcastic : ' + sarcasticValue)
                        const ensemblePython = await detectSentimentEnsemblePython(tweet.message);
                        logger.log('debug', 'Python ensemble: ' + ensemblePython)

                        TweetSentiment.upsert({
                            id: tweet.id,
                            sentiment: sentiment != '' ? sentiment.toLowerCase().trim() : null, // remove whitespaces and line breaks
                            sarcastic: sarcasticValue != '' ? sarcasticValue : null,
                            rEnsemble: sentiment != '' ? sentiment.toLowerCase().trim() : null, // remove whitespaces and line breaks
                            pythonEnsemble: ensemblePython != '' ? ensemblePython.toLowerCase().trim() : null, // remove whitespaces and line breaks
                        })
                    }
                    logger.log('info', "10 Sentiments of tweets detected ")
                    this.detectSentiments();
                } else {
                    setTimeout(() => this.detectSentiments(), 600000) // wait 10 minutes for new tweets to come ine
                }
            });
        } else {
            logger.log('warn', 'Sentiment detection worker is not running');
        }
    }
}
