.PHONY: all
all: build/dethine.tools.Snipper_snapshot.xrnx

clean: 
	rm -rf build/*

build/dethine.tools.Snipper_snapshot.xrnx: main.lua manifest.xml
	mkdir -p build
	./build.sh $@