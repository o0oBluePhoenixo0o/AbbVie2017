import Twitter from "twitter";
import moment from "moment";
import { Author } from '../data/connectors';
import { Dashboard } from '../data/connectors';


import preprocess from './preprocess.js';
import classify from './classify.js';

module.exports = class TwitterCrawler {

    constructor(config) {
        this.client = new Twitter({
            consumer_key: config.consumer_key,
            consumer_secret: config.consumer_secret,
            access_token_key: config.access_token_key,
            access_token_secret: config.access_token_secret
        });
        console.log("Twitter API initialized successfully");

        this.track(process.env.TWITTER_STREAMING_FILTERS);
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

    getHTMLTagContent(string) {
        return string.replace(/<\/?[^>]+(>|$)/g, "");
    }

    /**
     * Starts using the twitter api with the specified filters
     * @param {String} filters 
     */
    track(filters) {
        console.log("Start streaming Twitter tweets with filters: " + filters);
        this.client.stream('statuses/filter', { track: filters, tweet_mode: 'extended' }, (stream) => {
            stream.on('data', (event) => {
                if (event.lang == 'en') {

                    var messagePrep = preprocess.preprocessTweetMessage(event.text);

                    //Insert in the normal tables
                    //If an author already exists an error is thrown
                    Author
                        .build({ id: event.user.id, username: event.user.name, screenname: event.user.screen_name })
                        .save()
                        .then(author => {
                            author.createTW_CORE({
                                id: event.id,
                                keywordType: "Placeholder",
                                keyword: this.getKeyword(event.text, filters),
                                created: event.created_at,
                                createdWeek: moment(event.created_at).week(),
                                toUser: event.in_reply_to_user_id,
                                language: event.lang,
                                source: this.getHTMLTagContent(event.source),
                                message: event.text,
                                messagePrep: messagePrep,
                                latitude: event.coordinates,
                                longitude: event.coordinates,
                                retweetCount: event.retweet_count,
                                favorited: event.favorited,
                                favoriteCount: event.favorite_count,
                                isRetweet: event.retweeted_status ? true : false,
                                retweeted: event.retweeted
                            })
                        })
                        .catch(error => {
                            console.log(error);
                        });

                    //Insert in the Dashboard tables                       
                    classify.sentiment("./ML/Java/naivebayes.bin", messagePrep, (result) => {

                        Dashboard
                            .build({
                                id: event.id,
                                keywordType: "Placeholder",
                                keyword: this.getKeyword(event.text, filters),
                                message: event.text,
                                created: moment(event.created).toDate(),
                                createdWeek: moment(event.created).week(),
                                fromScreenName: event.user.screen_name,
                                toScreenName: event.in_reply_to_screen_name,
                                tweetType: event.retweeted_status ? "retweet" : "tweet",
                                sentiment: result,
                                topicWhole: "Great topic such wow",
                                topicWhole_C: "great, doge, content",
                                topic3Month: "Cultural man",
                                topic3Month_C: "i, see, cultural, man, too, you"
                            })
                            .save()
                            .catch(error => {
                                console.log(error);
                            });
                    });
                } else {
                    console.log("no eng tweet: " + event.lang);
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
