import React, { Component } from "react";
import PropTypes from 'prop-types';
import { NavLink } from "react-router-dom";
import { Menu, Image } from "semantic-ui-react";
import { withRouter } from 'react-router-dom';
import Icon from '../Icon.component';

/**
 * @class SideNavigation
 * @extends {React.Component}
 * @description Class for displaying the side navigation of the app if viewed on devices not mobile
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



SideNavigation.propTypes = {
    /** {Object} The match object from react-router */
    match: PropTypes.Object
}

export default withRouter(SideNavigation);
