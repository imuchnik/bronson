class exports.Room
  # Room.list
  # object of all rooms in the app
  @list: {}
  @debug: false

  # Room.get (roomId)
  # creates the room if it does not exist
  #
  # returns pointer to room object or false if invalid
  @get: (roomId) ->
    unless Room.list[roomId]?
      Room.list[roomId] = new Room(roomId)
    Room.list[roomId]
    


  constructor: (@id) ->
    @clients = []

  addClient: (client) ->
    @clients.push(client) unless @clients.indexOf(client) > -1
    console.log("client joined room #{@id}, (#{@clients.length} people in room)") if Room.debug

  removeClient: (client) ->
    console.log "#{client.id} left the room #{@id}" if Room.debug
    @clients[i..i] = [] if (i=@clients.indexOf(client)) > -1
    if @clients.length is 0
      delete Room.list[@id]

  broadcast: (event, data) ->
    for client in @clients
      client.emit(event,data)

