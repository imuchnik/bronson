URL = require 'url'

class HttpRequest
  constructor: (@req, @res) ->
    @req.url = URL.parse @req.url, true
    @headers = @req.headers
    @path = []

    path = @req.url.pathname.split /\//g
    @path.push path[i] for i in [1..path.length-1] by 1

  err: (code) ->
    @res.writeHead code, 'Content-Type': 'text/html'
    @res.write "<h1>Bronson - #{code} Error</h1>"
    @res.end()

  notModified: ->
    @res.writeHead 304
    @res.end()

  # Sends data to the browser
  end: (data, contentType='application/json', etag=null) ->
    if @req.url.query.callback? and contentType is 'application/json'
      # JSONP request, we need to wrap data in a callback
      data = "#{@req.url.query.callback}(#{data})"
      contentType = 'text/javascript'

    byteLength = if data instanceof Buffer then data.length else Buffer.byteLength(data, 'utf8')
    headers =
      'Content-Type': contentType
      'Content-Length': byteLength
    headers.Etag = etag if etag?
    @res.writeHead 200, headers

    @res.write data
    @res.end()


  # Returns true if the request path begins with "/bronson/"
  isBronsonNamespace: ->
    @path[0] is 'bronson'


module.exports = HttpRequest
