import {
    Author
} from './connectors';
import {
    Tweet
} from './connectors';
import {
    Sentiment
} from './connectors';
import {
    Topic
} from './connectors';

const resolvers = {
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
                offset: args.offset
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