import React from 'react';
import {
    gql,
    graphql,
} from 'react-apollo';
import { Table, Menu } from 'semantic-ui-react'

const TweetsList = ({ tweets, loading, error, loadMoreEntries }) => {
    if (loading) {
        return <div className="message success" data-component="message">Loading..<span className="close small"></span></div>;
    }
    if (error) {
        return <div className="message error" data-component="message">{error}<span className="close small"></span></div>;
    }

    if (!tweets) {
        return <div className="message error" data-component="message">Unable to fetch the data<span className="close small"></span></div>;
    }

    return (
        <div>
            <Table basic="very" stackable>
                <Table.Header>
                    <Table.Row>
                        <Table.HeaderCell>Id</Table.HeaderCell>
                        <Table.HeaderCell>Message</Table.HeaderCell>
                        <Table.HeaderCell>Created at</Table.HeaderCell>
                    </Table.Row>
                </Table.Header>
                <Table.Body>
                    {tweets.map(ch =>
                        (
                            <Table.Row key={ch.id}>
                                <Table.Cell>{ch.id}</Table.Cell>
                                <Table.Cell>{ch.message}</Table.Cell>
                                <Table.Cell>{ch.created}</Table.Cell>

                            </Table.Row>
                        )
                    )}
                </Table.Body>
                <Table.Footer>
                    <Table.Row>
                        <Table.HeaderCell colSpan="2">Total tweets</Table.HeaderCell>
                        <Table.HeaderCell>{tweets.length}</Table.HeaderCell>
                    </Table.Row>

                </Table.Footer>
            </Table>

            <Menu pagination>
                <Menu.Item name='Show more' onClick={() => loadMoreEntries()} />
            </Menu>
        </div>
    );
};

export const tweetsListQuery = gql`
  query TweetsListQuery($offset: Int, $limit: Int) {
    tweets(limit: $limit, offset: $offset) {
      id
      message
      created
    }
  }
`;

const ITEMS_PER_PAGE = 20;
const TweetsListQuery = graphql(tweetsListQuery, {
    options(props) {
        return {
            variables: {
                offset: 0,
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
})(TweetsList);


export default TweetsListQuery;
/*
export default graphql(tweetsListQuery, {
    options: { pollInterval: 5000 },
})(TweetsList);*/