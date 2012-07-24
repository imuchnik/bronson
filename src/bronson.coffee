# Makes  the SocketIO server available to Bronson clients.
exports.io = require 'socket.io'

Client = require('./client').Client
Room = require('./room').Room
HTTPController = require('./httpcontroller').HTTPController

# The global HTTPController instance.
httpController = null


# Sets the backend host address.
exports.setHost = (host, port) ->
  httpController = new HTTPController host, port
  exports


# Starts the Bronson server.
exports.listen = (port) ->
  io = exports.io.listen port
  io.sockets.on 'connection', (socket) -> new Client(socket, httpController)
  exports
