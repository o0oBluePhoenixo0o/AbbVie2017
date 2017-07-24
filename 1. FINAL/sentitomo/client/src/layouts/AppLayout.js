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
import ToolBox from '../components/toolbox/ToolBox.component.jsx';


export const AppLayout = ({ match }) => (
    <div className="">
        <main className="main">
            <SideNavigation />
            <Container className="main-content">
                <Switch>
                    <Route exact path={match.url + '/dashboard'} component={Dashboard} />
                    <Route path={match.url + '/toolbox'} component={ToolBox} />
                </Switch>
            </Container>
        </main>
    </div>
);

export default AppLayout;
