
http = require('http')

exports.HTTPHost = ""

class exports.HTTPController

  constructor: () ->
    hostarr = exports.HTTPHost.split(":")
    @hostname = hostarr[0]
    @port = hostarr[1]


  request: (obj) ->
    obj.data ?= {}
    obj.method ?= 'POST'
    obj.headers ?= {}

    obj.path = obj.path.replace /[^a-z0-9/_.-]/ig, ""

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
        try
          console.log responseBody
          if responseBody.trim() isnt ''
            obj.success JSON.parse(responseBody)
          else
            obj.success()
        catch error
          # if the server returns invalid JSON catch it
          obj.error error
      )
    )

    request.write(jsonString)
    request.end()
