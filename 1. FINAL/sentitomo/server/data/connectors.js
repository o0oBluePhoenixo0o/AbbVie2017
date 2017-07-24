import Sequelize from 'sequelize';
import casual from 'casual';
import _ from 'lodash';
import logger from './../service/logger.js';
require('dotenv').config();

const db = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
    dialect: 'mysql',
    host: process.env.DB_HOST,
    /*
        logging: false,*/
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


const Author = db.define('TW_User', {
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


//TODO: Either constantly also feed the Dash, or use a varibale 'inDash' for Bulk insert
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

var Sentiment = db.define('TW_SENTIMENT', {
    id: {
        type: Sequelize.STRING,
        primaryKey: true
    },
    sentiment: {
        type: Sequelize.STRING
    },
    sarcastic: {
        type: Sequelize.BOOLEAN
    },
    r_ensemble: {
        type: Sequelize.STRING
    },
    python_ensemble: {
        type: Sequelize.STRING
    }
})

var Topic = db.define('TW_TOPIC', {
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

Author.hasMany(Tweet);
Tweet.belongsTo(Author);

Tweet.Sentiment = Tweet.hasOne(Sentiment, {
    foreignKey: 'id',
    onDelete: 'cascade'
});

Tweet.Topic = Tweet.hasOne(Topic, {
    foreignKey: 'id',
    onDelete: 'cascade'
});



//Create tables if not exist
Author.sync()
Tweet.sync()
Dashboard.sync();
Sentiment.sync();
Topic.sync({
    force: true
});

Sentiment = Tweet.Sentiment;
Topic = Tweet.Topic;

export {
    Author,
    Tweet,
    Sentiment,
    Topic,
    Dashboard,
};