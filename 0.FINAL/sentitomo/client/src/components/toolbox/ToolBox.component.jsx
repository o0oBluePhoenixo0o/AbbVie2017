import React, { Component } from 'react';
import { Header, Menu, Segment } from 'semantic-ui-react'
import TopicToolBox from './TopicToolBox.component';
import WorkerToolBox from './WorkerToolBox.component';

/**
 * @class ToolBox
 * @extends {React.Component}
 * @description Class for displaying the Toolbox
 */
class ToolBox extends Component {

    state = { activeItem: 'topic' }

    handleItemClick = (e, { name }) => this.setState({ activeItem: name })

    render() {
        const { activeItem } = this.state
        return (
            <Segment basic>
                <Header size='huge'>
                    ToolBox
                    <Header.Subheader>
                        Manage all server tasks here
                    </Header.Subheader>
                </Header>
                <div>
                    <Menu pointing secondary>
                        <Menu.Item name='topic' active={activeItem === 'topic'} onClick={this.handleItemClick} />
                        <Menu.Item name='worker' active={activeItem === 'worker'} onClick={this.handleItemClick} />
                    </Menu>
                    <Segment >
                        {activeItem === "topic" ? <TopicToolBox /> : null}
                        {activeItem === "worker" ? <WorkerToolBox /> : null}
                    </Segment>
                </div>

            </Segment>
        );
    }
}

export default ToolBox;