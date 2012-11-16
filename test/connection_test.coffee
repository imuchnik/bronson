sinon = require('./test_helper').sinon
Connection = require('../src/connection')


describe 'Connection', ->

  connection = mockSocket = mockBackendHandler = null
  beforeEach ->
    mockSocket = on: ->
    mockBronson = testing: yes, options: { sendToSelf: true }, emit: ->
    mockBackendHandler = {}
    mockBackendHandler.request = sinon.stub()
    connection = new Connection mockSocket, mockBronson, mockBackendHandler
    connection.error = sinon.spy()
    connection.emit = sinon.spy()


  describe 'constructor', ->

    it 'stores the given socket', ->
      connection.socket.should.equal mockSocket

    it 'stores the given BackendHandler instance', ->
      connection.backendHandler.should.equal mockBackendHandler


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

      broadcastObject = onHttpRequest = null
      beforeEach ->
        onHttpRequest = ->
        connection.room = broadcast: sinon.spy()
        broadcastObject =
          event: 'foo'
          broadcast: 'bc data'
          backendRequest: data: 'be data'
        mockBackendHandler.request = (backendRequest) ->
          onHttpRequest.apply {}, arguments
          backendRequest.success 'be response'

      it 'makes a request to the backend with the given data', (done) ->
        onHttpRequest = (backendRequest) ->
          backendRequest.data.should.eql 'be data'
          done()
        connection.broadcast broadcastObject


      describe 'backend request done', ->

        it 'broadcasts the original broadcast data', (done) ->
          connection.room.broadcast = (event, data) ->
            data.broadcast.should.eql 'bc data'
            done()
          connection.broadcast broadcastObject

        it 'broadcasts the response from the backend', (done) ->
          connection.room.broadcast = (event, data) ->
            data.backendResponse.should.eql 'be response'
            done()
          connection.broadcast broadcastObject

        describe 'backend request exception', ->
          it 'sends an error back to the connection'
          it 'logs the error on the console'


    describe 'no backend request', ->
      it 'does not call the backend', ->
        connection.broadcast event: 'foo'
        connection.backendHandler.request.should.not.have.been.called


      it 'performs a broadcast', ->
        connection.room = broadcast: sinon.spy()
        connection.broadcast event: 'foo'
        connection.room.broadcast.should.have.been.calledOnce


      it 'broadcasts the original broadcast data', ->
        connection.room = broadcast: sinon.spy()
        connection.broadcast event: 'foo', broadcast: 'bc data'
        connection.room.broadcast.args[0][0].should.equal('foo')
        connection.room.broadcast.args[0][1].should.eql(broadcast: 'bc data')

