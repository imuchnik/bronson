(function() {

  window.Bronson = (function() {

    function Bronson(host) {
      var _this = this;
      if (host == null) {
        host = window.location.origin;
      }
      this.socket = io.connect(host);
      this.socket.on('connect', function() {
        if (_this.room != null) {
          return _this.joinRoom(_this.room, _this.username);
        }
      });
    }

    Bronson.prototype.broadcast = function(event, payload, sendToSelf) {
      if (sendToSelf == null) {
        sendToSelf = true;
      }
      return this.socket.emit('send', {
        event: event,
        toSelf: sendToSelf,
        broadcast: payload
      });
    };

    Bronson.prototype.emit = function(event, settings) {
      var backendRequest, _base, _ref, _ref1, _ref2;
      if (settings.path != null) {
        if ((_ref = settings.type) == null) {
          settings.type = 'GET';
        }
        if ((_ref1 = settings.headers) == null) {
          settings.headers = {};
        }
        if ((_ref2 = (_base = settings.headers).cookie) == null) {
          _base.cookie = document.cookie;
        }
        backendRequest = {
          data: settings.data,
          headers: settings.headers,
          method: settings.type,
          path: settings.path,
          toSelf: settings.sendToSelf
        };
      }
      return this.socket.emit('send', {
        event: event,
        broadcast: settings.broadcast,
        backendRequest: backendRequest
      });
    };

    Bronson.prototype.joinRoom = function(room, username) {
      this.room = room;
      this.username = username != null ? username : "";
      return this.socket.emit('join', {
        roomId: this.room,
        userId: this.username
      });
    };

    Bronson.prototype.on = function(event, callback) {
      return this.socket.on(event, callback);
    };

    Bronson.prototype.ping = function() {
      return this.socket.emit('ping', +(new Date));
    };

    return Bronson;

  })();

}).call(this);
