import { Author } from './connectors';
import { Tweet } from './connectors';

const resolvers = {
    Query: {
        author(_, args) {
            return Author.find({ where: args });
        },
        tweet(_, args) {
            return Tweet.find({ where: args });
        },
        tweets(_, args) {
            return Tweet.findAll({
                limit: args.limit,
                offset: args.offset
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
    },
};

export default resolvers;