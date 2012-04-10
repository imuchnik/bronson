

require('should')

Room = require('../room.js').Room
Client = require('../client.js').Client
Rails = require('../RailsAPI.js')
http = require('http')


class sampleSocket
  constructor: ->
    @emits = {}
    @emit = ->
  emulateEmit: (event, data) ->
    @emits[event]?(data)
  on: (event, fn) ->
    @emits[event] = fn


sampleInitObject = {userId:1,roomId:1,uri:"/"}


railsServerDoneFunction = ->
demoRailsServer = http.createServer( (request, response) ->
  response.end('{"debug":1}')
  railsServerDoneFunction()
).listen(8080)


describe('Client',->
  describe('constructor',->
    it('should add to Client.list when creating a new client object',->
      client = new Client(new sampleSocket())
      Client.list.should.include(client)
    )
  )

  describe('init', ->
    
    it('should notify rails via http that a client connected', (done) ->


      railsServerDoneFunction = done
      socket = new sampleSocket()
      client = new Client(socket)
      socket.emulateEmit('init',sampleInitObject)
    )


    it('should broadcast the response from rails to all initialized clients', (done) ->


      emitCounter = 0

      railsServerDoneFunction = ->
      socket1 = new sampleSocket()
      socket2 = new sampleSocket()

      socket1.emit = (event, data) ->
        emitCounter++

      socket2.emit = (event, data) ->
        emitCounter++
        emitCounter.should.equal(3)
        done()

      client = new Client(socket1)
      client2 = new Client(socket2)

      socket1.emulateEmit('init',sampleInitObject)
      socket2.emulateEmit('init',sampleInitObject)
      
    )

  )
)
