http = require('http')
querystring = require('querystring')

makePostRequest = (uri,data,callback) ->
  data = querystring.stringify(data)
  options =
    host: 'localhost'
    port: 2020
    path: uri
    method: 'POST'
    headers:
      'Content-Type': 'application/x-www-form-urlencoded'
      'Content-Length': data.length



  request = http.request(options, (response) ->
    responseBody = ""
    response.on('data', (chunk) ->
      responseBody += chunk
    )
    response.on('end', ->
      try
        callback JSON.parse(responseBody)
      catch error
        # if the server returns invalid JSON catch it
        console.error error
      
    )
  )
  

  request.write(data)
  request.end()


exports.update = (eventId, data, railsURL, callback) ->
  makePostRequest(railsURL, {eventId:eventId,data:data}, callback)

exports.connect = (userId, roomId, railsURL, callback) ->
  makePostRequest(railsURL, {userId: userId, roomId: roomId}, callback)
