/** 
 * @module ML_Wrapper
 * @description Contains function for invoking the different Machine Learning files
 */

import { PythonShell, JavaShell, RShell } from '../util/foreignCode';
import { Tweet } from '../data/connectors';
import { convertToCsvRaw } from '../util/export';
import moment from 'moment';

/**
 * @function detectSentimentJavaNB
 * @param  {String} modelPath Path to the model to use
 * @param  {String} message  The message you want to detect the sentiment
 * @description Detects the sentiment of a message using Mallet and Naive Bayes
 * @see File server/ML/Java/sentiment/sentiment_executor
 * @returns {Promise<String>} A Promise that contains the sentiment of the message
 * when fulfilled.
 * @memberof module:ML_Wrapper
 */
export function detectSentimentJavaNB(modelPath, message) {
    return new Promise((resolve, reject) => {
        JavaShell('./ML/Java/sentiment/sentiment.jar')
            .data(['2', modelPath, message.replace(/"/g, '\\"').replace(/'/g, "\\'")])
            .call(result => {
                resolve(result);
            });
    });
}

/**
 * @function detectSentimentEnsembleR
 * @param  {String} message  The message to detect the sentiment
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
 * @returns {Promise<String>} A Promise that contains the sentiment of the message
 * when fulfilled.
 */
export function detectSentimentEnsembleR(tweetMessage) {
    return new Promise((resolve, reject) => {
        RShell('./ML/R/sentiment/ensembleSentiment.R')
            .data([tweetMessage])
            .call(result => {
                resolve(result.replace(/\s*\[(.+?)\]\s*/g, "").replace(/"/g, '')); // Strip out the typical R prints 
            });
    })
}

/**
 * @function detectSentimentEnsembleRSync
 * @param  {String} message  The message to detect the sentiment
 * @description This is the synchronous version of {@link module:ML_Wrapper~detectSentimentEnsembleR}
 * @see File server/ML/R/sentiment/ensembleSentiment.R
 * @returns {String} String indicating the sentiment
 */
export function detectSentimentEnsembleRSync(tweetMessage) {
    var out = RShell('./ML/R/sentiment/ensembleSentiment.R')
        .data([tweetMessage])
        .callSync();
    return out.replace(/\s*\[(.+?)\]\s*/g, "").replace(/"/g, ''); // Strip out the typical R prints 
}

/**
* @function detectSarcasm
* @param  {String} message The message to detect the sarcasm
* @description Detect if a message is meant in a saracastic way. Internally it uses a Naive Bayes based method to detect it.
* @see File server/ML/R/sarcasm/sarcasmDetection.R
* @returns {Promise<Double>} A Promise that contains the probability of the message to be sarcastic when fulfilled.
*/
export function detectSarcasm(tweetMessage) {
    return new Promise((resolve, reject) => {
        RShell('./ML/R/sarcasm/sarcasmDetection.R')
            .data([tweetMessage])
            .call(result => {
                resolve(result.replace(/\s*\[(.+?)\]\s*/g, "").replace(/"/g, '')); // Strip out the typical R prints 
            });
    })
}

/**
* @function detectSarcasmSync
* @param  {String} message The message to detect the sarcasm
* @description This is the synchronous version of {@link module:ML_Wrapper~detectSarcasm}
* @see File server/ML/R/sarcasm/sarcasmDetection.R
* @returns {Double} Probability of the message to be sarcastic
*/
export function detectSarcasmSync(message) {
    var out = RShell('./ML/R/sarcasm/sarcasmDetection.R')
        .data([message])
        .callSync();
    return out.replace(/\s*\[(.+?)\]\s*/g, "").replace(/"/g, '');
}

/**
 * @function detectSentimentEnsemblePython
 * @param  {String} message  The message to detect the sentiment
 * @description Detects the sentiment of a message using different Python packages. It uses:
 *  <ul>
 *      <li>Vader (Lexicon Based)</li>
 *      <li>Textblob Vers. 1 (Lexcion Based)</li>
 *      <li>Textblob Vers. 2 (Naive Bayes)</li>
 * </ul>
 * Implemented in Python
 * @see File server/ML/Python/sentiment/ensembleSentiment.R
 * @returns {Promise<String>} A Promise that contains the sentiment of the message
 * when fulfilled.
 */
export function detectSentimentEnsemblePython(message) {
    return new Promise((resolve, reject) => {
        PythonShell("./ML/Python/sentiment/ensembleSentiment.py", 2).data([message]).call(result => {
            resolve(result);
        })
    })
}

/**
 * @function detectSentimentEnsemblePythonSync
 * @param  {String} message  The message to detect the sentiment
 * @description This is the synchronous version of {@link module:ML_Wrapper~detectSentimentEnsemblePython}
 * @see File server/ML/Python/sentiment/ensembleSentiment.R
 * @returns {String} String indicating the sentiment
 */
export function detectSentimentEnsemblePythonSync(message) {
    var out = PythonShell("./ML/Python/sentiment/ensembleSentiment.py", 2)
        .data([message])
        .callSync();
    return out;
}

/**
 * @function detectTopicCTM
 * @param  {String} csvFile Path to the .csv file containing the objects to the detect the topic with
 * @description Creates a new topic model out of the specified csv file and detects the topics on those objects inside. Internally it uses the Correlated Topic Models (CTM).
 * @see File server/ML/R/topic/ctm.R
 * @returns {Promise<String>} A Promise that contains an array as JSON encoded String containing the topics of the objects
 * when fulfilled.
*/
export function detectTopicCTM(csvFile) {
    return new Promise((resolve, reject) => {
        RShell('./ML/R/topic/ctm.R').data([csvFile]).call(result => {
            resolve(result);
        })
    });
}

/**
 * @function detectTopicLDADynamic
 * @param  {String} csvFile Path to the .csv file containing the objects to the detect the topic with 
 * @description Creates a new topic model out of the specified csv file and detects the topics on those objects inside. Internally it uses LDA.
 * @see File server/ML/Python/topic/lda/dynamic/dynamic.py
 * @returns {Promise<String>} A Promise that contains an array as JSON encoded String containing the topics of tweets
 * when fulfilled.
*/
export function detectTopicLDADynamic(csvFile) {
    return new Promise((resolve, reject) => {
        PythonShell('./ML/Python/topic/lda/dynamic/dynamic.py', 3).data([csvFile]).call(result => {
            resolve(result);
        });
    })
}

/**
 * @function detectTopicLDAStatic
 * @param  {String} jsonString A JSON representation of a tweet object to detect the topic
 * @description Uses a predefined model trained on all tweets at the end of this project to detect the topics of  a single tweet. Internally it uses LDA.
 * @see File server/ML/Python/topic/lda/static/final.py
 * @returns {Promise<String>} A Promise that contains an array as JSON encoded String containing the topics of tweets
 * when fulfilled.
 */
export function detectTopicLDAStatic(jsonString) {
    return new Promise((resolve, reject) => {
        PythonShell('./ML/Python/topic/lda/static/staticSingle.py', 3).data([jsonString]).call(result => {
            resolve(result);
        })
    })
}

/**
 * @function detectTopicLDAStaticBatch
 * @param  {String} csvFile Path to the .csv file containing the tweets
 * @description Uses a predefined model trained on all tweets at the end of this project to detect the topics of tweets inside a csv. Internally it uses LDA.
 * @see File server/ML/Python/topic/lda/static/staticBatch.py
 * @returns {Promise<String>} A Promise that contains an array as JSON encoded String containing the topics of tweets
 * when fulfilled.
 */
export function detectTopicLDAStaticBatch(csvFile) {
    return new Promise((resolve, reject) => {
        PythonShell('./ML/Python/topic/lda/static/staticBatch.py', 3).data([csvFile]).call(result => {
            resolve(result);
        })
    })
}

/**
 * @function detectTopicLDAStaticSync
 * @param  {String} jsonString A JSON representation of a tweet object to detect the topic
 * @description This is the synchronous version of {@link module:ML_Wrapper~detectTopicLDAStatic}
 * @see File server/ML/Python/topic/lda/static/final.py
 * @return {String} An array as JSON encoded String containing the topics of tweets
 */
export function detectTopicLDAStaticSync(jsonString, callback) {
    var out = PythonShell('./ML/Python/topic/lda/static/staticSingle.py', 3).data([jsonString]).callSync()
    return out;
}


/**
 * @function detectTrends
 * @param  {String} csvFile Path to the .csv file containing the topics of tweets
 * @description Uses a  possion model to buid a graph containing the data points for trend detection
 * @see File server/ML/Python/trend/trend.py
 * @returns {Promise<String>} A Promise that contains an array as JSON encoded String containing the topics of tweets
 * when fulfilled.
 */
export function detectTrends(csvFile) {
    return new Promise((resolve, reject) => {
        PythonShell('./ML/Python/trend/trend.py', 3).data([csvFile]).call(result => {
            resolve(result);
        })
    })
}