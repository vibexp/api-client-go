.PHONY: generate build vet check tidy

# Regenerate the client from the backend spec (see scripts/generate.sh).
generate:
	./scripts/generate.sh

build:
	go build ./...

vet:
	go vet ./...

tidy:
	go mod tidy

# The generation gate: regenerate, then make sure it compiles and vets.
check: generate build vet
