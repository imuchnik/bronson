IO = require 'socket.io'
FS = require 'fs'
Connection = require './connection'
Room = require './room'
BackendHandler = require './backend_handler'
HttpServer = require './http_server/http_server'
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
    httpServer = new HttpServer port

    @io = IO.listen httpServer.server, options
    @io.sockets.on 'connection', (socket) =>
      new Connection socket, @, @backendHandler


module.exports = Bronson
