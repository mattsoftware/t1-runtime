ENABLE_TLS ?= 1
ENABLE_NET ?= 1

# Update when targeting new Node build.
NODE_VERSION ?= v0.10.32

CONFIG ?= Release

ifeq ($(ARM),1)
	compile = \
		AR=arm-none-eabi-ar AR_host=arm-none-eabi-ar AR_target=arm-none-eabi-ar CC=arm-none-eabi-gcc CXX=arm-none-eabi-g++ gyp $(1) --depth=. -f ninja-arm -D builtin_section=.rodata -D enable_ssl=$(ENABLE_TLS) -D enable_net=$(ENABLE_NET) &&\
		ninja -C out/$(CONFIG)
else
    compile = \
        gyp $(1) --depth=. -f ninja -D enable_ssl=$(ENABLE_TLS) -D enable_net=$(ENABLE_NET) -D compiler_path="$(shell pwd)/node_modules/colony-compiler/bin/colony-compiler.js" &&\
		ninja -C out/$(CONFIG)
endif

NODE_FILES = deps/node-libs/events.js deps/node-libs/domain.js

.PHONY: all test test-colony test-node

all: colony

clean:
	ninja -v -C out/Debug -t clean
	ninja -v -C out/Release -t clean

nuke:
	rm -rf out build

update:
	git submodule update --init --recursive
	cp $(NODE_FILES) src/colony/modules/
	npm install

test: test-node test-colony

test-colony:
	@echo "colony testbench:"
	@./node_modules/.bin/tap -e './tools/tap-colony.sh' test/suite/*.js test/colony/*.js  test/issues/*.js test/net/*.js

test-node:
	@echo "node testbench:"
	@./node_modules/.bin/tap -e node test/suite/*.js test/issues/*.js test/net/*.js

update-node-libs:
	$(eval ORIG_BRANCH := $(shell git rev-parse --abbrev-ref HEAD))
	git remote rm node || true
	git branch -D node_master || true
	git branch -D node_lib || true
	git remote add -t master node https://github.com/joyent/node.git
	git fetch node --tags
	git checkout $(NODE_VERSION)
	git subtree split --rejoin --prefix=lib -b node_lib
	git checkout -f $(ORIG_BRANCH)
	if [ -a deps/node-libs ]; then \
		git subtree merge --squash --prefix=deps/node-libs node_lib; \
	else \
		git subtree add --squash --prefix=deps/node-libs .git node_lib; \
	fi

# Targets

libcolony:
	$(call compile, libcolony.gyp)

colony:
	$(call compile, colony.gyp)

libtm-test:
	$(call compile, libtm-test.gyp)
	./out/Release/libtm-test

libtm:
	$(call compile, libtm.gyp)


# Compiler Targets

compile-axtls:
	gyp libtm.gyp --depth=. -f ninja -D enable_ssl=1 -R tm-ssl
	ninja -C out/$(CONFIG)
