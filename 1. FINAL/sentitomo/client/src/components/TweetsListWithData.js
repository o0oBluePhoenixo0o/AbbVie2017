import React from 'react';
import {
    gql,
    graphql,
} from 'react-apollo';


const TweetsList = ({ data: { loading, error, tweets } }) => {
    if (loading) {
        return <p>Loading ...</p>;
    }
    if (error) {
        return <p>{error.message}</p>;
    }

    return (
        <div className="channelsList">
            {tweets.map(ch =>
                (
                    <div key={ch.id} className="channel">
                        {ch.created}
                        {ch.message}
                    </div>
                )
            )}
        </div>
    );
};

export const tweetsListQuery = gql`
  query TweetsListQuery {
    tweets {
      id
      message
      created
    }
  }
`;

export default graphql(tweetsListQuery, {
    options: { pollInterval: 5000 },
})(TweetsList);