import React, { Component } from 'react';
import {
    gql,
    graphql,
    withApollo
} from 'react-apollo';

import { Dimmer, Grid, Loader, Message, Segment } from 'semantic-ui-react';
import TweetsList from './TweetsList.component';
import Timeline from './Timeline.component';


const Dashboard = ({ tweets, loading, error, loadMoreEntries }) => {
    if (loading) {
        return <Dimmer active>
            <Loader indeterminate>Getting your data ready!</Loader>
        </Dimmer>;
    }
    if (error) {
        return <Message error>
            <Message.Header>We're sorry, something went wrong!</Message.Header>
            <p>{error}</p>
        </Message>;
    }
    if (!tweets) {
        return <Message warning>
            <Message.Header>We're sorry, something happened</Message.Header>
            <p>Unable to fetch the data,</p>
        </Message>;
    }
    return (
        <Segment className="dashboard" basic>
            <Grid stackable>
                <Grid.Row columns={2}>
                    <Grid.Column>
                        <TweetsList tweets={tweets} loadMoreEntries={loadMoreEntries} />
                    </Grid.Column>
                    <Grid.Column>
                        <div>Here comes topic? </div>
                    </Grid.Column>
                </Grid.Row>
                <Grid.Row columns={1}>
                    <Grid.Column>
                        <Timeline tweets={tweets} />
                    </Grid.Column>
                </Grid.Row>
            </Grid>

        </Segment>
    );

}


export const tweetsListQuery = gql`
  query TweetsListQuery($offset: Int, $limit: Int) {
                tweets(limit: $limit, offset: $offset) {
                id
      message
            created
      keyword
      sentiment {
                sentiment
            }
            }
  }
`;

const ITEMS_PER_PAGE = 20;
const DashboadWithData = graphql(tweetsListQuery, {
    options(props) {
        return {
            variables: {
                offset: 1000,
                limit: ITEMS_PER_PAGE,
            },
        };
    },
    props: ({ data: { fetchMore, loading, tweets } }) => ({
        loading,
        tweets,
        loadMoreEntries() {
            return fetchMore({
                // query: ... (you can specify a different query.
                // GROUP_QUERY is used by default)
                variables: {
                    // We are able to figure out offset because it matches
                    // the current messages length
                    offset: tweets.length,
                },
                updateQuery: (previousResult, { fetchMoreResult }) => {
                    console.log(previousResult)
                    // we will make an extra call to check if no more entries
                    if (!fetchMoreResult) { return previousResult; }
                    // push results (older messages) to end of messages list
                    return Object.assign({}, previousResult, {
                        // Append the new feed results to the old one
                        tweets: [...previousResult.tweets, ...fetchMoreResult.tweets],
                        loading: loading
                    });
                },
            });
        },
    }),
})(Dashboard);


export default withApollo(DashboadWithData);