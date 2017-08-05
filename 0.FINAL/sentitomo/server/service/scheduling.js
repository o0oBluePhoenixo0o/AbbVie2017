import cron from 'cron';
import { Tweet, Dashboard } from '../data/connectors';

import logger from './logger';

/*
 * Runs every weekday (Monday through Friday)
 * at 11:30:00 AM. It does not run on Saturday
 * or Sunday.
 */
var syncJob = new cron.CronJob({
    cronTime: process.env.DASH_SYNC_CRON,
    onTick: function () {
        console.log('syncJob ticked');
        /*
        var allTweets = Tweet.findAll({ where: { inDash: 0 } });
        allTweets.classify and topic detect
        modify tweets to match the dashboard table

        

        Dashboard.bulkCreate(allTweets).then(() => { // Notice: There are no arguments here, as of right now you'll have to...
            return Dashboard.findAll();
        }).then(dashTweets => {
            console.log(dashTweets) // ... in order to get the array of user objects
        })*/

    },
    start: false,
    timeZone: 'America/Los_Angeles'
});

logger.log('info', 'Topic Detection Sync job started!');