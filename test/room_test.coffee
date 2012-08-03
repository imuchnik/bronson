assert = require('assert')
should = require('chai').should()
sinon = require('sinon')
Room = require('../src/room')


describe 'Room', ->

  room = null
  beforeEach ->
    room = new Room 'room id'
    Room.rooms = {}

  describe 'constructor', ->
    
    it 'saves the room id', ->
      room.id.should.equal 'room id'
      
    it 'starts the room empty', ->
      room.connections.should.have.length 0


  describe '#get', ->

    it 'returns the room with the given id', ->
      Room.get('foo').should.have.property 'id', 'foo'

    it "creates a new room if one doesn't exist", ->
      Room.get('foo').should.not.be.undefined
      
    it 'adds the new room to the list of rooms', ->
      room = Room.get 'foo'
      Room.rooms.should.have.property 'foo', room

    it 'takes the room from the list of existing rooms if it exists', ->
      Room.rooms['foo'] = 'existing foo room'
      Room.get('foo').should.equal 'existing foo room'


  describe 'addConnection', ->

    describe 'connection is not in the room yet', ->

      it 'adds the given connection to the list of connections in this room', ->
        room.addConnection 'foo'
        room.connections.should.have.length 1
        room.connections.should.include 'foo'

    describe 'connection is already in the room', ->

      it "doesn't add the connection again", ->
        room.connections = ['foo']
        room.addConnection 'foo'
        room.connections.should.have.length 1
        room.connections.should.include 'foo'


  describe 'broadcast', ->

    it 'emits the given message to each connection in this room', ->
      room.addConnection connection_1 = emit: sinon.spy()
      room.addConnection connection_2 = emit: sinon.spy()

      room.broadcast 'foo', 'data'

      connection_1.emit.should.have.been.calledOnce
      connection_1.emit.args[0].should.eql ['foo', 'data']
      connection_2.emit.should.have.been.calledOnce
      connection_2.emit.args[0].should.eql ['foo', 'data']

    it "doesn't emit the message to self if sendToSelf is false", ->
      room.addConnection connection_1 = emit: sinon.spy()
      room.addConnection connection_2 = emit: sinon.spy()

      room.broadcast 'foo', 'data', no, connection_1

      connection_1.emit.should.not.have.been.called
      connection_2.emit.should.have.been.calledOnce
      connection_2.emit.args[0].should.eql ['foo', 'data']

    it 'works if the connection list is empty', ->
      room.broadcast 'foo', 'data'


  describe 'hasConnection', ->
    
    it 'returns TRUE if the room already is connected to the given connection', ->
      room.addConnection 'foo'
      room.hasConnection('foo').should.be.true

    it "returns FALSE if the room doesn't have the given connection yet", ->
      room.hasConnection('foo').should.be.false
      

  describe 'removeConnection', ->

    it 'removes the given connection from the given room', ->
      room.addConnection 'foo'
      room.addConnection 'bar'
      room.removeConnection 'foo'
      room.connections.should.not.include 'foo'

    it 'removes the room if it is empty now', ->
      room = Room.get 'room'
      room.addConnection 'foo'
      room.removeConnection 'foo'
      Room.rooms.should.not.have.property 'room'

    it 'keeps the room if other clients are still connected to it', ->
      room = Room.get 'room'
      room.addConnection 'foo'
      room.addConnection 'bar'
      room.removeConnection 'foo'
      Room.rooms.should.have.property 'room'


    it 'works if the connection was not in the room to begin with', ->
      room.removeConnection 'foo'

