
# Sentitomo


[TOC]



As part of our Master Team Project named "Topic Monitoring in the Pharmaceutical Industry" we wanted to develop an application to incorporate our findings and different Machine Learning scripts so that they can be used with ease in an production environment. Our application is named "Sentitomo" as a combination of the words "Sentiment Analysis" and "Topic Monitoring".

## Idea
The idea of accomplish such an application was to create a client-server architecture. The server part will be responsible for crawling social media data from Twitter and Facebook, as well as performing the different machine learning tasks, such as sentiment analysis (classification ), topic detection and trend detection (clustering). Besides this, the results of those tasks will be saved in an database for persistence to be available through an Application Programming Interface (API).

## Problem Statement and Way to go
Throughout our work on this project we tried out different programming languages. So it comes that we have different algorithms implemented in different programming languages. The three most used ones related to machine learning tasks are R, Python and Java. This fact leads to the main problem that we had to find a common platform for the server to work with those languages. We tried out different solutions to choose one of those as the primary one, but in the end we decided to treat them all on the same level of importance and find a 'wrapper' language which can work with all languages in the same way. This ensures that the different languages, and machine learning scripts can easily be switched out or updated without influencing other parts of the application because those will always interact with the wrapper language which copes with the different languages.
Because of the rising popularity and the possibility to be run on server and client side we chose JavaScript as our wrapper language. With the open-source and community driven framework called 'Node.js' it is possible to create powerful server and client applications. Based on this starting point we want to provide you an overview about the main technologies which we used to built up the application and how you the application is structured and can be used in an production environment.


## Fundamental technologies

To give you an idea which technologies were used throughout the development process of Sentitomo this chapter gives an overview about the most prominent ones.

### Node.js

Node.js is an open-source, cross-platform framework written in C, C++ and JavaScript, which makes it possible to run JavaScript code on the server-side. The initial release was on May the 27th, 2009 and was written by Ryan Dahl. Primarily it was built because the most common web server at this time, Apache HTTP Server, has troubles with a lot of concurrent connections and normally used  blocking code executions which led to poor server performance. The idea behind Node utilizes a simplified event-driven programming paradigm where the program flow is determined by so called events (user clicks, messages from other methods etc.) to let so called callback functions take care of the result of method calls therefore main thread of a Node.js application is not blocked by method executions. Basically node is run only on thread, 
This makes it easy build highly scalable applications without the need of threads, which often leads to poor performance.
Hand in hand to Node there is a package manager called npm which stands for Node Packaging Manager. It is used to install, update and remove third party Node.js programs which are listed in the npm registry. npm also enables developers to easily share and distribute Node.js code, so it can be used in other projects.

### Yarn

### Express.js
Express.js is a JavaScript framework built with Node.js and today the de-facto standard to build a web-server application with Node. It is open-source and released under the MIT License. In its fundamental form it is very lightweight and only offers the minimum functionalities to program a web-server. But the capability of adding plugins, like logging, security related ones, templating engines, server side rendering, and even more, makes Express.js very versatile and the number one solution for developing a web server with Node.js.

### GraphQL
### React

## The Application

Due to the fact that Sentitomo is built up with different technologies, there are some requirements that need to be fulfilled when you are trying to set up the application. To clarify the different environment settings and the overall structure an overview is given in the next section.

### Overview

The directory structure of the application can be seen in the following: *(without files except package.json and yarn.lock*):

    .
    ├── client
    │   ├── package.json
    │   ├── build
    │   ├── public
    │   ├── src
    │   │   ├── components
    │   │   ├── data
    │   │   ├── fonts
    │   │   ├── layouts
    │   │   ├── styles
    │   │   └── tests
    │   └── yarn.lock
    └── server
        ├── ML
        │   ├── Java
        │   ├── Python
        │   ├── R  
        ├── data
        ├── middlewares
        ├── package.json
        ├── service
        └── yarn.lock
        
Sentitomo is divided into two parts, client and server.  The main entry point of the application lies in the server directory which then is starting up the server and serving files form the build directory of the client.  Before we have a deeper look into the different directories we first introduce you the installation process of Sentitomo.


### Installation

The main steps to install Sentitomo are:

 1. Install Node.js and npm
 2. Install Yarn packaging manager (optional)
 3. Install dependencies
 4. Install Java Version 6 an 8 
 5. Install Python Version 3 
 6. Install R
 7. Set up environment variables
 8. Start the server

#### Node.js and npm

Node.js always comes in combination with it's packaging manager npm . It can be installed on any common OS, and therefore you can use nearly any server architecture you like. Sentitomo was built on MacOS X Sierra Version 10.12.6 so we suggest using a Unix based server here.  To install Node you can either use the downloads provided by the [Node website](https://nodejs.org/en/download/) or using one of the following aproaches.

__MacOS:__

Using [homebrew](https://brew.sh/):

    $ brew install node

__Linux:__

On Linux there are plenty of different installation possibilities. We suggest to use the ones provided on the [Node website](https://nodejs.org/en/download/package-manager/).

#### Yarn (optional)

After installing Node it comes to the decision to either stay with npm as your desired dependency manager or additionally install Yarn. If you decide to go with yarn this has the advantage that you will get exact the same dependency version as they are tested with Sentitomo. This is ensured with the `yarn.lock files` . This is not mandatory but when you are using npm it can be that you will get a slightly different dependency tree than with npm. Yarn is installed via npm with the following command.

    sudo npm install -g yarn # use sudo to ensure yarn is on your path

#### Install dependencies
Now that the package managers are set up we can use them to install our dependencies. The following commands assume that you are in the top level `sentitomo/` of the application.

**npm:**

    $ cd server
    $ npm install
    # installing dependencies
    
    $ cd ../client
    $ npm install

**Yarn:**

    $ cd server
    $ yarn install
    # installing dependencies
    
    $ cd ../client
    $ yarn install

#### Install Java Version 6 and 8

To install the Java versions just follow the basic instructions of your specified distribution. You just have to ensure that the server has access to both libraries.

#### Install Python
The server needs the newer Python version 3, because some of our scripts are taking advantage of this version. Also for python follow the common ways to install it on your server OS. 

**Dependencies**
Before you can run the Python files you have to install these modules through pip3:

    $ pip3 install sklearn
    ....

#### Install R

**MacOS:**
On MacOS we suggest using the `.pkg`file from the [r-project site](https://cran.r-project.org/bin/macosx/) to install R.

**Linux:**
The same way applies for Linux, please have a look at the [r-project site](https://cran.r-project.org/bin/macosx/) to install R.

#### Set up environment variables

Sentitomo is using some environment variables to connect to different services which are necessary to let the applicaiton do its job. 

**Database**

Our application is using a MySQL database as it's backend. To use your database you have to modify the `.env` file in the root of `sentitomo/server`. This file is used for setting up some configuration settings. Just fill out the following key/value pairs to connect your database.

    DB_NAME=yourDBName
    DB_USER=yourDBUser
    DB_PASS=userPassword
    DB_HOST=hostURL
When the application is connected to the first time it will create the mandatory table structure in your database automatically. 

**Twitter**

In order have access to the Twitter Streaming API you have to obtain your client credentials by creating a new Twitter APP on the [Twitter Dev Website](https://apps.twitter.com/app/new). After doing so, also save your credentials in the `.env`file:

    TWITTER_CONSUMER_KEY=yourConsumerKey
    TWITTER_CONSUMER_SECRET=yourConsumerSecret
    TWITTER_ACCESS_TOKEN_KEY=yourAccessTokenKey
    TWITTER_ACCESS_TOKEN_SECRET=yourAccessTokenSecret

You are also able to change the filters which are used to crawl the Twitter API here. A `,` indicates OR and a whitespace an AND concatenation.

    TWITTER_STREAMING_FILTERS="YOURFILTERS"

Examples: 

 - `"humira,abbvie"` crawls all tweets that contain `humira OR abbvie` 
 -  `"humira abbvie"` crawls all tweets that contain `humira AND abbvie`
   

#### Start the server
After installing all necessary software fragments you just need to start the server with the following command, assuming you are in the `sentitomo/server`directory:

    $ npm start
    #or 
    $ yarn start

After that the server is listening on Port:8080.
If you test locally then visit:

 - Front-End: [localhost:8080/app/dashboard](localhost:8080/app/dashboard) 
 - GraphQL Endpoint:  [localhost:8080/graphql](localhost:8080/graphql) 
 - Endpoint for testing the API: [localhost:8080/graphiql](localhost:8080/graphiql)
If you want to access the server from a remote destination just switch out localhost with your server IP or domain.


After setting up and starting the server we will have a deeper look into the database and the directories of Sentitomo.

### Database

By default Sentitomo is using a MySQL database, but it can be used with any other DBMS. We choosed a MySQL database because for us it was the easiest and fastest way to set up. When the appilication is initially connected to the database it is creating all necessary tables automatically. In the following the different CREATE statements of the tables are listed.

__TW_CORE__ holds all raw information of the tweets.

    CREATE TABLE `TW_CORE` (
      `id` varchar(255) NOT NULL,
      `keywordType` varchar(255) DEFAULT NULL,
      `keyword` varchar(255) DEFAULT NULL,
      `created` datetime DEFAULT NULL,
      `createdWeek` int(11) DEFAULT NULL,
      `toUser` varchar(255) DEFAULT NULL,
      `language` varchar(255) DEFAULT NULL,
      `source` varchar(255) DEFAULT NULL,
      `message` varchar(255) DEFAULT NULL,
      `latitude` varchar(255) DEFAULT NULL,
      `longitude` varchar(255) DEFAULT NULL,
      `retweetCount` int(11) DEFAULT NULL,
      `favorited` tinyint(1) DEFAULT NULL,
      `favoriteCount` int(11) DEFAULT NULL,
      `isRetweet` tinyint(1) DEFAULT NULL,
      `retweeted` int(11) DEFAULT NULL,
      `createdAt` datetime NOT NULL,
      `updatedAt` datetime NOT NULL,
      `TWUserId` varchar(255) DEFAULT NULL,
      PRIMARY KEY (`id`),
      KEY `TWUserId` (`TWUserId`),
      CONSTRAINT `TW_CORE_ibfk_1` FOREIGN KEY (`TWUserId`) REFERENCES `TW_User` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

__TW_Users__ contains information about the tweet authors.

    CREATE TABLE `TW_User` (
      `id` varchar(255) NOT NULL,
      `username` varchar(255) DEFAULT NULL,
      `screenname` varchar(255) DEFAULT NULL,
      `createdAt` datetime NOT NULL,
      `updatedAt` datetime NOT NULL,
      `followercount` bigint(20) DEFAULT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



__TW_SENTIMENT__ contains information about the sentiments of different tweets.

    CREATE TABLE `TW_SENTIMENT` (
      `id` varchar(255) NOT NULL,
      `sarcastic` double DEFAULT NULL COMMENT 'Sarcasm probability',
      `emo_senti` double DEFAULT NULL COMMENT 'Sentiment of emojis in the message',
      `emo_desc` varchar(255) DEFAULT NULL COMMENT 'Emojis in the message',
      `r_ensemble` varchar(255) DEFAULT NULL COMMENT 'Result from R sentiment analysis',
      `python_ensemble` varchar(255) DEFAULT NULL COMMENT 'Result from Python sentiment analysis',
      `sentiment` varchar(255) DEFAULT NULL COMMENT 'Final sentiment result',
      `createdAt` datetime NOT NULL,
      `updatedAt` datetime NOT NULL,
      PRIMARY KEY (`id`),
      CONSTRAINT `TW_SENTIMENT_ibfk_1` FOREIGN KEY (`id`) REFERENCES `TW_CORE` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

__TW_TOPIC__ contains information about the topics of different tweets.

    CREATE TABLE `TW_TOPIC` (
      `id` varchar(255) NOT NULL,
      `topic1Month` varchar(255) DEFAULT NULL,
      `topic1Month_C` varchar(255) DEFAULT NULL,
      `topic3Month` varchar(255) DEFAULT NULL,
      `topic3Month_C` varchar(255) DEFAULT NULL,
      `topicWhole` varchar(255) DEFAULT NULL,
      `topicWhole_C` varchar(255) DEFAULT NULL,
      `createdAt` datetime NOT NULL,
      `updatedAt` datetime NOT NULL,
      PRIMARY KEY (`id`),
      CONSTRAINT `TW_TOPIC_ibfk_1` FOREIGN KEY (`id`) REFERENCES `TW_CORE` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;



### Server

All the backend server logic is placed inside the `server`directory. We won't cover every single file or directory, but we want to introduce the most important ones which are the `ML` and `data` directories and the `server/service/TwitterCrawler.js` file.

#### ML
Inside the ML directory we have all code which is related to the machine learning tasks, like sentiment analysis, topic detection and trend detection. It is divided in three subdirectories `Java`, `Python` and `R` to seperate the different programming languages. Also in the top level of `ML` you can find the wrapper files for incorporating the different programming languages with Javascript, `ml_wrapper.js` and `preprocess.js`. To let the different programming files work together we use Node's opportunity to spawn child processes and capture the output of these. With that procedure we can spawn the machine learning tasks asynchronously to the main process, which leads to the fact that the main thread is blocked or influenced by executing foreign code. In the following we want to explain how we integrated the different files into the server application




##### Preface (Important Notice)

It is not possible to pass complex data types and structures from Javascript to R, Python or Java. It can either be a **plain string** or a **JSON encoded string** which then needs to be parsed by the executed application. The same applies for the output. If the foreign code wants to output an complex object it is the best practice to convert to a JSON representation so that the server can easily read it. 

__Possible packages and modules to use__
* __R__ with [RJSONIO](https://cran.r-project.org/web/packages/RJSONIO/index.html)
* __Pyhton__ with [JSON Module](https://docs.python.org/2/library/json.html)
* __Java__ with [org.json library](https://github.com/stleary/JSON-java)

__Paths__
When the foreign code needs access to some other files inside the R directory it is mandatory to know that all those files are executed in the scope of `server/`. For example if a Python file needs to load a model from the Python directory it has to do it with the relative path `./ML/Python/filename.bin`.

__Examples__
All examples in JavaScript are written in ES6.


##### R
For integrating R with the server we are using a package called [r-script](https://github.com/joshkatz/r-script) package. It comes with an R function called `needs()`. This is basically a combination of `install()` and `require()`.  This ensures that the different packages which are needed by our R scripts are installed and loaded in the correct way. Therefore every R file has to use `needs()` instead `ìnstall.package("packageName")` and `require("package")/load("package")`. Also it is recommended  to put all functions at the top of the R files.
To send data to the R process from and back to the Javascript we can attach data to the R process like so: 

*Javascript*
```
R("example/test.R")
  .data({message: tweet.message })
  .call(function(err, d) {
    if (err) throw err;
    console.log(d);
  });
```
*R*

      
    attach(input[[0]]) # This is needed to have access to the variables from the Javascript object
    message # this is the same variable name like in the Javascript ({message: tweet.message }) code

One thing to mention is that the `r-script` package reads the console log from the R scripts. So if you want to give some value back to the server to process, for example the output of a classification task **DO NOT ASSIGN IT TO VARIABLE** just let it print to the console by writing:

```
yourVariable
```

Here is an example code block in R
```
needs(dplyr) # require every library so
attach(input[[1]]) # used to get the javascript values

# Here comes all your function
# function 1
# function 2
# *****

# assign the retrieved value to a local one, this comes from the Javascript code
# It was passed like this {message: tweet.message}. It has the same name, 'message'.
out <- message 
out <- gsub("ut","ot",out) # do something with it
out # last line of the script should always print the value which you want to return to the server
```


**Example for converting JSON to data.frame in R**

see: [Stackoverflow for this example](https://stackoverflow.com/a/16948174)

*Javascript*
```
const message = {message: "[{"name":"Doe, John","group":"Red","age (y)":24,"height (cm)":182,"wieght (kg)":74.8,"score":null},
    {"name":"Doe, Jane","group":"Green","age (y)":30,"height (cm)":170,"wieght (kg)":70.1,"score":500},
    {"name":"Smith, Joan","group":"Yellow","age (y)":41,"height (cm)":169,"wieght (kg)":60,"score":null},
    {"name":"Brown, Sam","group":"Green","age (y)":22,"height (cm)":183,"wieght (kg)":75,"score":865},
    {"name":"Jones, Larry","group":"Green","age (y)":31,"height (cm)":178,"wieght (kg)":83.9,"score":221},
    {"name":"Murray, Seth","group":"Red","age (y)":35,"height (cm)":172,"wieght (kg)":76.2,"score":413},
    {"name":"Doe, Jane","group":"Yellow","age (y)":22,"height (cm)":164,"wieght (kg)":68,"score":902}]'"}

R("example/test.R")
  .data({message: message })
  .call(function(err, d) {
    if (err) throw err;
    console.log(d);
  });
```

*R*
```
needs(RJSONIO)   
attach(input[[0]]) # This is needed to have access to the variables from the JS
json <- fromJSON(message)   # comes from Javascript {message: variable}
json <- lapply(json, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})
do.call("rbind", json)
```

Outcome is a data.frame
```
     name           group    age (y) height (cm) wieght (kg) score
[1,] "Doe, John"    "Red"    "24"    "182"       "74.8"      NA   
[2,] "Doe, Jane"    "Green"  "30"    "170"       "70.1"      "500"
[3,] "Smith, Joan"  "Yellow" "41"    "169"       "60"        NA   
[4,] "Brown, Sam"   "Green"  "22"    "183"       "75"        "865"
[5,] "Jones, Larry" "Green"  "31"    "178"       "83.9"      "221"
[6,] "Murray, Seth" "Red"    "35"    "172"       "76.2"      "413"
[7,] "Doe, Jane"    "Yellow" "22"    "164"       "68"        "902"
```


##### Python
For Python we initially used a package called [python-shell](https://github.com/extrabacon/python-shell) to execute single Pyhton script files. But as we switched from Pyhton 2 to Python 3 we had some issues to tell the package to use Python 3 instead of Pyhton 2. So in the end we decided to spawn the child process of Pyhton by our own. Then we were able to set the Python version by our own. Also the files are able to retrieve command line arguments which makes the communication between JS and Python possible. The communication is then again managed by reading the console prints of the Python file. One advice to give is to make sure to not heavily use the console for prints, because the main process only needs to know the final outcome of the script. 

*Javascript*
```
import child_process from 'child_process';

/**
 * @function test
 * @param  {String} message  Message to the file
 * @param  {Function} callback Function to handle the sentiment result
 * @description Test function to show the Python procedure
 * @return {String} Result of the 
 */
var test = function(filename, callback) {
	var child = child_process.exec(
                'python3 ./ML/Python/test.py ' + message, (error, stdout, stderr) => {
                    if (error !== null) {
                        console.log("Error -> " + error);
                    }
                    if (typeof callback === "function") {
                        callback(stdout.trim());
                    }

                }
            );
}

test("{ a: 'b' }).send(null).send([1, 2, 3]", (result) => {
	console.log(result);
});


```

*Python*
```
import sys, json

# simple JSON echo script
for line in sys.argv[1:]:
  print json.dumps(json.loads(line))


#Plain decode JSON
json.loads(argv[1])

```
**Output in the Javascript**
```
{"a": "b"}\nnull\n[1, 2, 3]\n
```

##### Java
For Java we followed the same approach and developed the spawning process of the files by our own. It is exact the same like with Python, the only thing which is different that you have to execute the .jar instead of the Python file.

*Javascript*

    import child_process from 'child_process';
    
   

     /**
         * @function test
         * @param  {String} message  Message to the file
         * @param  {Function} callback Function to handle the sentiment result
         * @description Test function to show the Java procedure
         * @return {String} Result of the 
         */
        var test = function(filename, callback) {
        	var child = child_process.exec(
                        'java -jar ./ML/Java/test.jar ' + message, (error, stdout, stderr) => {
                            if (error !== null) {
                                console.log("Error -> " + error);
                            }
                            if (typeof callback === "function") {
                                callback(stdout.trim());
                            }
        
                        }
                    );
        }
        
    test("Hello world", result => {
    	console.log(result)
    });
*Java*

    public class HelloWorld {
   
        public static void main(String[] args) {
            // Prints the command line argument to the terminal window.
            System.out.println(args[0]);
        }
    
    }


#### data

Inside the `data` directory the connection to the database and the `GraphQL` schema definitions are expressed. 
For connecting to the database we use a package called [Sequlize.js](http://docs.sequelizejs.com/). It was very easy to set up and operates on a higher level, so that you just have to define your database schema and all necessary queries to the database are handled by the package itself. It supports  PostgreSQL, MySQL, SQLite and MSSQL dialects. Also it lets us easily combine it with the GraphQL API.

Another main part of the `data` directory is the set up of GraphQL which is written in `resolvers.js`, which handles all the request to the API and `schema.js` which is setting up the different endpoints of the API. We used [apollo-server](https://github.com/apollographql/apollo-server) to set up the API. `apollo-server`is a great, easy to use open-source implementation of GraphQL on the server-side. In the following we want to provide a sample request to the API and what the response looks like:

Request sent to [localhost:8080/graphql]():
```
{
  tweet(id: "881026061806571520"){
    id
    message
    sentiment {
      id
      sentiment
    }
    author{
      id
      screenname
      username
    }
  }
}
```

Response:
```
{
  "data": {
    "tweet": {
      "id": "881026061806571520",
      "message": "New2Trip: Rheumatoid arthritis-specific cardiovascular risk scores are not superior to general risk scores: va<U+2026> https://t.co/KRZDi95ctL",
      "sentiment": {
        "id": "881026061806571520",
        "sentiment": "negative"
      },
      "author": {
        "id": "2199494760",
        "screenname": "TripPrimaryCare",
        "username": "Trip Primary Care"
      }
    }
  }
}
```

__What is happening ?__
In the following we want to provide a quick look at what is happening on the server side when a request comes in.
At first the request from the client is piped through the resolvers of `resolvers.js` and the `tweet(_,args)` method is invoked because we wanted to access the `tweet` endpoint. This takes all the arguments provied in the request. Right now this is only the `id`argument. To get the result from the database we use the database model object of sequlize.js called `Tweet` which we defined in the `connectors.js` file. It returns the exact tweet where the `id` matches. Because in the request only some fields are requested only those get responded. Only fields which are stated in the `schema.ja` can be returned.
In the end a new data object is constructed which contains only the information that was requested.

`resolvers.js` (truncated)
```
import {
    Author,
    Tweet,
    Sentiment,
    Topic
} from './connectors';


const resolvers = {
    Date: GraphQLMoment,
    Query: {
        ...,
        tweet(_, args) {
            return Tweet.find({
                where: args
            });
        },
        ...
    },
    Author: {
        tweets(author) {
            return author.getTweets();
        },
    },
    Tweet: {
        author(tweet) {
            return tweet.getTW_User();
        },
        sentiment(tweet) {
            return tweet.getTW_SENTIMENT();
        },
        topic(tweet) {
            return tweet.getTW_TOPIC();
        }
    },
};
```
`schema.js` (Provides the different API queries and the available fields)
```
/**
 * @constant typeDefinitions
 * @type {String}
 * @description Type definition schema for the GraphQL API. here all types, queries and mutations are specified which the API is offering
 */
const typeDefinitions = `

  scalar Date
  type Tweet {
    id: String
    keywordType: String
    keyword: String
    created: String
    createdWeek: Int
    toUser: String
    language: String
    source: String
    message: String
    messagePrep: String
    latitude: String
    longitude: String
    retweetCount: Int
    favorited: Boolean
    favoriteCount: Int
    isRetweet: Boolean
    retweeted: Int
    author: Author
    sentiment: Sentiment
    topic: Topic
  }

  type Author {
    id: String
    username: String
    screenname: String
    tweets: [Tweet]
  }

  type Sentiment {
    id: String
    sentiment: String
  }

  type Topic {
    id: String
    topic1Month: String
    topic1Month_C: String
    topic3Month: String
    topic3Month_C: String
    topicWhole: String
    topicWhole: String
  }

  type Query {
    tweet(id: String): Tweet
    sentiment(id: String): Sentiment
    topic(id: String): Topic
    author(username: String): Author
    tweets(limit: Int, offset: Int, startDate: Date, endDate: Date): [Tweet]
    count(startDate: Date, endDate: Date): Int
  }

  schema {
      query: Query
  }
`;


export default [typeDefinitions];
```



### Client

## Typical Workflow

