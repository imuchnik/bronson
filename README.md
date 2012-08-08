# BRowser ONline SynchrONization [![Build Status](https://secure.travis-ci.org/Originate-Inc/bronson.png)](http://travis-ci.org/#!/Originate-Inc/bronson)

Bronson is a real-time, cross-platform instant messaging framework for web, hybrid, and native mobile and desktop applications, built on top of [Node.js](http://nodejs.org) and [Socket.IO](http://socket.io). 


## Functionality

Bronson shines in three areas: 

1. A wide array of [supported platforms](#supported-platforms)
2. Isolated communication channels ([rooms](#rooms))
3. Integration of existing [backend APIs](#backend-integration) into the broadcasting platform.


### Supported platforms

* __Desktop web browsers:__ IE 6+, FF 3+, Safari 3+, Chrome 4+, Opera 10+
* __Mobile browsers:__ iOS Safari, Android WebKit, [Android Chrome](https://play.google.com/store/apps/details?id=com.android.chrome)
* __Hybrid mobile applications:__ [PhoneGap](http://phonegap.com), [RhoMobile](http://www.motorola.com/Business/US-EN/Business+Product+and+Services/Software+and+Applications/RhoMobile+Suite), [Sencha](http://www.sencha.com), [Titanium Appcelerator](http://www.appcelerator.com)
* __Native mobile applications:__ iOS (via [socket.IO-objc](https://github.com/pkyeck/socket.IO-objc)), Android (via [java-socket.io.client](https://github.com/clwillingham/java-socket.io.client))


### Rooms
Clients can enter dedicated _chat rooms_ to talk to other clients in that room. 
The visibility of broadcast messages is restricted to the _room_ that the emitting client is in. Several rooms can be active at a time, allowing for parallel, isolated communication. 


### Backend integration
Besides the traditional broadcast of static payload directly to peers, Bronson's broadcast messages can include a dynamic backend portion. 
In this scenario, the Bronson platform performs the backend request first in the name of the emitting client, then includes the backend's response into the message broadcasted to all clients.

This is useful, for example, to notify participants in a room about new data objects that have to be created on the server first. 
Bronson allows to do both things (creating objects in the backend and notifying all other clients) using only one call from the emitting device, thereby saving bandwidth and battery life on it.

<table>
  <tr>
    <td width="60px">
      <b>Step 1</b>
    </td>
    <td>
      Clients load from the backend system and set up a persistent connection to the Bronson server.
    </td>
    <td>
      <img src="http://originate-inc.github.com/bronson/1.png">
    </td>
  </tr>
  <tr>
    <td>
      <b>Step 2</b>
    </td>
    <td>
      A client emits a broadcast message with a backend portion to the Bronson server.
    </td>
    <td>
      <img src="http://originate-inc.github.com/bronson/2.png">
    </td>
  </tr>
  <tr>
    <td>
      <b>Step 3</b>
    </td>
    <td>
      The Bronson server forwards the request, including all request headers and cookies, to the backend system.
    </td>
    <td>
      <img src="http://originate-inc.github.com/bronson/3.png">
    </td>
  </tr>
  <tr>
    <td>
      <b>Step 4</b>
    </td>
    <td>
      The backend system responds to the Bronson server. No traffic to the clients happens at this stage.
    </td>
    <td>
      <img src="http://originate-inc.github.com/bronson/4.png">
    </td>
  </tr>
  <tr>
    <td>
      <b>Step 5</b>
    </td>
    <td>
      The Bronson server broadcasts the original broadcast message, including the response from the backend, to all clients.
    </td>
    <td>
      <img src="http://originate-inc.github.com/bronson/5.png">
    </td>
  </tr>
</table>


## How to use

### Creating a Bronson server

Install the NPM module.

```bash
$ npm install bronson
```

Now, create a file called _server.coffee_, with this content:

```CoffeeScript
Bronson = require 'bronson'
bronson = new Bronson "api.my-backend-host.com"
bronson.listen 3000
```

You can start this server like so:

```bash
$ coffee server.coffee
```

### Chat server example.

More complete usage examples are given in the [/examples](https://github.com/Originate-Inc/bronson/tree/master/examples) directory.

The [chat](https://github.com/Originate-Inc/bronson/tree/master/examples/chat) directory contains a fully functional chat application.
The server portion, [chat.coffee](https://github.com/Originate-Inc/bronson/blob/master/examples/chat/chat.coffee), 
creates a web server that serves an HTML file as well as a Bronson server for real-time broadcasting in only 12 lines of CoffeeScript.
The client portion, [chat.html](https://github.com/Originate-Inc/bronson/blob/master/examples/chat/chat.html),
connects to the server, logs into a room, announces the user to the other participants, and provides facilities as well as UI for sending and receiving chat messages in only 10 lines of CoffeeScript.


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


## Authors

Bronson is developed by [Alex David](https://github.com/alexdavid) and [Kevin Goslar](https://github.com/kevgo) at [Originate Inc.](http://originate.com), and is in production use for a variety of internal and external projects.


