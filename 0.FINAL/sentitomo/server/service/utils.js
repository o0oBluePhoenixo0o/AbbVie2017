/** @module Utils */

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
export function occurrences(string, subString, allowOverlapping) {
    string += "";
    subString += "";
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
 * @description Extract a keyword out of a text based on possible keywords
 * @return {String} The keyword which is most likely to represent the content of this text
 */
export function getKeyword(message, filters) {
    var mostOcc = "";
    var key = "";
    var keywords = filters.split(",");
    keywords.map(keyword => {
        var occurrences = occurrences(
            message.toLowerCase(),
            keyword,
            false
        );
        if (occurrences > mostOcc) {
            mostOcc = occurrences;
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
export function stripHTMLTags(text) {
    return text.replace(/<\/?[^>]+(>|$)/g, "");
}