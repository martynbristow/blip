prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
sharedir = $(prefix)/share
mandir = $(sharedir)/man
man1dir = $(mandir)/man1

all:
	true

install:
	install -m 0644 blip.bash $(DESTDIR)$(libdir)
	install -m 0644 blip.1 $(DESTDIR)$(man1dir)
    
.PHONY: install
