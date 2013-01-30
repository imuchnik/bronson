(function() {
  var FS, Room, Route, crypto, md5;

  FS = require('fs');

  crypto = require('crypto');

  Room = require('../room');

  md5 = function(s) {
    var md5sum;
    md5sum = crypto.createHash('md5');
    return md5sum.update(s).digest('hex');
  };

  Route = (function() {

    function Route() {
      this.subRoutes = {};
      this.etag = null;
    }

    Route.prototype.setOptions = function(options) {
      this.file = options.file;
      this.type = options.type;
      this.compiler = options.compiler;
      if (options.render != null) {
        return this.render = options.render;
      }
    };

    Route.prototype.addSubRoute = function(str, route) {
      if (str[0] === ':') {
        this.varName = str.substr(1);
        return this.varRoute = route;
      } else {
        return this.subRoutes[str] = route;
      }
    };

    Route.prototype.getSubRoute = function(str, vars) {
      if (vars == null) {
        vars = null;
      }
      if (this.subRoutes[str] != null) {
        return this.subRoutes[str];
      }
      if ((vars != null) && (this.varRoute != null)) {
        vars[this.varName] = str;
        return this.varRoute;
      }
      return null;
    };

    Route.prototype.render = function(request) {
      var _this = this;
      if ((this.etag != null) && request.headers['if-none-match'] === this.etag) {
        request.notModified();
      }
      return FS.readFile("" + __dirname + "/../../" + this.file, function(err, data) {
        if (err != null) {
          return request.err(500);
        }
        if (_this.etag == null) {
          _this.etag = md5(data.toString());
        }
        if (_this.compiler != null) {
          data = _this.compiler.compile(data.toString())({
            geoip: require('geoip-lite'),
            rooms: Room.rooms
          });
        }
        return request.end(data, _this.type, _this.etag);
      });
    };

    return Route;

  })();

  module.exports = Route;

}).call(this);
