import React, { Component } from 'react';
import { Button, Divider, Header } from 'semantic-ui-react'
import socket from "../../socket.js";


/**
 * @class WorkerToolBox
 * @extends {React.Component}
 * @description Class for displaying the Toolbox for stopping and starting the sentiment and topic detection workers on the server.
 */
class WorkerToolBox extends Component {

    state = {
        topicWorker: null,
        sentimentWorker: null,
    };


    componentDidMount() {
        socket.on('server:getWorkers', data => {
            this.setState({
                topicWorker: data.topicWorker,
                sentimentWorker: data.sentimentWorker
            })
        })
        setInterval(() => this.getWorkerState(), 5000)
    }

    /**
     * @function getWorkerState
     * @description Sends a message to the server, to get the status of the topic and sentiment workers
     * @memberof WorkerToolBox
     * @return {void}
     */
    getWorkerState = () => {
        socket.emit('client:getWorkers', null)
    }

    /**
    * @function toggleWorker
    * @param {String} worker Specifies which worker function to toggle
    * @description Sends a message to the server and toggles the state of the specified worker, either topic or sentiment
    * @memberof WorkerToolBox
    * @return {void}
    */
    toggleWorker = (worker) => {
        socket.emit('client:toggleWorker', {
            type: worker
        })
    }

    render() {
        const { topicWorker, sentimentWorker } = this.state;
        return (
            <div>
                <Button.Group>
                    {topicWorker ? <Button negative onClick={() => this.toggleWorker('topic')}>Stop topic worker</Button> : <Button positive onClick={() => this.toggleWorker('topic')}>Start topic worker</Button>}
                    {sentimentWorker ? <Button negative onClick={() => this.toggleWorker('sentiment')}>Stop sentiment worker</Button> : <Button positive onClick={() => this.toggleWorker('sentiment')}>Start sentiment worker</Button>}
                </Button.Group>
            </div>


        );
    }
}

export default WorkerToolBox;