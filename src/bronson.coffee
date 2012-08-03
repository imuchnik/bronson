# Makes  the SocketIO server available to Bronson clients.
IO = require 'socket.io'
Connection = require './connection'
Room = require './room'
HTTPController = require './httpcontroller'
EventEmitter = require('events').EventEmitter


class Bronson extends EventEmitter

  constructor: (host, port, @options={}) ->
    @httpController = new HTTPController(host, port) if host

    # Set default values for options.
    @options.sendToSelf ||= yes


  # Starts the Bronson server.
  listen: (port, options = {}) ->
    @io = IO.listen port, options
    @io.sockets.on 'connection', (socket) ->
      new Connection socket, @, @httpController


module.exports = Bronson
