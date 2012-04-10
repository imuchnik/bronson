require('should')

Room = require('../room.js').Room
Client = require('../client.js').Client


class SampleClient
  @numClients = 0

  constructor: ->
    @id = "Client #{++SampleClient.numClients}"

  emit: (event, data) ->


describe('Room', ->

  describe('Room.get', ->
    it('should create a new room if it does not exist',->
      room1 = Room.get("room 1")
      room2 = Room.get("room 2")

      room1.should.not.equal(room2)
    )
    it('should return room pointer if room does exist',->
      room1 = Room.get("room 3")
      room2 = Room.get("room 3")

      room1.should.equal(room2)
    )
  )



  describe('addClient', ->
    it('should add to clients list',->
      room = new Room("room 4")
      exampleClient = new SampleClient()
      exampleClient2 = new SampleClient()

      room.clients.should.have.length(0)

      room.addClient(exampleClient)
      room.clients.should.have.length(1)

      room.addClient(exampleClient2)
      room.clients.should.have.length(2)

    )
    it('should not re-add the same client',->
      room = new Room("room 5")
      exampleClient = new SampleClient()

      room.clients.should.have.length(0)

      room.addClient(exampleClient)
      room.clients.should.have.length(1)

      room.addClient(exampleClient)
      room.clients.should.have.length(1)
    )
  )
  

  describe('removeClient', ->
    it('should remove from clients list',->
      room = new Room("room 6")
      exampleClient = new SampleClient()
      exampleClient2 = new SampleClient()

      room.addClient(exampleClient)
      room.addClient(exampleClient2)

      room.clients.should.have.length(2)

      room.removeClient(exampleClient)
      room.clients.should.have.length(1)
      room.clients[0].should.equal(exampleClient2)
    )
    it('should destroy the room if it is empty',->
      room = Room.get("room 7")
      exampleClient = new SampleClient()

      Room.list.should.have.property(room.id)
      room.addClient(exampleClient)
      room.removeClient(exampleClient)

      Room.list.should.not.have.property(room.id)
    )
  )


  describe('broadcast', ->
    it('should emit to all clients in the room', (done) ->
      room = new Room("room 7")
      exampleClient = new SampleClient()
      exampleClient2 = new SampleClient()

      room.addClient(exampleClient)
      room.addClient(exampleClient2)

      sampleEmit = "sample emit"
      sampleData = {"data": 1}

      emitToClient1 = false

      exampleClient.emit = (event, data) ->
        event.should.equal(sampleEmit)
        data.should.equal(sampleData)
        emitToClient1 = true

      exampleClient2.emit = (event, data) ->
        event.should.equal(sampleEmit)
        data.should.equal(sampleData)
        emitToClient1.should.be.true
        done()

      room.broadcast(sampleEmit, sampleData)

    )
  )
)
