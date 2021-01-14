#
# Copyright (c) 2020 Gearbox Software, Inc. All rights reserved.
#
HOSTNAME?=$(shell hostname)
USERNAME?=spark-techtests

AWS_ACCOUNT_ID=<YOUR_ACCOUNT_ID>
REGISTRY?=$(AWS_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com

APPLICATION?=devops-bloodwing
REPO?=$(APPLICATION)
DOCKERFILE?=Dockerfile
CONTEXT?=.
DOCKER_IMAGE_NAME?=$(shell cat .docker-image-name 2> /dev/null)

# retrieve docker tag from env var first
ifneq ($(DOCKER_TAG),)
  TAG?=$(DOCKER_TAG)
else
  TAG:=MANUAL-$(shell date +%Y%m%d%H%M)
endif
BUILD_IMAGE?=$(USERNAME)/$(REPO):$(TAG)
BUILD_LATEST_IMAGE?=$(USERNAME)/$(REPO):latest
BUILDER_TAG:=$(TAG)-BUILDER
BUILDER_IMAGE:=$(USERNAME)/$(REPO):$(BUILDER_TAG)
REMOTE_TAG?=$(REGISTRY)/$(BUILD_IMAGE)
REMOTE_LATEST_TAG?=$(REGISTRY)/$(BUILD_LATEST_IMAGE)

GOOS?=linux
GOARCH?=amd64

all:
	@echo Targets
	@echo
	@echo "build       - build Devops Bloodwing"
	@echo "run         - run Devops Bloodwing and its dependencies"
	@echo "push        - push Devops Bloodwing"
	@echo "clean       - clean dangling docker images"
	@echo

build:
	docker image build \
		$(BUILD_OPTIONS) \
	   -f $(DOCKERFILE) --pull -t $(BUILD_IMAGE) -t $(BUILD_LATEST_IMAGE) $(CONTEXT)

push: build
	docker image tag $(BUILD_LATEST_IMAGE) $(REMOTE_LATEST_TAG)
	docker image push $(REMOTE_LATEST_TAG)
        @echo  $(REMOTE_TAG) > .docker-image-name

run: build
	$(info Running with image $(BUILDER_IMAGE))
	$(eval DOCKER_COMPOSE_CMD:=TAG=$(TAG) COMPOSE_PROJECT_NAME=$(APPLICATION) docker-compose -f docker-compose.yml )

	$(DOCKER_COMPOSE_CMD) up

#docker compose files should be the only thing creating containers and networks so lets clean em up.
clean:
	-for f in $(wildcard docker-compose*.yml); do \
	    echo Cleaning up resources from $${f};   \
	    docker-compose -f $${f} down --remove-orphans -v;            \
	done

.PHONY: help

help:
	@echo "Target Description" | awk '{printf "%-30s\033[0m %s\n", $$1, $$2}'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
