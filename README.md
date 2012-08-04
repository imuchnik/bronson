# BRowser ONline SynchrONization [![Build Status](https://secure.travis-ci.org/Originate-Inc/bronson.png)](http://travis-ci.org/#!/Originate-Inc/bronson)

Bronson is a cross-platform real-time messaging framework for a variety of client platforms, including web browsers, native as well as HTML5 on mobile and desktop platforms. 
It is based on Node.js and the popular [Socket.IO](http://socket.io) platform, and provides a way to broadcast arbitrary messages with data payloads to clients in a "chat room".

Bronson is developed by [Alex David](https://github.com/alexdavid) and [Kevin Goslar](https://github.com/kevgo) at [Originate Inc.](http://originate.com), and is in production use for a variety of internal and external projects.


## Installation

```bash
$ npm install bronson
```

## Usage

```CoffeeScript
Bronson = require '../..'
bronson = new Bronson null
bronson.listen app
```

Usage examples are given in the `examples` directory.


## Development

Fork away and send us a pull request!


### Run the unit tests
```bash
$ npm test
```

You can alternatively run tests automatically with guard:

```bash
$ guard
```
