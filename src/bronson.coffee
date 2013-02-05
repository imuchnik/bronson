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

    # Set default log function
    @options.logFn ?= (obj) ->
      logMsg = "\x1b[0m[#{obj.date}]\x1b[0;32m #{obj.event}"
      logMsg += "\x1b[0m  -  (#{JSON.stringify(obj.client)})" if obj.client?
      console.log logMsg
    @log = (data) => @options.logFn data

    # Create BackendHandler instance if we have backend integration.
    @backendHandler = new BackendHandler(host, port) if host


  # Starts the Bronson server.
  listen: (port, options = {}) ->
    httpServer = new HttpServer port

    @io = IO.listen httpServer.server, options
    @io.sockets.on 'connection', (socket) =>
      new Connection socket, @, @backendHandler


module.exports = Bronson
