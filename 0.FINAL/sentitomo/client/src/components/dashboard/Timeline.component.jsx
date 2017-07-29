import React from 'react';
import {
    XYPlot,
    XAxis,
    YAxis,
    VerticalGridLines,
    HorizontalGridLines,
    VerticalRectSeries,
    makeWidthFlexible
} from 'react-vis';
import { Segment } from 'semantic-ui-react';
import moment from 'moment';

const Timeline = ({ tweets }) => {

    var results = {}, rarr = [], i, date;

    for (i = 0; i < tweets.length; i++) {
        // get the date
        date = moment(tweets[i].created).format("YYYY-MM-DD");
        results[date] = results[date] || 0;
        results[date]++;
    }
    // you can always convert it into an array of objects, if you must
    for (i in results) {
        if (results.hasOwnProperty(i)) {
            console.log(i)
            rarr.push({ x0: moment(i).toDate(), x: moment(i).add(1, 'days').toDate(), y: results[i] });
        }
    }

    rarr.sort(function (a, b) {
        // Turn your strings into dates, and then subtract them
        // to get a value that is either negative, positive, or zero.
        return moment(b.x0) - moment(a.x0);
    });

    console.log(rarr);

    /*
    const DATA = [
        { x0: moment("2017-03-01").toDate(), x: moment("2017-03-01").add(1, 'days').toDate(), y: 5 },
        { x0: moment("2017-03-02").toDate(), x: moment("2017-03-02").add(1, 'days').toDate(), y: 10 },
        { x0: moment("2017-03-03").toDate(), x: moment("2017-03-03").add(1, 'days').toDate(), y: 15 },
        { x0: moment("2017-03-04").toDate(), x: moment("2017-03-04").add(1, 'days').toDate(), y: 12 },
        { x0: moment("2017-03-05").toDate(), x: moment("2017-03-05").add(1, 'days').toDate(), y: 20 },
        { x0: moment("2017-03-06").toDate(), x: moment("2017-03-06").add(1, 'days').toDate(), y: 45 },
        { x0: moment("2017-03-07").toDate(), x: moment("2017-03-07").add(1, 'days').toDate(), y: 20 },
        { x0: moment("2017-03-08").toDate(), x: moment("2017-03-08").add(1, 'days').toDate(), y: 20 },
        { x0: moment("2017-03-09").toDate(), x: moment("2017-03-09").add(1, 'days').toDate(), y: 10 },
        { x0: moment("2017-04-09").toDate(), x: moment("2017-04-09").add(1, 'days').toDate(), y: 90 },

    ]*/

    const Plot = ({ width, data }) =>
        <XYPlot
            xType="time"
            width={width}
            height={300} >
            <VerticalGridLines />
            <HorizontalGridLines />
            <XAxis />
            <YAxis />
            <VerticalRectSeries data={data} style={{ stroke: '#fff' }} />
        </XYPlot >


    Plot.propTypes = { width: React.PropTypes.number, measurements: React.PropTypes.array }
    Plot.displayName = 'TimeSeriesLineChartPlot'
    const FlexibleXYPlot = makeWidthFlexible(Plot)



    return (
        <Segment raised>
            <FlexibleXYPlot data={rarr} />
        </Segment>

    )

}

export default Timeline;