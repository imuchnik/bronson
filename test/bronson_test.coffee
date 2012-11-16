sinon = require('./test_helper').sinon
http = require 'http'
fs = require 'fs'
portFinder = require 'portfinder'
Bronson = require('../src/bronson')


describe 'Bronson', ->

  describe 'constructor', ->

    describe 'sendToSelf configuration option', ->

      it 'is true by default', ->
        bronson = new Bronson
        bronson.options.sendToSelf.should.be.true

      it 'can be overridden to FALSE', ->
        bronson = new Bronson null, null, sendToSelf: false
        bronson.options.sendToSelf.should.be.false

    describe 'backendHandler instance', ->

      it 'creates an BackendHandler instance if a host is given', ->
        bronson = new Bronson 'host', 80
        bronson.backendHandler.should.exist

      it 'does not create a BackendHandler instance if no host is given', ->
        bronson = new Bronson
        bronson.should.not.have.property 'backendHandler'


  describe 'listen', ->

    unused_port = null
    beforeEach (done) ->
      portFinder.getPort (err, port) ->
        throw err if err
        unused_port = port
        done()

    it 'serves the client-side library as /bronson/bronson.js', (done) ->
      bronson = new Bronson
      bronson.listen unused_port, "log level": 0
      requestOptions =
        host: 'localhost'
        port: unused_port
        path: '/bronson/bronson.js'

      httpData = ''
      fsData = fs.readFileSync('client/bronson.min.js').toString()
      request = http.request requestOptions, (res) ->
        res.on 'data', (chunk) -> httpData += chunk
        res.on 'end', ->
          httpData.should.equal fsData
          done()
      request.end()
