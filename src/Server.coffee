io = require('socket.io').listen(8080)

Client = require('./Client.js').Client
Room = require('./Room.js').Room

Client.debug = true
Room.debug = true


io.sockets.on('connection', (socket) -> new Client(socket) )




