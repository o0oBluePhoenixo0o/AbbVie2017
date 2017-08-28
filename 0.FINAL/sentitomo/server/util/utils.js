/** @module Utils 
 * @description Some useful methods for working with strings or importing data
*/
import fs from 'fs';
import csv from 'fast-csv';
import dl from 'datalib';

var _this = this;

/** 
 * @function occurrences
 * @param {String} string The string
 * @param {String} subString The sub string to search for
 * @param {Boolean} allowOverlapping Optional. (Default:false)
 * @author Vitim.us https://gist.github.com/victornpb/7736865/edit
 * @see Unit Test https://jsfiddle.net/Victornpb/5axuh96u/
 * @see http://stackoverflow.com/questions/4009756/how-to-count-string-occurrence-in-string/7924240#7924240
 * @description Function that count occurrences of a substring in a string;
 * @return {int} How many times the substring occurs
 */
var occurrences = function occurrences(string, subString, allowOverlapping) {
    string += '';
    subString += '';
    if (subString.length <= 0) return string.length + 1;

    var n = 0,
        pos = 0,
        step = allowOverlapping ? 1 : subString.length;

    while (true) {
        pos = string.indexOf(subString, pos);
        if (pos >= 0) {
            ++n;
            pos += step;
        } else break;
    }
    return n;
}

/**
 * @function getKeyword
 * @param  {String} message The text to extract keyword
 * @param  {String} filters Comma separated possible keywords
 * @description Extract a keyword out of a text based on possible keywords and their occurrences in the message
 * @see @see {@link module:Utils~occurrences}
 * @return {String} The keyword which is most likely to represent the content of this text
 */
function getKeyword(message, filters) {
    var mostOcc = '';
    var key = '';
    var keywords = filters.split(',');
    keywords.map(keyword => {
        var counts = occurrences(
            message.toLowerCase(),
            keyword,
            false
        );
        if (counts > mostOcc) {
            mostOcc = counts;
            key = keyword;
        }
    });
    return key;
}

/**
 * @function stripHTMLTags
 * @param  {String} text A string containing HTML Tags
 * @description Remove all HTML tags
 * @return {String} String where every HTML tag is stripped out
 */
function stripHTMLTags(text) {
    return text.replace(/<\/?[^>]+(>|$)/g, '');
}

/**
 * @function extractHashTagsFromString
 * @param  {String} text A string containing hashtags
 * @description Extract every hashtag from a given text. Returns a concatenated string of those separated by ','
 * @return {String} Concatenated string with hashtags, separated by ','
 */
function extractHashTagsFromString(text) {
    var matches = text.match(/\B\#\w\w+\b/g);
    return matches ? matches.filter((element, index, array) => index === array.indexOf(element)).join(',').replace(/#/g, '') : null; // Filter array to have uniques and join them by ","*/
}

/**
 * @function extractHashtagsFromTweet
 * @param  {Object} hashtags Hashtags object from the Twitter API
 * @description Extract every hashtag from a given Twitter API hashtags object. Returns a concatenated string of those separated by ','
 * @return {String} Concatenated string with hashtags, separated by ','
 */
function extractHashtagsFromTweet(hashtags) {
    var tags = new Array();

    hashtags.forEach((hashtag) => {
        tags.push(hashtag.text);
    }, this);
    if (hashtags.length == 0) {
        return null;
    } else {
        return tags.join(',');
    }
}


function importTweetCsv(csvFile) {

    var stream = fs.createReadStream(csvFile);
    var objects = new Array();
    csv
        .fromStream(stream, { headers: true, objectMode: true })
        .on('data', data => {
            objects.push(data);
        })
        .on('end', () => {
            var interval = 10 * 400; // 4 seconds;
            for (var i = 0; i <= objects.length - 1; i++) {
                if (objects[i]['Language'] == 'eng') {
                    setTimeout(
                        i => {
                            twitterCrawler.client.get(
                                'users/search', {
                                    q: objects[i]['From.User']
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
                                                Tweet.upsert({
                                                    id: objects[i]['Id'],
                                                    keywordType: 'Placeholder',
                                                    keyword: objects[i]['key'],
                                                    created: objects[i]['created_time'],
                                                    createdWeek: moment(
                                                        objects[i]['created_time'], 'dd MMM DD HH:mm:ss ZZ YYYY', 'en'
                                                    ).week(),
                                                    toUser: objects[i]['To.User'] == 'NA' ? null : objects[i]['To.User'],
                                                    language: objects[i]['Language'],
                                                    source: stripHTMLTags(
                                                        objects[i]['Source']
                                                    ),
                                                    message: objects[i]['message'],
                                                    messagePrep: null,
                                                    latitude: objects[i]['Geo.Location.Latitude'] == 'NA' ? null : objects[i]['Geo.Location.Latitude'] == 'NA',
                                                    longitude: objects[i]['Geo.Location.Longitude'] == 'NA' ? null : objects[i]['Geo.Location.Longitude'] == 'NA',
                                                    retweetCount: objects[i]['Retweet.Count'],
                                                    favorited: objects[i]['favorited'] == 'TRUE',
                                                    favoriteCount: objects[i]['favoriteCount'],
                                                    isRetweet: objects[i]['isRetweet'] == 'TRUE',
                                                    retweeted: objects[i]['retweeted'],
                                                    TWUserId: tweets[0].id,
                                                });
                                            });
                                        });
                                    };
                                });
                        },
                        interval * i,
                        i
                    );
                }
            }
        });

}

/**
 * @function buildCommonTopicHeader
 * @param  {String} csvFile Path to the csv file which contains our allocation of topic contents and their respective common topic headlines
 * @description Build an array out of our csv file which contain allocation of topic contents and their respective common topic names
 * @return {Array} Array with topic content terms and their corresponding common topic name
 */
function buildCommonTopicHeader(csvFile) {
    return new Promise((resolve, reject) => {
        var stream = fs.createReadStream(csvFile);
        var commonHeadlines = new Array();
        csv
            .fromStream(stream, { headers: true, objectMode: true })
            .on('data', data => {
                commonHeadlines.push(data);
            })
            .on('end', () => {
                resolve(commonHeadlines);
            })
    })
}

/**
 * @function commonTopicHeader
 * @param  {String} topicContent Topic content string out of database
 * @param  {Array} commonHeadlines  Array of topic contents with their headlines
 * @description Tries to find a common topic header for a given topic content based on previously build array of associations between topic contents and headline
 * @see {@link module:Utils~buildCommonTopicHeader}
 * @return {String} Common topic name for given topic content
 */
function commonTopicHeader(topicContent, commonHeadlines) {
    const terms = topicContent.split(', ');

    //flatten the result of the buildCommonTopicHeader function
    var flattened = commonHeadlines.reduce(function (result, element) {
        let index = terms.indexOf(element.term)
        if (index != -1) {
            var commonName = commonHeadlines[index];
            for (const key of Object.keys(commonName)) {
                commonName[key] = parseInt(commonName[key])
            }
            delete commonName["term"]
            return result.concat(commonName);

        } else {
            return result;
        }
    }, []);

    //Prepare reference object for extracting keys
    var referenceObj = commonHeadlines[1];
    delete referenceObj["term"]
    var termsArray = new Array();

    for (const key of Object.keys(referenceObj)) {

        var term = dl.groupby(key).count().execute(flattened).filter(element => {
            return element[key] == 1;
        })[0];

        // prepare term object
        if (term) {
            term.term = Object.keys(term)[0];
            delete term[Object.keys(term)[0]]
            termsArray.push(term)
        }
    }

    const highestTerm = termsArray.reduce((prev, current) => (prev.count > current.count) ? prev : current) //most appropriate term for list of topic content
    return highestTerm.term;
}



export {
    extractHashTagsFromString,
    extractHashtagsFromTweet,
    occurrences,
    getKeyword,
    stripHTMLTags,
    importTweetCsv,
    buildCommonTopicHeader,
    commonTopicHeader
}