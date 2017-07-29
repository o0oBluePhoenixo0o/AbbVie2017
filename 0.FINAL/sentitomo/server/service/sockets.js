/** @module Sockets */
import SocketIO from 'socket.io';
import { detectTopicDynamic, detectTopicStatic } from '../ML/ml_wrapper';
import { Tweet } from '../data/connectors';


/**
 * @function listenToSockets
 * @param  {Object} httpServer Express httpServer instance
 * @description Start up webserver sockets to allow a bidrectional communication between client and server. 
 * <br />  <strong>Possible events: </strong>
 *      <ul>
 *          <li>client:runTopicDetection - Runs the topic detection method with specified time range, invoked from the client</li>
 *          <li>server:response - sends a status repsonse from server down to the client</li>
 *      </ul>
 * @return {void} 
 */
export function listenToSockets(httpServer) {
    var io = new SocketIO(httpServer);
    io.on('connection', function (socket) {
        socket.emit('news', {
            hello: 'world'
        });

        socket.on('client:runTopicDetection', data => {

            socket.emit("server:response", {
                level: "success",
                message: 'Topic detection has started at: ' + new Date(),
                finished: false,
            });
            detectTopicDynamic(data.from, data.to, result => {
                console.log(result);
                socket.emit("server:response", {
                    level: "success",
                    message: 'Topic detection has finished at: ' + new Date(),
                    finished: true,
                    result: JSON.parse(result)
                });
            });

        });
    });
}

