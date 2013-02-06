Room = require('./room')

class Connection

  constructor: (@socket, @bronson, @backendHandler) ->
    @socket.on 'disconnect', @disconnect
    @socket.on 'join', @joinRoom
    @socket.on 'ping', @ping
    @socket.on 'send', @broadcast
    @ip = @socket.handshake.address.address

    @log 'Client connected', transport: @socket.transport


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
    @log "Client broadcasted '#{data.event}' into room '#{@room.id}'"

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
          # response.backendResponse = body: "{ \"delay\": #{0} }"
          @room.broadcast data.event, response, data.toSelf, @
      )
      # delay = 2000
      # setTimeout =>
      #   response.backendResponse = body: "{ \"delay\": #{0} }"
      #   @room.broadcast data.event, response, data.toSelf, @
      # , delay
    else
      # No backend request --> just broadcast immediately.
      @room.broadcast data.event, response, data.toSelf, @


  # Called on disconnect.
  disconnect: =>
    @room?.removeConnection(@)
    @room?.broadcast 'room left',
      userId: @userId
      usersInRoom: @room.getUserIds()
    @log "Client disconnected"


  # Sends the given message to this connection.
  emit: (message, data) ->
    @socket.emit(message,data)


  # Sends the given error message to the connection.
  error: (errorMessage) ->
    @log "Client error", error: errorMessage
    @socket.emit 'error', errorMessage


  # Called when a connection requests to join the given room.
  joinRoom: (data) =>
    return unless data? and data.userId? and data.roomId?

    @room?.removeConnection(@)
    @userId = data.userId
    @room = Room.get data.roomId
    @room.addConnection(@)
    @room.broadcast 'room joined',
      userId: @userId
      usersInRoom: @room.getUserIds()

    @log "Client joined room", roomId: data.roomId

    # Notify listeners.
    @bronson.emit 'room joined', data


  log: (event, data={}) ->
    logObj =
      event: event
      date: new Date()
      client:
        ip: @ip
        userId: @userId
        socketId: @socket.id
    logObj[option] = data[option] for option of data
    @bronson.log logObj



  # For diagnosing connection issues.
  ping: (data) =>
    @emit 'pong', data


module.exports = Connection
