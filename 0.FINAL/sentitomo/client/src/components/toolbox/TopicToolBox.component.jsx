import React, { Component } from 'react';
import { Button, Divider, Header } from 'semantic-ui-react'
import DayPicker, { DateUtils } from 'react-day-picker';
import moment from 'moment';
import 'react-day-picker/lib/style.css';
import {
    gql,
    graphql,
    withApollo
} from 'react-apollo';
import socket from "../../socket.js";


/**
 * @class TopicToolBox
 * @extends {React.Component}
 * @description Class for displaying the Toolbox for initiation the dynamic topic detection
 */
class TopicToolBox extends Component {

    state = {
        from: null,
        to: null,
        tweetsSize: 0
    };

    /**
    * @function handleDayClick
    * @param  {Object} day      
    * @param  {boolean} disabled Is the selected day disabled
    * @param  {boolean} selected Is the day which was clicked selected
    * @description Handles a click on the DayPicker component. Set the range state of this component and 
    * executes a GraphQL query to the server to get the count of selected Tweets.
    * @memberof TopicToolBox
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
                    console.log(response);
                    this.setState({
                        tweetsSize: response.data.tweetCount
                    })
                });
            });
        }
    };

    /**
     * @function handleResetClick
     * @param  {Event} e Click event
     * @description Resets the this.state.from and this.state.to
     * @memberof TopicToolBox
     * @return {void}
     */
    handleResetClick = e => {
        e.preventDefault();
        this.setState({
            from: null,
            to: null,
        });
    };

    /**
     * @function sendMessage
     * @param  {Object} message Message to send to the server
     * @description Sends a message to the server, to start the dynamic topic detection
     * @memberof TopicToolBox
     * @return {void}
     */
    sendMessage = message => {
        socket.emit('client:runTopicDetection', message)
    }

    render() {
        const { from, to, tweetsSize } = this.state;
        return (
            <div>
                <Header size='medium'>Initiate new topic clustering</Header>
                <p>First choose your date ranges in which you want to analyze your tweets</p>
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
                <p>Your bag will contain {tweetsSize} tweets. {tweetsSize < 1000 ? "Your bag need at least 1000 tweets to detect the topic dynamically" : null}</p>
                <Button disabled={!from && !to || from && !to || !from && to || tweetsSize < 1000} primary onClick={() => this.sendMessage({ from: from, to: to })}>Detect topics</Button>

                <Divider />
            </div>
        );
    }
}

export const tweetsListQuery = gql`
  query TweetsListQuery($startDate: Date, $endDate: Date) {
    tweets(startDate: $startDate, endDate: $endDate) {
      id
      message
      created
    }
  }
`;
const TopicToolBoxWithData = withApollo(TopicToolBox);



export default TopicToolBoxWithData;