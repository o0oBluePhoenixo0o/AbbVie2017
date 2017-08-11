import React, { Component } from 'react';
import { Card, Checkbox, Grid, Label, List, Segment, Table, Header } from 'semantic-ui-react'
import { PieChart, Pie, Cell, Legend, Tooltip, LineChart, XAxis, YAxis, CartesianGrid, Line, ResponsiveContainer } from 'recharts';
import randomColor from 'randomcolor';
import dl from 'datalib';
import moment from 'moment';

const data = [
    {
        id: 884019304458362880,
        message: "Hepatitis C Cases Increase More Than 3-Fold in Iowa https://t.co/UcvuFnwG7H #HCV",
        topicId: 20,
        topic: "hepatitis, psoriasis, case, pediatric, dermatitis",
        topicProbability: 0.8374999999999982,
        created: "2017-07-09T10:00:01.000Z",
        sentiment: "positive"
    },
    {
        id: "884020381849444352",
        message: "RT @Celgene: Blogger Alisha tells all: \"Having a disease like psoriasis is humbling, you find strengths outside of just your looks\" #ShowMo<U+2026>",
        topicId: 25,
        topic: "psoriasis, treatment, arthritis, antiseptic, p4mhl7ckq9",
        topicProbability: 0.9113636363636357,
        created: "2017-07-08T10:04:17.000Z",
        sentiment: "neutral"
    }, {
        id: "884021569177227264",
        message: "RT @patientsrising: Thank you @DrBobGoldberg @feliciatemple @StaceyLWorthy @aimedalliance @RareDiseases @CureSarcoma @Celgene @IpsenGroup @<U+2026>",
        topicId: 30,
        topic: "psoriasis, tina, nature, health, front",
        topicProbability: 0.8916666666666656,
        created: "2017-07-07T10:09:01.000Z",
        sentiment: null
    },
    {
        id: "884022607653343232",
        message: "Ausdal Financial Partners Inc. Continues to Hold Stake in Bristol-Myers Squibb Company $BMY https://t.co/bqHVzbpy1B",
        topicId: 10,
        topic: "amgn, amgen, stake, sfmg, hepatitis",
        topicProbability: 0.5251771032239684,
        created: "2017-07-09T10:13:08.000Z",
        sentiment: "neutral"
    }
    , {
        id: "884023406445961216",
        message: "Specialist Information Systems Engineer - Automation @amgen US <U+2013> Florida <U+2013> Tampa #dotNET #AWS #Azure https://t.co/TuthOz8Ca5",
        topicId: 31,
        topic: "psoriasis, health, amgen, psorcoach, hospital",
        topicProbability: 0.9187499999999996,
        created: "2017-07-09T10:16:19.000Z",
        sentiment: "neutral"
    },
    {
        id: "88401217",
        message: "Specialist Information Systems Engineer - Automation @amgen US <U+2013> Florida <U+2013> Tampa #dotNET #AWS #Azure https://t.co/TuthOz8Ca5",
        topicId: 31,
        topic: "psoriasis, health, amgen, psorcoach, hospital",
        topicProbability: 0.9187499999999996,
        created: "2017-07-09T10:20:19.000Z",
        sentiment: "neutral"
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
                    return (<List.Item key={`item-${index}`} >
                        <Label style={{ background: entry.color }} horizontal />
                        <Checkbox label={entry.payload.payload.topic} onClick={() => props.onClick(entry.payload.payload)} />
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

    state = { selectedEntries: [] }

    /**
     * @function aggregateTopics
     * @param  {type} data Array of topic detection data
     * @return {Array} Aggregrated topic array
     */
    aggregateTopics = (data) => {
        var des = [...data];
        var aggr = dl.read(des, { type: 'json', parse: 'auto' });
        return (dl.groupby(['topicId', 'topic']).count().execute(aggr));
    }

    /**
     * @function aggregateSentiment
     * @param  {type} data Array of topic detection data
     * @return {Array} Aggregrated sentiment array
     */
    aggregateSentiment = (data) => {
        var des = [...data];
        var aggr = dl.read(des, { type: 'json', parse: 'auto' });
        return (dl.groupby(['sentiment']).count().execute(aggr));
    }

    /**
     * @function aggregateDate
     * @param  {type} data Array of topic detection data
     * @return {Array} Aggregrated date array, aggregrated by day
     */
    aggregateByDay = (data) => {
        console.log(data);
        var des = [...data];
        des.forEach((obj, index, array) => {
            array[index].created = new Date(array[index].created).setHours(0, 0, 0, 0)
        })
        var aggr = dl.read(des, { type: 'json', parse: 'auto' });
        var aggrCT = dl.groupby(['created', 'topicId']).count().execute(aggr);  //1. aggregrate by created time(C) and topicId(T)
        var aggrCCT = dl.groupby(['created']).execute(aggrCT);//2. aggregrate again to have created time(C) on the top level and values specify the timeline data(CT - see 1.)


        var final = new Array();
        aggrCCT.forEach((element) => {
            var data = new Object();
            element.values.forEach(value => {
                data[value.topicId] = value.count;
            })
            data.created = element.created;
            final.push(data);
        }, this);

        console.log(final);


        return (aggrCCT);
    }


    onCellClick = (entry, index) => {
        this.setState({
            selectedEntry: entry
        })
    }

    onTopicLegendClick = (data) => {

        var index = this.state.selectedEntries.findIndex(el => {
            return el.topicId == data.topicId;
        });
        if (index == -1) {
            this.setState({
                selectedEntries: [...this.state.selectedEntries, data]
            });
        } else {
            const prev = this.state.selectedEntries;
            this.setState({
                selectedEntries: [...prev.slice(0, index), ...prev.slice(index + 1)]
            });
        }
    }

    inState(id) {
        return this.state.selectedEntries.some(function (item) {
            return item.topicId === id;
        });
    }



    formatDate = (data) => {
        return moment(data).format("DD-MM-YYYY");
    }

    render() {
        const result = data;
        //console.log(JSON.stringify(result));
        const { selectedEntry } = this.state;

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

                aggregateDate = this.aggregateByDay(result.filter(element => {
                    return element.topicId === selectedEntry.topicId
                }));
            }

            return (
                <div className="result-pane">
                    {selectedEntry ? <Header size='large'>You selected: {selectedEntry.topic}</Header> : null}
                    <Grid stackable columns={3}>
                        <Grid.Row>
                            <Grid.Column mobile={16} tablet={8} computer={8}>
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
                                                <Legend content={renderTopicLegend} onClick={this.onTopicLegendClick} />
                                            </PieChart>
                                        </ResponsiveContainer >
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                            <Grid.Column mobile={16} tablet={8} computer={8}>
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
                                                    <Legend content={renderSentimentLegend} style={{ maxHeight: "250px !important", overflow: "auto" }} onClick={this.onLegendClick} />
                                                </PieChart>
                                            </ResponsiveContainer >
                                            : ""}
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                        </Grid.Row>
                        <Grid.Row>
                            <Grid.Column mobile={16} tablet={16} computer={8}>
                                <Card fluid className="result">
                                    <Card.Content header={"Timeline"} />
                                    <Card.Content>
                                        {this.state.selectedEntries ?
                                            <ResponsiveContainer height={400}>
                                                <LineChart height={400} data={this.aggregateByDay(result.filter(element => {
                                                    return this.inState(element.topicId);
                                                }))}
                                                    margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                                                    <XAxis dataKey="created" tickFormatter={this.formatDate} />
                                                    <YAxis />
                                                    <CartesianGrid />
                                                    <Tooltip />
                                                    <Legend />



                                                    {Object.keys(this.aggregateByDay(result.filter(element => {
                                                        return this.inState(element.topicId);
                                                    }))).forEach(key => {
                                                        return <Line type="monotone" dataKey={key.toString()} stroke="#8884d8" />
                                                    })}
                                                </LineChart>
                                            </ResponsiveContainer >
                                            : ""}
                                    </Card.Content>
                                </Card>
                            </Grid.Column>
                        </Grid.Row>
                        <Grid.Row>
                            <Grid.Column mobile={16} tablet={16} computer={16}>
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
                                                        <Table.Cell>{moment(tweet.created).format("DD-MM-YYYY hh:mm")}</Table.Cell>
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