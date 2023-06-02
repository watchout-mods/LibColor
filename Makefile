LUA=lua5.1

all: test docs

clean: 
	rm -R docs

install-dependencies:
	sudo luarocks install busted

test:
	busted --exclude-tags=ignore

test-only:
	busted -t only

docs: LibColor.lua
	luadoc -d docs LibColor.lua

docs: LibColor.lua .ldoc/config.ld .ldoc/ldoc.css .ldoc/ldoc.ltp
	ldoc --format=markdown --config=.ldoc/config.ld -d docs LibColor.lua

