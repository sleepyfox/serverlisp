.PHONY: clean echo start-redis start-debug-BaaS start-BaaS start-squirter

PWD=$(shell pwd)
LC=node_modules/.bin/sibilant

clean:
	rm js/*.js src/*~

echo:
	@echo "PWD is " $(PWD)
	@echo "LC is " $(LC)

build: js/squirter.js js/lottie.js js/test-lottie.js js/BaaS.js

js/squirter.js: src/squirter.lisp
	$(LC) $< -o js

js/lottie.js: src/lottie.lisp
	$(LC) $< -o js

js/test-lottie.js: src/test-lottie.lisp
	$(LC) $< -o js

js/BaaS.js: src/BaaS.lisp
	$(LC) $< -o js

test: js/test-lottie.js js/lottie.js
	mocha js/test-lottie.js

start-redis:
	 docker run -d -p 6379:6379 redis:alpine

start-debug-BaaS:
	DEBUG=1 node js/BaaS.js

start-BaaS:
	node js/BaaS.js

start-squirter:
	node js/squirter.js



