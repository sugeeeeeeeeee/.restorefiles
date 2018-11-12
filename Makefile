NAME	   := DotfileInstaller
VERSION  := 1.0.0

.PHONY: install clean

install:
	/bin/bash ./setup.sh install

clean:
	/bin/bash ./setup.sh clean
