PACKAGE = iana-etc
ORG = amylum

RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

PROTOCOL_URL = https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xml
PORT_URL = https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xml

PACKAGE_VERSION = $$(grep -m1 '<updated>' $(RELEASE_DIR)/usr/share/iana-etc/port-numbers.iana | sed 's/[^0-9]//g')
PATCH_VERSION = $$(cat version)
VERSION = $(PACKAGE_VERSION)-$(PATCH_VERSION)

.PHONY : default submodule deps manual container deps build version push local

default: submodule container

manual:
	./meta/launch /bin/bash || true

container:
	./meta/launch

build:
	rm -rf $(RELEASE_DIR)
	mkdir -p $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE) $(RELEASE_DIR)/usr/share/$(PACKAGE) $(RELEASE_DIR)/etc
	curl -sLo $(RELEASE_DIR)/usr/share/$(PACKAGE)/protocol-numbers.iana $(PROTOCOL_URL)
	curl -sLo $(RELEASE_DIR)/usr/share/$(PACKAGE)/port-numbers.iana $(PORT_URL)
	gawk -f protocols.awk $(RELEASE_DIR)/usr/share/$(PACKAGE)/protocol-numbers.iana > $(RELEASE_DIR)/etc/protocols
	gawk -f ports.awk $(RELEASE_DIR)/usr/share/$(PACKAGE)/port-numbers.iana > $(RELEASE_DIR)/etc/services
	cp PACKAGE_LICENSE $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)/LICENSE
	cd $(RELEASE_DIR) && tar -czvf $(RELEASE_FILE) *

version:
	@echo $$(($(PATCH_VERSION) + 1)) > version

push: version
	git commit -am "$(VERSION)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$(VERSION)"
	git push --tags origin master
	@sleep 3
	targit -a .github -c -f $(ORG)/$(PACKAGE) $(VERSION) $(RELEASE_FILE)
	@sha512sum $(RELEASE_FILE) | cut -d' ' -f1

local: build push

