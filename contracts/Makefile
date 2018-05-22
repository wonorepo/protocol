all: artifacts

.PHONY: artifacts

node_modules:
	npm install

artifacts:
	truffle compile --all

install:
	truffle migrate --reset

clean:
	rm -rf build

distclean:
	rm -rf build node_modules

