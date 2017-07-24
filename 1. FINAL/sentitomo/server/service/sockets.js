import SocketIO from 'socket.io';
import { topicDetection } from '../ML/classify';
import { Tweet } from '../data/connectors';


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

