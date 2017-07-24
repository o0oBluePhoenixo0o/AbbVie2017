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



import io from 'socket.io-client'
let socket = io(`http://localhost:8080`)

class TopicToolBox extends Component {

    state = {
        from: null,
        to: null,
        tweetsSize: 0
    };

    handleDayClick = day => {
        const range = DateUtils.addDayToRange(day, this.state);
        this.setState(range, () => {
            this.props.client.query({
                query: gql`
                    query TweetsListQuery($startDate: Date, $endDate: Date) {
                        tweets(startDate: $startDate, endDate: $endDate) {
                            id
                            message
                            created
                        }
                    }
                `,
                variables: { startDate: this.state.from, endDate: this.state.to },
            }).then(data => {
                this.setState({
                    tweetsSize: data.data.tweets.length
                })
            });
            //socket.emit('client:checkTweetBagSize', { from: this.state.from, to: this.state.to })
        });

    };
    handleResetClick = e => {
        e.preventDefault();
        this.setState({
            from: null,
            to: null,
        });
    };


    componentDidMount() {
        socket.on(`server:checkTweetBagSize`, data => {
            this.setState({
                tweetsSize: data.tweetsSize
            })
        })
    }

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
                <p>Your bag will contain {tweetsSize} tweets.</p>
                <Button disabled={!from && !to || from && !to || !from && to} primary onClick={() => this.sendMessage({ from: from, to: to })}>Detect topics</Button>

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