.PHONY: test cover 

NAME ?= template
BIN_DIR ?= $(HOME)/bin
GITHUB_TOKEN ?= "SET_ME"
USER ?= $(USER)
NAMESPACE ?= "example-ns"
DATE ?= $(shell date -u --iso-8601=seconds)
COMMIT ?= $(shell git log -1 --pretty=format:"%h")

# TODO bump this port up - to be able to run multiple executors on devs machine
run-executor: 
	EXECUTOR_PORT=8084 go run cmd/executor/main.go

run-mongo-dev: 
	docker run -p 27017:27017 mongo


build: 
	go build -o $(BIN_DIR)/$(NAME)-executor cmd/executor/main.go

docker-build-executor: 
	docker build -t $(NAME)-executor -f build/executor/Dockerfile .

install-swagger-codegen-mac: 
	brew install swagger-codegen

test: 
	go test ./... -cover

test-e2e:
	go test --tags=e2e -v ./test/e2e

cover: 
	@go test -failfast -count=1 -v -tags test  -coverprofile=./testCoverage.txt ./... && go tool cover -html=./testCoverage.txt -o testCoverage.html && rm ./testCoverage.txt 
	open testCoverage.html

version-bump: version-bump-patch

version-bump-patch:
	go run cmd/tools/main.go bump -k patch

version-bump-minor:
	go run cmd/tools/main.go bump -k minor

version-bump-major:
	go run cmd/tools/main.go bump -k major

version-bump-dev:
	go run cmd/tools/main.go bump --dev

build-agent:
	docker build -f postman-agent/Dockerfile . -t kubetest/postman-agent