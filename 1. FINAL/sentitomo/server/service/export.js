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
export function convertToCsvRaw(data, filepath) {
    var csv = json2csv({
        data: data,
        fields: Object.keys(data[0]),
        doubleQuotes: "",
        del: ","
    });

    fs.writeFile(filepath, csv, function (err) {
        if (err) throw err;
        console.log('file saved');
    });
    logger.log('info', "CSV export was saved in " + filepath);
}

/**
 * @function convertToCsvModel
 * @param  {Array} data Data model array returned from a sequelize query
 * @param  {String} filepath Filepath where the csv gets stored
 * @description Writes an array sequlize objects into a .csv file with the specified filepath
 * @return {void}
 */
export function convertToCsvModel(data, filepath) {
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