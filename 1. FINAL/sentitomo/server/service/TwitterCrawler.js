import Twitter from "twitter";
import moment from "moment";
import {
    Author
} from "../data/connectors";
import {
    Dashboard
} from "../data/connectors";

import preprocess from "./preprocess.js";
import classify from "./classify.js";
var logger = require('./logger.js');


module.exports = class TwitterCrawler {
    constructor(config) {
        this.client = new Twitter({
            consumer_key: config.consumer_key,
            consumer_secret: config.consumer_secret,
            access_token_key: config.access_token_key,
            access_token_secret: config.access_token_secret
        });
        logger.log('info', 'Twitter API initialized successfully');
        /*Start tracking keywords */
        this.track(process.env.TWITTER_STREAMING_FILTERS);
        //this.updateAuthors();

        /*classify.sentiment("./ML/Java/naivebayes.bin",
            "I love you",
            result => {
                console.log(result);
            });*/

        //console.log(preprocess.preprocessTweetMessage("RT @dude this is a cool twitter message"));
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
        keywords.map(keyword => {
            var occurrences = this.occurrences(
                message.toLowerCase(),
                keyword,
                false
            );
            if (occurrences > mostOcc) {
                mostOcc = occurrences;
                key = keyword;
            }
        });
        return key;
    }

    /** 
     * @function occurrences
     * @param {String} string The string
     * @param {String} subString The sub string to search for
     * @param {Boolean} allowOverlapping Optional. (Default:false)
     * @author Vitim.us https://gist.github.com/victornpb/7736865/edit
     * @see Unit Test https://jsfiddle.net/Victornpb/5axuh96u/
     * @see http://stackoverflow.com/questions/4009756/how-to-count-string-occurrence-in-string/7924240#7924240
     * @description Function that count occurrences of a substring in a string;
     * @return {int} How many times the substring occurs
     */
    occurrences(string, subString, allowOverlapping) {
        string += "";
        subString += "";
        if (subString.length <= 0) return string.length + 1;

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
     * @function getHTMLTagContent
     * @param  {String} string A string containing HTML Tags
     * @description Parse out HTML tags
     * @return {String} Returns a string where every HTML tag is parsed out
     */
    getHTMLTagContent(string) {
        return string.replace(/<\/?[^>]+(>|$)/g, "");
    }

    /**
     * @function updateAuthors
     * @description Updates all Twitter users in the database
     * @return {void}
     */
    updateAuthors() {
        Author.findAll({
            where: {
                followercount: null
            }
        }).then(authors => {
            var interval = 10 * 1000; // 10 seconds;
            for (var i = 0; i <= authors.length - 1; i++) {
                setTimeout(
                    i => {
                        this.client.get(
                            "users/search", {
                                q: authors[i].username
                            },
                            (error, tweets, response) => {
                                if (!error && tweets[0]) {
                                    console.log(tweets[0]);
                                    Author.update({
                                            followercount: tweets[0].followers_count,
                                            screenname: tweets[0].screen_name
                                        }, {
                                            where: {
                                                id: authors[i].id
                                            }
                                        })
                                        .then(result =>
                                            console.log(
                                                "Author: " +
                                                authors[i].id +
                                                " was updated"
                                            )
                                        )
                                        .catch(err => logger.log('error', err));
                                } else {
                                    logger.log('error', error);
                                }
                            }
                        );
                    },
                    interval * i,
                    i
                );
            }
        });
    }

    /**
     * @function track 
     * @param {String} filters 
     * @description Starts using the twitter api with the specified filters
     */
    track(filters) {
        logger.log("info", "Start streaming Twitter tweets with filters: " + filters);
        this.client.stream(
            "statuses/filter", {
                track: filters,
                tweet_mode: "extended"
            },
            stream => {
                stream.on("data", event => {
                    if (event.lang == "en") {
                        var messagePrep = preprocess.preprocessTweetMessage(
                            event.text
                        );
                        //Insert in the normal tables
                        //If an author already exists an error is thrown
                        Author.build({
                                id: event.user.id,
                                username: event.user.name,
                                screenname: event.user.screen_name,
                                followercount: event.user.followers_count
                            })
                            .save()
                            .then(author => {
                                author.createTW_CORE({
                                    id: event.id,
                                    keywordType: "Placeholder",
                                    keyword: this.getKeyword(
                                        event.text,
                                        filters
                                    ),
                                    created: event.created_at,
                                    createdWeek: moment(
                                        event.created_at
                                    ).week(),
                                    toUser: event.in_reply_to_user_id,
                                    language: event.lang,
                                    source: this.getHTMLTagContent(
                                        event.source
                                    ),
                                    message: event.text,
                                    messagePrep: messagePrep,
                                    latitude: event.coordinates,
                                    longitude: event.coordinates,
                                    retweetCount: event.retweet_count,
                                    favorited: event.favorited,
                                    favoriteCount: event.favorite_count,
                                    isRetweet: event.retweeted_status ?
                                        true : false,
                                    retweeted: event.retweeted
                                });
                            })
                            .catch(error => {
                                logger.log("error", error);
                            });

                        //Insert in the Dashboard tables
                        classify.sentiment(
                            "./ML/Java/naivebayes.bin",
                            messagePrep,
                            result => {
                                Dashboard.build({
                                        id: event.id,
                                        keywordType: "Placeholder",
                                        keyword: this.getKeyword(
                                            event.text,
                                            filters
                                        ),
                                        message: event.text,
                                        created: moment(event.created).toDate(),
                                        createdTime: moment(event.created)
                                            .utc()
                                            .format("hh:mm:ss"),
                                        createdDate: moment(event.created).format(
                                            "YYYY-MM-DD"
                                        ),
                                        createdWeek: moment(event.created).week(),
                                        screenName: event.user.screen_name,
                                        tweetType: event.retweeted_status ?
                                            "retweet" : "tweet",
                                        sentiment: result,
                                        sarcasm: false, //TODO: Change with sarcasm detection file result
                                        topicWhole: "Great topic such wow",
                                        topicWhole_C: "great, doge, content",
                                        topic3Month: "Cultural man",
                                        topic3Month_C: "i, see, cultural, man, too, you"
                                    })
                                    .save()
                                    .catch(error => {
                                        logger.log("error", error);
                                    });
                            }
                        );
                    } else {
                        //no english tweet
                    }
                });

                stream.on("error", function (error) {
                    logger.log("error", error);
                    //throw error;
                });
            }
        );
    }
};