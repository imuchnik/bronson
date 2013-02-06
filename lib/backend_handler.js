(function() {
  var BackendHandler, http;

  http = require('http');

  BackendHandler = (function() {

    function BackendHandler(hostname, port, bronson) {
      var _ref;
      this.hostname = hostname;
      this.port = port != null ? port : 80;
      this.bronson = bronson;
      if ((_ref = this.bronson) == null) {
        this.bronson = {
          log: (function() {})
        };
      }
    }

    BackendHandler.sanitize_url = function(url) {
      return url.replace(/[^a-z0-9/_.-]/ig, "");
    };

    BackendHandler.prototype.request = function(obj) {
      var jsonString, options, request, startRequestTime, _ref, _ref1, _ref2,
        _this = this;
      if ((_ref = obj.data) == null) {
        obj.data = {};
      }
      if ((_ref1 = obj.method) == null) {
        obj.method = 'POST';
      }
      if ((_ref2 = obj.headers) == null) {
        obj.headers = {};
      }
      obj.path = BackendHandler.sanitize_url(obj.path);
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
      startRequestTime = new Date;
      request = http.request(options, function(response) {
        var responseBody;
        responseBody = "";
        response.on('data', function(chunk) {
          return responseBody += chunk;
        });
        return response.on('end', function() {
          _this.bronson.log({
            event: 'Backend request',
            status: response.statusCode,
            requestParams: options,
            startRequestTime: startRequestTime,
            endRequestTime: new Date
          });
          return obj.success({
            status: response.statusCode,
            body: responseBody
          });
        });
      });
      request.write(jsonString);
      return request.end();
    };

    return BackendHandler;

  })();

  module.exports = BackendHandler;

}).call(this);
