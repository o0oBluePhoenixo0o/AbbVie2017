import express from "express";
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
import { listenToSockets } from './service/sockets';


import { Author, Tweet, Sentiment } from './data/connectors';
import { preprocessTweetMessage } from "./ML/preprocess.js";
import { detectSentiment, detectSarcasm, detectTopicStatic, detectTopicDynamic } from "./ML/ml_wrapper.js";
import { getKeyword, stripHTMLTags } from './service/utils';
import moment from 'moment';

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





var stream = fs.createReadStream("../1407.csv");
var datas = new Array();
csv
    .fromStream(stream, { headers: true, objectMode: true })
    .on("data", data => {
        datas.push(data);
    })
    .on("end", () => {
        var interval = 10 * 400; // 1 seconds;
        for (var i = 0; i <= datas.length - 1; i++) {
            if (datas[i]['Language'] == "eng") {
                setTimeout(
                    i => {
                        var messagePrep = preprocessTweetMessage(datas[i].message);
                        console.log(datas[i]['isRetweet'])
                        twitterCrawler.client.get(
                            "users/search", {
                                q: datas[i]['From.User']
                            },
                            (error, tweets, response) => {
                                if (!error && tweets[0]) {
                                    Author.upsert({
                                        id: tweets[0].id,
                                        username: tweets[0].name,
                                        screenname: tweets[0].screen_name,
                                        followercount: tweets[0].followers_count
                                    }).then(created => {
                                        Author.findOne({
                                            where: {
                                                id: tweets[0].id
                                            }
                                        }).then(author => {
                                            detectSentiment("./ML/Java/naivebayes.bin", messagePrep, result => {
                                                Tweet.upsert({
                                                    id: datas[i]['Id'],
                                                    keywordType: "Placeholder",
                                                    keyword: datas[i]['key'],
                                                    created: moment(datas[i]['created_time']).toDate(),
                                                    createdWeek: moment(
                                                        datas[i]['created_at']
                                                    ).week(),
                                                    toUser: datas[i]['To.User'] == "NA" ? null : datas[i]['To.User'],
                                                    language: datas[i]['Language'],
                                                    source: stripHTMLTags(
                                                        datas[i]['Source']
                                                    ),
                                                    message: datas[i]['message'],
                                                    messagePrep: null,
                                                    latitude: datas[i]['Geo.Location.Latitude'] == "NA" ? null : datas[i]['Geo.Location.Latitude'] == "NA",
                                                    longitude: datas[i]['Geo.Location.Longitude'] == "NA" ? null : datas[i]['Geo.Location.Longitude'] == "NA",
                                                    retweetCount: datas[i]['Retweet.Count'],
                                                    favorited: datas[i]['favorited'] == "TRUE",
                                                    favoriteCount: datas[i]['favoriteCount'],
                                                    isRetweet: datas[i]['isRetweet'] == "TRUE",
                                                    retweeted: datas[i]['retweeted'],
                                                    TWUserId: tweets[0].id,
                                                }).then((created) => {
                                                    Sentiment.upsert({
                                                        id: datas[i]['Id'],
                                                        sentiment: result,
                                                        sarcastic: detectSarcasm(messagePrep),
                                                        emo_senti: null,
                                                        emo_desc: null,
                                                        r_ensemble: null,
                                                        python_ensemble: null,
                                                    })
                                                });
                                            });
                                        })
                                    })
                                }
                            });
                    },
                    interval * i,
                    i
                );
            }

        }
    });