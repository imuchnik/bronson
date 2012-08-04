IO = require 'socket.io'
Connection = require './connection'
Room = require './room'
HttpController = require './httpcontroller'
EventEmitter = require('events').EventEmitter


# Provides room-based communication services on top of Socket.IO.
class Bronson extends EventEmitter

  constructor: (host, port, @options={}) ->

    # Create HttpController instance if we have backend integration.
    @httpController = new HttpController(host, port) if host

    # Set default values for options.
    @options.sendToSelf ?= yes


  # Starts the Bronson server.
  listen: (port, options = {}) ->
    @io = IO.listen port, options
    @io.sockets.on 'connection', (socket) ->
      new Connection socket, @, @httpController


module.exports = Bronson
