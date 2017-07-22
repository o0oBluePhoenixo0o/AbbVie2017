require('dotenv').config()
require("./service/scheduling.js");
import logger from './service/logger.js';
import express from "express";
import Schema from './data/schema';
import Resolvers from './data/resolvers';
import Connectors from './data/connectors';
import {
  graphqlExpress,
  graphiqlExpress
} from 'graphql-server-express';

import {
  makeExecutableSchema,
  addMockFunctionsToSchema
} from 'graphql-tools';
import bodyParser from 'body-parser';
import cors from 'cors';

import cookieParser from 'cookie-parser';
var TwitterCrawler = require('./service/TwitterCrawler.js');

/**
 * @function loggingMiddleware
 * @param  {Object} req  Request object
 * @param  {Object} res  Response object
 * @param  {function} next Function so that the request will be passed on to the next function
 * @return {type} {description}
 */
function loggingMiddleware(req, res, next) {
  logger.log('debug', 'GraphQL IP Request', {
    ip: req.ip
  });
  next();
}


const GRAPHQL_PORT = 8080;
const graphQLServer = express();

logger.log('info', "Start up server");

graphQLServer.use(loggingMiddleware);
graphQLServer.use('*', cors({
  origin: 'http://localhost:3006'
}));
const executableSchema = makeExecutableSchema({
  typeDefs: Schema,
  resolvers: Resolvers,
  connectors: Connectors,
});

// `context` must be an object and can't be undefined when using connectors
graphQLServer.use('/graphql', bodyParser.json(), graphqlExpress({
  schema: executableSchema,
  context: {}, //at least(!) an empty object
}));

graphQLServer.use('/graphiql', graphiqlExpress({
  endpointURL: '/graphql',
}));

graphQLServer.listen(GRAPHQL_PORT, () => logger.log('info',
  `GraphQL Server is now running on http://localhost:${GRAPHQL_PORT}/graphql`
));


var twitterCrawler = new TwitterCrawler({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
});