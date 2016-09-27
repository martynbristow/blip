prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
sharedir = $(prefix)/share
mandir = $(sharedir)/man
man3dir = $(mandir)/man3

all:
	true

install:
	mkdir -pv "$(DESTDIR)$(libdir)"
	mkdir -pv "$(DESTDIR)$(man3dir)"
	install -m 0644 blip.bash "$(DESTDIR)$(libdir)"
	install -m 0644 blip.3 "$(DESTDIR)$(man3dir)"
    
.PHONY: install
