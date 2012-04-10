
Room = require('./Room.js').Room
Rails  = require('./RailsAPI.js')

class exports.Client
  # Client.list
  # array of all connected clients
  @list: []
  @debug: false

  constructor: (@socket) ->
    Client.list.push(@)
    @socket.on('init', @init)
    @socket.on('update', @update)
    @socket.on('disconnect', @disconnect)
    @id = new Date().getTime()
    @initialized = no
    @request "init"
    console.log "Client #{@id} connected" if Client.debug


  init: (data) =>
    unless data? and data.userId? and data.roomId? and data.uri?
      @request "missing params"
      return
    @initialized = yes

    @room?.removeClient(@)
    @userId = data.userId
    @roomId = data.roomId

    Rails.connect(@userId, @roomId, data.uri, (response) =>
      @room = Room.get(@roomId)
      @room.addClient(@)
      @room.broadcast('update', response)
      console.log "Client #{@id} identified itself as #{@userId} in room #{@roomId}" if Client.debug
    )



  update: (data) =>
    if not @initialized
      @request "init"
      return
    unless data? and data.eventId? and data.data? and data.uri?
      @request "missing params"
      return
    Rails.update(data.eventId, data.data, data.uri, (response) =>
      @room.broadcast('update', response)
    )

  disconnect: =>
    console.log "Client #{@id} disconnected" if Client.debug
    @room?.removeClient(@)
    Client.list[i..i] = [] if i=Client.list.indexOf(@) > -1


  # emits message to this client
  emit: (message, data) ->
    @socket.emit(message,data)

  # called when the server needs more data from the client
  request: (method) ->
    @emit('request', method)



