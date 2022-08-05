PROJECT = LaceworkOrganizationSync
DIR_NAME = organization-sync
FUNCTION = $(PROJECT)
DIST_DIR ?= "$(BASE)"/functions/dist/$(DIR_NAME)

all: build

.PHONY: clean build

clean:
	rm -rf build
	rm $(DIST_DIR)/$(FUNCTION).zip || true

build: clean
	mkdir -p build
	zip -r $(DIST_DIR)/$(FUNCTION).zip . -x "*.DS_Store*" "*.git*" "build*" "Makefile" "requirements.txt"
	pip3 install -r requirements.txt -t build
	cd build; zip -r $(DIST_DIR)/$(FUNCTION).zip . -x "*.DS_Store*" "*.git*" "build*" "Makefile"
	rm -rf build
