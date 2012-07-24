// Generated by CoffeeScript 1.3.3
(function() {
  var http;

  http = require('http');

  exports.HTTPHost = "";

  exports.HTTPController = (function() {

    function HTTPController(hostname, port) {
      this.hostname = hostname;
      this.port = port;
    }

    HTTPController.prototype.request = function(obj) {
      var jsonString, options, request, _ref, _ref1, _ref2;
      if ((_ref = obj.data) == null) {
        obj.data = {};
      }
      if ((_ref1 = obj.method) == null) {
        obj.method = 'POST';
      }
      if ((_ref2 = obj.headers) == null) {
        obj.headers = {};
      }
      obj.path = obj.path.replace(/[^a-z0-9/_.-]/ig, "");
      jsonString = JSON.stringify(obj.data);
      options = {
        host: this.hostname,
        port: this.port,
        path: obj.path,
        method: obj.method,
        headers: obj.headers
      };
      options.headers['Content-Type'] = 'application/json';
      options.headers['Content-Length'] = Buffer.byteLength(jsonString, 'utf8');
      request = http.request(options, function(response) {
        var responseBody;
        responseBody = "";
        response.on('data', function(chunk) {
          return responseBody += chunk;
        });
        return response.on('end', function() {
          try {
            console.log(responseBody);
            if (responseBody.trim() !== '') {
              return obj.success(JSON.parse(responseBody));
            } else {
              return obj.success();
            }
          } catch (error) {
            return obj.error(error);
          }
        });
      });
      request.write(jsonString);
      return request.end();
    };

    return HTTPController;

  })();

}).call(this);
