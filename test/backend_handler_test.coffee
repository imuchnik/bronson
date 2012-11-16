sinon = require('./test_helper').sinon
portFinder = require 'portfinder'
BackendHandler = require('../src/backend_handler')
http = require 'http'


describe 'BackendHandler', ->

  describe 'constructor', ->

    it 'stores the hostname and port parameters', ->
      backendHandler = new BackendHandler 'host', 3000
      backendHandler.hostname.should.equal 'host'
      backendHandler.port.should.equal 3000

    it 'uses port 80 by default', ->
      backendHandler = new BackendHandler 'host'
      backendHandler.port.should.equal 80


  describe 'request', ->

    backendHandler = null
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

        backendHandler = new BackendHandler 'localhost', port
        done()


    it 'executes a backend request', (done) ->
      requestFunction = sinon.spy()
      requestOptions.success = ->
        requestFunction.should.have.been.calledOnce
        done()
      backendHandler.request requestOptions


    it 'passes the returned status code from the server', (done) ->
      requestFunction = (req, res) -> res.writeHead 404
      requestOptions.success = (res) ->
        res.status.should.eql 404
        done()
      backendHandler.request requestOptions


    it 'passes the proper path to the server', (done) ->
      path = "/some/path/to/file"
      requestFunction = (req, res) -> req.url.should.equal path
      requestOptions.path = path
      requestOptions.success = -> done()
      backendHandler.request requestOptions


    it 'passes the proper request method to the server', (done) ->
      requestFunction = (req, res) -> req.method.should.equal "DELETE"
      requestOptions.method = "DELETE"
      requestOptions.success = -> done()
      backendHandler.request requestOptions


    it 'sends payload data to the server', (done) ->
      requestFunction = (req, res) ->
        requestData = ""
        req.on 'data', (data) -> requestData += data
        req.on 'end', ->
          requestData.toString().should.equal '{"hello":"world"}'
          done()
      requestOptions.data = { hello: "world" }
      requestOptions.success = ->
      backendHandler.request requestOptions


    it 'passes the response body as a paramter to the success callback', (done) ->
      responseBody = "This is the response data"
      requestFunction = (req, res) -> res.write responseBody
      requestOptions.success = (res) ->
        res.body.should.eql responseBody
        done()
      backendHandler.request requestOptions


  describe 'sanitize_url', ->

    it 'filters out special characters', ->
      BackendHandler.sanitize_url('!@#$%^&*()|?_-/\\').should.equal '_-/'

    it 'passes valid URLs', ->
      BackendHandler.sanitize_url('www.bronson.com/bronson-is/the_best').should.equal 'www.bronson.com/bronson-is/the_best'

