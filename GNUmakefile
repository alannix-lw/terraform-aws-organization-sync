default: ci

BASE = $(shell /bin/pwd)

TOPTARGETS := all clean package build

SUBDIRS := $(wildcard functions/src/*/.)
ZIP_SUBDIRS := $(wildcard functions/dist/*/.)

$(TOPTARGETS): $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS) $(ARGS) BASE="${BASE}"

ci:
	scripts/ci_tests.sh

release: ci
	scripts/release.sh prepare

.PHONY: $(TOPTARGETS) $(SUBDIRS)
