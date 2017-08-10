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
import { listenToSockets } from './service/sockets';


import moment from 'moment';

var twitterCrawler = new TwitterCrawler({
    consumer_key: process.env.TWITTER_CONSUMER_KEY,
    consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
    access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
    access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
});

var facebookCrawler = new FacebookCrawler({});

require('dotenv').config()
require('./service/scheduling.js');

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

server.get('*', (req, res) => {
    res.sendFile(path.join(__dirname + '/../client/build/index.html'));
});


// Set up socket.io
var http = createServer(server);
listenToSockets(http);


http.listen(GRAPHQL_PORT, () => logger.log('info',
    `GraphQL Server is now running on http://localhost:${GRAPHQL_PORT}/graphql`
));

global.appRoot = __dirname;


/*
detectSentiment("./ML/Java/sentiment/naivebayes.bin", "I love you very much", result => {
    console.log("Java Sentiment: " + result);
})

detectSentimentEnsembleR("I love you very much", result => {
    console.log("R Sentiment: " + result);
})

detectSarcasm("I love you very much", result => {
    console.log("Sarcasm Detection " + result);
})

detectSentimentEnsemblePython("I love you very much", result => {
    console.log("Pyhton Sentiment: " + result);
})*/





/*detectTopicLDAStatic(JSON.stringify({ id: "123123123", message: "Abbvie is such a great company with a huge sortiment of drugs!" }), result => {
    console.log(result);
})

detectTopicLDADynamic(moment("2017-03-01"), moment("2017-03-31"), result => {
    console.log(result);
});


detectTopicLDADynamic(moment("2017-03-01"), moment("2017-03-31"), result => {
    console.log(result);
});


*/
//console.log("[1] 53.42".replace(/\s*\[(.+?)\]\s*/g, ""));
//twitterCrawler.start();

//console.log(detectSentimentPhilipp("I really really love you that much!"))


//facebookCrawler.searchAndSaveFBPages("humira");
//facebookCrawler.searchAndSaveFBPages("enbrel");