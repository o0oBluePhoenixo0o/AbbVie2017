import Twitter from 'twitter';
import moment from 'moment';
import {
    TweetAuthor,
    Tweet,
    TweetSentiment,
    TweetTopic
} from '../data/connectors';
import { getKeyword, stripHTMLTags, extractHashtagsFromTweet } from '../util/utils';
import { preprocessTweetMessage } from '../ML/preprocess.js';
import { detectSentimentEnsembleR, detectSarcasmSync, detectTopicLDAStatic, detectSentimentEnsemblePythonSync } from '../ML/ml_wrapper.js';
import logger from './logger.js';

/** @class TwitterCrawler 
 *  @param  {Object} config Config object which contains the Twitter API credentials
 *  @classdesc Class for crawling Twitter data
*/
export default class TwitterCrawler {

    constructor(config) {
        this.client = new Twitter({
            consumer_key: config.consumer_key,
            consumer_secret: config.consumer_secret,
            access_token_key: config.access_token_key,
            access_token_secret: config.access_token_secret
        });
        logger.log('info', 'Twitter API initialized successfully');
    }

    /**
     * @function start
     * @description Starts the tracking function with the specified filters in the .env file
     * @see File /server/.env
     * @memberof TwitterCrawler
     * @return {void} 
     */
    start() {
        this.track(process.env.TWITTER_STREAMING_FILTERS);
        logger.log('info', 'Twitter API now crawling tweets');
    }

    /**
     * @function updateTweetAuthors
     * @description Updates all Twitter users in the database, where the followerCount is null
     * @memberof TwitterCrawler
     * @return {void}
     */
    updateTweetAuthors() {
        TweetAuthor.findAll({
            where: {
                followercount: null
            }
        }).then(authors => {
            var interval = 10 * 1000; // 10 seconds;
            for (var i = 0; i <= authors.length - 1; i++) {
                setTimeout(
                    i => {
                        this.client.get(
                            'users/search', {
                                q: authors[i].username
                            },
                            (error, tweets, response) => {
                                if (!error && tweets[0]) {
                                    console.log(tweets[0]);
                                    TweetAuthor.update({
                                        followercount: tweets[0].followers_count,
                                        screenname: tweets[0].screen_name
                                    }, {
                                            where: {
                                                id: authors[i].id
                                            }
                                        })
                                        .then(result =>
                                            console.log(
                                                'Author: ' +
                                                authors[i].id +
                                                ' was updated'
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
     * @param {String} filters The filters which are used to track tweets from the Twitter API
     * @description Starts using the Twitter API with the specified filters. When a new tweet is crawled it upserts the author data
     * and inserts the raw tweet data into the database. It also detects the sentiment of the tweet, along with detecting sarcasm and emoji sentiment.
     * @see {@link module:ML_Wrapper~detectSarcasm}
     * @see {@link module:Connectors~TwitterAuthor}
     * @see {@link module:Connectors~Tweet}
     * @see {@link module:Connectors~TwitterSentiment}
     * @see {@link module:Connectors~TwitterSentiment}
     * @memberof TwitterCrawler
     * @return {void}
     */
    track(filters) {
        logger.log('info', 'Start streaming Twitter tweets with filters: ' + filters);
        this.client.stream(
            'statuses/filter', {
                track: filters,
                tweet_mode: 'extended'/*
                filter_level: 'medium'*/
            },
            stream => {
                stream.on('data', event => {
                    if (event.lang == 'en') {
                        logger.log('debug', 'Message: ' + event.text)
                        logger.log('debug', 'Extended tweet: ' + (event.extended_tweet ? event.extended_tweet.full_text : 'No extended tweet'));
                        TweetAuthor.upsert({
                            id: event.user.id,
                            username: event.user.name,
                            screenname: event.user.screen_name,
                            followercount: event.user.followers_count
                        }).then(created => { // created is an boolean indicating whether the instance was created (1) or updated (0)
                            TweetAuthor.findOne({
                                where: {
                                    id: event.user.id
                                }
                            }).then(async author => {

                                author.createTW_Tweet({
                                    id: event.id,
                                    keywordType: 'Placeholder',
                                    keyword: getKeyword(
                                        event.extended_tweet ? event.extended_tweet.full_text : event.text,
                                        filters
                                    ),
                                    created: event.created_at,
                                    createdWeek: moment(
                                        event.created_at, 'dd MMM DD HH:mm:ss ZZ YYYY', 'en'
                                    ).week(),
                                    toUser: event.in_reply_to_user_id,
                                    language: event.lang,
                                    source: stripHTMLTags(
                                        event.source
                                    ),
                                    message: event.extended_tweet ? event.extended_tweet.full_text : event.text,
                                    hashtags: extractHashtagsFromTweet(event.entities.hashtags),
                                    latitude: event.coordinates ? event.coordinates[0] : null,
                                    longitude: event.coordinates ? event.coordinates[1] : null,
                                    retweetCount: event.retweet_count,
                                    favorited: event.favorited,
                                    favoriteCount: event.favorite_count,
                                    isRetweet: event.retweeted_status ?
                                        true : false,
                                    retweeted: event.retweeted
                                }).then(tweet => {
                                    console.log("Inserted message: " + tweet.message);
                                });
                            })
                        }).catch(error => {
                            console.log(error);
                            logger.log('error', error);
                            if (error.code == 'ER_DUP_ENTRY') { // user exists

                            }
                        });

                        //If an TwitterAuthor already exists it gets updated

                    } else { //NO english tweet
                    }
                });

                stream.on('error', function (error) {
                    logger.log('error', error);
                    //throw error;
                });
            }
        );
    }
};