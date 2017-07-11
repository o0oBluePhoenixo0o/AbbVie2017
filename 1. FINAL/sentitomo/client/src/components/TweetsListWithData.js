import React from 'react';
import {
    gql,
    graphql,
} from 'react-apollo';


const TweetsList = ({ tweets, loading, error, loadMoreEntries }) => {
    if (loading) {
        return <div className="message success" data-component="message">Loading..<span className="close small"></span></div>;
    }
    if (error) {
        return <div className="message error" data-component="message">{error}<span className="close small"></span></div>;
    }

    return (
        <table>
            <thead>
                <tr>
                    <th>Id</th>
                    <th>Message</th>
                    <th>Created at</th>
                </tr>
            </thead>
            <tbody>
                {tweets.map(ch =>
                    (
                        <tr key={ch.id}>
                            <td>{ch.id}</td>
                            <td>{ch.message}</td>
                            <td>{ch.created}</td>

                        </tr>
                    )
                )}
            </tbody>
            <tfoot>
                <tr>
                    <td colSpan="2">Total tweets</td>
                    <td>{tweets.lenght}</td>
                </tr>
            </tfoot>
            <button className="button outline" onClick={() => loadMoreEntries()}>Button</button>
        </table>
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
                    // we will make an extra call to check if no more entries
                    console.log(previousResult);
                    if (!fetchMoreResult) { return previousResult; }
                    // push results (older messages) to end of messages list
                    return Object.assign({}, previousResult, {
                        // Append the new feed results to the old one
                        tweets: [...previousResult.tweets, ...fetchMoreResult.tweets],
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