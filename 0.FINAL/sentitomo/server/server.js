import express from 'express';
import fs from 'fs';
import csv from 'fast-csv';
import path from 'path'
import bodyParser from 'body-parser';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import {
    createServer
} from 'http';
import {
    graphqlExpress,
    graphiqlExpress
} from 'graphql-server-express';
import {
    makeExecutableSchema,
    addMockFunctionsToSchema
} from 'graphql-tools';
import logger from './service/logger.js';
import loggingMiddleware from './middlewares/loggerMiddleware';
import Schema from './data/schema';
import Resolvers from './data/resolvers';
import Connectors from './data/connectors';
import TwitterCrawler from './service/TwitterCrawler';
import FacebookCrawler from './service/FacebookCrawler';
import TopicWorker from './service/TopicWorker';
import SentimentWorker from './service/SentimentWorker';
import { listenToSockets } from './service/sockets';

import { detectSentiment, detectSentimentEnsembleR, detectTopicLDADynamic, detectTopicLDAStatic, detectTopicLDAStaticBatch } from './ML/ml_wrapper';
import { Java, JavaShell, PythonShell } from './util/foreignCode';
var nodeCleanup = require('node-cleanup');



import moment from 'moment';

var twitterCrawler = new TwitterCrawler({
    consumer_key: process.env.TWITTER_CONSUMER_KEY,
    consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
    access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
    access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
});

var facebookCrawler = new FacebookCrawler({});
var topicWorker = new TopicWorker();
var sentimentWorker = new SentimentWorker();

require('dotenv').config()

const GRAPHQL_PORT = 8080;
const server = express();
const executableSchema = makeExecutableSchema({
    typeDefs: Schema,
    resolvers: Resolvers,
    connectors: Connectors,
});

logger.log('info', 'Start up server');

// Add middlewares
server.use(loggingMiddleware);

server.use('*', cors({
    origin: 'http://localhost:3000'
}));

server.use('/static', express.static(path.join(__dirname + '/../client/build/static')));
server.use('/static', express.static(path.join(__dirname + '/../client/build/fonts')));


//GraphQL Specific
// `context` must be an object and can't be undefined when using connectors
server.use('/graphql', bodyParser.json(), graphqlExpress({
    schema: executableSchema,
    context: {}, //at least(!) an empty object
}));

server.use('/graphiql', graphiqlExpress({
    endpointURL: '/graphql',
}));

server.get('/ldaresult', (req, res) => {
    res.sendFile(path.join(__dirname + '/../server/ML/Python/topic/dynamic/lda_tw40_0720.html'));
});

server.get('/app/*', (req, res) => {
    res.sendFile(path.join(__dirname + '/../client/build/index.html'));
});


// Set up socket.io
var http = createServer(server);
listenToSockets(http);


http.listen(GRAPHQL_PORT, () => logger.log('info',
    `GraphQL Server is now running on http://localhost:${GRAPHQL_PORT}/graphql`
));

global.appRoot = __dirname;
global.sentimentWorker = sentimentWorker;
global.topicWorker = topicWorker;

/*var h20Process = JavaShell("./ML/Java/h2o_3.10.5.3.jar");
console.log(h20Process);
h20Process.call();
logger.log('info', "Wait 2 minutes to let the h2o server start up")
setTimeout(() => {
    twitterCrawler.start()
    sentimentWorker.start()
t   opicWorker.start();
    //h20Process.kill()
}, 60000) // wait 1 minute for new tweets to come ine

*/


detectSentimentEnsembleR("https://t.co/Lo5kpa0Je6 *Need a Lyft coupon code? Here's one for $50 &lt;&lt; Here's the coupon code: RESERVE &gt;&gt; AbbVie").then(result => {
    console.log(result);
})


// Gracefully kill the h2o server process
nodeCleanup(function (exitCode, signal) {
    h20Process.kill();
    console.log(exitCode);
    console.log(signal);
    console.log("End node");
});

