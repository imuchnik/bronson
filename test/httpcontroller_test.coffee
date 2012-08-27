sinon = require('./test_helper').sinon
portFinder = require 'portfinder'
HttpController = require('../src/httpcontroller')
http = require 'http'


describe 'HttpController', ->

  describe 'constructor', ->

    it 'stores the hostname and port parameters', ->
      httpController = new HttpController 'host', 3000
      httpController.hostname.should.equal 'host'
      httpController.port.should.equal 3000

    it 'uses port 80 by default', ->
      httpController = new HttpController 'host'
      httpController.port.should.equal 80


  describe 'request', ->

    httpController = null
    requestOptions = null
    requestFunction = ->

    beforeEach (done) ->
      portFinder.getPort (err, port) ->
        throw err if err

        httpServer = http.createServer (req, res) ->
          requestFunction(req, res)
          res.end() # Finish the request if requestFunction hasn't already
        httpServer.listen port

        requestOptions =
          path: '/'
          success: -> throw "Success callback should not have been called"
          error: -> throw "Error callback should not have been called"

        httpController = new HttpController 'localhost', port
        done()


    it 'executes a backend request', (done) ->
      requestFunction = sinon.spy()
      requestOptions.success = ->
        requestFunction.should.have.been.calledOnce
        done()
      httpController.request requestOptions


    it 'calls error callback if server returns an error', (done) ->
      requestFunction = (req, res) -> res.writeHead 404
      requestOptions.error = -> done()
      httpController.request requestOptions


    it 'passes the proper path to the server', (done) ->
      path = "/some/path/to/file"
      requestFunction = (req, res) -> req.url.should.equal path
      requestOptions.path = path
      requestOptions.success = -> done()
      httpController.request requestOptions


    it 'passes the proper request method to the server', (done) ->
      requestFunction = (req, res) -> req.method.should.equal "DELETE"
      requestOptions.method = "DELETE"
      requestOptions.success = -> done()
      httpController.request requestOptions


    it 'sends payload data to the server', (done) ->
      requestFunction = (req, res) ->
        requestData = ""
        req.on 'data', (data) -> requestData += data
        req.on 'end', ->
          requestData.toString().should.equal '{"hello":"world"}'
          done()
      requestOptions.data = { hello: "world" }
      requestOptions.success = ->
      httpController.request requestOptions


    it 'passes the response body as a paramter to the success callback', (done) ->
      responseBody = "This is the response data"
      requestFunction = (req, res) -> res.write responseBody
      requestOptions.success = (res) ->
        res.should.equal responseBody
        done()
      httpController.request requestOptions


  describe 'sanitize_url', ->

    it 'filters out special characters', ->
      HttpController.sanitize_url('!@#$%^&*()|?_-/\\').should.equal '_-/'

    it 'passes valid URLs', ->
      HttpController.sanitize_url('www.bronson.com/bronson-is/the_best').should.equal 'www.bronson.com/bronson-is/the_best'

