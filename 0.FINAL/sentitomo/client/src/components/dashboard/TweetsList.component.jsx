import React from 'react';
import { Segment, Table, Menu } from 'semantic-ui-react'

const TweetsList = ({ tweets, loadMoreEntries }) => {
    return (
        <Segment raised style={{ maxHeight: "500px", overflow: "auto" }}>
            <Table basic="very" stackable>
                <Table.Header>
                    <Table.Row>
                        <Table.HeaderCell>Id</Table.HeaderCell>
                        <Table.HeaderCell>Message</Table.HeaderCell>
                        <Table.HeaderCell>Created at</Table.HeaderCell>
                    </Table.Row>
                </Table.Header>
                <Table.Body>
                    {tweets.map(ch =>
                        (
                            <Table.Row key={ch.id}>
                                <Table.Cell>{ch.id}</Table.Cell>
                                <Table.Cell>{ch.message}</Table.Cell>
                                <Table.Cell>{ch.created}</Table.Cell>

                            </Table.Row>
                        )
                    )}
                </Table.Body>
                <Table.Footer>
                    <Table.Row>
                        <Table.HeaderCell colSpan="2">Total tweets</Table.HeaderCell>
                        <Table.HeaderCell>{tweets.length}</Table.HeaderCell>
                    </Table.Row>

                </Table.Footer>
            </Table>

            <Menu pagination>
                <Menu.Item name='Show more' onClick={() => loadMoreEntries()} />
            </Menu>
        </Segment>
    );
};


export default TweetsList;
/*
export default graphql(tweetsListQuery, {
    options: { pollInterval: 5000 },
})(TweetsList);*/