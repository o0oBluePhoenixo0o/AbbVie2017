import logger from '../service/logger.js';


/**
 * @function loggingMiddleware
 * @param  {Object} req  Request object
 * @param  {Object} res  Response object
 * @param  {function} next Function so that the request will be passed on to the next function
 * @return {type} {description}
 */
export default function loggingMiddleware(req, res, next) {
    logger.log('debug', 'GraphQL IP Request', {
        ip: req.ip
    });
    next();
}