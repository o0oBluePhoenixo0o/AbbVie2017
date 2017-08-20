/** @module Connectors  
 *  @description Responsible for creating and accessing the MySQL Database
*/
import Sequelize from 'sequelize';
import casual from 'casual';
import _ from 'lodash';
import logger from './../service/logger.js';
require('dotenv').config();


/**
 * @constant db
 * @type {Object}
 * @description Represents the connection to the database
 */
const db = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
    dialect: 'mysql',
    host: process.env.DB_HOST,
    logging: true,
    pool: {
        max: 5,
        min: 1,
        idle: 10000
    },
    define: {
        freezeTableName: true
    }
});

db.authenticate()
    .then(() => {
        logger.log('info', 'Connection to database has been established successfully.');
    })
    .catch(err => {
        logger.error('error', 'Unable to connect to the database: ' + err);
    });


/**
 * @constant TweetAuthor
 * @type {Object}
 * @description Represents the Author table for tweets
 */
const TweetAuthor = db.define('TW_User', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    username: {
        type: Sequelize.STRING
    },
    screenname: {
        type: Sequelize.STRING
    },
    followercount: {
        type: Sequelize.INTEGER
    }
});

/**
 * @constant Tweet
 * @type {Object}
 * @description Represents the TW_Tweet table. It holds an foreign key on TW_User, TW_Sentiment and TW_Topic
 */
const Tweet = db.define('TW_Tweet', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true,
    },
    keywordType: {
        type: Sequelize.STRING
    },
    keyword: {
        type: Sequelize.STRING
    },
    created: {
        type: Sequelize.DATE
    },
    createdWeek: {
        type: Sequelize.INTEGER
    },
    toUser: {
        type: Sequelize.STRING
    },
    language: {
        type: Sequelize.STRING
    },
    source: {
        type: Sequelize.STRING
    },
    message: {
        type: Sequelize.STRING
    },
    hashtags: {
        type: Sequelize.STRING
    },
    latitude: {
        type: Sequelize.STRING
    },
    longitude: {
        type: Sequelize.STRING
    },
    retweetCount: {
        type: Sequelize.INTEGER
    },
    favorited: {
        type: Sequelize.BOOLEAN
    },
    favoriteCount: {
        type: Sequelize.INTEGER
    },
    isRetweet: {
        type: Sequelize.BOOLEAN
    },
    retweeted: {
        type: Sequelize.INTEGER
    }
});

/**
 * @constant Dashboard
 * @type {Object}
 * @description Represents the dashboard table
 */
const Dashboard = db.define('TW_DASH', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    keywordType: {
        type: Sequelize.STRING
    },
    keyword: {
        type: Sequelize.STRING
    },
    message: {
        type: Sequelize.STRING
    },
    created: {
        type: Sequelize.DATE
    },
    createdTime: {
        type: Sequelize.TIME
    },
    createdDate: {
        type: Sequelize.DATE
    },
    createdWeek: {
        type: Sequelize.INTEGER
    },
    screenName: {
        type: Sequelize.STRING
    },
    tweetType: {
        type: Sequelize.STRING
    },
    sentiment: {
        type: Sequelize.STRING
    },
    sarcasm: {
        type: Sequelize.BOOLEAN
    },
    topicWhole: {
        type: Sequelize.STRING
    },
    topicWhole_C: {
        type: Sequelize.STRING
    },
    topic3Month: {
        type: Sequelize.STRING
    },
    topic3Month_C: {
        type: Sequelize.STRING
    },
});

/**
 * @const TweetSentiment
 * @type {Object}
 * @description Represents the TW_Sentiment table, is referenced from TW_Tweet
 */
const TweetSentiment = db.define('TW_Sentiment', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    sentiment: {
        type: Sequelize.STRING
    },
    sarcastic: {
        type: Sequelize.DOUBLE
    },
    emojiSentiment: {
        type: Sequelize.INTEGER
    },
    emojiDesc: {
        type: Sequelize.STRING
    },
    rEnsemble: {
        type: Sequelize.STRING
    },
    pythonEnsemble: {
        type: Sequelize.STRING
    }
})

/**
 * @const TweetTopic
 * @type {Object}
 * @description Represents the TW_Topic table, is referenced from the TW_Tweet table
 */
const TweetTopic = db.define('TW_Topic', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    topicId: {
        type: Sequelize.INTEGER
    },
    topicContent: {
        type: Sequelize.STRING
    },
    probability: {
        type: Sequelize.DOUBLE
    }
})

TweetAuthor.hasMany(Tweet);
Tweet.belongsTo(TweetAuthor);

Tweet.Sentiment = Tweet.hasOne(TweetSentiment, {
    foreignKey: 'id',
    onDelete: 'cascade'
});

Tweet.Topic = Tweet.hasOne(TweetTopic, {
    foreignKey: 'id',
    onDelete: 'cascade'
});

/**
 * @const FacebookPage
 * @type {Object}
 * @description Represents the FB_Profile table
 */
const FacebookProfile = db.define('FB_Profile', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    keyword: {
        type: Sequelize.STRING
    },
    name: {
        type: Sequelize.STRING
    },
    category: {
        type: Sequelize.STRING
    },
    likes: {
        type: Sequelize.INTEGER
    },
    type: {
        type: Sequelize.STRING
    }
});

/**
 * @const FacebookPost
 * @type {Object}
 * @description Represents the FB_Post table, has foreign keys on FB_Profile, FB_Sentiment and FB_Topic
 */
const FacebookPost = db.define('FB_Post', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    message: {
        type: Sequelize.STRING
    },
    lang: {
        type: Sequelize.STRING
    },
    story: {
        type: Sequelize.STRING
    },
    likes: {
        type: Sequelize.INTEGER
    },
    link: {
        type: Sequelize.STRING
    },
    created: {
        type: Sequelize.DATE,
    }
});

/**
 * @const FacebookComment
 * @type {Object}
 * @description Represents the table FB_Comment table
 */
const FacebookComment = db.define('FB_Comment', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    message: {
        type: Sequelize.TEXT
    },
    lang: {
        type: Sequelize.TEXT
    }
});

/**
 * @const FacebookSentiment
 * @type {Object}
 * @description Represents the FB_Sentiment table, is referenced from the FB_Post table
 */
const FacebookSentiment = db.define('FB_Sentiment', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    sentiment: {
        type: Sequelize.STRING
    },
    sarcastic: {
        type: Sequelize.DOUBLE
    },
    emojiSentiment: {
        type: Sequelize.INTEGER
    },
    emojiDesc: {
        type: Sequelize.STRING
    },
    rEnsemble: {
        type: Sequelize.STRING
    },
    pythonEnsemble: {
        type: Sequelize.STRING
    }
});

/**
 * @const FacebookTopic
 * @type {Object}
 * @description Represents the FB_Topic table, is referenced from the FB_Post table
 */
const FacebookTopic = db.define('FB_Topic', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    topicId: {
        type: Sequelize.INTEGER
    },
    topicContent: {
        type: Sequelize.STRING
    },
    probability: {
        type: Sequelize.DOUBLE
    }
});


FacebookProfile.hasMany(FacebookPost);
FacebookPost.belongsTo(FacebookProfile);

FacebookPost.hasMany(FacebookComment);
FacebookComment.belongsTo(FacebookPost);

FacebookPost.Sentiment = FacebookPost.hasOne(FacebookSentiment, {
    foreignKey: 'id',
    onDelete: 'cascade'
});

FacebookPost.Topic = FacebookPost.hasOne(FacebookTopic, {
    foreignKey: 'id',
    onDelete: 'cascade'
});

//Create tables if not exist
TweetAuthor.sync()
Tweet.sync()
Dashboard.sync();
TweetSentiment.sync();
TweetTopic.sync();

FacebookProfile.sync();
FacebookPost.sync();
FacebookComment.sync();
FacebookSentiment.sync();
FacebookTopic.sync();

export {
    TweetAuthor,
    Tweet,
    TweetSentiment,
    TweetTopic,
    FacebookProfile,
    FacebookPost,
    FacebookComment,
    FacebookSentiment,
    FacebookTopic,
    Dashboard,
};