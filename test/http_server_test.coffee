sinon = require('./test_helper').sinon
portFinder = require 'portfinder'
http = require 'http'
fs = require 'fs'
HttpServer = require '../src/http_server'
HttpRequest = HttpServer.HttpRequest
Room = require '../src/room.coffee'

describe 'HttpServer', ->

  unused_port = null
  httpServer = null
  beforeEach (done) ->
    portFinder.getPort (err, port) ->
      throw err if err
      unused_port = port
      httpServer = new HttpServer unused_port
      done()


  describe 'constructor', ->
    it 'creates a new http server that listens on the specified port', (done) ->
      requestOptions =
        host: 'localhost'
        port: unused_port
        path: '/bronson/'
      request = http.request requestOptions, -> done()
      request.end()


  describe 'routeHandlers', ->

    mockHttpRequest = null
    beforeEach ->
      mockHttpRequest = {}

    describe 'clientLibrary', ->
      it 'returns the client-side library as /bronson/bronson.js', (done) ->
        fsData = fs.readFileSync('client/bronson.min.js').toString()
        httpServer.routeHandlers.clientLibrary mockHttpRequest
        mockHttpRequest.end = (data) ->
          data.should.eql fsData
          done()


    describe 'room', ->
      it 'returns an empty object if the room does not exist', (done) ->
        mockHttpRequest.end = (data) ->
          data.should.eql "{}"
          done()
        httpServer.routeHandlers.room mockHttpRequest, "empty room"

      it 'returns json string with an array of connected clients to the room', ->
        Room.rooms["test room"] = mockRoom = new Room
        mockRoom.connections = [
          { userId: 1 }
          { userId: 2 }
          { userId: 3 }
        ]
        mockHttpRequest.end = (data) ->
          connections = JSON.parse(data).connections
          connections.should.have.length 3
          connections.should.include 1
          connections.should.include 2
          connections.should.include 3
        httpServer.routeHandlers.room mockHttpRequest, "test room"



describe 'HttpRequest', ->

  httpRequest = null
  mockHttpRequest = null
  mockHttpResponse = null
  testData = null
  testContentType = null
  beforeEach ->
    mockHttpRequest = url: "/p/a/t/h?query=string"
    mockHttpResponse =
      writeHead: sinon.spy()
      write: sinon.spy()
      end: sinon.spy()
    httpRequest = new HttpRequest mockHttpRequest, mockHttpResponse

  describe 'constructor', ->
    it 'parses the path into a path array', ->
      httpRequest.path.should.eql ['p', 'a', 't', 'h']

    it 'saves the parsed query into res.query object', ->
      httpRequest.req.query.should.eql query: 'string'


  describe 'end', ->
    beforeEach ->
      testData = 'test data'
      testContentType = 'content/type'
      httpRequest.end testData, testContentType

    it 'writes the proper http headers', ->
      mockHttpResponse.writeHead.should.have.been.calledOnce
      mockHttpResponse.writeHead.args[0][0].should.eql 200
      mockHttpResponse.writeHead.args[0][1].should.eql
        'Content-Type': testContentType
        'Content-Length': testData.length

    it 'writes the data', ->
      mockHttpResponse.write.should.have.been.calledOnce
      mockHttpResponse.write.args[0][0].should.eql testData

    it 'ends the stream', ->
      mockHttpResponse.end.should.have.been.calledOnce


  describe 'callback is passed (JSONP mode)', ->
    beforeEach ->
      testData = '{ test: "data" }'
      testContentType = 'application/json'
      httpRequest.req.query.callback = 'mycallback'
      httpRequest.end testData, testContentType

    it 'wraps the passed data in a callback', ->
      mockHttpResponse.write.should.have.been.calledOnce
      mockHttpResponse.write.args[0][0].should.eql "mycallback(#{testData})"

    it 'sets the content type to text/javascript', ->
      mockHttpResponse.writeHead.args[0][1]['Content-Type'].should.eql "text/javascript"
