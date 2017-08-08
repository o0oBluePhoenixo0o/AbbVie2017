/** @module ForeignCode
 *  @description Contains methods for spawning child processes for different programming languages. This is not an exhaustive implementation.
 * It could provide more functionality here, but because this is not the real purpose, just only the necessary methods are available.
 */
import child_process from 'child_process';
import _ from 'underscore';
import logger from '../service/logger';

const defaults = {
    cwd: global.appRoot,
    env: process.env,
    encoding: 'utf8'
};

/**
 * @function PythonShell
 * @param  {String}  path    Path to the Python file to execute
 * @param  {Integer} version Specify the Python version to use
 * @description Instantiates a new Python object. Useful to call the Python class methods without the "new" keyword
 * @see {@link module:ForeignCode~Python}
 * @return {Object}  A Python object
 */
export function PythonShell(path, version) {
    var obj = new Python(path, version);
    return _.bindAll(obj, 'data', 'call', );
}

/**
 * @class Python
 * @param  {String} path    Path to the Python file to execute
 * @param  {Integer} version Specify the Python version to use
 * @classdesc Class for execting Jar files
 */
class Python {
    constructor(path, version) {
        this.version = version;
        this.args = [path];
        this.output = "";
    }

    /**
    * @function data
    * @param  {Array} data Array of command line arguments
    * @description Add command line arguments to the execution of the file
    * @memberof module:ForeignCode~Python
    * @return {Object} Pyhton object instance
    */
    data(data) {
        data.forEach((element) => {
            this.args.push(element.toString());
        });
        return this;
    }

    /**
    * @function call
    * @param  {Function} callback Function to handle the result of the execution
    * @description Spawns a child process and executes the specified Python file asynchronously
    * @memberof module:ForeignCode~Python
    * @return {void}
    */
    call(callback) {
        const process = child_process.spawn(this.version == 2 ? 'python2' : 'python3', this.args, defaults);

        process.stdout.on('data', (data) => {
            this.output += '' + data

        });

        process.stderr.on('data', (data) => {
            logger.error(`stderr: ${data}`);
        });

        process.on('close', (code) => {
            logger.info(`child process exited with code ${code}`);
            console.log(this.output);
            callback(this.output);
        });
    }


    callSync() {
        const process = child_process.spawnSync(this.version == 2 ? 'python2' : 'python3', this.args, defaults);
        if (process.stderr) console.log(process.stderr);
        return (process.stdout);
    }
}


/**
 * @function JavaShell
 * @param  {String}  path    Path to the Jar file to execute
 * @description Instantiates a new Java object. Useful to call the Java class methods without the "new" keyword
 * @see {@link module:ForeignCode~Java}
 * @return {Object}  A Java object
 */
export function JavaShell(path) {
    var obj = new Java(path);
    return _.bindAll(obj, 'data', 'call', );
}


/** 
 * @class Java
 * @param {String} path  Path to the Jar file to executeo use
 * @classdesc Class for execting Jar files
*/
class Java {

    constructor(path) {
        this.args = ['-jar', path];
        this.output = '';
    }

    /**
     * @function data
     * @param  {Array} data Array of command line arguments
     * @description Add command line arguments to the execution of the file
     * @memberof module:ForeignCode~Java
     * @return {Object} Java object instance
     */
    data(data) {
        data.forEach((element) => {
            this.args.push(element.toString());
        });
        return this;
    }

    /**
    * @function call
    * @param  {Function} callback Function to handle the result of the execution
    * @description Spawns a child process and executes the specified Jar file asynchronously
    * @memberof module:ForeignCode~Java
    * @return {void}
    */
    call(callback) {
        const process = child_process.spawn('java', this.args, defaults);

        process.stdout.on('data', (data) => {
            this.output += '' + data
        });

        process.stderr.on('data', (data) => {
            logger.error(`stderr: ${data}`);
        });

        process.on('close', (code) => {
            logger.info(`child process exited with code ${code}`);
            callback(this.output);
        });
    }

}


/**
 * @function RShell
 * @param  {String} path    Path to the R file to execute
 * @description Instantiates a new R object. Useful to call the R class methods without the "new" keyword
 * @see {@link module:ForeignCode~R}
 * @return {Object}  A R object
 */
export function RShell(path) {
    return new R(path);
}

/** 
 * @class R 
 * @param {String} path  Path to the R file to execute
 * @classdesc Class for execting R files
*/
class R {

    constructor(path) {
        this.path = path;
        this.args = ['--vanilla', path];
        this.output = '';
    }

    /**
     * @method data
     * @param  {Array} data Array of command line arguments
     * @description Add command line arguments to the execution of the file
     * @return {Object} R object instance
     * @memberof module:ForeignCode~R
     */
    data(data) {
        data.forEach((element) => {
            this.args.push(element.toString());
        });
        return this;
    }

    /**
     * @method call
     * @param  {Function} callback Function to handle the result of the execution
     * @description Spawns a child process and executes the specified R file asynchronously
     * @return {void}
     * @memberof module:ForeignCode~R
     */
    call(callback) {
        const process = child_process.spawn('Rscript', this.args, defaults);

        process.stdout.on('data', (data) => {
            this.output += '' + data
        });

        process.stderr.on('data', (data) => {
            console.log(`stderr: ${data}`);
        });

        process.on('close', (code) => {
            console.log(`child process exited with code ${code}`);
            callback(this.output);
        });
    }

    /**
     * @function callSync
     * @description Spawns a child process and executes the specified R file synchronously
     * @return {String} The stdout of the process
     * @memberof module:ForeignCode~R
    */
    callSync() {
        const process = child_process.spawnSync('Rscript', this.args, defaults);
        if (process.stderr) console.log(process.stderr);
        return (process.stdout);
    }
}








