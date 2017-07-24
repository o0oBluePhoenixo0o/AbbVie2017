import R from "r-script";
import PythonShell from "python-shell";
import franc from "franc-min";

module.exports = {
    /**
     * @function preprocessTweetMessage
     * @param  {String} tweetMessage The Twitter tweet
     * @description Preprocesses a message from Twitter
     * @see File server/ML/R/preprocess.R
     * @return {String} A preprocessed message
     */
    preprocessTweetMessage: function (tweetMessage) {
        var out = R("./ML/R/preprocess.R")
            .data({
                message: tweetMessage
            })
            .callSync();
        return out;
    },
    detectLanguage: function (message) {
        return franc(message);
    }
};

/*
PythonShell.run('./server/ML/Python/myscript.py', {
    args: ['hello', 'world']
}, function (err, results) {
    if (err) console.log(err);
    console.log('results: %j', results);
    console.log("finish")
});


var pyshell = new PythonShell('./server/ML/Python/myscript.py');

// sends a message to the Python script via stdin
pyshell.send('hello');

pyshell.on('message', function (message) {
    // received a message sent from the Python script (a simple "print" statement)
    console.log(message);
});

// end the input stream and allow the process to exit
pyshell.end(function (err) {
    if (err) throw err;
    console.log('finished');
});*/