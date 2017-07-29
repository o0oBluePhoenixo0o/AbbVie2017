import React, { Component } from 'react';
import { Header, Grid, Menu, Segment } from 'semantic-ui-react'
import TopicToolBox from './TopicToolBox.component';

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
                        Manage all of the ML taks here
                    </Header.Subheader>
                </Header>
                <div>
                    <Menu pointing secondary>
                        <Menu.Item name='sentiment' active={activeItem === 'sentiment'} onClick={this.handleItemClick} />
                        <Menu.Item name='topic' active={activeItem === 'topic'} onClick={this.handleItemClick} />
                    </Menu>
                    <Segment >
                        {activeItem === "topic" ? <TopicToolBox /> : null}
                    </Segment></div>

            </Segment>
        );
    }
}

export default ToolBox;