.PHONY: echo deploy start-redis

PWD=$(shell pwd)
SLS=$(PWD)/node_modules/.bin/serverless

echo:
	@echo "PWD is " $(PWD)

deploy:
	cd lottie && $(SLS) deploy 

start-redis:
	 docker run -d -p 6379:6379 redis:alpine

