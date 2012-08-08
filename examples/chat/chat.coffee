# This part serves the web pages
fs = require 'fs'
app = require('http').createServer (req, res) ->
  fs.readFile 'chat.html', (err, data) ->
    if (err)
      res.writeHead 500
      return res.end "Error loading '/examples/chat/chat.html'"

    res.writeHead 200
    res.end data

app.listen 3000


# This part starts the Chat server.
Bronson = require '../..'
bronson = new Bronson 'backend.host.address.com'
bronson.listen app

