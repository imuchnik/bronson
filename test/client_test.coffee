assert = require 'assert'
Client = require('../src/client').Client
should = require('chai').should()
sinon = require('sinon')

describe 'Client', ->

  client = mockSocket = mockHttpController = null
  beforeEach ->
    mockSocket = { on: -> }
    mockHttpController = {}
    mockHttpController.request = sinon.stub()
    client = new Client mockSocket, mockHttpController
    client.error = sinon.spy()
    client.emit = sinon.spy()


  describe 'constructor', ->

    it 'stores the given socket', ->
      client.socket.should.equal mockSocket

    it 'stores the given HttpController instance', ->
      client.httpController.should.equal mockHttpController


  describe 'broadcast', ->

    it 'returns an error if the user is not in a room', ->
      client.broadcast('foo')
      client.error.should.have.been.calledOnce

    it 'returns an error if no data is given', ->
      client.broadcast()
      client.error.should.have.been.calledOnce

    describe 'backend request', ->
      it 'returns an error if no backend is configured', ->
        client.broadcast { backendRequest: 1 }
        client.error.should.have.been.calledOnce

      it 'makes a request to the backend with the given data', ->


      describe 'backend request done', ->

        it 'performs a broadcast'

        it 'broadcasts the response from the backend'

        it 'broadcasts the original broadcast data'

        describe 'backend request exception', ->
          it 'sends an error back to the client'
          it 'logs the error on the console'


    describe 'no backend request', ->
      it 'does not call the backend'

      it 'performs a broadcast'
      
      it 'broadcasts the original broadcast data'
