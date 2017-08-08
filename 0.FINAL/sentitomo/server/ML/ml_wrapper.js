/** @module ML_Wrapper
 *  @description Contains function for invoking the different Machine Learning files
 */
import { PythonShell, JavaShell, RShell } from '../util/foreignCode';
import { Tweet } from '../data/connectors';
import { convertToCsvRaw } from '../util/export';
import moment from 'moment';


/**
 * @function detectSentiment
 * @param  {String} message  The message you want to detect the sentiment
 * @param  {Function} callback Function to handle the sentiment result
 * @description Detects the sentiment of a message
 * @see File server/ML/Java/sentiment_executor
 * @return {String} sentiment string
 */
export function detectSentiment(file, message, callback) {
    JavaShell('./ML/Java/sentiment_executor-1.0-SNAPSHOT-jar-with-dependencies.jar')
        .data(['2', file, message.replace(/"/g, '\\"').replace(/'/g, "\\'")])
        .call(result => {
            callback(result);
        });
}

export function detectSentimentPhilipp(tweetMessage) {
    var out = RShell('./ML/R/EnsembleR_server.R')
        .data([tweetMessage])
        .callSync();
    console.log('Output -> ' + out)
    return out;
}

/**
* @function detectSarcasm
* @param  {String} tweetMessage The Twitter tweet
* @description Detect if a message is meant in a saracastic way
* @see File server/ML/R/sarcasmDetection.R
* @return {String} A boolean whether the tweet is sacrastic or not
*/
export function detectSarcasm(tweetMessage) {
    var out = RShell('./ML/R/sarcasmDetection.R')
        .data([tweetMessage])
        .callSync()

    console.log('Output -> ' + out)
    return out;
}


export function detectTopicCTM(startDate, endDate, callback) {
    Tweet.findAll({
        where: {
            created: {
                $lt: endDate, // less than
                $gt: startDate //greater than
            }
        },
        raw: true //we use raw, we do not need to have access to the sequlize model here
    }).then(tweets => {
        tweets.forEach(function (tweet, index) {
            // part and arr[index] point to the same object
            // so changing the object that part points to changes the object that arr[index] points to
            tweet.created = moment(tweet.created).format('YYYY-MM-DD hh:mm').toString();
            tweet.createdAt = moment(tweet.createdAt).format('YYYY-MM-DD hh:mm')
            tweet.updatedAt = moment(tweet.updatedAt).format('YYYY-MM-DD hh:mm')
        });
        const filename = './ML/R/tweets.csv';

        //TODO: There is a problem with the filepath uUEO of json input
        convertToCsvRaw(tweets, filename, () => {

            RShell('./R/ctm.R').data([filename]).call(result => {
                console.log(result);
            })
        });

    });
}


/**
 * @function detectTopicDynamic
 * @param  {String} startDate  File path to the .csv file which contains all tweets needed for topic detection
 * @param  {Function} callback Callback function which handles the result
 * @description Creates a new topic model out of the specified time range of tweets and detects the topics on those
 * @see File server/ML/Python/dynamic/dynamic.py
 * @return {String} A JSON encoded string, containing the results of the topic detection
 */
export function detectTopicDynamic(startDate, endDate, callback) {
    Tweet.findAll({
        where: {
            created: {
                $lt: endDate, // less than
                $gt: startDate //greater than
            }
        },
        raw: true //we use raw, we do not need to have access to the sequlize model here
    }).then(tweets => {
        tweets.forEach(function (tweet, index) {
            // part and arr[index] point to the same object
            // so changing the object that part points to changes the object that arr[index] points to
            tweet.created = moment(tweet.created).format('YYYY-MM-DD hh:mm').toString();
            tweet.createdAt = moment(tweet.createdAt).format('YYYY-MM-DD hh:mm')
            tweet.updatedAt = moment(tweet.updatedAt).format('YYYY-MM-DD hh:mm')
        });

        const filename = './ML/Python/dynamic/tweets.csv';

        convertToCsvRaw(tweets, filename, () => {
            console.log('Starting dynamic ')
            PythonShell('./ML/Python/dynamic/dynamic.py', 3).data([filename]).call(result => {
                callback(result);
            });
        });

    });
}

/**
 * @function detectTopicStatic
 * @param  {type} last100Tweets {description}
 * @param  {type} callback      {description}
 * @description Uses a predefined model trained on all tweets at the end of this project to detect the topics of tweets
 * @see File server/ML/Python/static/final.py
 * @return {String} A JSON encoded string, containing the results of the topic detection
 */
export function detectTopicStatic(jsonString, callback) {
    console.log('starting static');
    PythonShell('./ML/Python/static/final.py', 3).data([jsonString]).call(result => {
        if (typeof callback === 'function') {
            callback(result);
        }
    })
}

