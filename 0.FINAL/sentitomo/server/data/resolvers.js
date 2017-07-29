import {
    Author,
    Tweet,
    Sentiment,
    Topic
} from './connectors';
import moment from 'moment';
import GraphQLMoment from './scalar/GraphQLMoment';


/**
 * @constant resolvers
 * @type {Object}
 * @description Resolver object for handling GraphQL request and responding with correct data from the database
 */
const resolvers = {
    Date: GraphQLMoment,
    Query: {
        author(_, args) {
            return Author.find({
                where: args
            });
        },
        tweet(_, args) {
            return Tweet.find({
                where: args
            });
        },
        tweets(_, args) {
            var where;
            if (args.startDate && args.endDate) {
                where = {
                    created: {
                        $lt: args.endDate, // less than
                        $gt: args.startDate //greater than
                    }
                };
            }
            return Tweet.findAll({
                limit: args.limit,
                offset: args.offset,
                where: where,
            });

        },
        sentiment(_, args) {
            return Sentiment.find({
                where: args
            });
        },
        topic(_, args) {
            return Topic.find({
                where: args
            });
        },
        count(_, args) {
            var where;
            if (args.startDate && args.endDate) {
                where = {
                    created: {
                        $lt: args.endDate, // less than
                        $gt: args.startDate //greater than
                    }
                };
            }
            return Tweet.count({
                where: where
            });
        }
    },
    Author: {
        tweets(author) {
            return author.getTweets();
        },
    },
    Tweet: {
        author(tweet) {
            return tweet.getTW_User();
        },
        sentiment(tweet) {
            return tweet.getTW_SENTIMENT();
        },
        topic(tweet) {
            return tweet.getTW_TOPIC();
        }
    },
};

export default resolvers;