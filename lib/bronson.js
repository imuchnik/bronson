// Generated by CoffeeScript 1.3.3
(function() {
  var Bronson, Client, EventEmitter, HTTPController, IO, Room,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  IO = require('socket.io');

  Client = require('./client');

  Room = require('./room');

  HTTPController = require('./httpcontroller');

  EventEmitter = require('events').EventEmitter;

  Bronson = (function(_super) {

    __extends(Bronson, _super);

    function Bronson(host, port) {
      if (host) {
        this.httpController = new HTTPController(host, port);
      }
    }

    Bronson.prototype.listen = function(port, options) {
      if (options == null) {
        options = {};
      }
      this.io = IO.listen(port, options);
      return this.io.sockets.on('connection', function(socket) {
        return new Client(socket, this, this.httpController);
      });
    };

    return Bronson;

  })(EventEmitter);

  module.exports = Bronson;

}).call(this);