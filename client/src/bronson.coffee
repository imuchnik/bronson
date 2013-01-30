class window.Bronson

  constructor: (host=window.location.origin) ->
    @socket = io.connect host


  # Emits payload to all clients in the room
  broadcast: (event, payload, sendToSelf=yes) ->
    @socket.emit 'send',
      event: event
      toSelf: sendToSelf
      broadcast: payload


  # Makes a backend request
  emit: (event, settings) ->
    if settings.path?
      settings.type ?= 'GET'
      settings.headers ?= {}
      settings.headers.cookie ?= document.cookie

      backendRequest =
        data: settings.data
        headers: settings.headers
        method: settings.type
        path: settings.path
        toSelf: settings.sendToSelf

    @socket.emit 'send',
      event: event
      broadcast: settings.broadcast
      backendRequest: backendRequest


  # Join a specific room
  joinRoom: (room, username="") ->
    @socket.emit 'join',
      roomId: room
      userId: username


  # Bind callback to specific event
  on: (event, callback) ->
    @socket.on event, callback

  ping: ->
    @socket.emit 'ping'
