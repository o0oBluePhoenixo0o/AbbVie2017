//TODO: DOCU memberof

/** @module ForeignCode
 *  @description Contains methods for spawning child processes for different programming languages
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
 * @description Instantiates a new Python object
 * @return {Object}  A Python object
 */
export function PythonShell(path, version) {
    var obj = new Python(path, version);
    return _.bindAll(obj, 'data', 'call', );
}

/**
 * @function Python
 * @param  {String} path    Path to the Python file to execute
 * @param  {Integer} version Specify the Python version to use
 * @this Python
 * @return {void} 
 */
function Python(path, version) {
    this.version = version;
    this.args = [path];
    this.output = [];
}

/**
 * @function data
 * @param  {Array} data Array of command line arguments
 * @description Add command line arguments to the execution of the file
 * @this Python
 * @return {Object} Pyhton object instance
 */

Python.prototype.data = function (data) {
    data.forEach((element) => {
        this.args.push(element.toString());
    });
    return this;
}

/**
 * @function call
 * @param  {Function} callback Function to handle the result of the execution
 * @description Spawns a child process and executes the specified Python file asynchronously
 * @this Python
 * @return {void}
 */
Python.prototype.call = function (callback) {
    const process = child_process.spawn(this.version == 2 ? 'python2' : 'python3', this.args, defaults);

    process.stdout.on('data', (data) => {
        this.output.push(data.toString().trim());

    });

    process.stderr.on('data', (data) => {
        logger.error(`stderr: ${data}`);
    });

    process.on('close', (code) => {
        logger.info(`child process exited with code ${code}`);
        callback(this.output.join());
    });

}

/**
 * @function JavaShell
 * @param  {String}  path    Path to the Jar file to execute
 * @description Instantiates a new Java object
 * @return {Object}  A Java object
 */
export function JavaShell(path) {
    var obj = new Java(path);
    return _.bindAll(obj, 'data', 'call', );
}

/**
 * @function Java
 * @param  {String} path    Path to the Jar file to execute
 * @this Java
 * @return {void} 
 */
function Java(path) {
    this.args = ['-jar', path];
    this.output = [];
}

/**
 * @function data
 * @param  {Array} data Array of command line arguments
 * @description Add command line arguments to the execution of the file
 * @this Java
 * @return {Object} JavaShell object instance
 */
Java.prototype.data = function (data) {
    data.forEach((element) => {
        this.args.push(element.toString());
    });
    return this;
}

/**
 * @function call
 * @param  {Function} callback Function to handle the result of the execution
 * @description Spawns a child process and executes the specified Jar file asynchronously
 * @this Java
 * @return {void}
 */
Java.prototype.call = function (callback) {
    const process = child_process.spawn('java', this.args, defaults);

    process.stdout.on('data', (data) => {
        this.output.push(data.toString().trim());
    });

    process.stderr.on('data', (data) => {
        logger.error(`stderr: ${data}`);
    });

    process.on('close', (code) => {
        logger.info(`child process exited with code ${code}`);
        callback(this.output.join());
    });
}

/**
 * @function RShell
 * @param  {String} path    Path to the R file to execute
 * @description Instantiates a new R object
 * @return {Object}  A R object
 */
export function RShell(path) {
    var obj = new R(path);
    return _.bindAll(obj, 'data', 'call', );
}

/**
 * @function R
 * @param  {String} path    Path to the R file to executeo use
 * @this R
 * @return {void} 
 */
function R(path) {
    this.path = path;
    this.args = ['--vanilla', path];
    this.output = [];
}

/**
 * @function data
 * @param  {Array} data Array of command line arguments
 * @description Add command line arguments to the execution of the file
 * @this R
 * @return {Object} R object instance
 */
R.prototype.data = function (data) {
    data.forEach((element) => {
        this.args.push(element.toString());
    });
    return this;
}

/**
 * @function call
 * @param  {Function} callback Function to handle the result of the execution
 * @description Spawns a child process and executes the specified R file asynchronously
 * @this R
 * @return {void}
 */
R.prototype.call = function (callback) {
    const process = child_process.spawn('Rscript', this.args, defaults);

    process.stdout.on('data', (data) => {
        this.output.push(data.toString().trim());
    });

    process.stderr.on('data', (data) => {
        console.log(`stderr: ${data}`);
    });

    process.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
        callback(this.output.join());
    });
}

/**
 * @function callSync
 * @description Spawns a child process and executes the specified R file synchronously
 * @this R
 * @memberof R
 * @return {void}
 */
R.prototype.callSync = function () {
    const process = child_process.spawnSync('Rscript', this.args, defaults);
    if (process.stderr) console.log(process.stderr);
    return (process.stdout);
}

