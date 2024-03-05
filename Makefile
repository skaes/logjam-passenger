.PHONY: clean

.DEFAULT: packages

clean:
	rm -f passenger.load
	docker ps -a | awk '/Exited/ {print $$1;}' | xargs docker rm
	docker images | awk '/none|fpm-(fry|dockery)/ {print $$3;}' | xargs docker rmi

VERSION:=$(shell awk '/package:/ {print $$2};' versions.yml)
PASSENGER_VERSION := $(shell awk '/passenger:/ {print $$2};' versions.yml)
RUBY_VERSION := $(shell awk '/ruby:/ {print $$2};' versions.yml)
RUBY_API_VERSION := $(shell awk '/ruby:/ {split($$2, a, "."); printf("%s.%s.0", a[1], a[2]);}' versions.yml)

PACKAGES:=package-focal package-jammy
.PHONY: packages $(PACKAGES)

ARCH := amd64

ifeq ($(ARCH),)
PLATFORM :=
LIBARCH :=
else
PLATFORM := --platform $(ARCH)
LIBARCH := $(ARCH:arm64=arm64v8)/
endif


passenger.load: passenger.load.in versions.yml
	sed -e "s/PASSENGER_VERSION/$(PASSENGER_VERSION)/g" -e "s/RUBY_VERSION/$(RUBY_VERSION)/g"  -e "s/RUBY_API_VERSION/$(RUBY_API_VERSION)/g" $< >$@

packages: $(PACKAGES)

define build-package
  RUBYOPT='-W0' bundle exec fpm-fry cook $(PLATFORM) --pull --update=always $(LIBARCH)ubuntu:$(1) recipe.rb
  mkdir -p packages/ubuntu/$(1) && mv *.deb packages/ubuntu/$(1)
endef

package-focal: passenger.load
	$(call build-package,focal)
package-jammy: passenger.load
	$(call build-package,jammy)

LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-focal publish-jammy
publish: publish-focal publish-jammy

PACKAGE_NAME:=logjam-passenger_$(VERSION)_$(ARCH).deb

define upload-package
@if ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) debian-package-exists $(1) $(2); then\
  echo package $(1)/$(2) already exists on the server;\
else\
  tmpdir=`ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) mktemp -d` &&\
  rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/$(1)/$(2) $(LOGJAM_PACKAGE_HOST):$$tmpdir &&\
  ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) add-new-debian-packages $(1) $$tmpdir;\
fi
endef

publish-focal:
	$(call upload-package,focal,$(PACKAGE_NAME))
publish-jammy:
	$(call upload-package,jammy,$(PACKAGE_NAME))

show-jammy:
	docker run --rm -it -v `pwd`/packages/ubuntu/jammy:/src ubuntu:jammy bash -c 'dpkg -I /src/logjam-passenger_$(VERSION)_$(ARCH).deb'
	docker run --rm -it -v `pwd`/packages/ubuntu/jammy:/src ubuntu:jammy bash -c 'dpkg -c /src/logjam-passenger_$(VERSION)_$(ARCH).deb'
