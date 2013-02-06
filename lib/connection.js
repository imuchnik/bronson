(function() {
  var Connection, Room,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Room = require('./room');

  Connection = (function() {

    function Connection(socket, bronson, backendHandler) {
      this.socket = socket;
      this.bronson = bronson;
      this.backendHandler = backendHandler;
      this.ping = __bind(this.ping, this);

      this.joinRoom = __bind(this.joinRoom, this);

      this.disconnect = __bind(this.disconnect, this);

      this.broadcast = __bind(this.broadcast, this);

      this.socket.on('disconnect', this.disconnect);
      this.socket.on('join', this.joinRoom);
      this.socket.on('ping', this.ping);
      this.socket.on('send', this.broadcast);
      this.ip = this.socket.handshake.address.address;
      this.log('Client connected', {
        transport: this.socket.transport
      });
    }

    Connection.prototype.broadcast = function(data) {
      var response, _ref,
        _this = this;
      if (this.room == null) {
        return this.error("Not in a room");
      }
      if (data == null) {
        return this.error("Missing data");
      }
      if (!data.event) {
        return this.error("No event name given");
      }
      if ((_ref = data.toSelf) == null) {
        data.toSelf = this.bronson.options.sendToSelf;
      }
      response = {};
      if (data.broadcast != null) {
        response.broadcast = data.broadcast;
      }
      this.log("Client broadcasted '" + data.event + "' into room '" + this.room.id + "'");
      if (data.backendRequest != null) {
        if (this.backendHandler == null) {
          return this.error("No backend server specified");
        }
        return this.backendHandler.request({
          data: data.backendRequest.data,
          path: data.backendRequest.path,
          method: data.backendRequest.method,
          headers: data.backendRequest.headers,
          error: function(error) {
            return console.error(error);
          },
          success: function(backendResponse) {
            response.backendResponse = backendResponse;
            return _this.room.broadcast(data.event, response, data.toSelf, _this);
          }
        });
      } else {
        return this.room.broadcast(data.event, response, data.toSelf, this);
      }
    };

    Connection.prototype.disconnect = function() {
      var _ref, _ref1;
      if ((_ref = this.room) != null) {
        _ref.removeConnection(this);
      }
      if ((_ref1 = this.room) != null) {
        _ref1.broadcast('room left', {
          userId: this.userId,
          usersInRoom: this.room.getUserIds()
        });
      }
      return this.log("Client disconnected");
    };

    Connection.prototype.emit = function(message, data) {
      return this.socket.emit(message, data);
    };

    Connection.prototype.error = function(errorMessage) {
      this.log("Client error", {
        error: errorMessage
      });
      return this.socket.emit('error', errorMessage);
    };

    Connection.prototype.joinRoom = function(data) {
      var _ref;
      if (!((data != null) && (data.userId != null) && (data.roomId != null))) {
        return;
      }
      if ((_ref = this.room) != null) {
        _ref.removeConnection(this);
      }
      this.userId = data.userId;
      this.room = Room.get(data.roomId);
      this.room.addConnection(this);
      this.room.broadcast('room joined', {
        userId: this.userId,
        usersInRoom: this.room.getUserIds()
      });
      this.log("Client joined room", {
        roomId: data.roomId
      });
      return this.bronson.emit('room joined', data);
    };

    Connection.prototype.log = function(event, data) {
      var logObj, option;
      if (data == null) {
        data = {};
      }
      logObj = {
        event: event,
        date: new Date(),
        client: {
          ip: this.ip,
          userId: this.userId,
          socketId: this.socket.id
        }
      };
      for (option in data) {
        logObj[option] = data[option];
      }
      return this.bronson.log(logObj);
    };

    Connection.prototype.ping = function(data) {
      return this.emit('pong', data);
    };

    return Connection;

  })();

  module.exports = Connection;

}).call(this);
