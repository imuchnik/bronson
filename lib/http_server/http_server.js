(function() {
  var HTTP, HttpRequest, HttpServer, Room, Route, jade,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  HTTP = require('http');

  jade = require('jade');

  Room = require('../room');

  Route = require('./route');

  HttpRequest = require('./http_request');

  HttpServer = (function() {

    function HttpServer(port) {
      this.handleRequest = __bind(this.handleRequest, this);

      var _this = this;
      if (typeof port === 'number') {
        this.server = HTTP.createServer(this.handleRequest);
        this.server.listen(port);
      } else {
        this.server = port;
        this.server.on('request', this.handleRequest);
      }
      this.routes = new Route;
      this.routes.setOptions({
        type: 'text/plain',
        render: function(request) {
          return request.end('Welcome to Bronson.');
        }
      });
      this.addRoute('bronson.js', {
        file: 'client/bronson.min.js',
        type: 'text/javascript'
      });
      this.addRoute('admin', {
        file: 'admin/index.jade',
        type: 'text/html',
        compiler: jade
      });
      this.addRoute('admin/js', {
        file: 'admin/index.js',
        type: 'text/javascript'
      });
      this.addRoute('admin/css', {
        file: 'admin/index.css',
        type: 'text/css'
      });
      this.addRoute('admin/frame', {
        file: 'admin/frame.jade',
        type: 'text/html',
        compiler: jade
      });
      this.addRoute('admin/throbber', {
        file: 'admin/img/throbber.gif',
        type: 'image/gif'
      });
      this.addRoute('room/:roomId', {
        type: 'application/json',
        render: function(request, vars) {
          return request.end(_this.getRoomData(vars.roomId));
        }
      });
    }

    HttpServer.prototype.addRoute = function(path, options) {
      var newRoute, pathPart, routePointer, subRoute, _i, _len, _ref;
      routePointer = this.routes;
      _ref = path.split('/');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pathPart = _ref[_i];
        subRoute = routePointer.getSubRoute(pathPart);
        if (subRoute != null) {
          routePointer = subRoute;
        } else {
          newRoute = new Route;
          routePointer.addSubRoute(pathPart, newRoute);
          routePointer = newRoute;
        }
      }
      return routePointer.setOptions(options);
    };

    HttpServer.prototype.getRoomData = function(roomId) {
      var obj;
      if (Room.rooms[roomId] != null) {
        obj = {
          connections: Room.rooms[roomId].getUserIds()
        };
      } else {
        obj = {};
      }
      return JSON.stringify(obj);
    };

    HttpServer.prototype.handleRequest = function(req, res) {
      var pathPart, request, requestVars, routePointer, _i, _len, _ref;
      request = new HttpRequest(req, res);
      if (!request.isBronsonNamespace()) {
        return;
      }
      routePointer = this.routes;
      requestVars = {};
      _ref = request.path.slice(1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pathPart = _ref[_i];
        if (pathPart === '') {
          continue;
        }
        routePointer = routePointer.getSubRoute(pathPart, requestVars);
        if (routePointer == null) {
          break;
        }
      }
      if (routePointer != null) {
        return routePointer.render(request, requestVars);
      } else {
        return request.err(404);
      }
    };

    return HttpServer;

  })();

  module.exports = HttpServer;

}).call(this);
