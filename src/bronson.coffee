IO = require 'socket.io'
HTTP = require 'http'
FS = require 'fs'
Connection = require './connection'
Room = require './room'
BackendHandler = require './backend_handler'
EventEmitter = require('events').EventEmitter


# Provides room-based communication services on top of Socket.IO.
class Bronson extends EventEmitter

  constructor: (host, port, @options={}) ->

    # Set default values for options.
    @options.sendToSelf ?= yes

    # Create BackendHandler instance if we have backend integration.
    @backendHandler = new BackendHandler(host, port) if host


  # Starts the Bronson server.
  listen: (port, options = {}) ->
    if typeof port is 'number'
      httpServer = HTTP.createServer @handleHttp
      httpServer.listen port
    else
      # an existing http server was passed instead of a port
      httpServer = port
      httpServer.on 'request', @handleHttp

    @io = IO.listen httpServer, options
    @io.sockets.on 'connection', (socket) =>
      new Connection socket, @, @backendHandler


module.exports = Bronson
