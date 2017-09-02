import React, { Component } from "react";
import PropTypes from 'prop-types';
import { NavLink } from "react-router-dom";
import { Header, Menu, Image } from "semantic-ui-react";
import { withRouter } from 'react-router-dom';

/**
 * @class SideNavigation
 * @extends {React.Component}
 * @description Class for displaying the side navigation of the app if viewed on devices not mobile
 */
class SideNavigation extends Component {

    render() {
        const { match } = this.props;
        return (
            <Menu vertical className="mobile hidden sidebar-left" >
                <Menu.Item header>
                    <NavLink to={'/app'}>
                        <Header style={{ color: "#fff" }}>Sentitomo</Header>
                    </NavLink>
                </Menu.Item>
                <div style={{ padding: "20px" }}>
                    <NavLink to={match.url + '/dashboard'} activeClassName="active">
                        <Menu.Item
                            active={false}
                            link
                            name="dashboard" >
                            Dashboard
                        </Menu.Item>
                    </NavLink>
                    <NavLink to={match.url + '/toolbox'} activeClassName="active">
                        <Menu.Item
                            active={false}
                            link
                            name="toolbox" >
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
    match: PropTypes.object
}

export default withRouter(SideNavigation);
