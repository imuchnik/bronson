assert = require 'assert'
chai = require 'chai'
should = chai.should()
sinon = require 'sinon'
chai.use require 'sinon-chai'

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

