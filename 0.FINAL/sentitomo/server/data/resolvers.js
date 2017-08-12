import {
    TweetAuthor,
    Tweet,
    TweetSentiment,
    TweetTopic,
    FacebookProfile,
    FacebookPost,
    FacebookComment
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
        tweetAuthor(_, args) {
            return TweetAuthor.find({
                where: args
            });
        },
        tweetSentiment(_, args) {
            return TweetSentiment.find({
                where: args
            });
        },
        tweetTopic(_, args) {
            return TweetTopic.find({
                where: args
            });
        },
        tweetCount(_, args) {
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
        },
        facebookPost(_, args) {
            return FacebookPost.find({
                where: args
            });
        },
        facebookPosts(_, args) {
            var where;
            if (args.startDate && args.endDate) {
                where = {
                    created: {
                        $lt: args.endDate, // less than
                        $gt: args.startDate //greater than
                    }
                };
            }
            return FacebookPost.findAll({
                limit: args.limit,
                offset: args.offset,
                where: where,
            });
        },
        facebookProfile(_, args) {
            return FacebookProfile.find({
                where: args
            });
        }
    },
    Tweet: {
        author(tweet) {
            return tweet.getTW_User();
        },
        sentiment(tweet) {
            return tweet.getTW_Sentiment();
        },
        topic(tweet) {
            return tweet.getTW_Topic();
        }
    },
    TweetAuthor: {
        tweets(author) {
            return author.getTweets();
        },
    },
    FacebookPost: {
        author(facebookPost) {
            return facebookPost.getFB_Profile();
        },
        comments(facebookPost) {
            return facebookPost.getFB_Comments();
        }
    },
    FacebookProfile: {
        posts(facebookProfile) {
            console.log(facebookProfile)
            return facebookProfile.getFB_Posts();
        }
    }

};

export default resolvers;