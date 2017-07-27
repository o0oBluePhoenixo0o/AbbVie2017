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

        socket.on("client:checkTweetBagSize", data => {
            Tweet.findAll({
                where: {
                    created: {
                        $lt: data.to, // less than
                        $gt: data.from //greater than
                    }
                },
                raw: true //we use raw, we do not need to have access to the sequlize model here
            }).then(tweets => {
                socket.emit("server:checkTweetBagSize", {
                    tweetsSize: tweets.length
                });
            });

        });

        socket.on('client:runTopicDetection', data => {

            socket.emit("server:response", {
                task: 'Topic detection',
                started: true,
                time: new Date()
            });
            topicDetection(data.from, data.to, result => {
                console.log(result);
            });


            console.log(data)
        });
    });
}

