sinon = require('./test_helper').sinon
portFinder = require 'portfinder'
http = require 'http'
fs = require 'fs'
HttpServer = require '../src/http_server/http_server'
HttpRequest = require '../src/http_server/http_request'
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

    it 'saves the parsed query into req.url.query object', ->
      httpRequest.req.url.query.should.eql query: 'string'


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
      httpRequest.req.url.query.callback = 'mycallback'
      httpRequest.end testData, testContentType

    it 'wraps the passed data in a callback', ->
      mockHttpResponse.write.should.have.been.calledOnce
      mockHttpResponse.write.args[0][0].should.eql "mycallback(#{testData})"

    it 'sets the content type to text/javascript', ->
      mockHttpResponse.writeHead.args[0][1]['Content-Type'].should.eql "text/javascript"
