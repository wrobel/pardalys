VERSION=0.0.6

pardalys-$(VERSION).tar.bz2:
	tar cvjf pardalys-$(VERSION).tar.bz2 pardalys --exclude=".git" --exclude=".svn" --exclude="config.yml"

.PHONY:dist
dist: pardalys-$(VERSION).tar.bz2

.PHONY:release
release: pardalys-$(VERSION).tar.bz2
	svn copy https://pardalys.svn.sourceforge.net/svnroot/pardalys/trunk https://pardalys.svn.sourceforge.net/svnroot/pardalys/tags/pardalys-$(VERSION) -m "Release of pardalys-$(VERSION)"
	git tag -m "Release of pardalys-$(VERSION)" pardalys-$(VERSION)
	scp pardalys-$(VERSION).tar.bz2 www:~/de/pardus/files/downloads/
	rsync -auP pardalys-$(VERSION).tar.bz2 luciferc@frs.sourceforge.net:uploads/
	cp pardalys-$(VERSION).tar.bz2 /usr/portage/distfiles/

.PHONY:clean
clean:
	rm -rf *.tar.bz2
