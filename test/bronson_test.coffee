sinon = require('./test_helper').sinon
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

