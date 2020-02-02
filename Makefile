DOCKER=docker
VERSION=2020.01-beta-1

all: build

build:
	$(DOCKER) build -t rosti/runtime:dev .

test: build
	DOCKER=$(DOCKER) ./tests.sh

squashed:
	$(DOCKER) build --squash -t rosti/runtime:dev-squashed .

push: squashed
	$(DOCKER) tag rosti/runtime:dev-squashed rosti/runtime:$(VERSION)
	$(DOCKER) push rosti/runtime:$(VERSION)
