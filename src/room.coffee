# A chat room.
#
# Users can join rooms, and then receive all the broadcast messages in that room.
class Room

  # All the rooms in the app.
  # Maps roomId to room instance.
  @rooms: {}

  # Returns the room with the given id.
  # Creates a new room if one doesn't exist yet.
  @get: (roomId) ->
    Room.rooms[roomId] = new Room(roomId) unless Room.rooms[roomId]?
    Room.rooms[roomId]
    

  constructor: (@id) ->

    # The clients that are currently subscribed to this room.
    @connections = []


  # Adds the given client to this room.
  addConnection: (connection) ->
    @connections.push(connection) unless @hasConnection connection


  # Sends the given event and data payload to all clients in this room.
  broadcast: (event, data) ->
    connection.emit(event, data) for connection in @connections


  # Returns whether this room already contains the given client.
  hasConnection: (connection) ->
    @connections.indexOf(connection) > -1


  # Removes the given client from this room.
  removeConnection: (connection) ->

    # Remove the client from the room.
    pos = @connections.indexOf connection
    @connections.splice(pos,1) if pos > -1

    # Remove the room from the room room if nobody is left in it.
    if @connections.length == 0
      delete Room.rooms[@id]


module.exports = Room
