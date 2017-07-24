import moment from 'moment';
import {
    GraphQLScalarType,
    GraphQLError,
    Kind
} from 'graphql';


/**
 * @description A custom GrapqhQLDate Type using moment.js
 * @author rijvirajib https://gist.github.com/rijvirajib/2f4dbd808185e73d69ed2bfae759b51b
 */
module.exports = new GraphQLScalarType({
    name: 'Date',
    /**
     * Serialize date value into string
     * @param  {moment} value date value
     * @return {String} date as string
     */
    serialize: function (value) {
        let date = moment(value);
        if (!date.isValid()) {
            throw new GraphQLError('Field serialize error: value is an invalid Date');
        }
        return date.format();
    },
    /**
     * Parse value into date
     * @param  {*} value serialized date value
     * @return {moment} date value
     */
    parseValue: function (value) {
        let date = moment(value);
        if (!date.isValid()) {
            throw new GraphQLError('Field parse error: value is an invalid Date');
        }
        return date;
    },
    /**
     * Parse ast literal to date
     * @param  {Object} ast graphql ast
     * @return {moment} date value
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