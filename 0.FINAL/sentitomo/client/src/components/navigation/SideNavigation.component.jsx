import React, { Component } from "react";
import { NavLink } from "react-router-dom";
import { Menu, Image } from "semantic-ui-react";
import Icon from '../Icon.component';
import { withRouter } from 'react-router-dom';

/**
 * @class SideNavigation
 * @extends {Component}
 * @description Side navigation for all import sections of the app
 */
class SideNavigation extends Component {

    render() {
        const { match, ...props } = this.props;
        return (
            <Menu vertical className="mobile hidden sidebar-left" >
                <Menu.Item header ><NavLink to={'/app'}><Image src="/logo.png" style={{ margin: "0 auto" }} /></NavLink></Menu.Item>
                <div style={{ padding: "20px" }}>
                    <NavLink to={match.url + '/dashboard'} activeClassName="active">
                        <Menu.Item
                            active={false}
                            link
                            name="dashboard" >
                            <Icon name='home' large />
                            Dashboard
                        </Menu.Item>
                    </NavLink>
                    <NavLink to={match.url + '/toolbox'} activeClassName="active">
                        <Menu.Item
                            active={false}
                            link
                            name="toolbox" >
                            <Icon name='settings' large />
                            Toolbox
                        </Menu.Item>
                    </NavLink>
                </div>
                <div className="grow" />
            </Menu >
        )
    }
}

export default withRouter(SideNavigation);
