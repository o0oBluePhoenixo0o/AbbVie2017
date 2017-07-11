var exec = require('child_process').exec;

module.exports = {
    /**
    * @function sentiment
    * @param  {String} message  The message you want to detect the sentiment
    * @param  {Function} callback Function to handle the sentiment
    * @return {String} sentiment string
    */
    sentiment: function (file, message, callback) {
        var child = exec('java -jar ./ML/Java/sentiment_executor-1.0-SNAPSHOT-jar-with-dependencies.jar "' + file + '" "' + message + '"',
            function (error, stdout, stderr) {
                if (error !== null) {
                    console.log("Error -> " + error);
                }
                console.log("Output -> " + stdout);
                callback(stdout.trim());
            }
        );
    }
}