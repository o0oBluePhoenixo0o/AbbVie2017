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
    /*logging: false,*/
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
 * @description Represents the raw tweets table. It holds an forein key on the author table, sentiment table and topic table
 */
const Tweet = db.define('TW_CORE', {
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
    messagePrep: {
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
 * @description Represents the sentiment table, is referenced from the raw tweets table
 */
const TweetSentiment = db.define('TW_SENTIMENT', {
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
    emo_senti: {
        type: Sequelize.INTEGER
    },
    emo_desc: {
        type: Sequelize.STRING
    },
    r_ensemble: {
        type: Sequelize.STRING
    },
    python_ensemble: {
        type: Sequelize.STRING
    }
})

/**
 * @const TweetTopic
 * @type {Object}
 * @description Represents the topic table, is referenced from the raw tweets table
 */
const TweetTopic = db.define('TW_TOPIC', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    topic1Month: {
        type: Sequelize.STRING
    },
    topic1Month_C: {
        type: Sequelize.STRING
    },
    topic3Month: {
        type: Sequelize.STRING
    },
    topic3Month_C: {
        type: Sequelize.STRING
    },
    topicWhole: {
        type: Sequelize.STRING
    },
    topicWhole_C: {
        type: Sequelize.STRING
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
 * @description Represents the table for Facebook pages
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
 * @description Represents the table for Facebook posts
 */
const FacebookPost = db.define('FB_Post', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    message: {
        type: Sequelize.STRING
    },
    story: {
        type: Sequelize.STRING
    },
    likes: {
        type: Sequelize.INTEGER
    },
    created: {
        type: Sequelize.DATE,
    }
});

/**
 * @const FacebookComment
 * @type {Object}
 * @description Represents the table for Facebook comments
 */
const FacebookComment = db.define('FB_Comment', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
});

FacebookProfile.hasMany(FacebookPost);
FacebookPost.belongsTo(FacebookProfile);

FacebookPost.hasMany(FacebookComment);
FacebookComment.belongsTo(FacebookPost);


//Create tables if not exist
TweetAuthor.sync()
Tweet.sync()
Dashboard.sync();
TweetSentiment.sync();
TweetTopic.sync();


FacebookProfile.sync();
FacebookPost.sync();
FacebookComment.sync();


export {
    TweetAuthor,
    Tweet,
    TweetSentiment,
    TweetTopic,
    FacebookProfile,
    FacebookPost,
    FacebookComment,
    Dashboard,
};