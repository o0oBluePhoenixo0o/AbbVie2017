import PythonShell from 'python-shell';
import child_process from 'child_process';
import {
    Tweet
} from '../data/connectors';
import moment from 'moment';
import {
    convertToCsvRaw
} from './export';


/*
export function sentiment(file, message, callback) {
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
}*/


module.exports = {
    /**
     * @function sentiment
     * @param  {String} message  The message you want to detect the sentiment
     * @param  {Function} callback Function to handle the sentiment resutl
     * @description Detects the sentiment of a message
     * @return {String} sentiment string
     */
    sentiment: function (file, message, callback) {
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
    },
    topicDetection(startDate, endDate) {
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
        });
    }
};