DOCKER_RM = false

build: buildfs
	@docker build -t imega/redis .

buildfs:
	@docker run --rm=$(DOCKER_RM) \
		-v $(CURDIR)/runner:/runner \
		-v $(CURDIR)/build:/build \
		-v $(CURDIR)/src:/src \
		imega/base-builder \
		--packages="redis"

build/containers/container_data:
	@mkdir -p $(shell dirname $@)
	@docker run -d --name container_data imega/redis
	@touch $@

discovery_data: build/containers/container_data
	@while [ "`docker inspect -f {{.State.Running}} container_data`" != "true" ]; do \
		echo "wait db"; sleep 0.3; \
	done

get_containers:
	$(eval CONTAINERS := $(subst build/containers/,,$(shell find build/containers -type f)))

stop: get_containers
	@-docker stop $(CONTAINERS)

clean: stop
	@-docker rm -fv $(CONTAINERS)
	@-rm -rf build/containers/*

test: build discovery_data
	@docker run --rm=$(DOCKER_RM) \
		-v $(CURDIR)/tests:/data \
		-w /data \
		--link container_data:server \
		alpine \
		sh -c 'apk add --update bash && ./test.sh server'

.PHONY: build
