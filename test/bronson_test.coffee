assert = require 'assert'
chai = require 'chai'
should = chai.should()
sinon = require 'sinon'
chai.use require 'sinon-chai'

Bronson = require('../src/bronson')
Connection = require('../src/connection')


describe 'Bronson', ->

  describe 'constructor', ->

    describe 'sendToSelf configuration option', ->
      
      it 'is true by default', ->
        bronson = new Bronson
        bronson.options.sendToSelf.should.be.true

      it 'can be overridden to FALSE', ->
        bronson = new Bronson null, null, sendToSelf: false
        bronson.options.sendToSelf.should.be.false

