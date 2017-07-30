# Instruction Manual for File Usage on Sentitomo Server


## Introduction

Sentitomo Server is an application built with `express.js`. It utilizes machine learning algorithms to analyze social media messages according to sentiment, topics, and trends. The results are saved in a MySQL database to display the results in any needed way.

## Directory Structure
```
.
├── README.md
├── package.json
├── server
│   ├── ML
│   │   ├── Java
│   │   │   ├── naivebayes.bin
│   │   │   └── sentiment_executor-1.0-SNAPSHOT-jar-with-dependencies.jar
│   │   ├── Python
│   │   │   └── myscript.py
│   │   └── R
│   │       ├── abbrev.csv
│   │       └── preprocess.R
│   ├── data
│   │   ├── connectors.js
│   │   ├── resolvers.js
│   │   └── schema.js
│   ├── routes
│   │   └── index.js
│   ├── server.js
│   └── service
│       ├── TwitterCrawler.js
│       ├── classify.js
│       └── preprocess.js
└── yarn.lock

```
The server directory is separeted in 3 main parts `ML`, `data`, `service`. 
### ML
The ML directory contains all files which are neede to execute the different Machine Learning algorithms. In total this application uses 3 different programming languages, R, Pyhton and Java to accomplish the ML tasks. The different files containing some special lines which make them work with the Javascript enviroment this server is running in. More detail about this in the `File Preparation` part.

### data
Inside this directory the GraphQL API is living. The application offers an endpoint to query the database whith the modern solution of GraphQL. The fact that the API is built with GraphQL it makes it even possible to switch out the DBMS entirely wihtout changing the API endpoints.

### service
The service directory contains files for crawling different social media APIs, classifying sentiment of messages and the corresponding topics of them

## GraphQL API
To access the GraphQL API just query it with the standard Query structure to retrieve the data you want. In dev the server is listening on port 8080:

```
{
  tweet(id: "883620904663744500") {
    id
    message
    language
    created
    favorited
    author{
      id
      screenname
      username
    }
  }
}

```
Leeds to:

```
{
  "data": {
    "tweet": {
      "id": "883620904663744500",
      "message": "RT @K0YCHEV: Create Static Sites With #Webpack https://t.co/3ca4L5D7vA #javascript #HTML #webdev #programming #devops https://t.co/aAFsavHP…",
      "language": "en",
      "created": "Sat Jul 08 2017 11:36:55 GMT+0200 (CEST)",
      "favorited": false,
      "author": {
        "id": "802981345123299300",
        "screenname": "K0YCHEV",
        "username": "KOYCHEV.DE"
      }
    }
  }
}
```

## Execution of foreign code
All foreign code files (insde the ML directory) are executed asynchronously in child processes so the main server thread is not directly influenced by the execution of these files. This makes the server work more smoothly and not get blocked if some file will fail to execute or taking a lot of time to execute. 

### File Preparation 
To let files of different programming languages work with the server they need to be adjusted a little bit. In the following there will be a small instruction on how to prepare the files. 



#### Forword (Important Notice)

It is not possible to pass complex data types and structures from Javascript to R or Python. It can either be a **plain string** or a **JSON encoded string** which then needs to be parsed by R or Pyhton. The same applies for your output. If you want to output an array for example, be sure to first encode it as an JSON Array so that the server can easily read it. 

**Possible packages and modules to use**
* **R** with [RJSONIO](https://cran.r-project.org/web/packages/RJSONIO/index.html)
* **Pyhton** with [JSON Module](https://docs.python.org/2/library/json.html)

#### R
For R it is pretty straight forward. We use the [r-script](https://github.com/joshkatz/r-script) package. This comes with an R function called `needs()`. This is basically a combination of `install()` and `require()`. So every R file needs to use `needs()` instead of the other files. Also it is recommoned to put all needed functions at the top of the file. To send data to the R process from and back to the Javascript we can attach data to the R process like so: 

**Javascript**
```
R("example/ex-async.R")
  .data({message: tweet.message })
  .call(function(err, d) {
    if (err) throw err;
    console.log(d);
  });
```
**R**
```
 attach(input[[0]]) # This is needed to have access to the variables from the Javascript object
 message # this is the same variable name like in the Javascript ({message: tweet.message }) code
 ```

One thing to mention is that the `r-script` package reads the console log from the R scripts. So if you want to give some value back to our server to process, for example the output of a classification task **DO NOT ASSIGN IT TO VARIABLE** just let it print to the console by writing:
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


**JSON to data.frame in R**

see: [Stackoverflow for this example](https://stackoverflow.com/a/16948174)

Javascript
```
{message: "[{"name":"Doe, John","group":"Red","age (y)":24,"height (cm)":182,"wieght (kg)":74.8,"score":null},
    {"name":"Doe, Jane","group":"Green","age (y)":30,"height (cm)":170,"wieght (kg)":70.1,"score":500},
    {"name":"Smith, Joan","group":"Yellow","age (y)":41,"height (cm)":169,"wieght (kg)":60,"score":null},
    {"name":"Brown, Sam","group":"Green","age (y)":22,"height (cm)":183,"wieght (kg)":75,"score":865},
    {"name":"Jones, Larry","group":"Green","age (y)":31,"height (cm)":178,"wieght (kg)":83.9,"score":221},
    {"name":"Murray, Seth","group":"Red","age (y)":35,"height (cm)":172,"wieght (kg)":76.2,"score":413},
    {"name":"Doe, Jane","group":"Yellow","age (y)":22,"height (cm)":164,"wieght (kg)":68,"score":902}]'"}
```

Then in R
```
attach(input[[0]]) # This is needed to have access to the variables from the 
needs(RJSONIO)   
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

Also please have a look at the `preprocess.R` file to get an overview on how to do it.


#### Python
 We use [python-shell](https://github.com/extrabacon/python-shell) to execute single Pyhton script files. The files need to be capable of retrieving starting arguments, for example the path to a serialized model file which is then used to classify the topic of a tweet message. The communication between Python and the server is then again managed by reading the console prints of the Python file. Make sure to not heavily use the console for prints, because our server only needs to knwo the final outcome of the script. For example you can print out the topic of a message and the corresponding contents of this topic. 


If you want that your input is parsed in a JSON way you can define this in the options object of the `PyhtonShell`.


**Javascript**
```
var PythonShell = require('python-shell');

var options = {
  mode: 'json', #here you can specify the mode either 'text' or 'json'
  args: [{ a: 'b' }, null, [1, 2, 3]] #arguments for the python script
};

PythonShell.run('my_script.py', options, function (err, results) {
  if (err) throw err;
  // results is an array consisting of messages collected during execution
  console.log('results: %j', results);
});
```

**Python**
```
import sys, json

# simple JSON echo script
for line in sys.argv[1:]:
  print json.dumps(json.loads(line))


#Plain decode JSON
json.loads(argv[1])

```
**Output**
```
{"a": "b"}\nnull\n[1, 2, 3]\n
```





  ## Start up the server and client
 To start the server run `yarn start` in the server directory. It uses [nodemon](https://github.com/remy/nodemon) to automatically restart the server if some source file changes. 
 
 * GraphQL Endpoint: [localhost:8080/graphql/](localhost:8080/graphql/)
 * GraphiQL Endpoint for testing GraphQL: [localhost:8080/graphiql/](localhost:8080/graphiql/)
 * Front End: [localhost:8080/app/](localhost:8080/app/)

 If you want to view the client you first have to run `yarn build` in the client directory and then start up the server.