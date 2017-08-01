/** @module ML_Wrapper
 *  @description Contains function for invoking the different Machine Learning files
 */
import child_process from 'child_process';
import PythonShell from 'python-shell';
import R from "r-script";
import moment from 'moment';
import {
    Tweet
} from '../data/connectors';
import {
    convertToCsvRaw
} from '../service/export';


/**
 * @function detectSentiment
 * @param  {String} message  The message you want to detect the sentiment
 * @param  {Function} callback Function to handle the sentiment result
 * @description Detects the sentiment of a message
 * @see File server/ML/Java/sentiment_executor
 * @return {String} sentiment string
 */
export function detectSentiment(file, message, callback) {
    console.log(message.replace(/"/g, '\\"').replace(/'/g, "\\'"))
    var child = child_process.exec(
        'java -jar ./ML/Java/sentiment_executor-1.0-SNAPSHOT-jar-with-dependencies.jar ' + '"2" "' +
        file +
        '" "' +
        message.replace(/"/g, '\\"').replace(/'/g, "\\'") +
        '"',
        function (error, stdout, stderr) {
            if (error !== null) {
                console.log("Error -> " + error);
            }
            console.log("Output -> " + stdout);
            callback(stdout.trim());
        }
    );
}


/**
 * @function detectTopicDynamic
 * @param  {String} startDate  File path to the .csv file which contains all tweets needed for topic detection
 * @param  {Function} callback Callback function which handles the result
 * @description Creates a new topic model out of the specified time range of tweets and detects the topics on those
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
            tweet.created = moment(tweet.created).format("YYYY-MM-DD hh:mm").toString();
            tweet.createdAt = moment(tweet.createdAt).format('YYYY-MM-DD hh:mm')
            tweet.updatedAt = moment(tweet.updatedAt).format('YYYY-MM-DD hh:mm')
        });

        const filename = "./ML/Python/dynamic/tweets.csv";

        convertToCsvRaw(tweets, filename, () => {
            console.log("Starting dynamic ")
            var child = child_process.exec(
                'python3 ./ML/Python/dynamic/dynamic.py ' + filename, (error, stdout, stderr) => {
                    if (error !== null) {
                        console.log("Error -> " + error);
                    }
                    if (typeof callback === "function") {
                        callback(stdout.trim());
                    }

                }
            );
        });

    });
}

/**
 * @function detectTopicStatic
 * @param  {type} last100Tweets {description}
 * @param  {type} callback      {description}
 * @description Uses a predefined model trained on all tweets at the end of this project to detect the topics of tweets 
 * @return {String} A JSON encoded string, containing the results of the topic detection
 */
export function detectTopicStatic(startDate, endDate, callback) {
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
            tweet.created = moment(tweet.created).format("YYYY-MM-DD hh:mm").toString();
            tweet.createdAt = moment(tweet.createdAt).format('YYYY-MM-DD hh:mm')
            tweet.updatedAt = moment(tweet.updatedAt).format('YYYY-MM-DD hh:mm')
        });

        const filename = "./ML/Python/static/tweets.csv";

        convertToCsvRaw(tweets, filename, () => {
            console.log("starting static topic detection")
            var child = child_process.exec(
                'python3 ./ML/Python/static/static.py ' + filename, (error, stdout, stderr) => {
                    if (error !== null) {
                        console.log("Error -> " + error);
                    }
                    if (typeof callback === "function") {
                        callback(stdout.trim());
                    }

                }
            );
        });

    });
}

/**
* @function detectSarcasm
* @param  {String} tweetMessage The Twitter tweet
* @description Detect if a message is meant in a saracastic way
* @see File server/ML/R/sarcasmDetection.R
* @return {String} A boolean whether the tweet is sacrastic or not
*/
export function detectSarcasm(tweetMessage) {
    var out = R("./ML/R/sarcasmDetection.R")
        .data({
            message: tweetMessage
        })
        .callSync();
    console.log("Output -> " + out)
    return out;
}