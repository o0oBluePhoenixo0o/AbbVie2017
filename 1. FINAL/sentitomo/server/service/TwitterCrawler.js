var DatabaseConnection = require("../service/database.js");
var Twitter = require('twitter');

var preprocess = require('./preprocess.js');
var classify = require('./classify.js');


module.exports = class TwitterCrawler {

    constructor(config) {
        this.client = new Twitter({
            consumer_key: config.consumer_key,
            consumer_secret: config.consumer_secret,
            access_token_key: config.access_token_key,
            access_token_secret: config.access_token_secret
        });
        console.log("Twitter API initialized successfully")

        this.db = new DatabaseConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASS,
            database: process.env.DB_NAME,
            dateStrings: 'date',
            port: process.env.DB_PORT
        });


        classify.sentiment("./server/ML/Java/naivebayes.bin", "i love you", (result) => {
            console.log(result);
        });


        console.log(preprocess.preprocessTweetMessage("RT @TessEractica: @indgop  I really like this product humira #humira #abbvie"))
        //this.track(process.env.TWITTER_STREAMING_FILTERS);

        //this.track("abbvie")
        //this.track("amgen")
        //this.track("javascript")
    }

    /**
    * @function getKeyword
    * @param  {String} message The message where we want to extract the most possible keyword
    * @param  {String} filters The filters which were used to get this message
    * @description Because the twitter API do not let us know what keyword was the reason a tweet was crawled we try to extract the most possible one
    * @return {String} The keyword which is most likely the reason why this message was crawles
    */
    getKeyword(message, filters) {
        var mostOcc = "";
        var key = "";
        var keywords = filters.split(",");
        keywords.map((keyword) => {
            var occurrences = this.occurrences(message.toLowerCase(), keyword, false);
            console.log(keyword + " #" + occurrences)
            if (occurrences > mostOcc) {
                mostOcc = occurrences;
                key = keyword;
            }
        })
        return key;
    }

    /** Function that count occurrences of a substring in a string;
    * @param {String} string               The string
    * @param {String} subString            The sub string to search for
    * @param {Boolean} [allowOverlapping]  Optional. (Default:false)
    *
    * @author Vitim.us https://gist.github.com/victornpb/7736865/edit
    * @see Unit Test https://jsfiddle.net/Victornpb/5axuh96u/
    * @see http://stackoverflow.com/questions/4009756/how-to-count-string-occurrence-in-string/7924240#7924240
    */
    occurrences(string, subString, allowOverlapping) {

        string += "";
        subString += "";
        if (subString.length <= 0) return (string.length + 1);

        var n = 0,
            pos = 0,
            step = allowOverlapping ? 1 : subString.length;

        while (true) {
            pos = string.indexOf(subString, pos);
            if (pos >= 0) {
                ++n;
                pos += step;
            } else break;
        }
        return n;
    }

    /**
     * Starts using the twitter api with the specified filters
     * @param {String} filters 
     */
    track(filters) {
        console.log("Start streaming Twitter tweets with filters: " + filters);
        this.client.stream('statuses/filter', { track: filters, tweet_mode: 'extended' }, (stream) => {
            stream.on('data', (event) => {
                console.log("New tweet")

                if (event.lang == 'en') {
                    var tweet = {
                        id: event.id,
                        key: this.getKeyword(event.text, filters),
                        created: event.created_at,
                        from: event.user.id,
                        to: event.in_reply_to_user_id,
                        language: event.lang,
                        source: event.source,
                        message: event.text,
                        messagePrep: preprocess.preprocessTweetMessage(event.text),
                        latitude: event.coordinates,
                        longitude: event.coordinates,
                        retweet_count: event.retweet_count,
                        favorited: event.favorited,
                        favorite_count: event.favorite_count,
                        is_retweet: event.retweeted_status ? true : false,
                        retweeted: event.retweeted,

                    }

                    this.db.insertTweet(tweet);

                    classify.sentiment("./server/ML/Java/naivebayes.bin", tweet.messagePrep, (result) => {
                        var testTweet = {
                            id: tweet.id,
                            key: tweet.key,
                            created: tweet.created,
                            from: event.user.name,  // only for testing we using the user name
                            to: tweet.to,
                            message: tweet.message,
                            favorite_count: tweet.favorite_count,
                            is_retweet: tweet.is_retweet,
                            retweet_count: tweet.retweet_count,
                            sentiment: result
                        }
                        console.log(testTweet)
                        this.db.insertTweetFinalTest(testTweet);

                    });

                    this.db.insertTwitterUser({ id: event.user.id, name: event.user.name })
                    console.log("-------------------------------------")
                } else {
                    console.log("no eng tweet");
                    console.log(event.lang);
                }
            });


            stream.on('error', function (error) {
                console.log(error)
                //throw error;
            });
        });
    }
}
