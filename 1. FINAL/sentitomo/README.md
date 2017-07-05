# Instruction Manual for File Usage on Sentitomo Server


## Introduction

Sentitomo Server is an application built with `Node.js`. We use `express.js` to built up the basic functionalities of this server. For Machine Learning tasks we use the programming languages `R`, `Python` and `Java`. We need to find a way to incorporate these languages in the server enviroment. Therefore some adjustments have to be made to our existing files.

## Directory Structure
```
├── app.js  
├── bin
│   └── www //Start script
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
│   ├── routes
│   │   └── index.js
│   └── service
│       ├── TwitterCrawler.js
│       ├── classify.js
│       ├── database.js
│       └── preprocess.js
└── yarn.lock
```

For now we have special directory for all of your foreign Machine Learning source files called `ML`. Inside this directory we seperate the files according to their programming language. Inside `./bin/www` we placed our main entry script which can be run with `PORT=30000 node bin/www` or if you want to use [nodemon](https://github.com/remy/nodemon) `PORT=30000 nodemon bin/www`.

### Execution of foreign code
All foreign code files are executed asynchronously in child processes so the main server thread is not influenced by the execution of these files. This makes our server work more smoothly and not get blocked if some file will fail to execute. 

### File Preparation 
To let our files work with the server they need to be adjusted a little bit. In the following there will be the instruction on how to prepare the files. 

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
 message # this is the same variable name like in the Javascript code
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

out <- message  # assign the retrieved value to a local one
out <- gsub("ut","ot",out) # do something with it
out # last line of the script should always print the value which you want to return to the server
```

Also please have a look at the `preprocess.R` file to get an overview on how to do it.


#### Python
 We use [python-shell](https://github.com/extrabacon/python-shell) to execute single Pyhton script files. The files need to be capable of retrieving starting arguments, for example the path to a serialized model file which is then used to classify the topic of a tweet message. The communication between Python and the server is then again managed by reading the console prints of the Python file. Make sure to not heavily use the console for prints, because our server only needs to knwo the final outcome of the script. For example you can print out the topic of a message and the corresporending contents of this topic. 

Small Example:
**Javascript**
```
var PythonShell = require('python-shell');

PythonShell.run('echo_args.py', { args: ['hello', 'world'] }, function (err, results) {
  if (err) throw err;
  // results is an array consisting of messages collected during execution
  console.log('results: %j', results);
});
```

**Python**
```
import sys

# simple argument echo script which prints the args specified in the Javascript
for v in sys.argv[1:]: 
  print v
```

