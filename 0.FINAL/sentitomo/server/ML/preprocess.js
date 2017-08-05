/** @module Preprocess */

import { RShell } from "../wrapper/codeWrapper";

/**
* @function preprocessTweetMessage
* @param  {String} tweetMessage The Twitter tweet
* @description Preprocesses a message from Twitter
* @see File server/ML/R/preprocess.R
* @return {String} A preprocessed message
*/
export function preprocessTweetMessage(tweetMessage) {
    var out = RShell("./ML/R/preprocess.R")
        .data([tweetMessage])
        .callSync();
    return out;
}