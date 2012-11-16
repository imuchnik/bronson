Room = require('./room')

class Connection

  constructor: (@socket, @bronson, @backendHandler) ->
    @socket.on 'disconnect', @disconnect
    @socket.on 'join', @joinRoom
    @socket.on 'ping', @ping
    @socket.on 'send', @broadcast


  # Allows a client to broadcast a message to all other clients in the room.
  broadcast: (data) =>

    # Check for errors.
    return @error("Not in a room") unless @room?
    return @error("Missing data") unless data?
    return @error("No event name given") unless data.event

    # Apply default sendToSelf if not provided.
    data.toSelf ?= @bronson.options.sendToSelf

    # Prepare the response object.
    response = {}
    response.broadcast = data.broadcast if data.broadcast?

    # Log the event.
    console.log "User '#{@userId}' broadcasts '#{data.event}' into room '#{@room.id}'." unless @bronson.testing

    if data.backendRequest?
      # The broadcast event contains a backend request portion --> perform the backend request here.

      return @error "No backend server specified" unless @backendHandler?

      @backendHandler.request(
        data: data.backendRequest.data
        path: data.backendRequest.path
        method: data.backendRequest.method
        headers: data.backendRequest.headers
        error: (error) -> console.error error
        success: (backendResponse) =>
          response.backendResponse = backendResponse
          @room.broadcast data.event, response, data.toSelf, @
      )
    else
      # No backend request --> just broadcast immediately.
      @room.broadcast data.event, response, data.toSelf, @


  # Called on disconnect.
  disconnect: =>
    @room?.removeConnection(@)
    @room?.broadcast 'room left', @userId
    console.log "#{@userId} has disconnected"


  # Sends the given message to this connection.
  emit: (message, data) ->
    @socket.emit(message,data)


  # Sends the given error message to the connection.
  error: (errorMessage) ->
    console.log "ERROR: #{errorMessage}"
    @socket.emit 'error', errorMessage


  # Called when a connection requests to join the given room.
  joinRoom: (data) =>
    return unless data? and data.userId? and data.roomId?

    @room?.removeConnection(@)
    @userId = data.userId
    @room = Room.get data.roomId
    @room.addConnection(@)
    @room.broadcast 'room joined', @userId

    console.log "#{data.userId} has joined room #{data.roomId}"

    # Notify listeners.
    @bronson.emit 'room joined', data


  # For diagnosing connection issues.
  ping: =>
    console.log 'ping'
    @emit 'pong'


module.exports = Connection
