var logger = require('winston');

logger.setLevels({
    debug: 0,
    info: 1,
    silly: 2,
    warn: 3,
    error: 4,
});
logger.addColors({
    debug: 'green',
    info: 'cyan',
    silly: 'magenta',
    warn: 'yellow',
    error: 'red'
});

logger.remove(logger.transports.Console);
logger.add(logger.transports.Console, {
    level: 'info',
    colorize: true
});
logger.add(logger.transports.File, {
    filename: 'server.log'
});

module.exports = logger;