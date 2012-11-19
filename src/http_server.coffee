URL = require 'url'
FS = require 'fs'
HTTP = require 'http'
Room = require './room'

class HttpServer
  constructor: (port) ->
    if typeof port is 'number'
      @server = HTTP.createServer @handleRequest
      @server.listen port
    else
      # an existing http server was passed instead of a port
      @server = port
      @server.on 'request', @handleRequest


  handleRequest: (req, res) =>
    request = new HttpServer.HttpRequest req, res
    return unless request.isBronsonNamespace()

    if request.path[0] is 'bronson.js'
      @routeHandlers.clientLibrary request

    else if request.path[0] is 'room'
      roomId = request.path[1]
      @routeHandlers.room request, roomId

    else
      request.end 'Welcome to Bronson.', 'text/plain'


  routeHandlers:

    # Serves client-side JS library
    clientLibrary: (request) ->
      FS.readFile "#{__dirname}/../client/bronson.min.js", (err, fsData) ->
        request.end fsData.toString(), 'text/javascript'

    # Serves room information
    room: (request, roomId) ->
      if Room.rooms[roomId]?
        obj = connections: Room.rooms[roomId].getUserIds()
      else
        obj = {}
      request.end JSON.stringify obj



class HttpServer.HttpRequest
  constructor: (@req, @res) ->
    @req = URL.parse @req.url, true
    @path = []

    path = @req.pathname.split /\//g
    @path.push path[i] for i in [1..path.length-1] by 1


  # Sends data to the browser
  end: (data, contentType='application/json') ->
    if @req.query.callback? and contentType is 'application/json'
      # JSONP request, we need to wrap data in a callback
      data = "#{@req.query.callback}(#{data})"
      contentType = 'text/javascript'

    @res.writeHead 200,
      'Content-Type': contentType
      'Content-Length': Buffer.byteLength data, 'utf8'

    @res.write data
    @res.end()


  # Returns true if the request path begins with "/bronson/"
  isBronsonNamespace: ->
    @path[0] is 'bronson'


module.exports = HttpServer
