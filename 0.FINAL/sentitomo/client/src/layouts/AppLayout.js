import React from "react";
import {
    Route,
    Switch,
    withRouter
} from "react-router-dom";
import "semantic-ui-css/semantic.min.css";
import "../styles/main.css";
import socket from "../socket.js";
import { Container, Dimmer, Loader } from "semantic-ui-react";
import SideNavigation from '../components/navigation/SideNavigation.component.jsx';
import TopNavigation from '../components/navigation/TopNavigation.component.jsx'
import NotificationSystem from 'react-notification-system';
import Dashboard from '../components/dashboard/Dashboard.component.jsx';
import ToolBox from '../components/toolbox/ToolBox.component.jsx';
import Result from '../components/result/Result.component.jsx';

class Applayout extends React.Component {


    state = { loading: false, result: null }


    componentDidMount() {
        socket.on('server:response', data => {
            this.notificationSystem.addNotification({
                message: data.message,
                level: data.level
            });
            this.setState({
                loading: !data.finished,
                result: data.result,
                html: data.pyhtonLDAHTML
            });

            if (data.result) {
                this.props.history.push('/app/result');
            }
        });

        socket.on('connect_error', data => {
            this.notificationSystem.addNotification({
                message: "Something went wrong",
                level: 'error'
            });
            this.setState({
                loading: false,
                result: null
            });
        });
    }

    render() {
        const { match } = this.props;
        const { loading } = this.state;
        return (
            <div className="" >
                <main className="main">
                    <SideNavigation />
                    <TopNavigation />
                    <NotificationSystem ref={(ref) => this.notificationSystem = ref} />
                    <Container className="main-content" fluid>
                        <Dimmer active={loading}>
                            <Loader>Detecting topics</Loader>
                        </Dimmer>
                        <Switch>
                            <Route exact path={match.url + '/dashboard'} component={Dashboard} />
                            <Route path={match.url + '/toolbox'} component={ToolBox} />
                            <Route path={match.url + '/result'} render={() => <Result result={this.state.result} html={this.state.html} />} />

                        </Switch>
                    </Container>
                </main>
            </div >
        )
    }
}

export default withRouter(Applayout)
