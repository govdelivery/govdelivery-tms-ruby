## The GitLab Project Name
app_name?=xact
## The GitLab Group
app_group?=development
rpm_name ?= gd-$(app_name)
specfile ?= $(rpm_name).spec

revision?=$(shell git rev-parse HEAD)
commit_time?=$(shell git show -s --format=%ci $$(git rev-parse HEAD) | awk -F'[- :]' '{print $$1 $$2 $$3 "." $$4 $$5}')
archive_version?=$(shell git describe --tags HEAD | awk -F '-' '{print $$1 "." $$2}' | sed 's/\.$$//')
archive_name?=$(app_name)-$(archive_version)

# Extra Directories created by the build step that are not in Git but need to be in the rpm
extra_dirs=""

tag ?= $(shell git rev-parse --short HEAD)
build_tag ?= centos6-internal-xact
git_url = git+ssh://git@dev-scm.office.gdi/development/$(app_name).git?\#$(tag)
ENV ?= poc

.DEFAULT_GOAL	:= help
help:
	@echo "Usage: make <option>"
	@echo " Supported options are:"
	@echo " sources         - Build $(app_name) tarball $(tarball) as Koji would"
	@echo " test            - Show name and versions that'll be generated"
	@echo " local-rpm       - Build a local-rpm locally"
	@echo " scratch-rpm     - Build scratch rpm on koji (set ENV variable)"
	@echo " rpm             - Build rpm on koji (set ENV variable)"
	@echo " clean           - Clean up build root"

# Build the source tarball
.PHONY: sources

sources: bundle configure
	echo $(revision) > .revision
	echo $(commit_time) > .commit-time
	echo $(archive_version) > .version

	## need to touch this before starting the tar so the . directory isn't changed by the tar causing the tar to fail.
	touch $(archive_name).tar.gz
	tar --exclude-vcs --exclude=$(archive_name).tar.gz -czvf $(archive_name).tar.gz .

	sed -e 's/@version@/$(archive_version)/' \
		-e 's/@revision@/$(revision)/' \
		-e 's/@commit_time@/$(commit_time)/' \
		-e 's/@name@/$(app_name)/' \
		-e 's/@group@/$(app_group)/' \
		-e 's;@scm@;$(app_scm);' \
		gd-$(app_name).spec.in > gd-$(app_name).spec


configure:
	echo "Configuring Code Directory"
	## Current Directory
	pwd

	## from code-checkout.rb
	### evo uses this in the UI
	echo $(archive_version)-$(revision) > REVISION

	## from ruby-extact.rb
	### logs link
	rm -rf log
	ln -s /var/log/$(app_name)  log
	### DB Migrate writes to this...
	touch         db/schema.rb

	### ruby-extact.rb after_extract

	mkdir -p public
	ln -s "/opt/$(app_name)/shared/public/custom_reports"    "public/custom_reports"
	ln -s "/opt/$(app_name)/local/tmp"                       "tmp"

	ln -s "/etc/sysconfig/$(app_name)-database.yml"          "config/database.yml"
	ln -s "newrelic.yml.deploy"                              "config/newrelic.yml"

bundle:
	echo "Executing Bundle Install"
	### ruby-extact.rb bundle_install
	## need to use the rpm instantclient path because /opt/oracle is not setup without puppet
	## link against a specific version of the instaclient library 
	ln -s /opt/jruby/bin/jruby ./ruby
	PATH=/opt/jruby/bin:./:$$PATH LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib bundle install --gemfile Gemfile --path bundle --deployment --without development test  
	rm ./ruby

test:
	echo $(app_name)
	echo $(app_group)
	echo $(archive_version)
	echo $(archive_name)

.PHONY: local-rpm
local-rpm: sources
	@echo "Cleaning old buildroots and building the RPM locally"
	-rm -rf $(HOME)/rpmbuild/BUILDROOT/$(rpm_name)*
	-rm -rf $(HOME)/rpmbuild/BUILD/$(rpm_name)*
	cp *.tar.gz $(HOME)/rpmbuild/SOURCES/
	rpmbuild --nodeps -ba $(specfile)

.PHONY: git-refresh
git-refresh:
	@echo "Refreshing directory with checked-out versions of files containing credentials"
	git checkout $(specfile)

.PHONY: clean
clean: git-refresh
	@echo "Cleaning ${archive_name}"
	-@git checkout $(specfile)
	-@rm -rvf build
	-@rm -rvf ~/rpmbuild/SOURCES/$(rpm_name)-*.tar.gz

.PHONY: scratch-rpm rpm
scratch-rpm:
	@echo "Submitting job to koji in $(ENV) to build a scratch RPM."
	ssh -qt $(ENV)-koji-service1.ep.gdi sudo -u kojiadmin -i koji build $(build_tag) "$(git_url)" --scratch
rpm:
	@echo "Submitting job to koji in $(ENV) to build an RPM."
	ssh -qt $(ENV)-koji-service1.ep.gdi sudo -u kojiadmin -i koji build $(build_tag) "$(git_url)"
