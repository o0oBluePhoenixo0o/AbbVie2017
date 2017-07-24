import R from "r-script";
import PythonShell from "python-shell";

/**
* @function preprocessTweetMessage
* @param  {String} tweetMessage The Twitter tweet
* @description Preprocesses a message from Twitter
* @see File server/ML/R/preprocess.R
* @return {String} A preprocessed message
*/
function preprocessTweetMessage(tweetMessage) {
    var out = R("./ML/R/preprocess.R")
        .data({
            message: tweetMessage
        })
        .callSync();
    return out;
}


module.exports = {
    preprocessTweetMessage: preprocessTweetMessage,
};
