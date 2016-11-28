.PHONY: echo deploy

PWD=$(shell pwd)
SLS=$(PWD)/node_modules/.bin/serverless

echo:
	@echo "PWD is " $(PWD)

deploy:
	cd lottie && $(SLS) deploy 
