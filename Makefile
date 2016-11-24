.PHONY: credentials deploy

credentials:
	source credentials.sh

deploy:
	serverless deploy
