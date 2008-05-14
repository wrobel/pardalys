VERSION=0.0.1

pardalys-$(VERSION).tar.bz2:
	tar cvjf pardalys-$(VERSION).tar.bz2 pardalys --exclude=".git" --exclude=".svn"

.PHONY:dist
dist: pardalys-$(VERSION).tar.bz2

.PHONY:release
release: pardalys-$(VERSION).tar.bz2
	svn copy https://pardalys.svn.sourceforge.net/svnroot/pardalys/trunk https://pardalys.svn.sourceforge.net/svnroot/pardalys/tags/pardalys-$(VERSION)
	git tag pardalys-$(VERSION)
	scp dist/pardalys-$(VERSION).tar.bz2 www:~/de/pardus/files/downloads/
	lftp -f upload-release
