A simple chat server that uses Bronson.

The server portion, chat.coffee, contains a web server that serves an HTML file as well as a Bronson server for real-time broadcasting.
The client portion, chat.html, connects to the server, logs into a room, announces the user to the other participants, and provides a simple UI for chat.

To start the server: coffee chat.coffee
Open http://localhost:3000 in several browser windows to chat.

