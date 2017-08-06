import React, { Component } from 'react';
import { Card, Grid, Label, List, Segment, Table, Header } from 'semantic-ui-react'
import { PieChart, Pie, Cell, Legend, Tooltip, ResponsiveContainer } from 'recharts';
import randomColor from 'randomcolor';
import dl from 'datalib';
import moment from 'moment';

const data = [
    {
        id: "1357670736", topicId: 10, topic: "abbvie, collaboration, research, announce, m2gen", topicProbability: 0.8916666666666664, message: "I'm noticing with the humira dosage increase that lately the sun doesn't seem to make me feel sick.", created: moment("2017-03-02").toDate(),
        sentiment: "positive"
    },
    {
        id: "16549201", topicId: 6, topic: "hepatitis, drug, european, country, civil", topicProbability: 0.8781249999999988, message: ".@MaggieMAEdays wishing u the best w/ Humira. I was on it for almost 15yrs. w/ gr8 results-till recently-but may even re-try it again.", created: moment("2017-03-04").toDate(),
        sentiment: "negative"
    }, {
        id: "16549501", topicId: 6, topic: "hepatitis, drug, european, country, civil", topicProbability: 0.8781249999999988, message: ".@MaggieMAEdays wishing u the best w/ Humira. I was on it for almost 15yrs. w/ gr8 results-till recently-but may even re-try it again.", created: moment("2017-03-04").toDate(),
        sentiment: "neutral"
    },
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
                <Card className="custom-tooltip">
                    <Card.Content>
                        <p className="label">{`Topic-ID : ${payload[0].payload.bin_topicId}`}</p>
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
                <Card className="custom-tooltip">
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
        var bin_topicId = dl.$bin(myData, 'topicId');
        var bin_topic = dl.$bin(myData, 'topic');
        return (dl.groupby(['topicId', 'topic']).count().execute(myData));
    }

    aggregateSentiment = (data) => {
        var myData = dl.read(data, { type: 'json', parse: 'auto' });
        var bin_sentiment = dl.$bin(myData, 'sentiment');
        console.log(dl.groupby(['sentiment']).count().execute(myData))
        return (dl.groupby(['sentiment']).count().execute(myData));
    }


    onCellClick = (entry, index) => {
        this.setState({
            selectedEntry: entry
        })
    }

    render() {
        const { result } = this.props;
        const { selectedEntry } = this.state;
        var aggregatedTopics = null;
        var aggregateSentiment = null;
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
            }

            return (
                <div className="result-pane">
                    {selectedEntry ? <Header size='large'>You selected: {selectedEntry.topic}</Header> : null}
                    <Grid stackable>
                        <Grid.Row stretched>
                            <Grid.Column width={8}>
                                <Segment>
                                    <ResponsiveContainer height={1000}>
                                        <PieChart>
                                            <Pie data={aggregatedTopics} dataKey="count" fill="#8884d8" label onClick={(entry, index) => this.onCellClick(entry, index)}>
                                                {
                                                    aggregatedTopics.map((entry, index) => (
                                                        <Cell key={`cell-${index}`} fill={colors[index]} />
                                                    ))
                                                }
                                            </Pie>
                                            <Tooltip content={<CustomTopicToolTip />} />
                                            <Legend content={renderTopicLegend} onClick={(event) => this.onLegendClick(event)} />
                                        </PieChart>
                                    </ResponsiveContainer >
                                </Segment>
                            </Grid.Column>
                            <Grid.Column width={8}>
                                <Segment>
                                    {this.state.selectedEntry ?

                                        <div style={{ height: "500px" }}>
                                            <ResponsiveContainer>
                                                <PieChart>
                                                    <Pie data={aggregateSentiment} dataKey="count" fill="#8884d8" label onClick={(entry, index) => this.onCellClick(entry, index)}>
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
                                        </div>


                                        : ""}
                                </Segment>
                            </Grid.Column>
                        </Grid.Row>
                        <Grid.Row stretched>
                            <Grid.Column width={8}>
                                <Segment>
                                    {this.state.selectedEntry ? <Table fixed stackable>
                                        <Table.Header>
                                            <Table.Row>
                                                <Table.HeaderCell>Id</Table.HeaderCell>
                                                <Table.HeaderCell>Topic</Table.HeaderCell>
                                                <Table.HeaderCell>Sentiment</Table.HeaderCell>
                                                <Table.HeaderCell>Message</Table.HeaderCell>
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
                                                </Table.Row>)
                                            })}
                                        </Table.Body>
                                    </Table> : ""}

                                </Segment>
                            </Grid.Column>
                        </Grid.Row>

                    </Grid>
                </div>
            )
        } else {
            return (
                <Segment>
                    No results
                </Segment>
            );

        }
    }
}

export default Result;