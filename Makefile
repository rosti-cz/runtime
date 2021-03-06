DOCKER=docker
VERSION=2021.04-2

all: build

build:
	$(DOCKER) pull debian:buster
	$(DOCKER) build -t rosti/runtime:dev .

test:
	DOCKER=$(DOCKER) ./tests.sh

squashed:
	$(DOCKER) pull debian:buster
	$(DOCKER) build --squash -t rosti/runtime:dev-squashed .

push: squashed
	$(DOCKER) tag rosti/runtime:dev-squashed rosti/runtime:$(VERSION)
	$(DOCKER) push rosti/runtime:$(VERSION) 
