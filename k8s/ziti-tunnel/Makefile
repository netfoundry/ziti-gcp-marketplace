#TAG = 0.5.8-2554# for MOP compatibility
TAG ?= 0.9.0-44
REGISTRY ?= gcr.io/netfoundry-marketplace-dev

MARKETPLACE_TOOLS_TAG := 0.9.10

$(info ---- REGISTRY = $(REGISTRY))
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/ziti-tunnel/deployer:$(TAG)
NAME ?= ziti-tunnel-1

ifdef IMAGE_ZITI_TUNNEL
  IMAGE_ZITI_TUNNEL_FIELD = , "IMAGE_ZITI_TUNNEL": "$(IMAGE_ZITI_TUNNEL)"
endif

#ifdef ZITI_TUNNEL_PARAMETER1
#  ZITI_TUNNEL_PARAMETER1_FIELD = , "ZITI_TUNNEL_PARAMETER1": "$(ZITI_TUNNEL_PARAMETER1)"
#endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_ZITI_TUNNEL_FIELD) \
  $(ZITI_TUNNEL_PARAMETER1_FIELD) \
}


TESTER_IMAGE ?= $(REGISTRY)/ziti-tunnel/tester:$(TAG)


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
	docker pull docker.io/netfoundry/ziti-tunnel:$(TAG)
	docker tag docker.io/netfoundry/ziti-tunnel:$(TAG) "$(REGISTRY)/ziti-tunnel:$(TAG)"
	docker push "$(REGISTRY)/ziti-tunnel:$(TAG)"
	@touch "$@"


.build/ziti-tunnel/enroller: $(shell find images/enroller -type f) \
                             | .build/ziti-tunnel
	docker build \
	    --build-arg IMAGE_ZITI_TUNNEL=$(IMAGE_ZITI_TUNNEL) \
	    --build-arg ZITI_VERSION=$(TAG) \
	    --tag $(IMAGE_ZITI_ENROLLER) \
	    images/enroller
	docker push "$(IMAGE_ZITI_ENROLLER)"
	@touch "$@"


.build/ziti-tunnel/test-controller: $(shell find images/test-controller -type f) \
                             | .build/ziti-tunnel
	docker build \
	    --build-arg ZITI_VERSION=$(TAG) \
	    --tag $(IMAGE_ZITI_TEST_CONTROLLER) \
	    images/test-controller
	docker push "$(IMAGE_ZITI_TEST_CONTROLLER)"
	@touch "$@"


.build/ziti-tunnel/tester: $(shell find apptest -type f) \
                          | .build/ziti-tunnel
	$(call print_target,$@)
	docker build \
	    --build-arg ZITI_VERSION=$(TAG) \
	    --tag "$(TESTER_IMAGE)" \
	    apptest/tester
	docker push "$(TESTER_IMAGE)"
	@touch "$@"