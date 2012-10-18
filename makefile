all:
	npm install
	
	@echo "Building server coffeescript"
	./node_modules/.bin/coffee -o lib/ -c src/
	
	@echo "Building client coffeescript"
	./node_modules/.bin/coffee -o client/lib/ -c client/src/
	echo "// Bronson v`npm view bronson version` | github.com/Originate-Inc/bronson" > client/bronson.js
	echo ";" >> client/bronson.js
	cat client/lib/* client/socket.io/socket.io.js >> client/bronson.js
	./node_modules/.bin/uglifyjs client/bronson.js > client/bronson.min.js
	
	@echo
	@echo "Done."
