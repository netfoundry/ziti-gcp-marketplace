ZITI_VERSION ?= 0.9.0-44
TAG ?= 0.9
REGISTRY ?= gcr.io/netfoundry-marketplace-dev

MARKETPLACE_TOOLS_TAG := 0.9.10

$(info "---- REGISTRY = $(REGISTRY)")
$(info "---- TAG = $(TAG)")

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/ziti-tunnel/deployer:$(TAG)
TESTER_IMAGE ?= $(REGISTRY)/ziti-tunnel/tester:$(TAG)
IMAGE_ZITI_TUNNEL ?= $(REGISTRY)/ziti-tunnel:$(TAG)
IMAGE_ZITI_TEST_CONTROLLER ?= $(REGISTRY)/ziti-tunnel/test-controller:$(TAG)
IMAGE_ZITI_ENROLLER ?= $(REGISTRY)/ziti-tunnel/enroller:$(TAG)

app/build:: .build/ziti-tunnel/deployer \
            .build/ziti-tunnel/ziti-tunnel \
            .build/ziti-tunnel/enroller \
            .build/ziti-tunnel/test-controller \
            .build/ziti-tunnel/tester


.build/ziti-tunnel: | .build
	mkdir -p "$@"


.build/ziti-tunnel/deployer: deployer/* \
                       manifest/* \
                       schema.yaml \
                       $(shell find apptest/deployer -type f) \
                       | .build/ziti-tunnel
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/ziti-tunnel" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/ziti-tunnel/ziti-tunnel: | .build/ziti-tunnel
	docker pull docker.io/netfoundry/ziti-tunnel:$(ZITI_VERSION)
	docker tag docker.io/netfoundry/ziti-tunnel:$(ZITI_VERSION) "$(IMAGE_ZITI_TUNNEL)"
	docker push "$(IMAGE_ZITI_TUNNEL)"
	@touch "$@"


.build/ziti-tunnel/enroller: $(shell find images/enroller -type f) \
                             | .build/ziti-tunnel
	docker build \
	    --build-arg IMAGE_ZITI_TUNNEL=$(IMAGE_ZITI_TUNNEL) \
	    --build-arg ZITI_VERSION=$(ZITI_VERSION) \
	    --tag $(IMAGE_ZITI_ENROLLER) \
	    images/enroller
	docker push "$(IMAGE_ZITI_ENROLLER)"
	@touch "$@"


.build/ziti-tunnel/test-controller: $(shell find images/test-controller -type f) \
                             | .build/ziti-tunnel
	docker build \
	    --build-arg ZITI_VERSION=$(ZITI_VERSION) \
	    --tag $(IMAGE_ZITI_TEST_CONTROLLER) \
	    images/test-controller
	docker push "$(IMAGE_ZITI_TEST_CONTROLLER)"
	@touch "$@"


.build/ziti-tunnel/tester: $(shell find apptest -type f) \
                          | .build/ziti-tunnel
	$(call print_target,$@)
	docker build \
	    --build-arg ZITI_VERSION=$(ZITI_VERSION) \
	    --tag "$(TESTER_IMAGE)" \
	    apptest/tester
	docker push "$(TESTER_IMAGE)"
	@touch "$@"