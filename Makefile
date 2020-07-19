.PHONY: clean

.DEFAULT: packages

clean:
	rm -f passenger.load
	docker ps -a | awk '/Exited/ {print $$1;}' | xargs docker rm
	docker images | awk '/none|fpm-(fry|dockery)/ {print $$3;}' | xargs docker rmi

VERSION:=$(shell awk '/package:/ {print $$2};' versions.yml)
PASSENGER_VERSION := $(shell awk '/passenger:/ {print $$2};' versions.yml)

PACKAGES:=package-focal package-bionic package-xenial
.PHONY: packages $(PACKAGES)

passenger.load: passenger.load.in versions.yml
	sed -e "s/PASSENGER_VERSION/$(PASSENGER_VERSION)/g" $< >$@

packages: $(PACKAGES)

package-focal: passenger.load
	bundle exec fpm-fry cook --update=always ubuntu:focal build_passenger.rb
	mkdir -p packages/ubuntu/focal && mv *.deb packages/ubuntu/focal
package-bionic: passenger.load
	bundle exec fpm-fry cook --update=always ubuntu:bionic build_passenger.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-xenial: passenger.load
	bundle exec fpm-fry cook --update=always ubuntu:xenial build_passenger.rb
	mkdir -p packages/ubuntu/xenial && mv *.deb packages/ubuntu/xenial

LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-focal publish-bionic publish-xenial
publish: publish-focal publish-bionic publish-xenial

PACKAGE_NAME:=logjam-passenger_$(VERSION)_amd64.deb

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

publish-bionic:
	$(call upload-package,bionic,$(PACKAGE_NAME))

publish-xenial:
	$(call upload-package,xenial,$(PACKAGE_NAME))
