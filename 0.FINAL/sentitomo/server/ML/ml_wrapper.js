/** @module ML_Wrapper
 * @description Contains function for invoking the different Machine Learning files
 */
import { PythonShell, JavaShell, RShell } from '../util/foreignCode';
import { Tweet } from '../data/connectors';
import { convertToCsvRaw } from '../util/export';
import moment from 'moment';

/**
 * @function detectSentiment
 * @param  {String} modelPath Path to the model to use
 * @param  {String} message  The message you want to detect the sentiment
 * @param  {Function} callback Function to handle the sentiment result
 * @description Detects the sentiment of a message using Mallet and Naive Bayes
 * @see File server/ML/Java/sentiment/sentiment_executor
 * @return {String} sentiment string
 * @memberof module:ML_Wrapper
 */
export function detectSentiment(modelPath, message, callback) {
    JavaShell('./ML/Java/sentiment/sentiment.jar')
        .data(['2', modelPath, message.replace(/"/g, '\\"').replace(/'/g, "\\'")])
        .call(result => {
            if (typeof callback === 'function') {
                callback(result);
            }
        });
}

/**
 * @function detectSentimentEnsembleR
 * @param  {String} message  The message to detect the sentiment
 * @param  {Function} callback Function to handle the sentiment result
 * @description Detects the sentiment of a message using six different sentiment analysis algorithms and pick the majority result of those. It uses:
 *  <ul>
 *      <li>Classification and Regression Trees (CART)</li>
 *      <li>Random Forest (RF)</li>
 *      <li>Support Vector Machines (SVM)</li>
 *      <li>Naive Bayes (NB)</li>
 *      <li>Distributed Random Forest (DRF)</li>
 *      <li>Gradient Boosting Machine (GBM)</li>
 * </ul>
 * Implemented in R
 * @see File server/ML/R/sentiment/ensembleSentiment.R
 * @return {String} sentiment string
 */
export function detectSentimentEnsembleR(tweetMessage, callback) {
    RShell('./ML/R/sentiment/ensembleSentiment.R')
        .data([tweetMessage])
        .call(result => {
            if (typeof callback === 'function') {
                callback(result.replace(/\s*\[(.+?)\]\s*/g, "").replace(/"/g, '')); // Strip out the typical R prints 
            }
        });
}

/**
 * @function detectSentimentEnsembleRSync
 * @param  {String} message  The message to detect the sentiment
 * @description This is the synchronous version of {@link module:ML_Wrapper~detectSentimentEnsembleR}
 * @see File server/ML/R/sentiment/ensembleSentiment.R
 * @return {String} sentiment string
 */
export function detectSentimentEnsembleRSync(tweetMessage) {
    var out = RShell('./ML/R/sentiment/ensembleSentiment.R')
        .data([tweetMessage])
        .calSync();
    return out.replace(/\s*\[(.+?)\]\s*/g, "").replace(/"/g, ''); // Strip out the typical R prints 
}

/**
* @function detectSarcasm
* @param  {String} message The message to detect the sarcasm
* @param  {Function} callback Function to handle the sentiment result
* @description Detect if a message is meant in a saracastic way. Internaly it uses a Naive Bayes based method to detect it.
* @see File server/ML/R/sarcasm/sarcasmDetection.R
* @return {Doube} A % number, indicating how much sarcastic this tweet is meant
*/
export function detectSarcasm(tweetMessage, callback) {
    RShell('./ML/R/sarcasm/sarcasmDetection.R')
        .data([tweetMessage])
        .call(result => {
            if (typeof callback === 'function') {
                callback(result.replace(/\s*\[(.+?)\]\s*/g, "").replace(/"/g, '')); // Strip out the typical R prints 
            }
        });
}

/**
* @function detectSarcasmSync
* @param  {String} message The message to detect the sarcasm
* @description This is the synchronous version of {@link module:ML_Wrapper~detectSarcasm}
* @see File server/ML/R/sarcasm/sarcasmDetection.R
* @return {Doube} A % number, indicating how much sarcastic this tweet is meant
*/
export function detectSarcasmSync(tweetMessage) {
    var out = RShell('./ML/R/sarcasm/sarcasmDetection.R')
        .data([tweetMessage])
        .callSync();
    return out.replace(/\s*\[(.+?)\]\s*/g, "").replace(/"/g, '');
}

/**
 * @function detectSentimentEnsemblePython
 * @param  {String} message  The message to detect the sentiment
 * @param  {Function} callback Function to handle the sentiment result
 * @description Detects the sentiment of a message using different Python packages. It uses:
 *  <ul>
 *      <li>Vader (Lexicon Based)</li>
 *      <li>Textblob Vers. 1 (Lexcion Based)</li>
 *      <li>Textblob Vers. 2 (Naive Bayes)</li>
 * </ul>
 * Implemented in Python
 * @see File server/ML/Python/sentiment/ensembleSentiment.R
 * @return {String} sentiment string
 */
export function detectSentimentEnsemblePython(message, callback) {
    PythonShell("./ML/Python/sentiment/ensembleSentiment.py", 2).data([message]).call(result => {
        if (typeof callback === 'function') {
            callback(result);
        }
    })
}

/**
 * @function detectSentimentEnsemblePythonSync
 * @param  {String} message  The message to detect the sentiment
 * @description This is the synchronous version of {@link module:ML_Wrapper~detectSentimentEnsemblePython}
 * @see File server/ML/Python/sentiment/ensembleSentiment.R
 * @return {String} sentiment string
 */
export function detectSentimentEnsemblePythonSync(message) {
    var out = PythonShell("./ML/Python/sentiment/ensembleSentiment.py", 2)
        .data([message])
        .callSync();
    return out;
}


/**
* @function detectTopicCTM
* @param  {Date} startDate Start date of the bucket 
* @param  {Date} endDate End date of the bucket 
* @param  {Function} callback Callback function which handles the result
* @description Creates a new topic model out of the specified time range of tweets and detects the topics on those. Internally it uses the Correlated Topic Models (CTM) model
* @see File server/ML/R/topic/ctm.R
* @return {String} A JSON encoded string containing an array consisting of the result of the topic detection
*/
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
        const filename = './ML/R/topic/tweets.csv';

        //TODO: There is a problem with the filepath uUEO of json input
        convertToCsvRaw(tweets, filename, () => {
            RShell('./ML/R/topic/ctm.R').data([filename]).call(result => {
                if (typeof callback === 'function') {
                    callback(result);
                }
            })
        });

    });
}

/**
 * @function detectTopicDynamic
 * @param  {String} startDate Start date of the bucket 
 * @param  {String} endDate End date of the bucket 
 * @param  {Function} callback Callback function which handles the result
 * @description Creates a new topic model out of the specified time range of tweets and detects the topics on those. Internally it uses LDA.
 * @see File server/ML/Python/topic/dynamic/dynamic.py
 * @return {String} A JSON encoded string containing an array consisting of the result of the topic detection
 */
export function detectTopicLDADynamic(startDate, endDate, callback) {
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

        const filename = './ML/Python/topic/dynamic/tweets.csv';

        convertToCsvRaw(tweets, filename, () => {
            PythonShell('./ML/Python/topic/dynamic/dynamic.py', 3).data([filename]).call(result => {
                if (typeof callback === 'function') {
                    callback(result);
                }
            });
        });

    });
}

/**
 * @function detectTopicLDAStatic
 * @param  {String} jsonString A JSON representation of a tweet object to detect the topic
 * @param  {type} callback Callback function which handles the result
 * @description Uses a predefined model trained on all tweets at the end of this project to detect the topics of  a single tweet. Internally it uses LDA.
 * @see File server/ML/Python/topic/static/final.py
 * @return {String} A JSON encoded string containing an array consisting of the result of the topic detection
 */
export function detectTopicLDAStatic(jsonString, callback) {
    console.log('starting static');
    PythonShell('./ML/Python/topic/static/final.py', 3).data([jsonString]).call(result => {
        if (typeof callback === 'function') {
            callback(result);
        }
    })
}

/**
 * @function detectTopicLDAStaticBatch
 * @param  {String} filename Path to the .csv file containing the tweets
 * @description Uses a predefined model trained on all tweets at the end of this project to detect the topics of tweets inside a csv. Internally it uses LDA.
 * @see File server/ML/Python/topic/static/staticBatch.py
 * @return {String} A JSON encoded string containing an array consisting of the result of the topic detection
 */
export function detectTopicLDAStaticBatch(csvFile, callback) {
    console.log('starting static batch');
    var out = PythonShell('./ML/Python/topic/static/staticBatch.py', 3).data([csvFile]).call(result => {
        if (typeof callback === 'function') {
            callback(result);
        }
    })
    return out;
}

/**
 * @function detectTopicLDAStaticSync
 * @param  {String} jsonString A JSON representation of a tweet object to detect the topic
 * @description This is the synchronous version of {@link module:ML_Wrapper~detectTopicLDAStatic}
 * @see File server/ML/Python/topic/static/final.py
 * @return {String} A JSON encoded string containing an array consisting of the result of the topic detection
 */
export function detectTopicLDAStaticSync(jsonString, callback) {
    console.log('starting static');
    var out = PythonShell('./ML/Python/topic/static/final.py', 3).data([jsonString]).callSync()
    return out;
}


