import io from 'socket.io-client'
const socket = io(`http://localhost:8080`, { reconnectionDelay: 4000 });
export default socket;