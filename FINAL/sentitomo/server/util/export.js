/** @module Export 
 *  @description Module which offers functions to convert JSON data to csv
*/
import json2csv from 'json2csv';
import fs from 'fs';
import logger from '../service/logger';

/**
 * @function convertToCsvRaw
 * @param  {Array} data Raw JSON Array of objects
 * @param  {String} filepath Filepath where the csv gets stored
 * @description Writes an array JSON objects into a .csv file with the specified filepath
 * @returns {Promise<String>} A Promise that contains the path to the created file
 */
export function convertRawToCsv(data, filepath, callback) {
    return new Promise((resolve, reject) => {
        var csv = json2csv({
            data: data,
            fields: Object.keys(data[0]),
            doubleQuotes: "",
            del: ','
        });

        fs.writeFile(filepath, csv, function (err) {
            if (err) reject(err);
            logger.log('info', 'CSV export was saved in ' + filepath);
            resolve(filepath);
        });
    })
}

/**
 * @function convertSequelizeModelToCsv
 * @param  {Array} data Data model array returned from a sequelize query
 * @param  {String} filepath Filepath where the csv gets stored
 * @description Writes an array of sequelize objects into a .csv file with the specified filepath
 * @return {Promise<String>} A Promise that contains the path to the created file
 */
export function convertSequelizeModelToCsv(data, filepath) {
    return new Promise((resolve, reject) => {
        var csv = json2csv({
            data: data,
            fields: Object.keys(data[0].dataValues),
            doubleQuotes: "",
            del: ','
        });

        fs.writeFile(filepath, csv, function (err) {
            if (err) reject(err);
            logger.log('info', 'CSV export was saved in ' + filepath);
            resolve(filepath);
        });
    });
}