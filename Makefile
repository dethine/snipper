.PHONY: all
all: build/dethine.tools.Snipper.xrnx

clean: 
	rm -rf build/*

build/dethine.tools.Snipper.xrnx: main.lua manifest.xml
	mkdir -p build
	zip -r $@ main.lua manifest.xml -x "Makefile" "build/*" "*.git*" "*.github*" "*.vscode*" "*.env"
