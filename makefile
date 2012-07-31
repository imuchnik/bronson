all:
	@PATH=./node_modules/.bin/

	@echo "Building server coffeescript"
	coffee -o lib/ -c src/

	@echo "Building client coffeescript"
	coffee -o client/lib/ -c client/src/
	cat client/src/* client/socket.io/socket.io.js > client/bronson.js
	uglifyjs client/bronson.js > client/bronson.min.js

	@echo
	@echo "Done."
