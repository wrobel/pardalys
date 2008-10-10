SHELL = /bin/sh
INSTALL = /usr/bin/install

INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_DIR = ${INSTALL} -m 755 -d

PACKAGE=pardalys

prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
sbindir = $(exec_prefix)/sbin
datarootdir = $(prefix)/share
datadir = $(datarootdir)
docdir = $(datarootdir)/doc/$(PACKAGE)
sysconfdir = $(prefix)/etc
dist_conf = modules/service_kolab/plugins/facter/dist_conf

.PHONY:
install:
	mkdir -p $(DESTDIR)$(sbindir)
	$(INSTALL_PROGRAM) bin/pardalys $(DESTDIR)$(sbindir)
	mkdir -p $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) bin/dev-pardalys $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) bin/kolab_ca $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(datadir)/$(PACKAGE)
	cp -r etc $(DESTDIR)$(datadir)/$(PACKAGE)
	cp -r modules $(DESTDIR)$(datadir)/$(PACKAGE)
	cp -r manifests $(DESTDIR)$(datadir)/$(PACKAGE)
	mkdir -p $(DESTDIR)$(datadir)/$(PACKAGE)/facter
	for FACT in modules/**/plugins/facter/*.rb; \
	do \
	  ln -s ../$$FACT $(DESTDIR)$(datadir)/$(PACKAGE)/facter; \
	done
	ln -s ../$(dist_conf) $(DESTDIR)$(datadir)/$(PACKAGE)/facter; \
	mkdir -p $(DESTDIR)$(docdir)
	$(INSTALL_DATA) INSTALL HACKING README CHANGES $(DESTDIR)$(docdir)
	mkdir -p $(DESTDIR)$(sysconfdir)/$(PACKAGE)
	$(INSTALL_DATA) etc/README $(DESTDIR)$(sysconfdir)/$(PACKAGE)

#FIXME: Add a basic bootstrap config file