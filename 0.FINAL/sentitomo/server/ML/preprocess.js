/** @module Preprocess */

import R from "r-script";

/**
* @function preprocessTweetMessage
* @param  {String} tweetMessage The Twitter tweet
* @description Preprocesses a message from Twitter
* @see File server/ML/R/preprocess.R
* @return {String} A preprocessed message
*/
export function preprocessTweetMessage(tweetMessage) {
    var out = R("./ML/R/preprocess.R")
        .data({
            message: tweetMessage
        })
        .callSync();
    return out;
}