HTTP = require 'http'
jade = require 'jade'
Room = require '../room'
Route = require './route'
HttpRequest = require './http_request'

class HttpServer
  constructor: (port) ->
    if typeof port is 'number'
      @server = HTTP.createServer @handleRequest
      @server.listen port
    else
      # an existing http server was passed instead of a port
      @server = port
      @server.on 'request', @handleRequest

    # -- HTTP Routes: --
    @routes = new Route
    @routes.setOptions
      type: 'text/plain'
      render: (request) -> request.end 'Welcome to Bronson.'

    # Client Library
    @addRoute 'bronson.js',
      file: 'client/bronson.min.js'
      type: 'text/javascript'

    # Admin
    @addRoute 'admin',
      file: 'admin/index.jade'
      type: 'text/html'
      compiler: jade
    @addRoute 'admin/js',
      file: 'admin/index.js'
      type: 'text/javascript'
    @addRoute 'admin/css',
      file: 'admin/index.css'
      type: 'text/css'
    @addRoute 'admin/frame',
      file: 'admin/frame.jade'
      type: 'text/html'
      compiler: jade
    @addRoute 'admin/throbber',
      file: 'admin/img/throbber.gif'
      type: 'image/gif'

    # Room information JSON API
    @addRoute 'room/:roomId',
      type: 'application/json'
      render: (request, vars) => request.end @getRoomData vars.roomId
    # ------------------


  addRoute: (path, options) ->
    routePointer = @routes
    for pathPart in path.split '/'
      subRoute = routePointer.getSubRoute(pathPart)
      if subRoute?
        routePointer = subRoute
      else
        newRoute = new Route
        routePointer.addSubRoute pathPart, newRoute
        routePointer = newRoute
    routePointer.setOptions options


  getRoomData: (roomId) ->
    if Room.rooms[roomId]?
      obj = connections: Room.rooms[roomId].getUserIds()
    else
      obj = {}
    JSON.stringify obj


  handleRequest: (req, res) =>
    request = new HttpRequest req, res
    return unless request.isBronsonNamespace()

    routePointer = @routes
    requestVars = {}

    for pathPart in request.path.slice(1)
      continue if pathPart is ''
      routePointer = routePointer.getSubRoute(pathPart, requestVars)
      break unless routePointer?

    if routePointer?
      routePointer.render request, requestVars
    else
      request.err 404


module.exports = HttpServer
