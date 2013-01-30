(function() {
  var HttpRequest, URL;

  URL = require('url');

  HttpRequest = (function() {

    function HttpRequest(req, res) {
      var i, path, _i, _ref;
      this.req = req;
      this.res = res;
      this.req.url = URL.parse(this.req.url, true);
      this.headers = this.req.headers;
      this.path = [];
      path = this.req.url.pathname.split(/\//g);
      for (i = _i = 1, _ref = path.length - 1; _i <= _ref; i = _i += 1) {
        this.path.push(path[i]);
      }
    }

    HttpRequest.prototype.err = function(code) {
      this.res.writeHead(code, {
        'Content-Type': 'text/html'
      });
      this.res.write("<h1>Bronson - " + code + " Error</h1>");
      return this.res.end();
    };

    HttpRequest.prototype.notModified = function() {
      this.res.writeHead(304);
      return this.res.end();
    };

    HttpRequest.prototype.end = function(data, contentType, etag) {
      var byteLength, headers;
      if (contentType == null) {
        contentType = 'application/json';
      }
      if (etag == null) {
        etag = null;
      }
      if ((this.req.url.query.callback != null) && contentType === 'application/json') {
        data = "" + this.req.url.query.callback + "(" + data + ")";
        contentType = 'text/javascript';
      }
      byteLength = data instanceof Buffer ? data.length : Buffer.byteLength(data, 'utf8');
      headers = {
        'Content-Type': contentType,
        'Content-Length': byteLength
      };
      if (etag != null) {
        headers.Etag = etag;
      }
      this.res.writeHead(200, headers);
      this.res.write(data);
      return this.res.end();
    };

    HttpRequest.prototype.isBronsonNamespace = function() {
      return this.path[0] === 'bronson';
    };

    return HttpRequest;

  })();

  module.exports = HttpRequest;

}).call(this);
