/** @module LogginMiddleware 
 *  @description Provides functions to add a login middleware to an express app
 */
import logger from '../service/logger.js';

/**
 * @function loggingMiddleware
 * @param  {Object} req  Request object
 * @param  {Object} res  Response object
 * @param  {function} next Function so that the request will be passed on to the next function
 * @description Injects a logger to an express app, which logs every request and the IP where the requests come from
 * @return {type} {description}
 */
export default function loggingMiddleware(req, res, next) {
    logger.log('debug', 'IP Request', {
        ip: req.ip
    });
    next();
}