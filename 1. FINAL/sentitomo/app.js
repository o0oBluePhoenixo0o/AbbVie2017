require('dotenv').config()
const express = require('express');
const path = require('path');
var http = require('http');
var logger = require('morgan')
var fs = require('fs')
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');



var index = require('./server/routes/index');
var TwitterCrawler = require('./server/service/TwitterCrawler.js');

const app = express();
// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));

// setup the logger
var accessLogStream = fs.createWriteStream(path.join(__dirname, 'access.log'), { flags: 'a' })
app.use(logger('dev', { stream: accessLogStream }));

// setup other
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());

// Serve static files from the React app if we want to use it
//app.use(express.static(path.join(__dirname, 'client/build/static')));

// setup routes
app.use('/', index);

var twitterCrawler = new TwitterCrawler({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
});


module.exports = app;

