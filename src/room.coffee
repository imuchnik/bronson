# A chat room.
#
# Users can join rooms, and then receive all the broadcast messages in that room.
class Room

  # All the rooms in the app.
  # Maps roomId to room instance.
  @list: {}

  # Returns the room with the given id.
  # Creates a new room if one doesn't exist yet.
  @get: (roomId) ->
    Room.list[roomId] = new Room(roomId) unless Room.list[roomId]?
    Room.list[roomId]
    

  constructor: (@id) ->

    # The clients that are currently subscribed to this room.
    @clients = []


  # Adds the given client to this room.
  addClient: (client) ->
    @clients.push(client) unless @hasClient client


  # Sends the given event and data payload to all clients in this room.
  broadcast: (event, data) ->
    client.emit(event,data) for client in @clients


  # Returns whether this room already contains the given client.
  hasClient: (client) ->
    @clients.indexOf(client) > -1


  # Removes the given client from this room.
  removeClient: (client) ->

    # Remove the client from the room.
    @clients[i..i] = [] if (i=@clients.indexOf(client)) > -1

    # Remove the room from the room list if nobody is left in it.
    if @clients.length is 0
      delete Room.list[@id]


module.exports = Room
