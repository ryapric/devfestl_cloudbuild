# Name of app
APPNAME := fredcast

# Need to adjust shell used, for `source` command
SHELL = /usr/bin/env bash

# Set venv activation, since make runs each recipe in its own shell instance
VENV-ACT = source venv/bin/activate

# More modular definitions for testing, to make it easier to write for Travis
# w/o a lot of copy-paste
# Note that I'm having a hard time getting `define` blocks to work, here, as
# well as .ONESHELL:
DEV-PKGS = pip3 install wheel && pip3 install setuptools coverage pytest pytest-cov pytest-flask
TEST = python3 -m pytest --cov $(APPNAME) . -v
COVCHECK = if [ $$(python3 -m coverage report | tail -1 | awk '{ print $$NF }' | tr -d '%') -lt $(COVREQ) ]; then echo -e "\nFAILED: Insufficient test coverage (<$(COVREQ)%)\n" 2>&1 && exit 1; fi

# Required test coverage; default to n% given here
ifeq ($(COVREQ),)
COVREQ := 0
endif


all: test

# Dummy FORCE target dep to make things always run
FORCE:

venv: FORCE
	@python3 -m venv --clear venv

dev-pkgs: venv
	@$(VENV-ACT) && \
	$(DEV-PKGS)

test: clean venv dev-pkgs install_venv
	@$(VENV-ACT) && \
	$(TEST) # don't chain from here, so failed tests throw shell error code
	@$(VENV-ACT) && \
	$(COVCHECK)
	@make -s clean
	@rm -rf venv

install_venv: venv
	@$(VENV-ACT); \
	if [ -e ./requirements.txt ]; then pip3 install -r requirements.txt; else pip3 install . ; fi

clean: FORCE
	@find . -type d -regextype posix-extended -regex ".*\.egg-info|.*py(test_)?cache.*" -exec rm -rf {} +
	@find . -type d -regextype posix-extended -regex ".*venv.*" -exec rm -rf {} +
	@find . -type f -regextype posix-extended -regex ".*\.pyc" -exec rm {} +
	@find . -type f -regextype posix-extended -regex ".*,?cover(age)?" -exec rm {} +
	@find . -name "test.db" -exec rm {} +


# Using local build tool, see how a Cloud Build would run
gcloud-build-local:
	@cloud-build-local --dryrun=false .

# Push up live-tests.sh to GS
gcloud-push-live-tests-script:
	@gsutil cp tests/cloudbuild-helpers/live-tests.sh gs://kv-store/live-tests.sh

# Add githooks to local config
add-git-hooks:
	@cp .githooks/* .git/hooks/
