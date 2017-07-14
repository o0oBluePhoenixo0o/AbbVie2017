import Sequelize from 'sequelize';
import casual from 'casual';
import _ from 'lodash';
require('dotenv').config();

const db = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
    dialect: 'mysql',
    host: process.env.DB_HOST,
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
        console.log('Connection has been established successfully.');
    })
    .catch(err => {
        console.error('Unable to connect to the database:', err);
    });

const AuthorModel = db.define('TW_User', {
    id: { type: Sequelize.STRING, primaryKey: true },
    username: { type: Sequelize.STRING },
    screenname: { type: Sequelize.STRING },
    followerCount: { type: Sequelize.INTEGER }
});


//TODO: Either constantly also feed the Dash, or use a varibale 'inDash' for Bulk insert
const TweetModel = db.define('TW_CORE', {
    id: { type: Sequelize.STRING, primaryKey: true },
    keywordType: { type: Sequelize.STRING },
    keyword: { type: Sequelize.STRING },
    created: { type: Sequelize.DATE },
    createdWeek: { type: Sequelize.INTEGER },
    toUser: { type: Sequelize.STRING },
    language: { type: Sequelize.STRING },
    source: { type: Sequelize.STRING },
    message: { type: Sequelize.STRING },
    messagePrep: { type: Sequelize.STRING },
    latitude: { type: Sequelize.STRING },
    longitude: { type: Sequelize.STRING },
    retweetCount: { type: Sequelize.INTEGER },
    favorited: { type: Sequelize.BOOLEAN },
    favoriteCount: { type: Sequelize.INTEGER },
    isRetweet: { type: Sequelize.BOOLEAN },
    retweeted: { type: Sequelize.INTEGER }
});


const DashboardModel = db.define('TW_DASH', {
    id: { type: Sequelize.STRING, primaryKey: true },
    keywordType: { type: Sequelize.STRING },
    keyword: { type: Sequelize.STRING },
    message: { type: Sequelize.STRING },
    created: { type: Sequelize.DATE },
    createdTime: { type: Sequelize.TIME },
    createdDate: { type: Sequelize.INTEGER }, // date only without time
    createdWeek: { type: Sequelize.INTEGER },
    screenName: { type: Sequelize.STRING },
    tweetType: { type: Sequelize.STRING },
    sentiment: { type: Sequelize.STRING },
    sarcasm: { type: Sequelize.BOOLEAN },
    topicWhole: { type: Sequelize.STRING },
    topicWhole_C: { type: Sequelize.STRING },
    topic3Month: { type: Sequelize.STRING },
    topic3Month_C: { type: Sequelize.STRING },
});

AuthorModel.hasMany(TweetModel);
TweetModel.belongsTo(AuthorModel);


const Author = db.models.TW_User;
const Tweet = db.models.TW_CORE;
const Dashboard = db.models.TW_DASH;

//Create tables
Author.sync()
Tweet.sync()
Dashboard.sync();

export { Author, Tweet, Dashboard };