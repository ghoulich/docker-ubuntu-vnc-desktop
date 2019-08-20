.PHONY: build run

REG_URL ?= registry.cn-hangzhou.aliyuncs.com
REG_USERNAME ?= ubuntu
REG_PASSWORD ?= ubuntu
REPO_PREFIX ?= ubuntu
REPO  ?= $(REG_URL)/$(REPO_PREFIX)/ubuntu-desktop-lxqt-vnc
TAG   ?= latest
IMAGE ?= ubuntu:18.04
LOCALBUILD ?= 163
HTTP_PASSWORD ?= 123456
CUSTOM_USER ?= ubuntu
PASSWORD ?= ubuntu
FLAVOR ?= lxqt
ARCH ?= amd64
ZH_HANS ?= true
ANACONDA ?= true

templates = Dockerfile image/etc/supervisor/conf.d/supervisord.conf

build: $(templates)
	docker build -t $(REPO):$(TAG) .

run:
	docker run --rm \
		-p 6080:80 -p 6081:443 \
		-v ${PWD}:/src:ro \
		--name ubuntu-desktop-lxde-test \
		$(REPO):$(TAG)

shell:
	docker exec -it ubuntu-desktop-lxde-test bash

gen-ssl:
	mkdir -p ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout ssl/nginx.key -out ssl/nginx.crt

clean:
	rm -f $(templates)

upload:
	docker login --username=$(REG_USERNAME) --password=$(REG_PASSWORD) $(REG_URL)
	docker push $(REPO):$(TAG)
	docker logout $(REG_URL)
		
%: %.j2 flavors/$(FLAVOR).yml
	docker run -v $(shell pwd):/data vikingco/jinja2cli \
		-D flavor=$(FLAVOR) \
		-D image=$(IMAGE) \
		-D localbuild=$(LOCALBUILD) \
		-D arch=$(ARCH) \
		-D zh_hans=$(ZH_HANS) \
		-D anaconda=$(ANACONDA) \
		$< flavors/$(FLAVOR).yml > $@ || rm $@
