.PHONY: echo build start-redis

PWD=$(shell pwd)
LC=$(node_modules/.bin/sibilant)

echo:
	@echo "PWD is " $(PWD)
	@echo "LC is " $(LC)

build:
	$(LC) squirter.lisp -o .

start-redis:
	 docker run -d -p 6379:6379 redis:alpine

