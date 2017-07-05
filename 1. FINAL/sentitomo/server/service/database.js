var mysql = require('mysql');
var moment = require('moment');

module.exports = class DatabaseConnection {

    //DATES ARE STORED YYYY-MM-DD
    constructor(db_config) {

        this.handleDisconnect(db_config);
        //Set up tables if not existent
        this.createTableTweets();
        this.createTableTwitterUser();
        this.createTableTwitterFinal();
        this.createTableFacebookPosts();
        this.createTableFacebookComments();
        this.createTableFacebookUsers();
        this.createTableFacebookFinal();

    }


    /**
    * @function handleDisconnect
    * @param  {type} db_config Configuration object for the database
    * @return {type} Connects to the database and handles disconnects
    */
    handleDisconnect(db_config) {
        this.connection = mysql.createConnection(db_config); // Recreate the connection, since the old one cannot be reused.

        this.connection.connect((err) => {                  // The server is either down
            if (err) {                                      // or restarting (takes a while sometimes).
                console.log('error when connecting to db:', err);
                setTimeout(handleDisconnect, 2000);         // We introduce a delay before attempting to reconnect,
            } else {
                console.log("Connected to " + db_config.host)
            }                                               // to avoid a hot loop, and to allow our node script to
        });                                                 // process asynchronous requests in the meantime.

        // If you're also serving http, display a 503 error.
        this.connection.on('error', (err) => {
            console.log('db error', err);
            if (err.code === 'PROTOCOL_CONNECTION_LOST') {  // Connection to the MySQL server is usually
                console.log("Server timed out")
                this.handleDisconnect(db_config);           // lost due to either server restart, or a
            } else {                                        // connnection idle timeout (the wait_timeout
                throw err;                                  // server variable configures this)
            }
        });
    }

    /**
    * @function createTableTweets
    * @description Creates the TW_Raw table if it not exists
    */
    createTableTweets() {
        this.connection.query('CREATE TABLE IF NOT EXISTS TW_Raw ( id bigint, keyword varchar(255), created datetime, fromUser bigint, toUser bigint, tweetLanguage varchar(255), tweetSource varchar(255), message varchar(255), messagePrep varchar(255), latitude varchar(255), longitude varchar(255), retweetCount int, favorited boolean, favoriteCount int, isRetweet boolean, retweeted boolean, dateretrieved datetime, PRIMARY KEY (id) ); ', function (error, results, fields) {
            if (error) {
                throw error;
            }
            console.log("Table TW_Raw successfully connected/created");
        });
    }

    /**
    * @function createTableTweets
    * @description Creates the TW_User table if it not exists
    */
    createTableTwitterUser() {
        this.connection.query('CREATE TABLE IF NOT EXISTS TW_User ( id bigint, name varchar(255), dateretrieved datetime, PRIMARY KEY (id) ); ', function (error, results, fields) {
            if (error) {
                throw error;
            }
            console.log("Table TW_User successfully connected/created");
        });
    }

    /**
    * @function createTableTweets
    * @description Creates the TW_Final table if it not exists
    */
    createTableTwitterFinal() {
        this.connection.query('CREATE TABLE IF NOT EXISTS TW_Final ( id bigint, sentiment varchar(255), topics text, dateprocessed datetime, PRIMARY KEY (id) ); ', function (error, results, fields) {
            if (error) {
                throw error;
            }
            console.log("Table TW_Final successfully connected/created");
        });
    }

    /**
    * @function createTableTweets
    * @description Creates the FB_Raw table if it not exists
    */
    createTableFacebookPosts() {
        this.connection.query('CREATE TABLE IF NOT EXISTS FB_Raw (id bigint, keyword varchar(255), language varchar(255), fromUser bigint, message text, messagePrep text, created datetime, link varchar(255), story text, commentsCount int, likesCount int, sharesCount int, lovesCount int, hahaCount int, wowCount int, sadCount int, angryCount int, dateretrieved datetime, PRIMARY KEY (id) ); ', function (error, results, fields) {
            if (error) {
                throw error;
            }
            console.log("Table FB_Raw successfully connected/created");
        });
    }

    /**
    * @function createTableTweets
    * @description Creates the FB_Comments table if it not exists
    */
    createTableFacebookComments() {
        this.connection.query('CREATE TABLE IF NOT EXISTS FB_Comments (id bigint, postId bigint, fromUser bigint, message text, messagePrep text, created datetime, commentsCount int, likesCount int, dateretrieved datetime, PRIMARY KEY (id) ); ', function (error, results, fields) {
            if (error) {
                throw error;
            }
            console.log("Table FB_Comments successfully connected/created");
        });
    }

    /**
    * @function createTableTweets
    * @description Creates the FB_Users table if it not exists
    */
    createTableFacebookUsers() {
        this.connection.query('CREATE TABLE IF NOT EXISTS FB_Users (id bigint, name varchar(255), dateretrieved datetime, PRIMARY KEY (id) ); ', function (error, results, fields) {
            if (error) {
                throw error;
            }
            console.log("Table FB_Users successfully connected/created");
        });
    }

    /**
    * @function createTableTweets
    * @description Creates the FB_Final table if it not exists
    */
    createTableFacebookFinal() {
        this.connection.query('CREATE TABLE IF NOT EXISTS FB_Final( id bigint, sentiment varchar(255), topics text, dateprocessed datetime, PRIMARY KEY (id) ); ', function (error, results, fields) {
            if (error) {
                throw error;
            }
            console.log("Table FB_Final successfully connected/created");
        });
    }

    /**
     * Inserts an tweet object in the tweets table on the mysql server
     * @param {*Object} tweet 
     */
    insertTweet(tweet) {
        this.connection.query('INSERT INTO TW_Raw VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW());', [tweet.id, tweet.key, moment(tweet.created).toDate(), tweet.from, tweet.to, tweet.language, tweet.source, tweet.message, tweet.messagePrep, tweet.latitude, tweet.longitude, tweet.retweet_count, tweet.favorited, tweet.favorite_count, tweet.is_retweet, tweet.retweeted], function (error, results, fields) {
            if (error) {
                console.log(error)
                console.log("Tweet with id " + tweet.id + " already in DB");
            } else {
                console.log("Tweet with id: " + tweet.id + " was successfully inserted");
            }

        });
    }

    /**
     * Inserts an classified tweet object in the tweets table on the mysql server
     * @param {*Object} finalTweet 
     */
    insertTweetFinal(finalTweet) {
        this.connection.query('INSERT INTO TW_Final VALUES (?, ?, ?, NOW());', [finalTweet.id, finalTweet.sentiment, finalTweet.topics], function (error, results, fields) {
            if (error) {
                console.log("Tweet with id " + finalTweet.id + " already in DB");
            } else {
                console.log("Tweet with id: " + finalTweet.id + " was successfully inserted");
            }

        });
    }

    /**
     * Inserts an classified tweet object in the tweets table on the mysql server
     * @param {*Object} finalTweet 
     */
    insertTweetFinalTest(finalTweet) {
        this.connection.query('INSERT INTO TW_Senti_Test VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);', [finalTweet.id, finalTweet.key, moment(finalTweet.created).toDate(), finalTweet.from, finalTweet.to, finalTweet.message, finalTweet.favorite_count, finalTweet.is_retweet, finalTweet.retweet_count, finalTweet.sentiment], function (error, results, fields) {
            if (error) {
                console.log(error)
                console.log("Test Senti Tweet with id " + finalTweet.id + " already in DB");
            } else {
                console.log("Test Senti Tweet with id: " + finalTweet.id + " was successfully inserted");
            }

        });
    }
    /**
    * Inserts an twitter user object in the tweets table on the mysql server
    * @param {*Object} user 
    */
    insertTwitterUser(user) {
        this.connection.query('INSERT INTO TW_User VALUES (?, ?,NOW());', [user.id, user.name], function (error, results, fields) {
            if (error) {
                console.log("User with id " + user.id + " already in DB");
            } else {
                console.log("User with id: " + user.id + " was successfully inserted");
            }

        });
    }

    /**
    * Inserts an facebook posts object in the fb_raw table on the mysql server
    * @param {*Object} post 
    */
    insertFacebookPost(post) {
        this.connection.query('INSERT INTO FB_Raw VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW());', [post.id, post.keyword, post.language, post.fromUser, post.message, post.messagePrep, post.created, post.link, post.story, post.commentsCount, post.likesCount, post.sharesCount, post.lovesCount, post.hahaCount, post.wowCount, post.sadCount, post.angryCount], function (error, results, fields) {
            if (error) {
                console.log("FB_Post with id " + post.id + " already in DB");
            } else {
                console.log("FB_Post with id: " + post.id + " was successfully inserted");
            }

        });
    }

    /**
   * Inserts an classified facebook post object in the tweets table on the mysql server
   * @param {*Object} finalPost 
   */
    insertFinalFacebookPost(finalPost) {
        this.connection.query('INSERT INTO FB_Final VALUES (?, ?, ?, NOW());', [finalPost.id, finalPost.sentiment, finalPost.topics], function (error, results, fields) {
            if (error) {
                console.log("FB_Post with id " + finalPost.id + " already in DB");
            } else {
                console.log("FB_Post with id: " + finalPost.id + " was successfully inserted");
            }

        });
    }

    /**
    * Inserts an facebook posts object in the fb_raw table on the mysql server
    * @param {*Object} comment 
    */
    insertFacebookComments(comment) {
        this.connection.query('INSERT INTO FB_Comments VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW());', [comment.id, comment.postId, comment.fromUser, comment.message, comment.messagePrep, comment.created, comment.commentsCount, comment.likesCount], function (error, results, fields) {
            if (error) {
                console.log("FB_Comment with id " + comment.id + " already in DB");
            } else {
                console.log("FB_Comment with id: " + comment.id + " was successfully inserted");
            }

        });
    }

    /**
    * Inserts an facebook user object in the fb_users table on the mysql server
    * @param {*Object} user 
    */
    insertFacebookUser(user) {
        this.connection.query('INSERT INTO FB_Users VALUES (?, ?,NOW());', [user.id, user.name], function (error, results, fields) {
            if (error) {
                console.log("User with id " + user.id + " already in DB");
            } else {
                console.log("User with id: " + user.id + " was successfully inserted");
            }

        });
    }

    /**
     * Disconnect from the mysql server
     */
    disconnect() {
        this.connection.end();
    }

}












