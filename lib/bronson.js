(function() {
  var BackendHandler, Bronson, Connection, EventEmitter, FS, HttpServer, IO, Room,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  IO = require('socket.io');

  FS = require('fs');

  Connection = require('./connection');

  Room = require('./room');

  BackendHandler = require('./backend_handler');

  HttpServer = require('./http_server/http_server');

  EventEmitter = require('events').EventEmitter;

  Bronson = (function(_super) {

    __extends(Bronson, _super);

    function Bronson(host, port, options) {
      var _base, _base1, _ref, _ref1,
        _this = this;
      this.options = options != null ? options : {};
      if ((_ref = (_base = this.options).sendToSelf) == null) {
        _base.sendToSelf = true;
      }
      if ((_ref1 = (_base1 = this.options).logFn) == null) {
        _base1.logFn = function(obj) {
          var logMsg;
          logMsg = "\x1b[0m[" + (new Date) + "]\x1b[0;32m " + obj.event;
          logMsg += "\x1b[0m  -  (" + (JSON.stringify(obj)) + ")";
          return console.log(logMsg);
        };
      }
      this.log = function(data) {
        return _this.options.logFn(data);
      };
      if (host) {
        this.backendHandler = new BackendHandler(host, port, this);
      }
    }

    Bronson.prototype.listen = function(port, options) {
      var httpServer,
        _this = this;
      if (options == null) {
        options = {};
      }
      httpServer = new HttpServer(port);
      this.io = IO.listen(httpServer.server, options);
      return this.io.sockets.on('connection', function(socket) {
        return new Connection(socket, _this, _this.backendHandler);
      });
    };

    return Bronson;

  })(EventEmitter);

  module.exports = Bronson;

}).call(this);
