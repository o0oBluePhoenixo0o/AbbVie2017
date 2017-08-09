/** @class TwitterCrawler 
 *  @param  {Object} config Config object which contains the Twitter API credentials
 *  @classdesc Class for crawling Twitter data
*/
import Twitter from 'twitter';
import moment from 'moment';
import {
    Author,
    Tweet,
    Sentiment,
    Topic
} from '../data/connectors';
import { getKeyword, stripHTMLTags } from '../util/utils';
import { preprocessTweetMessage } from '../ML/preprocess.js';
import { detectSentiment, detectSarcasm, detectTopicStatic, detectTopicDynamic, detectTopicCTM } from '../ML/ml_wrapper.js';
import logger from './logger.js';


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
     * @function updateAuthors
     * @description Updates all Twitter users in the database
     * @memberof TwitterCrawler
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
                            'users/search', {
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
     * @see {@link module:Connectors~Author}
     * @see {@link module:Connectors~Tweet}
     * @see {@link module:Connectors~Sentiment}
     * @see {@link module:Connectors~Topic}
     * @memberof TwitterCrawler
     * @return {void}
     */
    track(filters) {
        logger.log('info', 'Start streaming Twitter tweets with filters: ' + filters);
        this.client.stream(
            'statuses/filter', {
                track: filters,
                tweet_mode: 'extended'
            },
            stream => {
                stream.on('data', event => {
                    if (event.lang == 'en') {
                        var messagePrep = preprocessTweetMessage(
                            event.text
                        );
                        //Insert in the normal tables
                        //If an author already exists it is updated
                        Author.upsert({
                            id: event.user.id,
                            username: event.user.name,
                            screenname: event.user.screen_name,
                            followercount: event.user.followers_count
                        }).then(created => { // created is an boolean indicating whether the instance was created (1) or updated (0)
                            Author.findOne({
                                where: {
                                    id: event.user.id
                                }
                            }).then(author => {
                                detectSentiment('./ML/Java/sentiment/naivebayes.bin',
                                    messagePrep,
                                    result => {
                                        author.createTW_CORE({
                                            id: event.id,
                                            keywordType: 'Placeholder',
                                            keyword: getKeyword(
                                                event.text,
                                                filters
                                            ),
                                            created: event.created_at,
                                            createdWeek: moment(
                                                event.created_at
                                            ).week(),
                                            toUser: event.in_reply_to_user_id,
                                            language: event.lang,
                                            source: stripHTMLTags(
                                                event.source
                                            ),
                                            message: event.text,
                                            messagePrep: messagePrep,
                                            latitude: event.coordinates ? event.coordinates[0] : null,
                                            longitude: event.coordinates ? event.coordinates[1] : null,
                                            retweetCount: event.retweet_count,
                                            favorited: event.favorited,
                                            favoriteCount: event.favorite_count,
                                            isRetweet: event.retweeted_status ?
                                                true : false,
                                            retweeted: event.retweeted,
                                            TW_SENTIMENT: {
                                                sentiment: result,
                                                sarcastic: detectSarcasm(event.text),
                                                r_ensemble: '',
                                                python_ensemble: '',
                                            }
                                        }, {
                                                include: [{
                                                    association: Tweet.Sentiment
                                                }]
                                            })
                                    })
                            })
                        }).catch(error => {
                            console.log(error);
                            logger.log('error', error);
                            if (error.code == 'ER_DUP_ENTRY') { // user exists

                            }
                        });
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