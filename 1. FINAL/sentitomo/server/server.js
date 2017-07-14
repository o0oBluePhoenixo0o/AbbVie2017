require('dotenv').config()
require("./service/scheduling.js");

import express from "express";
import Schema from './data/schema';
import Resolvers from './data/resolvers';
import Connectors from './data/connectors';

import { graphqlExpress, graphiqlExpress } from 'graphql-server-express';
import { makeExecutableSchema, addMockFunctionsToSchema } from 'graphql-tools';
import bodyParser from 'body-parser';
import cors from 'cors';

const path = require('path');
var http = require('http');
var logger = require('morgan')
var fs = require('fs')
var cookieParser = require('cookie-parser');
var TwitterCrawler = require('./service/TwitterCrawler.js');



function loggingMiddleware(req, res, next) {
  console.log('ip:', req.ip);
  next();
}


const GRAPHQL_PORT = 8080;

const graphQLServer = express();

graphQLServer.use(loggingMiddleware);
graphQLServer.use('*', cors({ origin: 'http://localhost:3006' }));
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

graphQLServer.listen(GRAPHQL_PORT, () => console.log(
  `GraphQL Server is now running on http://localhost:${GRAPHQL_PORT}/graphql`
));

var twitterCrawler = new TwitterCrawler({
  consumer_key: process.env.TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
});




//module.exports = app;

