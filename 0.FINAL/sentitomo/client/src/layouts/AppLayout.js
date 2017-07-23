import React from "react";
import {
    Route,
    Switch
} from "react-router-dom";

import "semantic-ui-css/semantic.min.css";
import "../styles/main.css";
import { Container } from "semantic-ui-react";
import SideNavigation from '../components/navigation/SideNavigation.component.jsx';
import Dashboard from '../components/dashboard/Dashboard.component.jsx';




const Placeholder = () => {
    return (
        <p>Placeholder</p>
    )
}



export const AppLayout = ({ match }) => (
    <div className="">
        <main className="main">
            <SideNavigation />
            <Container className="main-content">
                <Switch>
                    <Route exact path={match.url + '/'} component={Placeholder} />
                    <Route path={match.url + '/dashboard'} component={Dashboard} />
                </Switch>
            </Container>
        </main>
    </div>
);

export default AppLayout;
