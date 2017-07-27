/** @module Export 
 *  @description Module which offers functions to convert JSON data to csv
*/
import json2csv from 'json2csv';
import fs from 'fs';
import logger from './logger.js';

/**
 * @function convertToCsvRaw
 * @param  {Array} data Raw JSON Array of objects
 * @param  {String} filepath Filepath where the csv gets stored
 * @description Writes an array JSON objects into a .csv file with the specified filepath
 * @return {void}
 */
export function convertToCsvRaw(data, filepath, callback) {
    var csv = json2csv({
        data: data,
        fields: Object.keys(data[0]),
        doubleQuotes: "",
        del: ","
    });

    fs.writeFile(filepath, csv, function (err) {
        if (err) throw err;
        console.log('file saved');
        callback()
    });
    logger.log('info', "CSV export was saved in " + filepath);
}

/**
 * @function convertSequlizeModelToCsv
 * @param  {Array} data Data model array returned from a sequelize query
 * @param  {String} filepath Filepath where the csv gets stored
 * @description Writes an array of sequlize objects into a .csv file with the specified filepath
 * @return {void}
 */
export function convertSequlizeModelToCsv(data, filepath) {
    var csv = json2csv({
        data: data,
        fields: Object.keys(data[0].dataValues),
        doubleQuotes: "",
        del: ","
    });

    fs.writeFile(filepath, csv, function (err) {
        if (err) throw err;
        console.log('file saved');
    });
    logger.log('info', "CSV export was saved in " + filepath);
}