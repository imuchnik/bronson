sinon = require('./test_helper').sinon
http = require 'http'
fs = require 'fs'
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

    describe 'httpController instance', ->

      it 'creates an HttpController instance if a host is given', ->
        bronson = new Bronson 'host', 80
        bronson.httpController.should.exist

      it 'does not create a HttpController instance if no host is given', ->
        bronson = new Bronson
        bronson.should.not.have.property 'httpController'


  describe 'listen', ->

    it 'serves the client-side library as /bronson/bronson.js', (done) ->
      bronson = new Bronson
      bronson.listen 8080
      requestOptions =
        host: 'localhost'
        port: 8080
        path: '/bronson/bronson.js'

      httpData = ''
      fsData = fs.readFileSync('client/bronson.min.js').toString()
      request = http.request requestOptions, (res) ->
        res.on 'data', (chunk) -> httpData += chunk
        res.on 'end', ->
          httpData.should.equal fsData
          done()
      request.end()
