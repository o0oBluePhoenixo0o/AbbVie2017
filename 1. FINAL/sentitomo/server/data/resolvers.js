import {
    Author,
    Tweet,
    Sentiment,
    Topic
} from './connectors';
import moment from 'moment';
import GraphQLMoment from './GraphQLMoment';

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
            return Tweet.findAll({
                limit: args.limit,
                offset: args.offset,
                where: {
                    created: {
                        $lt: args.endDate, // less than
                        $gt: args.startDate //greater than
                    }
                }
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