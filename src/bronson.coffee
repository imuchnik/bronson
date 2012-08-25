IO = require 'socket.io'
HTTP = require 'http'
FS = require 'fs'
Connection = require './connection'
Room = require './room'
HttpController = require './httpcontroller'
EventEmitter = require('events').EventEmitter


# Provides room-based communication services on top of Socket.IO.
class Bronson extends EventEmitter

  constructor: (host, port, @options={}) ->

    # Set default values for options.
    @options.sendToSelf ?= yes

    # Create HttpController instance if we have backend integration.
    @httpController = new HttpController(host, port) if host


  # Handles http request for client library
  handleHttp: (req, res) =>
    if req.url is '/bronson/bronson.js'
      FS.readFile "#{__dirname}/../client/bronson.min.js", (err, fsData) -> res.end fsData.toString()


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
      new Connection socket, @, @httpController


module.exports = Bronson
