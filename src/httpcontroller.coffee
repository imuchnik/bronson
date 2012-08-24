http = require 'http'


# Manages the connection to the backend system.
class HttpController

  constructor: (@hostname, @port=80) ->

  # Removes all characters that should not be part of a url.
  @sanitize_url: (url) ->
    url.replace /[^a-z0-9/_.-]/ig, ""

  request: (obj) ->
    obj.data ?= {}
    obj.method ?= 'POST'
    obj.headers ?= {}
    obj.path = HttpController.sanitize_url obj.path
    jsonString = JSON.stringify(obj.data)

    options =
      host: @hostname
      port: @port
      path: obj.path
      method: obj.method
      headers: obj.headers
    options.headers['Content-Type'] = 'application/json'
    options.headers['Content-Length'] = Buffer.byteLength(jsonString,'utf8')


    request = http.request(options, (response) ->
      responseBody = ""
      response.on('data', (chunk) -> responseBody += chunk )
      response.on('end', ->

        err = "Response status code returned #{response.statusCode}. Expected 200" unless response.statusCode is 200
        unless err
          obj.success responseBody

          obj.error error
      )
    )

    request.write(jsonString)
    request.end()



module.exports = HttpController

