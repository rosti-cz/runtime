DOCKER=docker
VERSION=2020.05-1

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
