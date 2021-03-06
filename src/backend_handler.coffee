http = require 'http'

# Manages the connection to the backend system.
class BackendHandler

  constructor: (@hostname, @port=80, @bronson) ->
    @bronson ?= log: (->)

  # Removes all characters that should not be part of a url.
  @sanitize_url: (url) ->
    url.replace /[^a-z0-9/_.-]/ig, ""

  request: (obj) ->
    obj.data ?= {}
    obj.method ?= 'POST'
    obj.headers ?= {}
    obj.path = BackendHandler.sanitize_url obj.path
    jsonString = JSON.stringify(obj.data)

    options =
      host: @hostname
      port: @port
      path: obj.path
      method: obj.method
      headers: obj.headers
    options.headers['Content-Type'] = 'application/json'
    options.headers['Content-Length'] = Buffer.byteLength(jsonString,'utf8')


    startRequestTime = new Date
    request = http.request(options, (response) =>
      responseBody = ""
      response.on('data', (chunk) -> responseBody += chunk )
      response.on('end', =>

        # Log the response
        @bronson.log
          event: 'Backend request'
          status: response.statusCode
          requestParams: options
          startRequestTime: startRequestTime
          endRequestTime: new Date

        # Call the success callback
        obj.success
          status: response.statusCode
          body: responseBody
      )
    )

    request.write(jsonString)
    request.end()



module.exports = BackendHandler

