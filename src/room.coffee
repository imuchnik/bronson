class Room
  # Room.list
  # object of all rooms in the app
  @list: {}

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

  removeClient: (client) ->
    @clients[i..i] = [] if (i=@clients.indexOf(client)) > -1
    if @clients.length is 0
      delete Room.list[@id]

  broadcast: (event, data) ->
    for client in @clients
      client.emit(event,data)

module.exports = Room
