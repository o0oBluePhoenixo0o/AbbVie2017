import React, { Component } from 'react';
import {
    gql,
    graphql,
    withApollo
} from 'react-apollo';

import { Button, Card, Divider, Header, Dimmer, Grid, Loader, Message, Segment } from 'semantic-ui-react';
import DayPicker, { DateUtils } from 'react-day-picker';
import moment from 'moment';
import TweetsList from './TweetsList.component';
import Timeline from './Timeline.component';
import Result from '../result/Result.component'



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
        data: null
    };


    /**
     * @function handleDayClick
     * @param  {Object} day      
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
                        count(startDate: $startDate, endDate: $endDate)
                    }
                `,
                    variables: { startDate: this.state.from, endDate: this.state.to },
                }).then(response => {
                    this.setState({
                        tweetsSize: response.data.count
                    })
                });
            });
        }
    };


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
                        }
                    }
                `,
            variables: { startDate: this.state.from, endDate: this.state.to },
        }).then(response => {
            this.setState({
                data: response,
                loading: false,
            })
        });
    }

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
                    <Loader>Set view range</Loader>
                </Dimmer>
                <Grid columns={2}>
                    <Grid.Row>
                        <Grid.Column>
                            <Card fluid>
                                <Card.Content header={"Aggregrated Topics"} />
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
                </Grid>





                <Result result={this.state.data ? this.state.data.data.tweets : null} />
            </Segment>
        );
    }
}
const DashboardWithData = withApollo(Dashboard);
export default withApollo(Dashboard);