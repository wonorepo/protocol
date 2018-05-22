all: contracts

.PHONY: contracts

node_modules:
	$(MAKE) -C contracts node_modules

contracts:
	$(MAKE) -C contracts

install:
	$(MAKE) -C contracts install

clean:
	$(MAKE) -C contracts clean

distclean:
	$(MAKE) -C contracts distclean

