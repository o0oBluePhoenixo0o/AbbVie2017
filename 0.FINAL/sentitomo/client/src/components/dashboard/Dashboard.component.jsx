import React from 'react';
import {
    gql,
    graphql,
    withApollo
} from 'react-apollo';

import { Button, Card, Header, Dimmer, Grid, Loader, Segment } from 'semantic-ui-react';
import DayPicker, { DateUtils } from 'react-day-picker';
import moment from 'moment';
import Result from '../result/Result.component'
import socket from "../../socket.js";



/**
 * @class Dashboard
 * @extends {React.Component}
 * @description Class for displaying the main dashboard
 */
class Dashboard extends React.Component {


    state = {
        from: null,
        to: null,
        tweetsSize: 0,
        data: new Object()
    };


    componentDidMount() {
        socket.on('server:getTrendsForRange', data => {
            console.log("result from the server trend");
            var newState = this.state.data;
            newState.trend = data.result ? data.result : [];
            this.setState({
                data: newState,
                loading: false
            })
        });
    }

    /**
     * @function handleDayClick
     * @param  {Object} day Selected day
     * @param  {boolean} disabled Is the selected day disabled
     * @param  {boolean} selected Is the day which was clicked selected
     * @description Handles a click on the DayPicker component. Set the range state of this component and 
     * executes a GraphQL query to the server to get the count of selected Tweets.
     * @memberof Dashboard
     * @return {void} 
     */
    handleDayClick = (day, { disabled, selected }) => {
        if (!disabled) {
            const range = DateUtils.addDayToRange(day, this.state);
            this.setState(range, () => {
                this.props.client.query({
                    query: gql`
                    query CountQuery($startDate: Date, $endDate: Date) {
                        tweetCount(startDate: $startDate, endDate: $endDate)
                    }
                `,
                    variables: { startDate: this.state.from, endDate: this.state.to },
                }).then(response => {
                    this.setState({
                        tweetsSize: response.data.tweetCount
                    })
                });
            });
        }
    };


    /**
     * @function loadTweets
     * @desc Loads tweets from the GraphQL API and displays them based on the selected start and end date. After 
     * retrieving the tweets a message is sent to server to detect the trends based on the selected time. When also this
     * result is gathered API and trend detection array get merged and set as the new component state.
     * @return {void}
     */
    loadTweets() {
        this.setState({
            loading: true,
        })
        this.props.client.query({
            query: gql`
                    query TweetsQuery($startDate: Date, $endDate: Date) {
                        tweets(startDate: $startDate, endDate: $endDate){
                            id
                            message
                            created
                            hashtags
                            sentiment{
                                sentiment
                            }
                            topic{
                                topicId
                                topicContent
                                probability
                            }
                        }
                    }
                `,
            variables: { startDate: this.state.from, endDate: this.state.to },
        }).then(response => {

            var tweets = JSON.parse(JSON.stringify(response.data.tweets));

            //flatten array
            tweets.forEach(tweet => {
                tweet.sentiment = tweet.sentiment ? tweet.sentiment.sentiment : null;
                tweet.topicId = tweet.topic ? tweet.topic.topicId : null;
                tweet.topicProbability = tweet.topic ? tweet.topic.probability : null;
                tweet.topic = tweet.topic ? tweet.topic.topicContent : null;
            })

            var newState = this.state.data;
            newState.tweets = tweets;

            this.setState({
                data: newState
            })
            socket.emit('client:getTrendsForRange', {
                from: this.state.from,
                to: this.state.to
            })
        });
    }

    /**
     * Handles the click on the 'reset' text when the user selects dates
     */
    handleResetClick = e => {
        e.preventDefault();
        this.setState({
            from: null,
            to: null,
        });
    };


    render() {

        const { from, to, tweetsSize, loading, data } = this.state;

        return (
            <Segment className="dashboard" basic>
                <Dimmer active={loading}>
                    <Loader>Set view range and preparing data</Loader>
                </Dimmer>
                <Grid columns={1}>
                    <Grid.Row>
                        <Grid.Column>
                            <Card fluid>
                                <Card.Content header={"Tweet selection"} />
                                <Card.Content>
                                    <Header size='medium'>Show the tweets you want</Header>
                                    <p>First choose your date ranges to view your tweets</p>
                                    <DayPicker
                                        numberOfMonths={2}
                                        selectedDays={[from, { from, to }]}
                                        onDayClick={this.handleDayClick}
                                        fixedWeeks
                                        disabledDays={{ after: new Date() }}
                                    />
                                    {!from && !to && <p>Please select the <strong>first day</strong>.</p>}
                                    {from && !to && <p>Please select the <strong>last day</strong>.</p>}
                                    {from &&
                                        to &&
                                        <p>
                                            You chose from
                                            {' '}
                                            {moment(from).format('L')}
                                            {' '}
                                            to
                                            {' '}
                                            {moment(to).format('L')}
                                            .
                                            {' '}<a href="." onClick={this.handleResetClick}>Reset</a>
                                        </p>}
                                    <p>You will view {tweetsSize} tweets. </p>
                                    <Button primary onClick={() => this.loadTweets()}>View tweets</Button>

                                </Card.Content>
                            </Card>
                        </Grid.Column>
                    </Grid.Row>
                    <Grid.Column>
                        <Grid.Row>
                            <Result data={this.state.data.trend ? this.state.data : null} withLDA={false} />
                        </Grid.Row>
                    </Grid.Column>
                </Grid>
            </Segment>
        );
    }
}
export default withApollo(Dashboard);