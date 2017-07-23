import React, { Component } from 'react';
import TweetsListWithData from './TweetsListWithData.component';
import {
    ApolloClient,
    ApolloProvider,
    createNetworkInterface, // <-- this line is new!
} from 'react-apollo';
const networkInterface = createNetworkInterface({ uri: 'http://localhost:8080/graphql' });
const client = new ApolloClient({
    networkInterface,
});


class Dashboard extends Component {
    render() {
        return (
            <div>
                <ApolloProvider client={client}>
                    <TweetsListWithData />
                </ApolloProvider>
            </div>
        );
    }
}

export default Dashboard;