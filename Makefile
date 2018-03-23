#
# Make sure you set PROXY_ARGS in your environment to:
#
#     user:password@host:port
#
# This won't work with CNTLM (localhost:3128), you must specify corporate proxy credentials. 
#
#
PROXY_ARGS = --build-arg http_proxy=http://$(PROXYSPEC) --build-arg https_proxy=https://$(PROXYSPEC)
IMAGE_NAME = gradle-springboot-rhel7

.PHONY: build
build:
	@sudo docker build $(PROXY_ARGS) -t $(IMAGE_NAME) .

.PHONY: test
test:
	@sudo docker build $(PROXY_ARGS) -t $(IMAGE_NAME)-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-candidate bash -x test/run
