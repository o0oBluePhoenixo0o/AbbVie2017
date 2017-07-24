import PythonShell from 'python-shell';
import child_process from 'child_process';
import moment from 'moment';
import {
    Tweet
} from '../data/connectors';
import {
    convertToCsvRaw
} from '../service/export';


/**
 * @function sentiment
 * @param  {String} message  The message you want to detect the sentiment
 * @param  {Function} callback Function to handle the sentiment resutl
 * @description Detects the sentiment of a message
 * @see File server/ML/Java/sentiment_executor
 * @return {String} sentiment string
 */
function sentiment(file, message, callback) {
    var child = child_process.exec(
        'java -jar ./ML/Java/sentiment_executor-1.0-SNAPSHOT-jar-with-dependencies.jar ' + '"2" "' +
        file +
        '" "' +
        message +
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
 * @function topicDetection
 * @param  {Date} startDate Date of the tweets created
 * @param  {Date} endDate   Date of the tweets created
 * @description Detects the topics of a bag of tweets created in a specific time range
 * @see File server/ML/Python/Test.py
 * @return {Array} Returns an array containing the result of the topic detection
 */
function topicDetection(startDate, endDate, callback) {
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
        convertToCsvRaw(tweets, "./ML/Python/tweets.csv");
        if (typeof callback === "function") {
            callback(tweets);
        }
    });
}


module.exports = {
    sentiment: sentiment,
    topicDetection: topicDetection
};