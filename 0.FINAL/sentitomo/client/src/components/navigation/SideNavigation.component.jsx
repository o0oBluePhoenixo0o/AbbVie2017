import React, { Component } from "react";
import { NavLink } from "react-router-dom";
import { Menu, Image, Icon } from "semantic-ui-react";
import { withRouter } from 'react-router-dom';

class SideNavigation extends Component {

    render() {
        const { user, registerUser, loginUser, logoutUser, createEvent, events, match, ...props } = this.props;
        return (
            <Menu vertical className="mobile hidden sidebar-left" >
                <Menu.Item header><NavLink to={'/'}><Image src="/logo.png" /></NavLink></Menu.Item>
                <div style={{ padding: "20px" }}>
                    <NavLink to={match.url + '/dashboard'} activeClassName="active">
                        <Menu.Item
                            active={false}
                            link
                            name="dashboard" >
                            Dashboard
                        </Menu.Item>
                    </NavLink>
                    <NavLink to={match.url + '/events'} activeClassName="active">
                        <Menu.Item
                            active={false}
                            link
                            name="events" >
                            Events
                        </Menu.Item>
                    </NavLink>
                </div>
                <div className="grow" />
            </Menu >
        )
    }
}

export default withRouter(SideNavigation);
