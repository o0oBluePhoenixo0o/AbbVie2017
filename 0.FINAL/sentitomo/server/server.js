import express from "express";
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
import { listenToSockets } from './service/sockets';

var twitterCrawler = new TwitterCrawler({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
});


require('dotenv').config()
require("./service/scheduling.js");

const GRAPHQL_PORT = 8080;
const server = express();
const executableSchema = makeExecutableSchema({
  typeDefs: Schema,
  resolvers: Resolvers,
  connectors: Connectors,
});

logger.log('info', "Start up server");

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

twitterCrawler.start();