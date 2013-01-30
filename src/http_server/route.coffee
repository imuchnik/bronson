FS = require 'fs'
crypto = require 'crypto'
Room = require '../room'

md5 = (s) ->
  md5sum = crypto.createHash('md5')
  md5sum.update(s).digest('hex')


class Route
  constructor: ->
    @subRoutes = {}
    @etag = null

  setOptions: (options) ->
    @file = options.file
    @type = options.type
    @compiler = options.compiler

    # Overload default file render function if one is passed
    @render = options.render if options.render?


  addSubRoute: (str, route) ->
    if str[0] is ':'
      @varName = str.substr(1)
      @varRoute = route
    else
      @subRoutes[str] = route


  getSubRoute: (str, vars=null) ->
    return @subRoutes[str] if @subRoutes[str]?

    if vars? and @varRoute?
      vars[@varName] = str
      return @varRoute
    return null


  # Compiles and sends @file to the browser
  render: (request) ->
    if @etag? and request.headers['if-none-match'] is @etag
      request.notModified()

    FS.readFile "#{__dirname}/../#{@file}", (err, data) =>
      return request.err 500 if err?
      @etag = md5 data.toString() unless @etag?
      if @compiler?
        data = @compiler.compile(data.toString())(
          geoip: require 'geoip-lite'
          rooms: Room.rooms
        )
      request.end data, @type, @etag


module.exports = Route
