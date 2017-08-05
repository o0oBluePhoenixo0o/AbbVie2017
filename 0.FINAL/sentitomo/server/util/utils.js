/** @module Utils */


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
 * @description Extract a keyword out of a text based on possible keywords and their occurences in the message
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
 * @description Parse out HTML tags
 * @return {String} String where every HTML tag is parsed out
 */
function stripHTMLTags(text) {
    return text.replace(/<\/?[^>]+(>|$)/g, '');
}



function importTweetCsv(csvFile) {

    var stream = fs.createReadStream(csvFile);
    var datas = new Array();
    csv
        .fromStream(stream, { headers: true, objectMode: true })
        .on('data', data => {
            datas.push(data);
        })
        .on('end', () => {
            var interval = 10 * 400; // 1 seconds;
            for (var i = 0; i <= datas.length - 1; i++) {
                if (datas[i]['Language'] == 'eng') {
                    setTimeout(
                        i => {
                            var messagePrep = preprocessTweetMessage(datas[i].message);
                            console.log(datas[i]['isRetweet'])
                            twitterCrawler.client.get(
                                'users/search', {
                                    q: datas[i]['From.User']
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
                                                detectSentiment('./ML/Java/naivebayes.bin', messagePrep, result => {
                                                    Tweet.upsert({
                                                        id: datas[i]['Id'],
                                                        keywordType: 'Placeholder',
                                                        keyword: datas[i]['key'],
                                                        created: moment(datas[i]['created_time']).toDate(),
                                                        createdWeek: moment(
                                                            datas[i]['created_at']
                                                        ).week(),
                                                        toUser: datas[i]['To.User'] == 'NA' ? null : datas[i]['To.User'],
                                                        language: datas[i]['Language'],
                                                        source: stripHTMLTags(
                                                            datas[i]['Source']
                                                        ),
                                                        message: datas[i]['message'],
                                                        messagePrep: null,
                                                        latitude: datas[i]['Geo.Location.Latitude'] == 'NA' ? null : datas[i]['Geo.Location.Latitude'] == 'NA',
                                                        longitude: datas[i]['Geo.Location.Longitude'] == 'NA' ? null : datas[i]['Geo.Location.Longitude'] == 'NA',
                                                        retweetCount: datas[i]['Retweet.Count'],
                                                        favorited: datas[i]['favorited'] == 'TRUE',
                                                        favoriteCount: datas[i]['favoriteCount'],
                                                        isRetweet: datas[i]['isRetweet'] == 'TRUE',
                                                        retweeted: datas[i]['retweeted'],
                                                        TWUserId: tweets[0].id,
                                                    }).then((created) => {
                                                        Sentiment.upsert({
                                                            id: datas[i]['Id'],
                                                            sentiment: result,
                                                            sarcastic: detectSarcasm(messagePrep),
                                                            emo_senti: null,
                                                            emo_desc: null,
                                                            r_ensemble: null,
                                                            python_ensemble: null,
                                                        })
                                                    });
                                                });
                                            })
                                        })
                                    }
                                });
                        },
                        interval * i,
                        i
                    );
                }

            }
        });

}

export { occurrences, getKeyword, stripHTMLTags, importTweetCsv }