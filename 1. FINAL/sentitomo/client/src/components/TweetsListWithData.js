import React from 'react';
import {
    gql,
    graphql,
} from 'react-apollo';

import styled from 'styled-components';

const TweetsListWrapper = styled.div`
    max-height: 100vh;
    overflow:auto;
    margin-top:64px;
`;

const TweetsList = ({ tweets, loading, error, loadMoreEntries }) => {
    if (loading) {
        return <TweetsListWrapper><div className="message success" data-component="message">Loading..<span className="close small"></span></div></TweetsListWrapper>;
    }
    if (error) {
        return <TweetsListWrapper><div className="message error" data-component="message">{error}<span className="close small"></span></div></TweetsListWrapper>;
    }

    if (!tweets) {
        return <TweetsListWrapper><div className="message error" data-component="message">Unable to fetch the data<span className="close small"></span></div></TweetsListWrapper>;
    }

    return (
        <TweetsListWrapper>
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
                        <td>{tweets.length}</td>
                    </tr>

                </tfoot>
            </table>

            <nav className="pagination pager align-center">
                <ul>
                    <li className="prev"><a onClick={() => loadMoreEntries()}>Show More</a></li>
                </ul>
            </nav>
        </TweetsListWrapper>
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