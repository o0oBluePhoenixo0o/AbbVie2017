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
                <Grid>
                    <Grid.Column width={4}>
                        <Menu fluid vertical tabular>
                            <Menu.Item name='topic' active={activeItem === 'topic'} onClick={this.handleItemClick} />
                            <Menu.Item name='sentiment' active={activeItem === 'sentiment'} onClick={this.handleItemClick} />
                            <Menu.Item name='database' active={activeItem === 'database'} onClick={this.handleItemClick} />
                        </Menu>
                    </Grid.Column>

                    <Grid.Column stretched width={12}>
                        <Segment>
                            {activeItem === "topic" ? <TopicToolBox /> : null}
                        </Segment>
                    </Grid.Column>
                </Grid>
            </Segment>
        );
    }
}

export default ToolBox;