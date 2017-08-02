import React, { Component } from 'react';
import { Card, Grid, Label, List, Segment, Table } from 'semantic-ui-react'
import { PieChart, Pie, Cell, Legend, Tooltip, ResponsiveContainer } from 'recharts';
import randomColor from 'randomcolor';

/*const data = [

    { key: "1357670736", topicId: 10, topic: "abbvie, collaboration, research, announce, m2gen", topicProbability: 0.8916666666666664 },
    { key: "16549201", topicId: 6, topic: "hepatitis, drug, european, country, civil", topicProbability: 0.8781249999999988 },
    { key: "2272625320", topicId: 38, topic: "humira, click, upper, right, page", topicProbability: 0.9113636363636356 },
    { key: "250638519", topicId: 4, topic: "patent, hepatitis, drug, challenge, join", topicProbability: 0.8916666666666658 },
    { key: "3226844125", topicId: 37, topic: "talk, johnson, cure, jmedchem, humira", topicProbability: 0.9024999999999991 },
    { key: "3304497570", topicId: 9, topic: "amgen, drug, cocoon, space, labcentral", topicProbability: 0.8916666666666656 },
    { key: "3381111885", topicId: 34, topic: "hepatitis, health, amgen, medicine, cost", topicProbability: 0.9024999999999991 },
    { key: "370881448", topicId: 32, topic: "join, research, share, myers, regrowz", topicProbability: 0.7709713413149403 },
    { key: "4912076385", topicId: 23, topic: "psoriasis, arthritis, rheumatoid, heal, fibromyalgia", topicProbability: 0.9024999999999999 },
    { key: "589481114", topicId: 2, topic: "treatment, hepatitis, book, free, amazon", topicProbability: 0.6050000339578792 },
    { key: "767000000000000000", topicId: 28, topic: "humira, johnson, help, psoriasis, davis", topicProbability: 0.8204545454545444 },
    { key: "77779419", topicId: 40, topic: "amgen, johnson, pain, parkerici, file", topicProbability: 0.4321428723981599 },
    { key: "84081850", topicId: 31, topic: "hepatitis, humira, torus, holobiome, cocoon", topicProbability: 0.9113636363636357 },
    { key: "841000000000000000", topicId: 26, topic: "hepatitis, squibb, value, pfizers, center", topicProbability: 0.9303571428571424 },
    { key: "842000000000000000", topicId: 24, topic: "hepatitis, patient, abbvie, nhttps, support", topicProbability: 0.8916666666666664 },
    { key: "843000000000000000", topicId: 14, topic: "rheumatotopicId, arthritis, hepatitis, john, amgn", topicProbability: 0.8374999999999995 },
    { key: "844000000000000000", topicId: 23, topic: "psoriasis, arthritis, rheumatotoid, heal, fibromyalgia", topicProbability: 0.4811737000560836 },
    { key: "845000000000000000", topicId: 29, topic: "hepatitis, treatment, cancer, half, lower", topicProbability: 0.8916666666666655 },
    { key: "846000000000000000", topicId: 14, topic: "rheumatotopicId, arthritis, hepatitis, john, amgn", topicProbability: 0.8049999999999994 },
    { key: "846676271023165440", topicId: 16, topic: "drug, hepatitis, report, hepc, amgens", topicProbability: 0.8781249999999989 },
    { key: "846693954485653504", topicId: 17, topic: "hepatitis, johnson, kill, amgen, dwayne", topicProbability: 0.9024999999999995 },
    { key: "846695458793762816", topicId: 6, topic: "hepatitis, drug, european, country, civil", topicProbability: 0.7805555555555546 },
    { key: "846696315727765504", topicId: 26, topic: "hepatitis, squibb, value, pfizers, center", topicProbability: 0.4333382809911925 },
    { key: "846700954934165504", topicId: 4, topic: "patent, hepatitis, drug, challenge, join", topicProbability: 0.8607142857142851 },
    { key: "846702174021279744", topicId: 26, topic: "hepatitis, squibb, value, pfizers, center", topicProbability: 0.3791664958144195 },
    { key: "846702453101940736", topicId: 40, topic: "amgen, johnson, pain, parkerici, file", topicProbability: 0.9113636363635268 },
];*/


var colors = [
    "#462446", "#B05F6D", "#EB6B56", "#FFC153", "#47B39D", "#E0E4CC", "#7BB0A6", "#1DABB8", "#BADA55", "#FF6766",
    "#953163", "#8870FF", "#2C82C9", "#F1654C", "#83D6DE", "#EEE657", "#3E4651", "#8A2D3C", "#3C3741"];



const renderLegend = (props) => {
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



class CustomToolTip extends Component {
    render() {
        const { active } = this.props;

        if (active) {
            const { payload, label } = this.props;
            return (
                <Card className="custom-tooltip">
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



class Result extends Component {



    state = { selectedEntry: null }





    aggregateTopics = (data) => {
        var topicAggregate = new Array();
        for (var i = 0; i < data.length; i++) {
            var orig = data[i];


            var topicAggregateObj = {
                topicId: orig.topicId,
                topic: orig.topic,
                value: 1
            }

            var found = false;
            for (var j = 0; j < topicAggregate.length; j++) {
                if (topicAggregate[j].topicId == topicAggregateObj.topicId) {
                    topicAggregate[j].value = topicAggregate[j].value + 1;
                    found = true;
                }
            }
            if (!found) {
                topicAggregate.push(topicAggregateObj);
            }



        }
        return topicAggregate;
    }


    onCellClick = (entry, index) => {
        console.log("clicked")
        console.log(entry.payload);
        this.setState({
            selectedEntry: entry
        })
    }

    render() {
        const { result } = this.props;


        //TODO: Check legends height
        if (result) {
            var aggregatedTopics = this.aggregateTopics(result).sort((a, b) => { return a.value - b.value });
            var colors = randomColor({
                count: aggregatedTopics.length,
                hue: 'random', luminosity: "random", seed: 123412
            });
            return (

                <Grid>
                    <Grid.Row>
                        <Grid.Column width={8}>
                            <Segment>
                                <div style={{ height: "1000px" }}>
                                    <ResponsiveContainer>
                                        <PieChart>
                                            <Pie data={aggregatedTopics} dataKey="value" fill="#8884d8" label onClick={(entry, index) => this.onCellClick(entry, index)}>
                                                {
                                                    aggregatedTopics.map((entry, index) => (
                                                        <Cell key={`cell-${index}`} fill={colors[index]} />
                                                    ))
                                                }
                                            </Pie>
                                            <Tooltip content={<CustomToolTip />} />
                                            <Legend content={renderLegend} style={{ maxHeight: "500px !important", overflow: "auto" }} />
                                        </PieChart>
                                    </ResponsiveContainer >
                                </div>

                            </Segment>
                        </Grid.Column>
                        <Grid.Column width={8}>
                            <Segment>
                                <p>You have selected: {this.state.selectedEntry ? this.state.selectedEntry.payload.topic : ""}</p>
                            </Segment>
                        </Grid.Column>
                    </Grid.Row>

                </Grid>
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