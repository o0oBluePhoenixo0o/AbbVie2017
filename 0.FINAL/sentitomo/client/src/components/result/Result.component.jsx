import React, { Component } from 'react';
import { Segment, Table } from 'semantic-ui-react'


class Result extends Component {
    render() {
        const { result } = this.props;


        if (result) {
            console.log(result);
            return (
                <Segment>
                    <Table celled striped>
                        <Table.Header>
                            <Table.Row>
                                <Table.HeaderCell>Tweet ID</Table.HeaderCell>
                                <Table.HeaderCell>Topic ID</Table.HeaderCell>
                                <Table.HeaderCell>Topic Content</Table.HeaderCell>
                                <Table.HeaderCell>Probability</Table.HeaderCell>
                            </Table.Row>
                        </Table.Header>

                        <Table.Body>
                            {result.map((entry) => {
                                return <Table.Row>
                                    <Table.Cell>{entry.key}</Table.Cell>
                                    <Table.Cell>{entry.id}</Table.Cell>
                                    <Table.Cell>{entry.topic}</Table.Cell>
                                    <Table.Cell>{entry.probability}</Table.Cell>
                                </Table.Row>
                            })}
                        </Table.Body>
                    </Table>
                </Segment>
            );
        } else {
            return (
                <Segment>
                    No results
                </Segment>
            );
        }


    }
}

export default Result;