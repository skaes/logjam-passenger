.PHONY: clean

.DEFAULT: packages

clean:
	docker ps -a | awk '/Exited/ {print $$1;}' | xargs docker rm
	docker images | awk '/none|fpm-(fry|dockery)/ {print $$3;}' | xargs docker rmi

PACKAGES:=package-bionic package-xenial
.PHONY: packages $(PACKAGES)

packages: $(PACKAGES)

package-bionic:
	bundle exec fpm-fry cook --update=always ubuntu:bionic build_passenger.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-xenial:
	bundle exec fpm-fry cook --update=always ubuntu:xenial build_passenger.rb
	mkdir -p packages/ubuntu/xenial && mv *.deb packages/ubuntu/xenial

LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-bionic publish-xenial
publish: publish-bionic publish-xenial

publish-bionic:
	rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/bionic/* $(LOGJAM_PACKAGE_HOST):/var/www/packages/ubuntu/bionic/
	ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) 'cd /var/www/packages/ubuntu/bionic && f=`tempfile` && (dpkg-scanpackages . /dev/null | gzip >$$f.gz) && mv $$f.gz Packages.gz'

publish-xenial:
	rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/xenial/* $(LOGJAM_PACKAGE_HOST):/var/www/packages/ubuntu/xenial/
	ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) 'cd /var/www/packages/ubuntu/xenial && f=`tempfile` && (dpkg-scanpackages . /dev/null | gzip >$$f.gz) && mv $$f.gz Packages.gz'
