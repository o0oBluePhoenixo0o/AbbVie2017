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


class TopicToolBox extends Component {

    state = {
        from: null,
        to: null,
        tweetsSize: 0
    };

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

    handleResetClick = e => {
        e.preventDefault();
        this.setState({
            from: null,
            to: null,
        });
    };

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