# BRowser ONline SynchrONization [![Build Status](https://secure.travis-ci.org/Originate-Inc/bronson.png)](http://travis-ci.org/#!/Originate-Inc/bronson)

Bronson is a NodeJS framework built on top [Socket.IO](http://socket.io) that provides two primary functions:
* It allows clients to join rooms where they can broadcast messages to all other clients in the room.
* It allows clients to make ajax style requests to a backend server and have the response be pushed to all connected clients in the room.

Bronson is developed by [Alex David](https://github.com/alexdavid) and [Kevin Goslar](https://github.com/kevgo) at [Originate Inc.](http://originate.com), and is in production use for a variety of internal and external projects.


## Installation

```bash
$ npm install bronson
```

## Usage

```CoffeeScript
Bronson = require 'bronson'
bronson = new Bronson "backend.host.name"
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
