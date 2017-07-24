import React from 'react';
import ReactDOM from 'react-dom';
import {
    BrowserRouter as Router,
    Route,
    Switch
} from "react-router-dom";
import registerServiceWorker from './registerServiceWorker';
import AppLayout from "./layouts/AppLayout.js";
import {
    ApolloClient,
    ApolloProvider,
    createNetworkInterface, // <-- this line is new!
} from 'react-apollo';

const networkInterface = createNetworkInterface({ uri: 'http://localhost:8080/graphql' });
const client = new ApolloClient({
    networkInterface,
});


const Main = () => {
    return (
        <Switch>
            <Route path="/app" component={AppLayout} />
        </Switch>
    )
}


ReactDOM.render(
    <Router>
        <ApolloProvider client={client}>
            <Main></Main>
        </ApolloProvider>
    </Router>,
    document.getElementById("root")
);
registerServiceWorker();