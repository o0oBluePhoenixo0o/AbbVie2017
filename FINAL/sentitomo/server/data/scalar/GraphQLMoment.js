import moment from 'moment';
import {
    GraphQLScalarType,
    GraphQLError,
    Kind
} from 'graphql';

/** @class GraphQLScalarType 
 *  @description A custom GrapqhQLDate Type using moment.js
 *  @author rijvirajib https://gist.github.com/rijvirajib/2f4dbd808185e73d69ed2bfae759b51b
*/
export default new GraphQLScalarType({
    name: 'Date',
    /**
     * @function serialize
     * @param  {moment} value date value
     * @description Serialize date value into string
     * @return {String} date as string
     * @throws {GraphQLError} when the date is invalid
     * @memberof GraphQLScalarType
     */
    serialize: function (value) {
        let date = moment(value);
        if (!date.isValid()) {
            throw new GraphQLError('Field serialize error: value is an invalid Date');
        }
        return date.format();
    },
    /**
     * @function parseValue
     * @param  {*} value serialized date value
     * @description Parse value into date
     * @return {moment} date value
     * @throws {GraphQLError} when the date is invalid
     * @memberof GraphQLScalarType
     */
    parseValue: function (value) {
        let date = moment(value);
        if (!date.isValid()) {
            throw new GraphQLError('Field parse error: value is an invalid Date');
        }
        return date;
    },
    /**
     * @function parseLiteral
     * @param  {Object} ast graphql ast
     * @description Parse ast literal to date
     * @return {moment} date value
     * @throws {GraphQLError} when the date is invalid or if it is not a string
     * @memberof GraphQLScalarType
     */
    parseLiteral: (ast) => {
        if (ast.kind !== Kind.STRING) {
            throw new GraphQLError('Query error: Can only parse strings to date but got: ' + ast.kind);
        }
        let date = moment(ast.value);
        if (!date.isValid()) {
            throw new GraphQLError('Query error: Invalid date');
        }
        return date;
    }
});