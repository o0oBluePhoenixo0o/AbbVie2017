import React, { Component } from 'react';
import { Card, Grid, Label, List, Segment, Table, Header } from 'semantic-ui-react'
import { PieChart, Pie, Cell, Legend, Tooltip, LineChart, XAxis, YAxis, CartesianGrid, Line, ResponsiveContainer } from 'recharts';
import randomColor from 'randomcolor';
import dl from 'datalib';
import moment from 'moment';

const data = [
    {
        id: "1357670736", topicId: 10, topic: "abbvie, collaboration, research, announce, m2gen", topicProbability: 0.8916666666666664, message: "I'm noticing with the humira dosage increase that lately the sun doesn't seem to make me feel sick.", created: moment("2017-03-01", "YYYY-MM-DD").toDate(),
        sentiment: "positive"
    }, {
        id: "1357670737", topicId: 10, topic: "abbvie, collaboration, research, announce, m2gen", topicProbability: 0.8916666666666664, message: "I'm noticing with the humira dosage increase that lately the sun doesn't seem to make me feel sick.", created: moment("2017-03-02", "YYYY-MM-DD").toDate(),
        sentiment: "positive"
    }, {
        id: "1357670737", topicId: 10, topic: "abbvie, collaboration, research, announce, m2gen", topicProbability: 0.8916666666666664, message: "I'm noticing with the humira dosage increase that lately the sun doesn't seem to make me feel sick.", created: moment("2017-03-02", "YYYY-MM-DD").toDate(),
        sentiment: "positive"
    }, {
        id: "13576707086", topicId: 9, topic: "amgen, bristol, haey, drugs", topicProbability: 0.7126666666666664, message: "I'm noticing with the humira dosage increase that lately the sun doesn't seem to make me feel sick.", created: moment("2017-03-04", "YYYY-MM-DD").toDate(),
        sentiment: "positive"
    }

];


var colors = [
    "#462446", "#B05F6D", "#EB6B56", "#FFC153", "#47B39D", "#E0E4CC", "#7BB0A6", "#1DABB8", "#BADA55", "#FF6766",
    "#953163", "#8870FF", "#2C82C9", "#F1654C", "#83D6DE", "#EEE657", "#3E4651", "#8A2D3C", "#3C3741"];



const renderTopicLegend = (props) => {
    const { payload } = props;
    return (
        <List divided selection>
            {
                payload.map((entry, index) => {
                    return (<List.Item key={`item-${index}`}>
                        <Label style={{ background: entry.color }} horizontal />
                        {entry.payload.payload.topic}
                    </List.Item>)

                })
            }
        </List>
    );
}

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

class Result extends Component {

    state = { selectedEntry: null }

    /**
     * @function aggregateTopics
     * @param  {type} data Array of topic detection data
     * @return {Array} Aggregrated topic array
     */
    aggregateTopics = (data) => {
        var myData = dl.read(data, { type: 'json', parse: 'auto' });
        return (dl.groupby(['topicId', 'topic']).count().execute(myData));
    }

    /**
     * @function aggregateSentiment
     * @param  {type} data Array of topic detection data
     * @return {Array} Aggregrated sentiment array
     */
    aggregateSentiment = (data) => {
        var myData = dl.read(data, { type: 'json', parse: 'auto' });
        return (dl.groupby(['sentiment']).count().execute(myData));
    }

    /**
     * @function aggregateDate
     * @param  {type} data Array of topic detection data
     * @return {Array} Aggregrated date array
     */
    aggregateDate = (data) => {
        console.log(data);
        var myData = dl.read(data, { type: 'json', parse: 'auto' });
        console.log(dl.groupby(['created']).count().execute(myData))
        return (dl.groupby(['created']).count().execute(myData));
    }


    onCellClick = (entry, index) => {
        this.setState({
            selectedEntry: entry
        })
    }


    formatDate = (data) => {
        console.log(data);
        return moment(data).format("DD-MM-YYYY");
    }

    render() {
        const { result } = this.props;
        const { selectedEntry } = this.state;
        console.log(result);

        var aggregatedTopics = null;
        var aggregateSentiment = null;
        var aggregateDate = null;

        if (result) {
            aggregatedTopics = this.aggregateTopics(result).sort((a, b) => { return a.count - b.count });

            var colors = randomColor({
                count: aggregatedTopics.length,
                hue: 'random', luminosity: "random", seed: 123412
            });

            if (selectedEntry) {
                aggregateSentiment = this.aggregateSentiment(result.filter(element => {
                    return element.topicId === selectedEntry.topicId
                }));

                aggregateDate = this.aggregateDate(result.filter(element => {
                    return element.topicId === selectedEntry.topicId
                }));
            }

            return (
                <div className="result-pane">
                    {selectedEntry ? <Header size='large'>You selected: {selectedEntry.topic}</Header> : null}
                    <Grid stackable columns={3}>
                        <Grid.Row>
                            <Grid.Column mobile={16} tablet={8} computer={4}>
                                <Card fluid className="result">
                                    <Card.Content header={"Aggregrated Topics"} />
                                    <Card.Content>
                                        <ResponsiveContainer height={400}>
                                            <PieChart>
                                                <Pie data={aggregatedTopics} dataKey="count" fill="#8884d8" label onClick={(entry, index) => this.onCellClick(entry, index)}>
                                                    {
                                                        aggregatedTopics.map((entry, index) => (
                                                            <Cell key={`cell-${index}`} fill={colors[index]} />
                                                        ))
                                                    }
                                                </Pie>
                                                <Tooltip content={<CustomTopicToolTip />} />
                                                {/*<Legend content={renderTopicLegend} onClick={(event) => this.onLegendClick(event)} />*/}
                                            </PieChart>
                                        </ResponsiveContainer >
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                            <Grid.Column mobile={16} tablet={8} computer={4}>
                                <Card fluid className="result">
                                    <Card.Content header={"Sentiments in topic"} />
                                    <Card.Content>
                                        {this.state.selectedEntry ?
                                            <ResponsiveContainer height={400}>
                                                <PieChart>
                                                    <Pie data={aggregateSentiment} dataKey="count" fill="#8884d8" label >
                                                        {
                                                            aggregateSentiment.map((entry, index) => {
                                                                return (<Cell key={`cell-${index}`} fill={entry.sentiment === 'negative' ? "#e74c3c" : entry.sentiment === 'positive' ? "#2ecc71" : "#f1c40f"} />)
                                                            })
                                                        }
                                                    </Pie>
                                                    <Tooltip content={<CustomSentimentToolTip />} />
                                                    <Legend content={renderSentimentLegend} style={{ maxHeight: "250px !important", overflow: "auto" }} onClick={(event) => this.onLegendClick(event)} />
                                                </PieChart>
                                            </ResponsiveContainer >
                                            : ""}
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                            <Grid.Column mobile={16} tablet={16} computer={8}>
                                <Card fluid className="result">
                                    <Card.Content header={"Timeline"} />
                                    <Card.Content>
                                        {this.state.selectedEntry ?
                                            <ResponsiveContainer height={400}>
                                                <LineChart height={400} data={aggregateDate}
                                                    margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                                                    <XAxis dataKey="created" tickFormatter={this.formatDate} />
                                                    <YAxis />
                                                    <CartesianGrid />
                                                    <Tooltip />
                                                    <Legend />
                                                    <Line type="monotone" dataKey="count" stroke="#8884d8" />
                                                </LineChart>
                                            </ResponsiveContainer >
                                            : ""}
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                        </Grid.Row>
                        <Grid.Row stretched>
                            <Grid.Column mobile={16} tablet={16} computer={8}>
                                <Card fluid className="result">
                                    <Card.Content>
                                        <Card.Header>Raw Tweets</Card.Header>
                                    </Card.Content>
                                    <Card.Content>
                                        {this.state.selectedEntry ? <Table fixed stackable>
                                            <Table.Header>
                                                <Table.Row>
                                                    <Table.HeaderCell>Id</Table.HeaderCell>
                                                    <Table.HeaderCell>Topic</Table.HeaderCell>
                                                    <Table.HeaderCell>Sentiment</Table.HeaderCell>
                                                    <Table.HeaderCell>Message</Table.HeaderCell>
                                                    <Table.HeaderCell>Created</Table.HeaderCell>
                                                </Table.Row>
                                            </Table.Header>

                                            <Table.Body>
                                                {result.filter(element => {
                                                    return element.topicId === selectedEntry.topicId
                                                }).map(tweet => {
                                                    return (<Table.Row key={`table-row-${tweet.id}`}>
                                                        <Table.Cell>{tweet.id}</Table.Cell>
                                                        <Table.Cell>{tweet.topic}</Table.Cell>
                                                        <Table.Cell>{tweet.sentiment}</Table.Cell>
                                                        <Table.Cell>{tweet.message}</Table.Cell>
                                                        <Table.Cell>{tweet.created}</Table.Cell>
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

export default Result;