Room = require('./room').Room

class exports.Client

  constructor: (@socket, @httpController) ->
    @socket.on 'join', @joinRoom
    @socket.on 'send', @broadcast
    @socket.on 'disconnect', @disconnect
    @socket.on 'ping', @ping


  # Allows a client to broadcast a message to all other clients in the room.
  broadcast: (obj) =>
    return @error("Not in room") unless @room?
    return @error("Missing data") unless obj?

    responseObject = {}
    eventString = if obj.event? then obj.event else "update"

    if obj.broadcast?
      # Send anything in broadcast to all clients
      responseObject.broadcast = obj.broadcast

    if obj.backendRequest?
      return @error "No backend server specified" unless @httpController?

      # Send data to http server, relay response to clients
      @httpController.request(
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


  # Called when the client disconnect.
  disconnect: =>
    @room?.removeClient(@)


  # Sends the given message to this client.
  emit: (message, data) ->
    @socket.emit(message,data)


  # Sends the given error message to the client.
  error: (errorMessage) ->
    @socket.emit 'error', errorMessage


  # Called when a client requests to join the given room.
  joinRoom: (data) =>
    return unless data? and data.userId? and data.roomId? and data.host?

    @room?.removeClient(@)
    @userId = data.userId
    @room = Room.get(data.roomId)
    @room.addClient(@)


  # For diagnosing connection issues.
  ping: =>
    @emit 'pong'

