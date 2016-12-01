.PHONY: clean echo start-redis

PWD=$(shell pwd)
LC=node_modules/.bin/sibilant

clean:
	rm js/*.js src/*~

echo:
	@echo "PWD is " $(PWD)
	@echo "LC is " $(LC)

build: js/squirter.js js/lottie.js js/test-lottie.js

js/squirter.js: squirter.lisp
	$(LC) src/squirter.lisp -o js

js/lottie.js: lottie.lisp
	$(LC) src/lottie.lisp -o js

js/test-lottie.js: test-lottie.lisp
	$(LC) src/test-lottie.lisp -o js

test: js/test-lottie.js js/lottie.js
	mocha js/test-lottie.js

start-redis:
	 docker run -d -p 6379:6379 redis:alpine

