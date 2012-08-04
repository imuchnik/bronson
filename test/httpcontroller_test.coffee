sinon = require('./test_helper').sinon
HttpController = require('../src/httpcontroller')


describe 'HttpController', ->

  describe 'constructor', ->

    it 'stores the hostname and port parameters', ->
      httpController = new HttpController 'host', 3000
      httpController.hostname.should.equal 'host'
      httpController.port.should.equal 3000

    it 'uses port 80 by default', ->
      httpController = new HttpController 'host'
      httpController.port.should.equal 80


  describe 'sanitize_url', ->

    it 'filters out special characters', ->
      HttpController.sanitize_url('!@#$%^&*()|?_-/\\').should.equal '_-/'

    it 'passes valid URLs', ->
      HttpController.sanitize_url('www.bronson.com/bronson-is/the_best').should.equal 'www.bronson.com/bronson-is/the_best'

