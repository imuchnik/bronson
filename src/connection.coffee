Room = require('./room')

class Connection

  constructor: (@socket, @bronson, @httpController) ->
    @socket.on 'disconnect', @disconnect
    @socket.on 'join', @joinRoom
    @socket.on 'ping', @ping
    @socket.on 'send', @broadcast


  # Allows a client to broadcast a message to all other clients in the room.
  # obj.broadcast contains what gets broadcasted to everyone else in the room after the optional backend request returns.
  # obj.backendRequest: Object that describes the request to be sent to the backend.
  #     .data: payload to be sent to backend
  #     .path: URL path to backend API
  #     .method: 'POST', 'GET', or 'DELETE'
  #     .headers: object containing key-values for the HTTP header of the backend request.
  broadcast: (data) =>

    # Check for errors.
    return @error("Not in a room") unless @room?
    return @error("Missing data") unless data?
    return @error("No event name given") unless data.event

    # Prepare the response object.
    response = {}
    response.broadcast = data.broadcast if data.broadcast?

    if data.backendRequest?
      # The broadcast event contains a backend request portion --> perform the backend request here.

      return @error "No backend server specified" unless @httpController?

      @httpController.request(
        data: data.backendRequest.data
        path: data.backendRequest.path
        method: data.backendRequest.method
        headers: data.backendRequest.headers
        error: (error) -> console.error error
        success: (response) =>
          response.backendResponse = response
          @room.broadcast data.event, response
      )
    else
      # No backend request --> just broadcast immediately.
      @room.broadcast data.event, response


  # Called on disconnect.
  disconnect: =>
    @room?.removeConnection(@)
    console.log "#{@userId} has disconnected"


  # Sends the given message to this connection.
  emit: (message, data) ->
    @socket.emit(message,data)


  # Sends the given error message to the connection.
  error: (errorMessage) ->
    @socket.emit 'error', errorMessage


  # Called when a connection requests to join the given room.
  joinRoom: (data) =>
    return unless data? and data.userId? and data.roomId?

    @room?.removeConnection(@)
    @userId = data.userId
    @room = Room.get(data.roomId)
    @room.addConnection(@)

    console.log "#{data.userId} has joined room #{data.roomId}"

    # Notify listeners.
    @bronson.emit 'room joined', data


  # For diagnosing connection issues.
  ping: =>
    console.log 'ping'
    @emit 'pong'


module.exports = Connection
