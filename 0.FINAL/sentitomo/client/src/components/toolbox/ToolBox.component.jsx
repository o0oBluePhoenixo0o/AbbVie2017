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
                <Grid stackable>
                    <Grid.Column width={4} only="large screen">
                        <Menu fluid vertical tabular stackable>
                            <Menu.Item name='topic' active={activeItem === 'topic'} onClick={this.handleItemClick} />
                            <Menu.Item name='sentiment' active={activeItem === 'sentiment'} onClick={this.handleItemClick} />
                            <Menu.Item name='database' active={activeItem === 'database'} onClick={this.handleItemClick} />
                        </Menu>
                    </Grid.Column>
                    <Grid.Column width={4} only="computer tablet">
                        <Menu fluid vertical tabular stackable>
                            <Menu.Item name='topic' active={activeItem === 'topic'} onClick={this.handleItemClick} />
                            <Menu.Item name='sentiment' active={activeItem === 'sentiment'} onClick={this.handleItemClick} />
                            <Menu.Item name='database' active={activeItem === 'database'} onClick={this.handleItemClick} />
                        </Menu>
                    </Grid.Column>
                    <Grid.Column width={4} only="mobile">
                        <Menu fluid stackable>
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