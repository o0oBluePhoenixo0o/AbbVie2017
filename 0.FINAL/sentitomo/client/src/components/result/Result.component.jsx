import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Card, Grid, Label, List, Segment, Table } from 'semantic-ui-react'
import { PieChart, Pie, Cell, Legend, Tooltip, XAxis, YAxis, CartesianGrid, Line, ResponsiveContainer, ComposedChart } from 'recharts';
import randomColor from 'randomcolor';
import dl from 'datalib';
import moment from 'moment';


/**
 * @constant renderTopicLegend
 * @param {Object} props Data about the different entries in the chart
 * @type {function}
 * @description Renders a custom topic pie chart legend
 */
const renderTopicLegend = (props) => {
    const { payload } = props;
    return (
        <List divided selection>
            {
                payload.map((entry, index) => {
                    return (<List.Item key={`item-${index}`} onClick={() => props.onClick(entry.payload.payload)}>
                        <Label style={{ background: entry.color }} horizontal />
                        {entry.payload.payload.topic ? entry.payload.payload.topic : "Null"}
                    </List.Item>)

                })
            }
        </List>
    );
}

/**
 * @class CustomTopicToolTip
 * @extends {React.Component}
 * @description Class for displaying customized tooltip on the topic pie chart
 */
class CustomTopicToolTip extends Component {
    render() {
        const { active } = this.props;

        if (active) {
            const { payload, label } = this.props;
            return (
                <Card className="tooltip" style={{ background: "#fff !important", color: "#000 !important" }}>
                    <Card.Content>
                        <p className="label">{`Topic-ID : ${payload[0].payload.topicId}`}</p>
                        <p className="intro">{'Conent:' + payload[0].payload.topic}</p>
                    </Card.Content>
                </Card>
            );
        }

        return null;
    }
}

/**
 * @constant renderSentimentLegend
 * @param {Object} props Data about the different entries in the chart
 * @type {function}
 * @description Renders a custom sentiment pie chart legend
 */
const renderSentimentLegend = (props) => {
    const { payload } = props;
    return (
        <List divided selection>
            {
                payload.map((entry, index) => {
                    return (<List.Item key={`item-${index}`}>
                        <Label style={{ background: entry.color }} horizontal />
                        {entry.payload.payload.sentiment}
                    </List.Item>)

                })
            }
        </List>
    );
}

/**
 * @class CustomSentimentToolTip
 * @extends {React.Component}
 * @description Class for displaying customized tooltip on the sentiment pie chart
 */
class CustomSentimentToolTip extends Component {
    render() {
        const { active } = this.props;

        if (active) {
            const { payload, label } = this.props;
            return (
                <Card className="tooltip">
                    <Card.Content>
                        <p className="label">{`Sentiment : ${payload[0].payload.sentiment}`}</p>
                    </Card.Content>
                </Card>
            );
        }

        return null;
    }
}

/**
 * @class Result
 * @extends {React.Component}
 * @description Class for displaying the result of a dynamic topic detection
 */
class Result extends Component {

    state = { selectedTopic: null, selectedSentiment: null }

    /**
     * @function aggregateTopics
     * @param  {Array} data Array of topic detection data
     * @description Aggregates the data of the array by topics
     * @memberof Result
     * @return {Array} Aggregated topic array
     */
    aggregateTopics = (data) => {
        var copy = JSON.parse(JSON.stringify(data)); // We need to deep copy the array, as we do not want to hold reference to the original array here
        var myData = dl.read(copy, { type: 'json', parse: 'auto' });
        return (dl.groupby(['topicId', 'topic']).count().execute(myData));
    }

    /**
     * @function aggregateSentiment
     * @param  {Array} data Array of topic detection data
     * @description Aggregates the data of the array by sentiment
     * @memberof Result
     * @return {Array} Aggregated sentiment array
     */
    aggregateSentiment = (data) => {
        var copy = JSON.parse(JSON.stringify(data)); // We need to deep copy the array, as we do not want to hold reference to the original array here
        var myData = dl.read(copy, { type: 'json', parse: 'auto' });
        return (dl.groupby(['sentiment']).count().execute(myData));
    }

    /**
     * @function aggregateDate
     * @param  {Array} data Array of topic detection data
     * @description Aggregates the data of the array by date (based on days)
     * @memberof Result
     * @return {Array} Aggregated date array
     */
    aggregateDate = (data) => {

        var copy = JSON.parse(JSON.stringify(data)); // We need to deep copy the array, as we do not want to hold reference to the original array here
        copy.forEach((obj, index, array) => {
            array[index].created = new Date(array[index].created).setHours(0, 0, 0, 0)
        })

        var myData = dl.read(copy, { type: 'json', parse: 'auto' });
        return (dl.groupby(['created'])
            .summarize({ 'created': 'count' })
            .execute(myData));
    }

    /**
     * @function onTopicCellClick
     * @param  {Object} entry Entry of the graph which was clicked
     * @param  {Integer} index Index of the selected entry inside the entries array
     * @description Set the this.state.selectedTopic to entry
     * @memberof Result
     * @return {void}
     */
    onTopicCellClick = (entry, index) => {
        this.setState({
            selectedTopic: entry,
            selectedSentiment: null // reset the sentiment selection
        })
    }

    /**
     * @function onTopicLegendClick
     * @param  {Object} data Data of the legend, same as an entry of the graph
     * @description Set the this.state.selectedTopic to data
     * @memberof Result
     * @return {void}
     */
    onTopicLegendClick = (data) => {
        this.setState({
            selectedTopic: data,
            selectedSentiment: null // reset the sentiment selection
        });
    }

    /**
     * @function onSentimentCellClick
     * @param  {Object} entry Entry of the graph which was clicked
     * @param  {Integer} index Index of the selected entry inside the entries array
     * @description Set the this.state.selectedSentiment to entry
     * @memberof Result
     * @return {void}
     */
    onSentimentCellClick = (entry, index) => {
        this.setState({
            selectedSentiment: entry
        })
    }

    /**
   * @function resetSelection
   * @description Sets this.state.selectedTopics and this.state.selectedSentiment to null
   * @memberof Result
   * @return {void}
   */
    resetSelection = () => {
        this.setState({
            selectedTopic: null,
            selectedSentiment: null,
        })
    }

    /**
     * @function formatDate
     * @param  {Object} data Date from the x-axis ticks
     * @description Formats the date of a data object in a readable format using moment.js
     * @memberof Result
     * @return {String} Date string encoded on "DD-MM-YYYY"
     */
    formatDate = (data) => {
        return moment(new Date(data)).format("DD-MM-YYYY");
    }

    render() {
        const { data, withLDA } = this.props;
        const { selectedTopic, selectedSentiment } = this.state;



        if (data) {

            console.log(data);
            const result = data.tweets;
            const trend = data.trend;

            var aggregatedTopics = null;
            var aggregateSentiment = null;
            var aggregateDate = null;
            var selectedTrendGraph = null;
            aggregatedTopics = this.aggregateTopics(result.slice()).sort((a, b) => { return a.count - b.count });

            var colors = randomColor({
                count: aggregatedTopics.length,
                hue: 'random', luminosity: "random", seed: 123412
            });


            if (selectedTopic) {

                if (selectedSentiment) {
                    aggregateSentiment = this.aggregateSentiment(result.slice().filter(element => {
                        return element.topicId == selectedTopic.topicId && element.sentiment == selectedSentiment.sentiment
                    }));

                    aggregateDate = this.aggregateDate(result.slice().filter(element => {
                        return element.topicId == selectedTopic.topicId && element.sentiment == selectedSentiment.sentiment
                    }))
                } else {

                    var trendDetail = trend.find(element => { return element.topicId == this.state.selectedTopic.topicId });
                    var selectedTrendGraph = trendDetail ? trendDetail.trendGraph : null;  // If the selected topic has an trend graph, return it, if not set the value to null

                    aggregateSentiment = this.aggregateSentiment(result.slice().filter(element => {
                        return element.topicId == selectedTopic.topicId
                    }));

                    aggregateDate = this.aggregateDate(result.slice().filter(element => {
                        return element.topicId == selectedTopic.topicId
                    }))
                }
            }

            return (
                <div className="result-pane">

                    <Grid stackable columns={3}>
                        <Grid.Row>
                            <Grid.Column mobile={16} tablet={7} computer={7}>
                                <Card fluid className="result">
                                    <Card.Content header={"Aggregrated Topics"} />
                                    <Card.Content className={'card-body'}>
                                        <ResponsiveContainer height={500}>
                                            <PieChart>
                                                <Pie data={aggregatedTopics} dataKey="count" fill="#8884d8" label onClick={(entry, index) => this.onTopicCellClick(entry, index)}>
                                                    {
                                                        aggregatedTopics.map((entry, index) => (
                                                            <Cell key={`cell-${index}`} fill={colors[index]} />
                                                        ))
                                                    }
                                                </Pie>
                                                <Tooltip content={<CustomTopicToolTip />} />

                                                <Legend content={renderTopicLegend} style={{ maxHeight: "250px !important", overflow: "auto" }} onClick={this.onTopicLegendClick} />
                                            </PieChart>
                                        </ResponsiveContainer >
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                            <Grid.Column mobile={16} tablet={7} computer={7}>
                                <Card fluid className="result">
                                    <Card.Content header={"Sentiments in topic"} />
                                    <Card.Content className={'card-body'}>
                                        {this.state.selectedTopic && aggregateSentiment.length > 0 ?
                                            < ResponsiveContainer height={500}>
                                                <PieChart>
                                                    <Pie data={aggregateSentiment} dataKey="count" fill="#8884d8" label onClick={(entry, index) => this.onSentimentCellClick(entry, index)} >
                                                        {
                                                            aggregateSentiment.map((entry, index) => {
                                                                return (<Cell key={`cell-${index}`} fill={entry.sentiment === 'negative' ? "#e74c3c" : entry.sentiment === 'positive' ? "#2ecc71" : "#f1c40f"} />)
                                                            })
                                                        }
                                                    </Pie>
                                                    <Tooltip content={<CustomSentimentToolTip />} />
                                                    <Legend content={renderSentimentLegend} style={{ maxHeight: "250px !important", overflow: "auto" }} onClick={this.onLegendClick} />
                                                </PieChart>
                                            </ResponsiveContainer >
                                            : "No sentiment values in data"}
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                            <Grid.Column mobile={16} tablet={2} computer={2}>
                                <Segment raised style={{ position: "fixed", marginRight: "2em", zIndex: "100" }}>
                                    <List>
                                        <List.Item><strong>Topic:</strong> {selectedTopic ? selectedTopic.topic : "Null"}</List.Item>
                                        <List.Item><strong>Sentiment:</strong> {selectedSentiment ? selectedSentiment.sentiment : "Null"}</List.Item>
                                    </List>
                                    <a href="#" onClick={() => this.resetSelection()}>Reset</a>
                                </Segment>
                            </Grid.Column>
                        </Grid.Row>
                        <Grid.Row>
                            <Grid.Column mobile={16} tablet={16} computer={7}>
                                <Card fluid className="result">
                                    <Card.Content header={"Timeline"} />
                                    <Card.Content className={'card-body'}>
                                        {this.state.selectedTopic ?
                                            <ResponsiveContainer height={500}>
                                                <ComposedChart height={500} data={aggregateDate}
                                                    margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                                                    <XAxis dataKey="created" tickFormatter={this.formatDate} />
                                                    <YAxis type="number" domain={['auto', 'auto']} />
                                                    <CartesianGrid />
                                                    <Tooltip />
                                                    <Legend />
                                                    {/*<Bar dataKey='average_sentimentValue' barSize={20} fill='#413ea0'>
                                                        {
                                                            aggregateDate.map((entry, index) => {
                                                                return (<Cell key={`cell-${index}`} fill={entry.average_sentimentValue < 35.00 ? "#e74c3c" : entry.average_sentimentValue > 85.00 ? "#2ecc71" : "#f1c40f"} />)
                                                            })
                                                        }
                                                    </Bar>*/}
                                                    <Line type="monotone" dataKey="count_created" stroke="#8884d8" />
                                                </ComposedChart>
                                            </ResponsiveContainer >
                                            : ""}
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                            <Grid.Column mobile={16} tablet={16} computer={7}>
                                <Card fluid className="result">
                                    <Card.Content header={"Poisson"} />
                                    <Card.Content className={'card-body'}>
                                        {this.state.selectedTopic ?
                                            <ResponsiveContainer height={500}>
                                                <ComposedChart height={500} data={selectedTrendGraph}
                                                    margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                                                    <XAxis dataKey="date" tickFormatter={this.formatDate} />
                                                    <YAxis type="number" domain={['auto', 'dataMax']} />
                                                    <CartesianGrid />
                                                    <Tooltip />
                                                    <Legend />
                                                    <Line type="monotone" dataKey="poisson" stroke="#8884d8" />
                                                </ComposedChart>
                                            </ResponsiveContainer >
                                            : ""}
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                        </Grid.Row>
                        {withLDA ? <Grid.Row>
                            <Grid.Column mobile={16} tablet={14} computer={14}>
                                <Card fluid>
                                    <Card.Content>
                                        <Card.Header>LDA HTML</Card.Header>
                                    </Card.Content>
                                    <Card.Content>
                                        <iframe src="http://localhost:8080/ldaresult" frameBorder="0" style={{ width: "100%", height: "900px" }}></iframe>
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                        </Grid.Row> : null}
                        <Grid.Row>
                            <Grid.Column mobile={16} tablet={14} computer={14}>
                                <Card fluid className="result">
                                    <Card.Content>
                                        <Card.Header>Raw Tweets</Card.Header>
                                    </Card.Content>
                                    <Card.Content className={'card-body'}>
                                        {this.state.selectedTopic ? <Table fixed stackable>
                                            <Table.Header>
                                                <Table.Row>
                                                    <Table.HeaderCell>Id</Table.HeaderCell>
                                                    <Table.HeaderCell>Topic</Table.HeaderCell>
                                                    <Table.HeaderCell>Sentiment</Table.HeaderCell>
                                                    <Table.HeaderCell>Topic Probability</Table.HeaderCell>
                                                    <Table.HeaderCell>Message</Table.HeaderCell>
                                                    <Table.HeaderCell>Hashtags</Table.HeaderCell>
                                                    <Table.HeaderCell>Created</Table.HeaderCell>
                                                </Table.Row>
                                            </Table.Header>

                                            <Table.Body>
                                                {result.slice().filter(element => {
                                                    if (this.state.selectedSentiment) {
                                                        return (element.topicId == selectedTopic.topicId && element.sentiment == selectedSentiment.sentiment)
                                                    } else {
                                                        return (element.topicId == selectedTopic.topicId)
                                                    }

                                                }).slice().map(tweet => {
                                                    return (<Table.Row key={`table-row-${tweet.id}`}>
                                                        <Table.Cell>{tweet.id}</Table.Cell>
                                                        <Table.Cell>{tweet.topic}</Table.Cell>
                                                        <Table.Cell>{tweet.sentiment}</Table.Cell>
                                                        <Table.Cell>{tweet.topicProbability}</Table.Cell>
                                                        <Table.Cell>{tweet.message}</Table.Cell>
                                                        <Table.Cell>{tweet.hashtags}</Table.Cell>

                                                        <Table.Cell>{moment(tweet.created).format("DD-MM-YYYY HH:mm:ss")}</Table.Cell>
                                                    </Table.Row>)
                                                })}
                                            </Table.Body>
                                        </Table> : ""}
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                        </Grid.Row>
                    </Grid>
                </div >
            )
        } else {
            return (
                <Segment basic>
                    No data
                </Segment>
            );

        }
    }
}


Result.propTypes = {
    /** {Array} Array with the result containing the dynamic topic detection*/
    result: PropTypes.array,
}

export default Result;