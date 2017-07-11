import React, { Component } from 'react';
import logo from './styles/logo.svg';
import './styles/kube.css';

import TweetsListWithData from './components/TweetsListWithData.js';

import {
  ApolloClient,
  ApolloProvider,
  createNetworkInterface, // <-- this line is new!
} from 'react-apollo';

const networkInterface = createNetworkInterface({ uri: 'http://localhost:8080/graphql' });
const client = new ApolloClient({
  networkInterface,
});






class App extends Component {
  render() {
    return (
      <ApolloProvider client={client}>
        <div className="row">
          <div className="col col-10">
            <h1 className="title">ALl tweets</h1>
            <TweetsListWithData />
          </div>
          <div className="col col-2">
            Test
          </div>
        </div>

      </ApolloProvider>
    );
  }
}

export default App;