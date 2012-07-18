
Room = require('./room').Room
HTTPController  = require('./httpcontroller').HTTPController

class exports.Client
  # Client.list
  # array of all connected clients

  constructor: (@socket) ->
    @socket.on('join', @joinRoom)
    @socket.on('send', @sendData)
    @socket.on('disconnect', @disconnect)


  joinRoom: (data) =>
    return unless data? and data.userId? and data.roomId? and data.host?

    @room?.removeClient(@)
    @userId = data.userId
    @room = Room.get(data.roomId)
    @room.addClient(@)
    #@room.broadcast('join', data)
    @controller = new HTTPController()


  sendData: (obj) =>
    return @error("Not in room") unless @room?
    return @error("Missing data") unless obj?

    responseObject = {}
    eventString = if obj.event? then obj.event else "update"

    if obj.broadcast?
      # Send anything in broadcast to all clients
      responseObject.broadcast = obj.broadcast

    if obj.backendRequest?
      # Send data to http server, relay response to clients
      @controller.request(
        data: obj.backendRequest.data
        path: obj.backendRequest.path
        method: obj.backendRequest.method
        headers: obj.backendRequest.headers
        error: (error) -> console.error error
        success: (response) =>
          responseObject.backendResponse = response
          @room.broadcast(eventString, responseObject)
      )
    else
      @room.broadcast(eventString, responseObject )

  disconnect: =>
    @room?.removeClient(@)


  # emits message to this client
  emit: (message, data) ->
    @socket.emit(message,data)



  error: (errorMessage) ->
    @socket.emit 'error', errorMessage
