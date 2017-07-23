import React from 'react';
import ReactDOM from 'react-dom';
import {
    BrowserRouter as Router,
    Route,
    Switch
} from "react-router-dom";
import registerServiceWorker from './registerServiceWorker';
import AppLayout from "./layouts/AppLayout.js";



const Main = () => {
    return (
        <Switch>
            <Route path="/app" component={AppLayout} />
        </Switch>
    )
}


ReactDOM.render(
        <Router>
            <Main></Main>
        </Router>,
        document.getElementById("root")
    );
registerServiceWorker();