exports.io = require 'socket.io'
Client = require('./client').Client
Room = require('./room').Room

exports.setHost = (host) ->
  require('./httpcontroller').HTTPHost = host

exports.listen = (port) ->
  io = exports.io.listen port
  io.sockets.on('connection', (socket) -> new Client(socket) )
