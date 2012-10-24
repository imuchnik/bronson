sinon = require('./test_helper').sinon
Connection = require('../src/connection')


describe 'Connection', ->

  connection = mockSocket = mockHttpController = null
  beforeEach ->
    mockSocket = on: ->
    mockBronson = testing: yes, options: { sendToSelf: true }, emit: ->
    mockHttpController = {}
    mockHttpController.request = sinon.stub()
    connection = new Connection mockSocket, mockBronson, mockHttpController
    connection.error = sinon.spy()
    connection.emit = sinon.spy()


  describe 'constructor', ->

    it 'stores the given socket', ->
      connection.socket.should.equal mockSocket

    it 'stores the given HttpController instance', ->
      connection.httpController.should.equal mockHttpController


  describe 'broadcast', ->

    it 'returns an error if the user is not in a room', ->
      connection.broadcast 'foo'
      connection.error.should.have.been.calledOnce

    it 'returns an error if no event name is given', ->
      connection.room = {}
      connection.broadcast {}
      connection.error.should.have.been.calledOnce

    it 'returns an error if no data is given', ->
      connection.room = {}
      connection.broadcast()
      connection.error.should.have.been.calledOnce


    describe 'sendToSelf', ->

      beforeEach ->
        connection.room = broadcast: sinon.spy()

      afterEach ->
        connection.room.broadcast.should.have.been.calledOnce

      it "uses the toSelf paramter if TRUE is given", ->
        connection.broadcast toSelf: true, event: 'foo'
        connection.room.broadcast.args[0][2].should.be.true

      it "uses the toSelf paramter if FALSE is given", ->
        connection.broadcast toSelf: false, event: 'foo'
        connection.room.broadcast.args[0][2].should.be.false

      it "uses bronsons default setting if the toSelf paramter is not provided", ->
        connection.broadcast event: 'foo'
        connection.room.broadcast.args[0][2].should.be.true

    describe 'backend request', ->
      it 'returns an error if no backend is configured', ->
        connection.broadcast backendRequest: 1
        connection.error.should.have.been.calledOnce

      it 'makes a request to the backend with the given data'


      #      describe 'backend request done', ->

      # it 'performs a broadcast'

      # it 'broadcasts the response from the backend'

      # it 'broadcasts the original broadcast data'

      # describe 'backend request exception', ->
      #   it 'sends an error back to the connection'
      #   it 'logs the error on the console'


    describe 'no backend request', ->
      it 'does not call the backend', ->
        connection.broadcast event: 'foo'
        connection.httpController.request.should.not.have.been.called


      it 'performs a broadcast', ->
        connection.room = broadcast: sinon.spy()
        connection.broadcast event: 'foo'
        connection.room.broadcast.should.have.been.calledOnce


      it 'broadcasts the original broadcast data', ->
        connection.room = broadcast: sinon.spy()
        connection.broadcast event: 'foo', broadcast: 'bc data'
        connection.room.broadcast.args[0][0].should.equal('foo')
        connection.room.broadcast.args[0][1].should.eql(broadcast: 'bc data')

