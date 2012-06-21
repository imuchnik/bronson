port = parseInt(process.env.PORT)
io = require('socket.io').listen(port)

io.configure(->
  io.set("transports", ["xhr-polling"])
  io.set("polling duration", 10)
  io.set("browser client minification", true)
  io.set("log level", 0)
)

Client = require('./client').Client
Room = require('./room').Room

Client.debug = true
Room.debug = true


io.sockets.on('connection', (socket) -> new Client(socket) )




