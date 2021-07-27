BINARY=word-cloud-generator

# help extracts the help texts for the comments following ': ##'
.PHONY: help
help: ## Print this help message
	@awk -F':.*## ' ' \
		/^[[:alpha:]_-]+:.*## / { \
			printf "\033[36m%s\033[0m\t%s\n", $$1, $$2 \
		} \
	' $(MAKEFILE_LIST) | column -s$$'\t' -t

.PHONY: init
init: ## Run go mod tidy on your project to get all required dependencies
	go mod tidy

.PHONY: build
build: ## Build and install service
	env GOOS=linux GOARCH=amd64 go build -o ./artifacts/${BINARY} -v .

.PHONY: clean
clean: ## Cleaning up previous builds
	go clean
	rm -rf ./artifacts/*

.PHONY: lint
lint: ## Lint all the files and fail if any would be changed by gofmt
	{ [ `gofmt -l -e . | wc -l` -gt 0 ] && gofmt -l -e . && exit 1; } || echo "no lint errors"

.PHONY: unittest
unittest: ## Run all the unit tests
	go test -mod=vendor -count=1 -vet=off -timeout 20m -failfast $$(go list ./... | grep -v 'jenkins_home')