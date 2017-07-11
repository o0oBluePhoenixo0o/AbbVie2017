import React, { Component } from 'react';
import logo from './styles/logo.svg';
import './styles/App.css';

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
        <div className="App">
          <div className="navbar">React + GraphQL Tutorial</div>
          <TweetsListWithData />
        </div>
      </ApolloProvider>
    );
  }
}

export default App;