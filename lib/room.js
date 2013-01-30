(function() {
  var Room;

  Room = (function() {

    Room.rooms = {};

    Room.get = function(roomId) {
      if (Room.rooms[roomId] == null) {
        Room.rooms[roomId] = new Room(roomId);
      }
      return Room.rooms[roomId];
    };

    function Room(id) {
      this.id = id;
      this.connections = [];
    }

    Room.prototype.addConnection = function(connection) {
      if (!this.hasConnection(connection)) {
        return this.connections.push(connection);
      }
    };

    Room.prototype.broadcast = function(event, data, sendToSelf, self) {
      var connection, _i, _len, _ref, _results;
      _ref = this.connections;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        connection = _ref[_i];
        if (sendToSelf || connection !== self) {
          _results.push(connection.emit(event, data));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Room.prototype.getUserIds = function() {
      var connection, _i, _len, _ref, _results;
      _ref = this.connections;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        connection = _ref[_i];
        _results.push(connection.userId);
      }
      return _results;
    };

    Room.prototype.hasConnection = function(connection) {
      return this.connections.indexOf(connection) > -1;
    };

    Room.prototype.removeConnection = function(connection) {
      var pos;
      pos = this.connections.indexOf(connection);
      if (pos > -1) {
        this.connections.splice(pos, 1);
      }
      if (this.connections.length === 0) {
        return delete Room.rooms[this.id];
      }
    };

    return Room;

  })();

  module.exports = Room;

}).call(this);
