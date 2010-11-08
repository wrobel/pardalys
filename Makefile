VERSION=0.0.7

pardalys-$(VERSION).tar.bz2:
	tar cvjf pardalys-$(VERSION).tar.bz2 pardalys --exclude=".git" --exclude=".svn" --exclude="config.yml"

.PHONY:dist
dist: pardalys-$(VERSION).tar.bz2

.PHONY:release
release: pardalys-$(VERSION).tar.bz2
	git tag -m "Release of pardalys-$(VERSION)" pardalys-$(VERSION)
	scp pardalys-$(VERSION).tar.bz2 www:~/de/pardus/files/downloads/

.PHONY:clean
clean:
	rm -rf *.tar.bz2
